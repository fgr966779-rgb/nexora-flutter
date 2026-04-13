import 'dart:convert';

import 'package:nexora/core/constants/app_enums.dart';
import 'package:nexora/data/models/goal_model.dart';

/// Репозиторій цілей накопичення (in-memory).
///
/// Забезпечує CRUD, фільтрацію за статусом/типом, сортування,
/// управління підцілями та мікро-цілями, заморожування,
/// аналітику, мотиваційні повідомлення, експорт/імпорт у JSON,
/// пакетні операції, архівування, пагінацію та розширену статистику.
///
/// Всі рядки-повідомлення українською.
class GoalRepository {
  final List<Goal> _goals = [];

  // ─── Базові CRUD ───────────────────────────────────────────────────

  /// Повертає активну ціль (першу з активних), або null.
  Goal? getActiveGoal() {
    for (final goal in _goals) {
      if (goal.status == GoalStatus.active) return goal;
    }
    return null;
  }

  /// Повертає всі активні цілі.
  List<Goal> getActiveGoals() {
    return _goals
        .where((g) => g.status == GoalStatus.active)
        .toList();
  }

  /// Повертає всі завершені цілі (найновіші перші).
  List<Goal> getCompletedGoals() {
    return _goals
        .where((g) => g.status == GoalStatus.completed)
        .toList()
      ..sort((a, b) {
        final aDate = a.completedAt ?? a.createdAt;
        final bDate = b.completedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
  }

  /// Повертає всі скасовані цілі.
  List<Goal> getAbandonedGoals() {
    return _goals
        .where((g) => g.status == GoalStatus.abandoned)
        .toList();
  }

  /// Повертає всі заархівовані цілі.
  List<Goal> getArchivedGoals() {
    return _goals
        .where((g) => g.status == GoalStatus.archived)
        .toList();
  }

  /// Повертає всі цілі (незмінний список).
  List<Goal> getAllGoals() {
    return List.unmodifiable(_goals);
  }

  /// Повертає всі цілі (синонім getAllGoals).
  List<Goal> getAll() => getAllGoals();

  /// Зберігає ціль. Якщо ID існує — оновлює, інакше створює з підцілями.
  Goal save(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = goal;
    } else {
      final goalWithSubs = goal.copyWith(
        subGoals: goal.subGoals.isEmpty
            ? _getDefaultSubGoals(goal)
            : goal.subGoals,
      );
      _goals.add(goalWithSubs);
      return goalWithSubs;
    }
    return goal;
  }

  /// Зберігає ціль без генерації підцілей (для імпорту).
  void saveSilent(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = goal;
    } else {
      _goals.add(goal);
    }
  }

  /// Оновлює існуючу ціль.
  void updateGoal(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = goal;
    }
  }

  /// Видаляє ціль за ID. Повертає true якщо видалено.
  bool deleteGoal(String id) {
    final initialLength = _goals.length;
    _goals.removeWhere((g) => g.id == id);
    return _goals.length < initialLength;
  }

  /// Видаляє ціль за ID (синонім deleteGoal).
  bool delete(String id) => deleteGoal(id);

  /// Знаходить ціль за ID.
  Goal? getById(String id) {
    for (final goal in _goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  /// Чи існує ціль з таким ID.
  bool exists(String id) {
    return _goals.any((g) => g.id == id);
  }

  /// Кількість цілей.
  int get count => _goals.length;

  /// Кількість активних цілей.
  int get activeCount =>
      _goals.where((g) => g.status == GoalStatus.active).length;

  /// Кількість завершених цілей.
  int get completedCount =>
      _goals.where((g) => g.status == GoalStatus.completed).length;

  /// Кількість скасованих цілей.
  int get abandonedCount =>
      _goals.where((g) => g.status == GoalStatus.abandoned).length;

  /// Кількість заархівованих цілей.
  int get archivedCount =>
      _goals.where((g) => g.status == GoalStatus.archived).length;

  /// Чи репозиторій порожній.
  bool get isEmpty => _goals.isEmpty;

  /// Очищає всі цілі.
  void clearAll() {
    _goals.clear();
  }

  // ─── Підцілі ───────────────────────────────────────────────────────

  /// Додає підціль до вказаної цілі.
  bool addSubGoal(String goalId, SubGoal subGoal) {
    final goal = getById(goalId);
    if (goal == null) return false;
    goal.addSubGoal(subGoal);
    updateGoal(goal);
    return true;
  }

  /// Видаляє підціль з вказаної цілі.
  bool removeSubGoal(String goalId, String subGoalId) {
    final goal = getById(goalId);
    if (goal == null) return false;
    goal.removeSubGoal(subGoalId);
    updateGoal(goal);
    return true;
  }

  /// Оновлює підціль.
  bool updateSubGoal(
    String goalId,
    String subGoalId, {
    String? name,
    double? targetAmount,
    double? currentAmount,
  }) {
    final goal = getById(goalId);
    if (goal == null) return false;
    goal.updateSubGoal(
      subGoalId,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
    );
    updateGoal(goal);
    return true;
  }

  /// Повертає підцілі для вказаної цілі.
  List<SubGoal> getSubGoals(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return [];
    return List.unmodifiable(goal.subGoals);
  }

  /// Повертає кількість завершених підцілей.
  int getCompletedSubGoalsCount(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return 0;
    return goal.subGoals.where((sg) => sg.isCompleted).length;
  }

  /// Повертає загальну кількість підцілей для цілі.
  int getSubGoalsCount(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return 0;
    return goal.subGoals.length;
  }

  // ─── Мікро-цілі ────────────────────────────────────────────────────

  /// Додає мікро-ціль до цілі.
  bool addMicroGoal(String goalId, MicroGoal microGoal) {
    final goal = getById(goalId);
    if (goal == null) return false;
    goal.addMicroGoal(microGoal);
    updateGoal(goal);
    return true;
  }

  /// Видаляє мікро-ціль.
  bool removeMicroGoal(String goalId, String microGoalId) {
    final goal = getById(goalId);
    if (goal == null) return false;
    goal.removeMicroGoal(microGoalId);
    updateGoal(goal);
    return true;
  }

  /// Виконує мікро-ціль. Повертає true якщо щойно виконано.
  bool completeMicroGoal(String goalId, String microGoalId) {
    final goal = getById(goalId);
    if (goal == null) return false;
    final result = goal.completeMicroGoal(microGoalId);
    if (result) updateGoal(goal);
    return result;
  }

  /// Повертає мікро-цілі для цілі.
  List<MicroGoal> getMicroGoals(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return [];
    return List.unmodifiable(goal.microGoals);
  }

  // ─── Статус цілей ──────────────────────────────────────────────────

  /// Змінює статус цілі на завершений.
  bool markAsCompleted(String id) {
    final goal = getById(id);
    if (goal == null) return false;
    final updated = goal.copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
    );
    updateGoal(updated);
    return true;
  }

  /// Змінює статус цілі на скасований.
  bool markAsAbandoned(String id) {
    final goal = getById(id);
    if (goal == null) return false;
    final updated = goal.copyWith(status: GoalStatus.abandoned);
    updateGoal(updated);
    return true;
  }

  /// Реактивує скасовану ціль.
  bool reactivateGoal(String id) {
    final goal = getById(id);
    if (goal == null) return false;
    if (goal.status != GoalStatus.abandoned) return false;
    final updated = goal.copyWith(status: GoalStatus.active);
    updateGoal(updated);
    return true;
  }

  /// Архівує завершену або скасовану ціль.
  bool archiveGoal(String id) {
    final goal = getById(id);
    if (goal == null) return false;
    if (goal.status == GoalStatus.active) return false;
    final updated = goal.copyWith(status: GoalStatus.archived);
    updateGoal(updated);
    return true;
  }

  /// Розархівує ціль, повертаючи до попереднього стану.
  bool unarchiveGoal(String id) {
    final goal = getById(id);
    if (goal == null) return false;
    if (goal.status != GoalStatus.archived) return false;
    // Повертаємо до активного стану
    final updated = goal.copyWith(status: GoalStatus.active);
    updateGoal(updated);
    return true;
  }

  /// Видаляє всі завершені цілі. Повертає кількість видалених.
  int deleteAllCompleted() {
    final initial = _goals.length;
    _goals.removeWhere((g) => g.status == GoalStatus.completed);
    return initial - _goals.length;
  }

  /// Видаляє всі скасовані цілі. Повертає кількість видалених.
  int deleteAllAbandoned() {
    final initial = _goals.length;
    _goals.removeWhere((g) => g.status == GoalStatus.abandoned);
    return initial - _goals.length;
  }

  /// Видаляє всі заархівовані цілі. Повертає кількість видалених.
  int deleteAllArchived() {
    final initial = _goals.length;
    _goals.removeWhere((g) => g.status == GoalStatus.archived);
    return initial - _goals.length;
  }

  // ─── Пакетні операції (Bulk Operations) ───────────────────────────

  /// Зберігає кілька цілей одночасно. Повертає кількість збережених.
  int saveAll(List<Goal> goals) {
    int saved = 0;
    for (final goal in goals) {
      save(goal);
      saved++;
    }
    return saved;
  }

  /// Зберігає кілька цілей без генерації підцілей (для імпорту).
  int saveAllSilent(List<Goal> goals) {
    int saved = 0;
    for (final goal in goals) {
      saveSilent(goal);
      saved++;
    }
    return saved;
  }

  /// Видаляє цілі за списком ID. Повертає кількість видалених.
  int deleteAllById(List<String> ids) {
    final initial = _goals.length;
    _goals.removeWhere((g) => ids.contains(g.id));
    return initial - _goals.length;
  }

  /// Пакетне оновлення статусу. Повертає кількість оновлених.
  int bulkUpdateStatus(List<String> ids, GoalStatus newStatus) {
    int updated = 0;
    for (final id in ids) {
      final goal = getById(id);
      if (goal == null) continue;
      final newGoal = goal.copyWith(status: newStatus);
      if (newStatus == GoalStatus.completed) {
        updateGoal(newGoal.copyWith(completedAt: DateTime.now()));
      } else {
        updateGoal(newGoal);
      }
      updated++;
    }
    return updated;
  }

  /// Архівує всі завершені цілі. Повертає кількість заархівованих.
  int archiveAllCompleted() {
    return bulkUpdateStatus(
      getCompletedGoals().map((g) => g.id).toList(),
      GoalStatus.archived,
    );
  }

  // ─── Розширена фільтрація ─────────────────────────────────────────

  /// Повертає цілі за типом.
  List<Goal> getGoalsByType(GoalType type) {
    return _goals.where((g) => g.type == type).toList();
  }

  /// Повертає цілі за статусом.
  List<Goal> getGoalsByStatus(GoalStatus status) {
    return _goals.where((g) => g.status == status).toList();
  }

  /// Шукає цілі за назвою (без регістру).
  List<Goal> searchGoals(String query) {
    if (query.isEmpty) return getAllGoals();
    final lower = query.toLowerCase();
    return _goals
        .where((g) => g.name.toLowerCase().contains(lower))
        .toList();
  }

  /// Шукає цілі за назвою та описом (без регістру).
  List<Goal> searchGoalsExtended(String query) {
    if (query.isEmpty) return getAllGoals();
    final lower = query.toLowerCase();
    return _goals.where((g) {
      final nameMatch = g.name.toLowerCase().contains(lower);
      final descMatch = g.description?.toLowerCase().contains(lower) ?? false;
      return nameMatch || descMatch;
    }).toList();
  }

  /// Повертає заморожені цілі (без внесків 7+ днів).
  List<Goal> getFrozenGoals() {
    return _goals.where((g) => g.isFrozen).toList();
  }

  /// Повертає цілі, які потребують розморожування (14+ днів).
  List<Goal> getGoalsNeedingUnfreeze() {
    return _goals.where((g) => g.needsUnfreeze).toList();
  }

  /// Повертає цілі ближчі до завершення (≥ 80%).
  List<Goal> getAlmostThereGoals() {
    return _goals.where((g) => g.isAlmostThere).toList();
  }

  /// Повертає цілі з встановленою цільовою датою.
  List<Goal> getGoalsWithDeadline() {
    return _goals.where((g) => g.targetDate != null).toList();
  }

  /// Повертає цілі, чий дедлайн вже минув.
  List<Goal> getOverdueGoals() {
    return _goals.where((g) {
      if (g.targetDate == null) return false;
      if (g.isCompleted) return false;
      return g.targetDate!.isBefore(DateTime.now());
    }).toList();
  }

  /// Фільтрує цілі за діапазоном прогресу.
  ///
  /// [minProgress] — мінімальний прогрес (0.0–1.0).
  /// [maxProgress] — максимальний прогрес (0.0–1.0).
  List<Goal> filterByProgress({
    double minProgress = 0.0,
    double maxProgress = 1.0,
  }) {
    return _goals.where((g) {
      return g.progress >= minProgress && g.progress <= maxProgress;
    }).toList();
  }

  /// Фільтрує цілі за діапазоном цільової суми.
  List<Goal> filterByTargetAmount({
    double? minAmount,
    double? maxAmount,
  }) {
    return _goals.where((g) {
      if (minAmount != null && g.targetAmount < minAmount) return false;
      if (maxAmount != null && g.targetAmount > maxAmount) return false;
      return true;
    }).toList();
  }

  /// Фільтрує цілі за датою створення.
  List<Goal> filterByCreationDate({
    DateTime? after,
    DateTime? before,
  }) {
    return _goals.where((g) {
      if (after != null && g.createdAt.isBefore(after)) return false;
      if (before != null && g.createdAt.isAfter(before)) return false;
      return true;
    }).toList();
  }

  // ─── Розширене сортування ────────────────────────────────────────

  /// Сортує цілі за назвою (алфавітно).
  List<Goal> sortByName({bool ascending = true}) {
    final sorted = List<Goal>.from(_goals);
    sorted.sort((a, b) => ascending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
    return sorted;
  }

  /// Сортує цілі за прогресом.
  List<Goal> sortByProgress({bool descending = true}) {
    final sorted = List<Goal>.from(_goals);
    sorted.sort((a, b) => descending
        ? b.progress.compareTo(a.progress)
        : a.progress.compareTo(b.progress));
    return sorted;
  }

  /// Сортує цілі за датою створення.
  List<Goal> sortByDate({bool newestFirst = true}) {
    final sorted = List<Goal>.from(_goals);
    sorted.sort((a, b) => newestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  /// Сортує цілі за стріком.
  List<Goal> sortByStreak({bool highestFirst = true}) {
    final sorted = List<Goal>.from(_goals);
    sorted.sort((a, b) => highestFirst
        ? b.streakDays.compareTo(a.streakDays)
        : a.streakDays.compareTo(b.streakDays));
    return sorted;
  }

  /// Сортує цілі за сумою, що залишилася.
  List<Goal> sortByRemaining({bool lowestFirst = true}) {
    final sorted = List<Goal>.from(_goals);
    sorted.sort((a, b) => lowestFirst
        ? a.remaining.compareTo(b.remaining)
        : b.remaining.compareTo(a.remaining));
    return sorted;
  }

  /// Сортує цілі за цільовою сумою.
  List<Goal> sortByTargetAmount({bool highestFirst = true}) {
    final sorted = List<Goal>.from(_goals);
    sorted.sort((a, b) => highestFirst
        ? b.targetAmount.compareTo(a.targetAmount)
        : a.targetAmount.compareTo(b.targetAmount));
    return sorted;
  }

  /// Сортує цілі за датою завершення.
  List<Goal> sortByCompletionDate({bool newestFirst = true}) {
    final completed = getCompletedGoals();
    completed.sort((a, b) {
      final aDate = a.completedAt ?? a.createdAt;
      final bDate = b.completedAt ?? b.createdAt;
      return newestFirst ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });
    return completed;
  }

  // ─── Пагінація ────────────────────────────────────────────────────

  /// Повертає сторінку цілей.
  ///
  /// [page] — номер сторінки (починаючи з 0).
  /// [pageSize] — кількість елементів на сторінці.
  /// [goals] — необов'язковий відфільтрований список (за замовчуванням — усі).
  ({List<Goal> items, int totalCount, int totalPages}) paginate({
    required int page,
    int pageSize = 10,
    List<Goal>? goals,
  }) {
    final source = goals ?? _goals;
    final totalCount = source.length;
    final totalPages = (totalCount / pageSize).ceil();

    if (page < 0 || page >= totalPages && totalPages > 0) {
      return (items: <Goal>[], totalCount: totalCount, totalPages: totalPages);
    }

    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, totalCount);
    final items = source.sublist(start, end);

    return (items: items, totalCount: totalCount, totalPages: totalPages);
  }

  // ─── Розширена статистика ─────────────────────────────────────────

  /// Загальна цільова сума всіх цілей.
  double get totalTargetAmount {
    return _goals.fold(0.0, (sum, g) => sum + g.targetAmount);
  }

  /// Загальна зібрана сума.
  double get totalCurrentAmount {
    return _goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  }

  /// Загальна сума, що залишилася.
  double get totalRemaining {
    return _goals.fold(0.0, (sum, g) => sum + g.remaining);
  }

  /// Загальний стрік по всіх цілях.
  int get totalStreak {
    return _goals.fold(0, (sum, g) => sum + g.streakDays);
  }

  /// Середній прогрес по всіх активних цілях (0.0–1.0).
  double get averageProgress {
    final active = getActiveGoals();
    if (active.isEmpty) return 0;
    return active.fold(0.0, (sum, g) => sum + g.progress) / active.length;
  }

  /// Загальна кількість підцілей у всіх цілях.
  int get totalSubGoalsCount {
    return _goals.fold(0, (sum, g) => sum + g.subGoals.length);
  }

  /// Загальна кількість завершених підцілей.
  int get totalCompletedSubGoalsCount {
    return _goals.fold(
      0,
      (sum, g) => sum + g.subGoals.where((sg) => sg.isCompleted).length,
    );
  }

  /// Найкраща серія серед усіх цілей.
  int get bestStreak {
    if (_goals.isEmpty) return 0;
    return _goals
        .map((g) => g.streakDays)
        .reduce((max, streak) => streak > max ? streak : max);
  }

  /// Середня тривалість досягнення цілей у днях.
  double get averageCompletionDays {
    final completed = getCompletedGoals();
    if (completed.isEmpty) return 0;
    int totalDays = 0;
    int count = 0;
    for (final goal in completed) {
      final completedAt = goal.completedAt ?? goal.createdAt;
      final days = completedAt.difference(goal.createdAt).inDays;
      if (days > 0) {
        totalDays += days;
        count++;
      }
    }
    return count > 0 ? totalDays / count : 0;
  }

  /// Повертає повний звіт по цілях.
  Map<String, dynamic> getFullStats() {
    final active = getActiveGoals();
    return {
      'загальноЦілей': count,
      'активних': activeCount,
      'завершених': completedCount,
      'скасованих': abandonedCount,
      'заархівованих': archivedCount,
      'заморожених': getFrozenGoals().length,
      'потребуютьРозморожування': getGoalsNeedingUnfreeze().length,
      'майжеЗавершені': getAlmostThereGoals().length,
      'з простроченимДедлайном': getOverdueGoals().length,
      'загальнаЦільоваСума': totalTargetAmount,
      'загальнаЗібранаСума': totalCurrentAmount,
      'залишилося': totalRemaining,
      'середнійПрогрес': (averageProgress * 100).toStringAsFixed(1),
      'загальнийСтрік': totalStreak,
      'найкращаСерія': bestStreak,
      'підцілейВсього': totalSubGoalsCount,
      'підцілейЗавершено': totalCompletedSubGoalsCount,
      'середняТривалістьДнів': averageCompletionDays.toStringAsFixed(1),
      'всьогоТипів': GoalType.values.length,
    };
  }

  /// Статистика по конкретній цілі.
  Map<String, dynamic> getGoalStats(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return {'помилка': 'Ціль не знайдено'};
    return {
      'назва': goal.name,
      'статус': goal.status.name,
      'тип': goal.type.name,
      'цільоваСума': goal.targetAmount,
      'зібрано': goal.currentAmount,
      'залишилось': goal.remaining,
      'прогрес': (goal.progress * 100).toStringAsFixed(1),
      'стрікДнів': goal.streakDays,
      'підцілей': goal.subGoals.length,
      'завершенихПідцілей': goal.subGoals.where((sg) => sg.isCompleted).length,
      'мікроцілей': goal.microGoals.length,
      'створено': goal.createdAt.toIso8601String(),
      'завершено': goal.completedAt?.toIso8601String(),
    };
  }

  // ─── Мотивація ─────────────────────────────────────────────────────

  /// Повертає мотиваційне повідомлення для головної цілі.
  String getMainMotivationMessage() {
    final goal = getActiveGoal();
    if (goal == null) {
      return '🎯 Створи нову ціль, щоб почати накопичувати!';
    }
    return goal.getMoodDescriptionUAH();
  }

  /// Повертає мотивоване повідомлення прогресу для цілі.
  String getProgressMessageForGoal(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return 'Ціль не знайдено';
    return goal.getProgressMessageUAH();
  }

  /// Повертає список мотиваційних повідомлень для всіх активних цілей.
  List<String> getAllMotivationMessages() {
    final goals = getActiveGoals();
    if (goals.isEmpty) return ['🎯 Створи нову ціль, щоб почати накопичувати!'];
    return goals.map((g) => g.getProgressMessageUAH()).toList();
  }

  // ─── Експорт ───────────────────────────────────────────────────────

  /// Експортує всі цілі у JSON з зведенням.
  String exportToJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'goals': _goals.map((g) => g.toJson()).toList(),
      'summary': {
        'total': count,
        'active': activeCount,
        'completed': completedCount,
        'abandoned': abandonedCount,
        'archived': archivedCount,
        'totalTarget': totalTargetAmount,
        'totalCurrent': totalCurrentAmount,
        'totalRemaining': totalRemaining,
        'averageProgress': averageProgress,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Експортує конкретну ціль у JSON.
  String? exportGoalToJson(String goalId) {
    final goal = getById(goalId);
    if (goal == null) return null;
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'goal': goal.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Експортує завершені цілі у JSON.
  String exportCompletedToJson() {
    final completed = getCompletedGoals();
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'goals': completed.map((g) => g.toJson()).toList(),
      'summary': {
        'total': completed.length,
        'totalCurrent': completed.fold(0.0, (s, g) => s + g.currentAmount),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Імпортує цілі з JSON. Повертає кількість імпортованих.
  int importFromJson(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final goalsData = data['goals'] as List<dynamic>?;
      if (goalsData == null) return 0;

      int imported = 0;
      for (final goalJson in goalsData) {
        try {
          final goal = Goal.fromJson(goalJson as Map<String, dynamic>);
          saveSilent(goal);
          imported++;
        } catch (_) {
          // Пропускаємо некоректні записи
        }
      }
      return imported;
    } catch (_) {
      return 0;
    }
  }

  /// Валідує JSON перед імпортом. Повертає результат перевірки.
  ({bool isValid, String message, int expectedCount}) validateImportJson(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final goalsData = data['goals'] as List<dynamic>?;

      if (goalsData == null) {
        return (isValid: false, message: 'Поле "goals" відсутнє у файлі', expectedCount: 0);
      }

      if (goalsData.isEmpty) {
        return (isValid: false, message: 'Список цілей порожній', expectedCount: 0);
      }

      // Перевіряємо, чи кожен об'єкт має необхідні поля
      int validCount = 0;
      for (final goalJson in goalsData) {
        final map = goalJson as Map<String, dynamic>;
        if (map.containsKey('id') && map.containsKey('name')) {
          validCount++;
        }
      }

      if (validCount == 0) {
        return (isValid: false, message: 'Жодна ціль не має обов\'язкових полів', expectedCount: 0);
      }

      return (
        isValid: true,
        message: 'Знайдено $validCount цілей для імпорту',
        expectedCount: validCount,
      );
    } catch (e) {
      return (isValid: false, message: 'Помилка парсингу JSON: ${e.toString()}', expectedCount: 0);
    }
  }

  // ─── Приватні методи ───────────────────────────────────────────────

  /// Створює стандартні підцілі для нової цілі залежно від типу.
  List<SubGoal> _getDefaultSubGoals(Goal goal) {
    switch (goal.type) {
      case GoalType.ps5:
        return _getPs5SubGoals(goal.id);
      case GoalType.monitor:
        return _getMonitorSubGoals(goal.id);
      case GoalType.custom:
        return [];
    }
  }

  /// Підцілі для PS5 (≈25 000 грн, 5 етапів).
  List<SubGoal> _getPs5SubGoals(String goalId) {
    return [
      SubGoal(
        id: '${goalId}_sub_1',
        goalId: goalId,
        name: 'Перший крок — 5 000 ₴',
        targetAmount: 5000,
        order: 0,
      ),
      SubGoal(
        id: '${goalId}_sub_2',
        goalId: goalId,
        name: 'Чверть шляху — 10 000 ₴',
        targetAmount: 10000,
        order: 1,
      ),
      SubGoal(
        id: '${goalId}_sub_3',
        goalId: goalId,
        name: 'Серединка — 15 000 ₴',
        targetAmount: 15000,
        order: 2,
      ),
      SubGoal(
        id: '${goalId}_sub_4',
        goalId: goalId,
        name: 'Фінішна пряма — 20 000 ₴',
        targetAmount: 20000,
        order: 3,
      ),
      SubGoal(
        id: '${goalId}_sub_5',
        goalId: goalId,
        name: 'PS5 моя! — 25 000 ₴',
        targetAmount: 25000,
        order: 4,
      ),
    ];
  }

  /// Підцілі для монітора (≈15 000 грн, 4 етапи).
  List<SubGoal> _getMonitorSubGoals(String goalId) {
    return [
      SubGoal(
        id: '${goalId}_sub_1',
        goalId: goalId,
        name: 'Розігрів — 3 000 ₴',
        targetAmount: 3000,
        order: 0,
      ),
      SubGoal(
        id: '${goalId}_sub_2',
        goalId: goalId,
        name: 'Половина шляху — 7 500 ₴',
        targetAmount: 7500,
        order: 1,
      ),
      SubGoal(
        id: '${goalId}_sub_3',
        goalId: goalId,
        name: 'Майже там — 12 000 ₴',
        targetAmount: 12000,
        order: 2,
      ),
      SubGoal(
        id: '${goalId}_sub_4',
        goalId: goalId,
        name: 'Новий монітор! — 15 000 ₴',
        targetAmount: 15000,
        order: 3,
      ),
    ];
  }
}
