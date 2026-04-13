import 'package:flutter/material.dart';
import 'package:nexora/core/constants/app_enums.dart';

/// Категорія цілі накопичення.
///
/// Використовується для класифікації цілей за сферою інтересів користувача.
enum GoalCategory {
  /// Техніка та гаджети.
  tech,

  /// Меблі та облаштування.
  furniture,

  /// Подорожі та відпустки.
  travel,

  /// Освіта та курси.
  education,

  /// Здоров'я та спорт.
  health,

  /// Розваги та ігри.
  entertainment,

  /// Одяг та стиль.
  fashion,

  /// Інше / власна категорія.
  other;

  /// Україномовна назва категорії.
  String get displayNameUA {
    switch (this) {
      case GoalCategory.tech: return 'Техніка';
      case GoalCategory.furniture: return 'Меблі';
      case GoalCategory.travel: return 'Подорожі';
      case GoalCategory.education: return 'Освіта';
      case GoalCategory.health: return 'Здоров\'я';
      case GoalCategory.entertainment: return 'Розваги';
      case GoalCategory.fashion: return 'Одяг';
      case GoalCategory.other: return 'Інше';
    }
  }

  /// Емодзі для категорії цілі.
  String get emoji {
    switch (this) {
      case GoalCategory.tech: return '💻';
      case GoalCategory.furniture: return '🪑';
      case GoalCategory.travel: return '✈️';
      case GoalCategory.education: return '📚';
      case GoalCategory.health: return '🏋️';
      case GoalCategory.entertainment: return '🎮';
      case GoalCategory.fashion: return '👕';
      case GoalCategory.other: return '🎯';
    }
  }

  /// Колір для категорії.
  Color get color {
    switch (this) {
      case GoalCategory.tech: return const Color(0xFF6C63FF);
      case GoalCategory.furniture: return const Color(0xFF8D6E63);
      case GoalCategory.travel: return const Color(0xFF26A69A);
      case GoalCategory.education: return const Color(0xFF5C6BC0);
      case GoalCategory.health: return const Color(0xFF66BB6A);
      case GoalCategory.entertainment: return const Color(0xFFFF7043);
      case GoalCategory.fashion: return const Color(0xFFEC407A);
      case GoalCategory.other: return const Color(0xFF78909C);
    }
  }
}

/// Пріоритет цілі для сортування та відображення.
enum GoalPriority {
  /// Низький пріоритет.
  low,

  /// Звичайний пріоритет.
  normal,

  /// Високий пріоритет.
  high,

  /// Критичний пріоритет (найважливіша ціль).
  critical;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case GoalPriority.low: return 'Низький';
      case GoalPriority.normal: return 'Звичайний';
      case GoalPriority.high: return 'Високий';
      case GoalPriority.critical: return 'Критичний';
    }
  }

  /// Емодзі для пріоритету.
  String get emoji {
    switch (this) {
      case GoalPriority.low: return '🟢';
      case GoalPriority.normal: return '🔵';
      case GoalPriority.high: return '🟠';
      case GoalPriority.critical: return '🔴';
    }
  }

  /// Числове значення для сортування (чим більше, тим вищий пріоритет).
  int get sortOrder {
    switch (this) {
      case GoalPriority.low: return 0;
      case GoalPriority.normal: return 1;
      case GoalPriority.high: return 2;
      case GoalPriority.critical: return 3;
    }
  }
}

/// Модель цілі накопичення.
///
/// Ціль — це основна одиниця заощаджень у додатку Nexora. Кожна ціль
/// має тип (PlayStation 5, Монітор, Власна ціль), цільову суму, поточну
/// суму, термін виконання, підцілі (SubGoal) та мікро-цілі (MicroGoal).
/// Гейміфікація реалізована через серію днів (streak), настрій прогресу
/// (ProgressMood), етапи колекції (collectionStage) та мотивційні повідомлення.
class Goal {
  final String id;
  final GoalType type;
  final String name;
  final String description;
  final double targetAmount;
  double currentAmount;
  final DateTime createdAt;
  DateTime? targetDate;
  DateTime? completedAt;
  GoalStatus status;
  int streakDays;
  int longestStreak;
  DateTime? lastDepositDate;
  List<SubGoal> subGoals;
  List<MicroGoal> microGoals;
  GoalCategory category;
  GoalPriority priority;
  List<String> tags;
  String? note;
  String? iconEmoji;
  int depositCount;

  Goal({
    required this.id,
    required this.type,
    required this.name,
    this.description = '',
    required this.targetAmount,
    this.currentAmount = 0,
    required this.createdAt,
    this.targetDate,
    this.completedAt,
    this.status = GoalStatus.active,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastDepositDate,
    List<SubGoal>? subGoals,
    List<MicroGoal>? microGoals,
    this.category = GoalCategory.other,
    this.priority = GoalPriority.normal,
    List<String>? tags,
    this.note,
    this.iconEmoji,
    this.depositCount = 0,
  })  : subGoals = subGoals ?? [],
        microGoals = microGoals ?? [],
        tags = tags ?? [];

  // ─── Обчислювані властивості ───────────────────────────────────────

  /// Прогрес від 0.0 до 1.0.
  double get progress {
    if (targetAmount <= 0) return 1.0;
    final p = currentAmount / targetAmount;
    return p.clamp(0.0, 1.0);
  }

  /// Прогрес у відсотках (0–100).
  double get progressPercent => progress * 100;

  /// Сума, що залишилася до цілі.
  double get remaining {
    final r = targetAmount - currentAmount;
    return r < 0 ? 0 : r;
  }

  /// Відсоток суми, що залишилася.
  double get remainingPercent {
    if (targetAmount <= 0) return 0;
    return ((remaining / targetAmount) * 100).clamp(0.0, 100.0);
  }

  /// Чи близько до завершення (≥ 80%).
  bool get isAlmostThere => progress >= 0.8 && status == GoalStatus.active;

  /// Чи завершено ціль.
  bool get isCompleted => status == GoalStatus.completed;

  /// Чи активна ціль.
  bool get isActive => status == GoalStatus.active;

  /// Чи призупинена ціль.
  bool get isPaused => status == GoalStatus.abandoned;

  /// Чи «заморожена» ціль (без внесків більше 7 днів).
  bool get isFrozen {
    if (status != GoalStatus.active) return false;
    if (lastDepositDate == null) {
      return createdAt.difference(DateTime.now()).inDays.abs() > 7;
    }
    return DateTime.now().difference(lastDepositDate!).inDays > 7;
  }

  /// Скільки днів ціль заморожена (0 якщо не заморожена).
  int get frozenDays {
    if (!isFrozen) return 0;
    if (lastDepositDate == null) {
      return createdAt.difference(DateTime.now()).inDays.abs();
    }
    return DateTime.now().difference(lastDepositDate!).inDays;
  }

  /// Чи потребує розморожування (без внесків 14+ днів).
  bool get needsUnfreeze {
    if (status != GoalStatus.active) return false;
    if (lastDepositDate == null) {
      return createdAt.difference(DateTime.now()).inDays.abs() > 14;
    }
    return DateTime.now().difference(lastDepositDate!).inDays > 14;
  }

  /// Настрій прогресу для анімацій.
  ProgressMood get mood {
    if (isCompleted) return ProgressMood.finale;
    if (progress >= 0.8) return ProgressMood.accelerating;
    if (progress >= 0.5) return ProgressMood.energetic;
    if (progress >= 0.2) return ProgressMood.growing;
    return ProgressMood.calm;
  }

  /// Чи має підцілі.
  bool get hasSubGoals => subGoals.isNotEmpty;

  /// Кількість завершених підцілей.
  int get completedSubGoalsCount =>
      subGoals.where((sg) => sg.isCompleted).length;

  /// Загальний прогрес підцілей (0.0–1.0).
  double get subGoalsProgress {
    if (subGoals.isEmpty) return 0;
    final total = subGoals.length;
    final completed = subGoals.where((sg) => sg.isCompleted).length;
    return completed / total;
  }

  /// Загальна цільова сума підцілей.
  double get subGoalsTotalTarget {
    return subGoals.fold(0.0, (sum, sg) => sum + sg.targetAmount);
  }

  /// Загальна поточна сума підцілей.
  double get subGoalsTotalCurrent {
    return subGoals.fold(0.0, (sum, sg) => sum + sg.currentAmount);
  }

  /// Пріоритет цільового дня (в останній тиждень = високий пріоритет).
  int get priorityScore {
    if (isCompleted) return 0;
    if (isPaused) return -1;
    int score = 10;
    if (targetDate != null) {
      final remaining = targetDate!.difference(DateTime.now()).inDays;
      if (remaining <= 0) score += 50;
      else if (remaining <= 7) score += 30;
      else if (remaining <= 14) score += 15;
    }
    if (isFrozen) score -= 5;
    if (needsUnfreeze) score -= 10;
    score += priority.sortOrder * 5;
    return score.clamp(0, 100);
  }

  /// Середній внесок.
  double get averageDeposit {
    if (depositCount <= 0) return 0;
    return currentAmount / depositCount;
  }

  /// Форматований середній внесок.
  String get formattedAverageDeposit => _formatCurrency(averageDeposit);

  /// Чи має нотатки.
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Чи має теги.
  bool get hasTags => tags.isNotEmpty;

  /// Форматований список тегів.
  String get formattedTags => tags.isEmpty ? '' : tags.map((t) => '#$t').join(' ');

  /// Іконка цілі (емодзі або іконка типу).
  String get displayIcon => iconEmoji ?? displayTypeIcon;

  // ─── Дисплейні властивості ─────────────────────────────────────────

  /// Дисплейна назва типу цілі українською.
  String get displayTypeName {
    switch (type) {
      case GoalType.ps5:
        return 'PlayStation 5';
      case GoalType.monitor:
        return 'Монітор';
      case GoalType.custom:
        return 'Власна ціль';
    }
  }

  /// Коротка емодзі-іконка для типу цілі.
  String get displayTypeIcon {
    switch (type) {
      case GoalType.ps5:
        return '🎮';
      case GoalType.monitor:
        return '🖥️';
      case GoalType.custom:
        return '🎯';
    }
  }

  /// Форматований прогрес у відсотках, наприклад "65.3%".
  String get formattedProgress {
    return '${progressPercent.toStringAsFixed(1)}%';
  }

  /// Форматований прогрес коротко (без десяткових), наприклад "65%".
  String get formattedProgressShort {
    return '${progressPercent.round()}%';
  }

  /// Форматована поточна сума, наприклад "12 450 грн".
  String get formattedCurrentAmount => _formatCurrency(currentAmount);

  /// Форматована цільова сума, наприклад "20 000 грн".
  String get formattedTargetAmount => _formatCurrency(targetAmount);

  /// Форматована сума, що залишилася, наприклад "7 550 грн".
  String get formattedRemaining => _formatCurrency(remaining);

  /// Повне описання прогресу для картки, наприклад "12 450 / 20 000 грн".
  String get formattedProgressFull =>
      '${formattedCurrentAmount} / ${formattedTargetAmount}';

  /// Статус цілі українською.
  String get displayStatus {
    switch (status) {
      case GoalStatus.active:
        if (isFrozen) return '❄️ Заморожено';
        if (needsUnfreeze) return '🧊 Потребує розморозки';
        return '🟢 Активна';
      case GoalStatus.completed:
        return '✅ Досягнуто';
      case GoalStatus.abandoned:
        return '⚫ Скасовано';
    }
  }

  /// Опис серії днів для відображення.
  String get displayStreak {
    if (streakDays == 0) return 'Без серії';
    if (streakDays == 1) return '🔥 1 день';
    if (streakDays < 5) return '🔥 $streakDays дні';
    return '🔥 $streakDays днів';
  }

  /// Опис категорії українською.
  String get displayCategory => category.displayNameUA;

  /// Емодзі категорії.
  String get displayCategoryEmoji => category.emoji;

  /// Опис пріоритету українською.
  String get displayPriority => priority.displayNameUA;

  // ─── Часові обчислення ─────────────────────────────────────────────

  /// Кількість днів з моменту створення цілі.
  int get daysSinceStart {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Кількість днів до цільової дати (null якщо не встановлено).
  int? get daysUntilTarget {
    if (targetDate == null) return null;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Чи прострочено цільову дату.
  bool get isOverdue {
    if (targetDate == null) return false;
    return targetDate!.isBefore(DateTime.now()) && !isCompleted;
  }

  /// Середня сума внесків за один день з моменту створення.
  double get averagePerDay {
    final days = daysSinceStart;
    if (days <= 0) return currentAmount;
    return currentAmount / days;
  }

  /// Очікувана дата завершення на основі середнього за день.
  DateTime? get estimatedCompletionDate {
    if (averagePerDay <= 0 || remaining <= 0) return null;
    final daysNeeded = (remaining / averagePerDay).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  /// Форматована очікувана дата завершення.
  String get formattedEstimatedCompletion {
    final date = estimatedCompletionDate;
    if (date == null) return 'Невизначено';
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  /// Місячна проекція заощаджень (на основі averagePerDay).
  double get monthlyProjection => averagePerDay * 30;

  /// Форматована місячна проекція.
  String get formattedMonthlyProjection =>
      '${monthlyProjection.toStringAsFixed(0)} грн/міс';

  /// Середня кількість внесків за тиждень (на основі переданих транзакцій).
  double depositsPerWeek(List<dynamic> transactions) {
    if (transactions.isEmpty) return 0;
    final goalTransactions = transactions
        .where((t) => (t as dynamic).goalId == id)
        .toList();
    if (goalTransactions.isEmpty) return 0;
    final days = daysSinceStart;
    if (days <= 0) return goalTransactions.length.toDouble();
    final weeks = days / 7;
    return goalTransactions.length / weeks;
  }

  // ─── Мотиваційні повідомлення ──────────────────────────────────────

  /// Мотиваційний опис на основі прогресу.
  String getMoodDescriptionUAH() {
    if (isCompleted) {
      return '🎉 Вітаємо! Твоя ціль "${name}" повністю досягнута! Ти величний накопичувач!';
    }
    if (progress >= 0.8) {
      return '🔥 Ти вже на ${formattedProgress}! Фінішна пряма — не здавайся зараз!';
    }
    if (progress >= 0.5) {
      return '💪 Більше половини пройдено! Кожна гривня наближає тебе до ${displayTypeName}.';
    }
    if (progress >= 0.2) {
      return '🌱 Хороший початок! Ти вже зібрав ${formattedCurrentAmount}. Продовжуй у тому ж дусі!';
    }
    if (isFrozen) {
      return '❄️ Твоя ціль замерзла (${frozenDays} дн). Зроби внесок сьогодні, щоб розморозити її!';
    }
    if (needsUnfreeze) {
      return '🧊 Увага! Ціль заморожена вже ${frozenDays} дн. Терміново потрібен внесок!';
    }
    return '🚀 Тільки почав? Кожен внесок — крок до ${displayTypeName}. Почни сьогодні!';
  }

  /// Повідомлення для поточного етапу прогресу.
  String getProgressMessageUAH() {
    if (progress >= 1.0) {
      return 'Ціль досягнуто! Час святкувати! 🎊';
    } else if (progress >= 0.9) {
      return 'Просто неймовірно! Лише ${formattedRemaining} залишилося!';
    } else if (progress >= 0.8) {
      return 'Вже майже! Залишилося ${formattedRemaining} — ти впораєшся!';
    } else if (progress >= 0.6) {
      return 'Ти на правильному шляху! Більше половини вже позаду.';
    } else if (progress >= 0.4) {
      return 'Солідний прогрес! Кожна гривня важлива.';
    } else if (progress >= 0.2) {
      return 'Хороший початок! Не зупиняйся.';
    } else if (progress > 0) {
      return 'Перший внесок зроблено! Тепер головне — регулярність.';
    } else {
      return 'Ціль створена. Зроби перший внесок, щоб почати!';
    }
  }

  /// Мотиваційне повідомлення для замороженої цілі.
  String getFrozenMessageUAH() {
    if (!isFrozen) return '';
    if (frozenDays >= 14) {
      return '🥶 Ого, ${frozenDays} днів без внесків! Розтопи лід — зроби внесок!';
    }
    return '❄️ ${frozenDays} дн без внесків. Час розтопити лід!';
  }

  /// Етап колекції (1–7) для візуалізації прогрес-бару.
  int getCollectionStage() {
    if (progress >= 1.0) return 7;
    if (progress >= 0.85) return 6;
    if (progress >= 0.7) return 5;
    if (progress >= 0.5) return 4;
    if (progress >= 0.3) return 3;
    if (progress >= 0.1) return 2;
    return 1;
  }

  /// Назва етапу колекції українською.
  String get collectionStageName {
    final stage = getCollectionStage();
    switch (stage) {
      case 1: return 'Початок';
      case 2: return 'Перші кроки';
      case 3: return 'Зростання';
      case 4: return 'Половина шляху';
      case 5: return 'Прискорення';
      case 6: return 'Фінішна пряма';
      case 7: return 'Перемога!';
      default: return '—';
    }
  }

  /// Емодзі для етапу колекції.
  String get collectionStageEmoji {
    final stage = getCollectionStage();
    switch (stage) {
      case 1: return '🌱';
      case 2: return '🌿';
      case 3: return '🪴';
      case 4: return '🌳';
      case 5: return '🚀';
      case 6: return '⚡';
      case 7: return '🏆';
      default: return '❓';
    }
  }

  /// Градієнт кольорів для етапу колекції.
  List<Color> get collectionStageColors {
    final stage = getCollectionStage();
    switch (stage) {
      case 1: return const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)];
      case 2: return const [Color(0xFFC8E6C9), Color(0xFFA5D6A7)];
      case 3: return const [Color(0xFFA5D6A7), Color(0xFF81C784)];
      case 4: return const [Color(0xFFFFF9C4), Color(0xFFFFF176)];
      case 5: return const [Color(0xFFFFE0B2), Color(0xFFFFB74D)];
      case 6: return const [Color(0xFFFFCCBC), Color(0xFFFF8A65)];
      case 7: return const [Color(0xFFF8BBD0), Color(0xFFF06292)];
      default: return const [Color(0xFFECEFF1), Color(0xFFCFD8DC)];
    }
  }

  // ─── Прогресні етапи ──────────────────────────────────────────────

  /// Повертає список досягнутих прогресних етапів (25%, 50%, 75%, 100%).
  List<String> get achievedMilestones {
    final milestones = <String>[];
    if (progress >= 0.25) milestones.add('25%');
    if (progress >= 0.50) milestones.add('50%');
    if (progress >= 0.75) milestones.add('75%');
    if (progress >= 1.00) milestones.add('100%');
    return milestones;
  }

  /// Повертає наступний прогресний етап, або null якщо досягнуто 100%.
  String? get nextMilestone {
    if (progress < 0.25) return '25%';
    if (progress < 0.50) return '50%';
    if (progress < 0.75) return '75%';
    if (progress < 1.00) return '100%';
    return null;
  }

  /// Відсоток до наступного прогресного етапу.
  double? get percentUntilNextMilestone {
    final next = nextMilestone;
    if (next == null) return null;
    final target = double.parse(next.replaceAll('%', '')) / 100;
    return ((target - progress) * 100).clamp(0.0, 100.0);
  }

  /// Мотиваційне повідомлення для наступного етапу.
  String get nextMilestoneMessage {
    final milestone = nextMilestone;
    if (milestone == null) return '🏆 Усі етапи пройдено!';
    final percent = percentUntilNextMilestone;
    if (percent == null) return '';
    return '🎯 Наступний етап: $milestone (ще ${percent.toStringAsFixed(1)}%)';
  }

  // ─── Статистика цілі ──────────────────────────────────────────────

  /// Обчислює повну статистику цілі.
  Map<String, dynamic> getStatisticsMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'priority': priority.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'remaining': remaining,
      'progress': progress,
      'progressPercent': progressPercent.toStringAsFixed(1),
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'depositCount': depositCount,
      'averageDeposit': averageDeposit.toStringAsFixed(2),
      'averagePerDay': averagePerDay.toStringAsFixed(2),
      'daysSinceStart': daysSinceStart,
      'isFrozen': isFrozen,
      'frozenDays': frozenDays,
      'subGoalsCount': subGoals.length,
      'completedSubGoalsCount': completedSubGoalsCount,
      'microGoalsCount': microGoals.length,
      'completedMicroGoalsCount': completedMicroGoalsCount,
      'collectionStage': getCollectionStage(),
      'estimatedCompletion': estimatedCompletionDate?.toIso8601String(),
      'tags': tags,
    };
  }

  /// Генерує дані для поділитися ціллю (share).
  Map<String, String> getSharingData() {
    return {
      'title': '🎯 Моя ціль у Nexora',
      'message': 'Я накопичую ${displayTypeName}!\n'
          '📌 ${name}\n'
          '💰 ${formattedProgressFull}\n'
          '📊 Прогрес: ${formattedProgress}\n'
          '🔥 Стрік: ${displayStreak}\n'
          '${isCompleted ? '✅ Ціль досягнуто!' : '💪 Продовжую накопичувати!'}',
      'category': category.displayNameUA,
      'progress': formattedProgress,
    };
  }

  // ─── Методи роботи з підцілями ─────────────────────────────────────

  /// Додає підціль.
  void addSubGoal(SubGoal subGoal) {
    subGoals.add(subGoal);
  }

  /// Видаляє підціль за ID.
  void removeSubGoal(String subGoalId) {
    subGoals.removeWhere((sg) => sg.id == subGoalId);
  }

  /// Оновлює підціль за ID.
  void updateSubGoal(
    String subGoalId, {
    String? name,
    double? targetAmount,
    double? currentAmount,
  }) {
    final index = subGoals.indexWhere((sg) => sg.id == subGoalId);
    if (index < 0) return;
    subGoals[index] = subGoals[index].copyWith(
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
    );
  }

  /// Повертає підціль за ID, або null.
  SubGoal? getSubGoalById(String subGoalId) {
    for (final sg in subGoals) {
      if (sg.id == subGoalId) return sg;
    }
    return null;
  }

  /// Сортує підцілі за порядком.
  void sortSubGoalsByOrder() {
    subGoals.sort((a, b) => a.order.compareTo(b.order));
  }

  /// Перевіряє, чи всі підцілі завершено.
  bool get allSubGoalsCompleted {
    if (subGoals.isEmpty) return false;
    return subGoals.every((sg) => sg.isCompleted);
  }

  // ─── Методи роботи з мікро-цілями ──────────────────────────────────

  /// Додає мікро-ціль.
  void addMicroGoal(MicroGoal microGoal) {
    microGoals.add(microGoal);
  }

  /// Видаляє мікро-ціль за ID.
  void removeMicroGoal(String microGoalId) {
    microGoals.removeWhere((mg) => mg.id == microGoalId);
  }

  /// Відзначає мікро-ціль як виконану.
  bool completeMicroGoal(String microGoalId) {
    final index = microGoals.indexWhere((mg) => mg.id == microGoalId);
    if (index < 0 || microGoals[index].isCompleted) return false;
    microGoals[index] = microGoals[index].copyWith(isCompleted: true);
    return true;
  }

  /// Кількість виконаних мікро-цілей.
  int get completedMicroGoalsCount {
    return microGoals.where((mg) => mg.isCompleted).length;
  }

  /// Кількість невиконаних мікро-цілей.
  int get pendingMicroGoalsCount {
    return microGoals.where((mg) => !mg.isCompleted).length;
  }

  /// Загальна нагорода XP за невиконані мікро-цілі.
  int get pendingMicroGoalsXp {
    return microGoals
        .where((mg) => !mg.isCompleted)
        .fold(0, (sum, mg) => sum + mg.xpReward);
  }

  /// Загальна нагорода монет за невиконані мікро-цілі.
  int get pendingMicroGoalsCoins {
    return microGoals
        .where((mg) => !mg.isCompleted)
        .fold(0, (sum, mg) => sum + mg.coinsReward);
  }

  /// Прогрес мікро-цілей (0.0–1.0).
  double get microGoalsProgress {
    if (microGoals.isEmpty) return 0;
    return completedMicroGoalsCount / microGoals.length;
  }

  // ─── Методи стану (state machine) ──────────────────────────────────

  /// Додає внесок до поточної суми цілі.
  ///
  /// Оновлює серію днів, відзначає дату останнього внеску.
  /// Якщо сума досягла або перевищила цільову — автоматично завершує ціль.
  /// Повертає нову поточну суму.
  double addDeposit(double amount) {
    currentAmount += amount;
    depositCount++;
    if (currentAmount >= targetAmount && targetAmount > 0) {
      currentAmount = targetAmount;
      status = GoalStatus.completed;
      completedAt = DateTime.now();
    }
    lastDepositDate = DateTime.now();
    streakDays++;
    if (streakDays > longestStreak) {
      longestStreak = streakDays;
    }
    return currentAmount;
  }

  /// Віднімає суму з поточного балансу (наприклад, скасування внеску).
  ///
  /// Не може стати меншим за 0. Повертає нову поточну суму.
  double undoDeposit(double amount) {
    final withdrawn = amount > currentAmount ? currentAmount : amount;
    currentAmount -= withdrawn;
    depositCount = (depositCount - 1).clamp(0, depositCount);
    if (isCompleted && currentAmount < targetAmount) {
      status = GoalStatus.active;
      completedAt = null;
    }
    return currentAmount;
  }

  /// Скидає серію днів до 0.
  void resetStreak() {
    streakDays = 0;
  }

  /// Ставить ціль на паузу (змінює статус на abandoned).
  void pause() {
    status = GoalStatus.abandoned;
  }

  /// Відновлює ціль (змінює статус на active).
  void resume() {
    if (status == GoalStatus.abandoned) {
      status = GoalStatus.active;
    }
  }

  /// Перевіряє, чи можливий перехід у вказаний статус.
  bool canTransitionTo(GoalStatus newStatus) {
    switch (newStatus) {
      case GoalStatus.active:
        return status == GoalStatus.abandoned;
      case GoalStatus.completed:
        return status == GoalStatus.active && currentAmount >= targetAmount;
      case GoalStatus.abandoned:
        return status == GoalStatus.active;
    }
  }

  /// Виконує перехід у вказаний статус. Повертає true якщо успішно.
  bool transitionTo(GoalStatus newStatus) {
    if (!canTransitionTo(newStatus)) return false;
    status = newStatus;
    if (newStatus == GoalStatus.completed) {
      completedAt = DateTime.now();
    }
    return true;
  }

  // ─── Клонування та шаблони ─────────────────────────────────────────

  /// Створює клон цілі з новим ID (для шаблонів).
  Goal clone({String? newId, String? newName}) {
    return Goal(
      id: newId ?? '${id}_clone_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      name: newName ?? '$name (копія)',
      description: description,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      category: category,
      priority: priority,
      tags: List.from(tags),
      note: note,
      iconEmoji: iconEmoji,
    );
  }

  /// Створює ціль з шаблону за замовчуванням.
  static Goal createFromTemplate({
    required String id,
    required String name,
    required GoalType type,
    required double targetAmount,
    GoalCategory category = GoalCategory.other,
    GoalPriority priority = GoalPriority.normal,
    DateTime? targetDate,
    String? description,
    String? iconEmoji,
  }) {
    return Goal(
      id: id,
      name: name,
      type: type,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
      category: category,
      priority: priority,
      targetDate: targetDate,
      description: description ?? '',
      iconEmoji: iconEmoji,
    );
  }

  // ─── Порівняння ────────────────────────────────────────────────────

  /// Порівнює прогрес двох цілей. Повертає >0 якщо this має більший прогрес.
  int compareProgressTo(Goal other) {
    return progress.compareTo(other.progress);
  }

  /// Порівнює приоритети. Повертає >0 якщо this має вищий пріоритет.
  int comparePriorityTo(Goal other) {
    return other.priority.sortOrder.compareTo(priority.sortOrder);
  }

  /// Порівнює суму, що залишилася. Повертає >0 якщо у this менше залишилось.
  int compareRemainingTo(Goal other) {
    return other.remaining.compareTo(remaining);
  }

  // ─── Аналітика ─────────────────────────────────────────────────────

  /// Повертає мапу для аналітики та графіків.
  Map<String, dynamic> toAnalyticsMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'priority': priority.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'progress': progress,
      'progressPercent': progressPercent.toStringAsFixed(1),
      'remaining': remaining,
      'remainingPercent': remainingPercent.toStringAsFixed(1),
      'daysSinceStart': daysSinceStart,
      'daysUntilTarget': daysUntilTarget,
      'averagePerDay': averagePerDay.toStringAsFixed(2),
      'monthlyProjection': monthlyProjection.toStringAsFixed(0),
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'frozenDays': frozenDays,
      'depositCount': depositCount,
      'averageDeposit': averageDeposit.toStringAsFixed(2),
      'subGoalsCount': subGoals.length,
      'completedSubGoalsCount': completedSubGoalsCount,
      'microGoalsCount': microGoals.length,
      'completedMicroGoalsCount': completedMicroGoalsCount,
      'pendingMicroGoalsXp': pendingMicroGoalsXp,
      'pendingMicroGoalsCoins': pendingMicroGoalsCoins,
      'collectionStage': getCollectionStage(),
      'collectionStageName': collectionStageName,
      'mood': mood.name,
      'status': status.name,
      'isFrozen': isFrozen,
      'isOverdue': isOverdue,
      'priorityScore': priorityScore,
      'estimatedCompletion': estimatedCompletionDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ─── Серіалізація ──────────────────────────────────────────────────

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.custom,
      ),
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      streakDays: (json['streakDays'] as int?) ?? 0,
      longestStreak: (json['longestStreak'] as int?) ?? 0,
      lastDepositDate: json['lastDepositDate'] != null
          ? DateTime.parse(json['lastDepositDate'] as String)
          : null,
      subGoals: (json['subGoals'] as List<dynamic>?)
              ?.map((e) => SubGoal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      microGoals: (json['microGoals'] as List<dynamic>?)
              ?.map((e) => MicroGoal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      category: GoalCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'other'),
        orElse: () => GoalCategory.other,
      ),
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? 'normal'),
        orElse: () => GoalPriority.normal,
      ),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>().toList() ?? [],
      note: json['note'] as String?,
      iconEmoji: json['iconEmoji'] as String?,
      depositCount: (json['depositCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'lastDepositDate': lastDepositDate?.toIso8601String(),
      'subGoals': subGoals.map((e) => e.toJson()).toList(),
      'microGoals': microGoals.map((e) => e.toJson()).toList(),
      'category': category.name,
      'priority': priority.name,
      'tags': tags,
      'note': note,
      'iconEmoji': iconEmoji,
      'depositCount': depositCount,
    };
  }

  /// Створює копію з можливістю заміни полів.
  Goal copyWith({
    String? id,
    GoalType? type,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? completedAt,
    GoalStatus? status,
    int? streakDays,
    int? longestStreak,
    DateTime? lastDepositDate,
    List<SubGoal>? subGoals,
    List<MicroGoal>? microGoals,
    GoalCategory? category,
    GoalPriority? priority,
    List<String>? tags,
    String? note,
    String? iconEmoji,
    int? depositCount,
  }) {
    return Goal(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDepositDate: lastDepositDate ?? this.lastDepositDate,
      subGoals: subGoals ?? this.subGoals,
      microGoals: microGoals ?? this.microGoals,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      depositCount: depositCount ?? this.depositCount,
    );
  }

  // ─── Річна та тижнева проекції ───────────────────────────────────

  /// Річна проекція заощаджень на основі середнього за день.
  double get yearlyProjection => averagePerDay * 365;

  /// Форматована річна проекція, наприклад "360 000 грн/рік".
  String get formattedYearlyProjection =>
      '${yearlyProjection.toStringAsFixed(0)} грн/рік';

  /// Необхідна щоденна сума для завершення вчасно.
  /// Повертає 0 якщо немає цільової дати або ціль вже завершена.
  double get requiredDailyAmount {
    if (targetDate == null || isCompleted || remaining <= 0) return 0;
    final daysLeft = daysUntilTarget;
    if (daysLeft == null || daysLeft <= 0) return remaining;
    return remaining / daysLeft;
  }

  /// Формована необхідна щоденна сума.
  String get formattedRequiredDailyAmount =>
      requiredDailyAmount > 0 ? '${requiredDailyAmount.toStringAsFixed(0)} грн/день' : '—';

  /// Чи ціль на правильному шляху для досягнення цілі вчасно.
  bool get isOnTrack {
    if (targetDate == null || isCompleted || remaining <= 0) return true;
    final daysLeft = daysUntilTarget;
    if (daysLeft == null || daysLeft <= 0) return currentAmount >= targetAmount;
    if (averagePerDay <= 0) return false;
    final projected = averagePerDay * daysLeft;
    return projected >= remaining;
  }

  /// Кількість днів до прострочення (null якщо немає цільової дати або вже прострочено).
  int? get daysUntilOverdue {
    if (targetDate == null || isCompleted) return null;
    final diff = targetDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Оцінка здоров'я цілі від 0 (критично) до 100 (ідеально).
  int get healthScore {
    int score = 50;
    // Прогрес
    if (progress >= 0.9) score += 15;
    else if (progress >= 0.5) score += 10;
    else if (progress >= 0.2) score += 5;
    else score -= 5;
    // Стрік
    if (streakDays >= 7) score += 10;
    else if (streakDays >= 3) score += 5;
    // Замороження
    if (isFrozen) score -= 15;
    if (needsUnfreeze) score -= 20;
    // Терміновість
    if (isOverdue) score -= 25;
    else if (daysUntilTarget != null && daysUntilTarget! <= 7 && !isCompleted) score += 10;
    // Підцілі
    if (hasSubGoals && subGoalsProgress > 0.5) score += 5;
    return score.clamp(0, 100);
  }

  /// Текстовий звіт про здоров'я цілі.
  String get healthReport {
    final score = healthScore;
    if (score >= 80) return '💚 Зціль у чудовому стані!';
    if (score >= 60) return '💚 Зціль в хорошому стані.';
    if (score >= 40) return '🟡 Є певні проблеми — варто звернути увагу.';
    if (score >= 20) return '🟠 Зціль потребує допомоги!';
    return '🔴 Критичний стан — терміново дійте!';
  }

  /// Повний звіт про стан та прогрес цілі.
  String getDetailedHealthReport {
    final parts = <String>[
      '📊 Звіт по цілі «$name»',
      'Стан: $displayStatus',
      'Прогрес: ${formattedProgress}',
      'Здоров\'я: $healthScore/100 — $healthReport',
    ];
    if (isOnTrack && targetDate != null) {
      parts.add('📈 Ціль на правильному шляху!');
    } else if (targetDate != null && !isCompleted) {
      parts.add('⚠️ Ціль відстає від графіку.');
    }
    if (isFrozen) {
      parts.add('❄️ Заморожено ${frozenDays} дн.');
    }
    if (isOverdue) {
      parts.add('⏰ Термін виконання минув!');
    }
    if (requiredDailyAmount > 0) {
      parts.add('💵 Необхідно: $formattedRequiredDailyAmount');
    }
    return parts.join('\n');
  }

  // ─── Пошуковий рядок ────────────────────────────────────────────────

  /// Об'єднує всі текстові поля для пошуку (lowercase).
  String toSearchString() {
    final parts = <String>[
      name.toLowerCase(),
      description.toLowerCase(),
      type.name.toLowerCase(),
      category.name.toLowerCase(),
      priority.name.toLowerCase(),
      note?.toLowerCase() ?? '',
      ...tags.map((t) => t.toLowerCase()),
    ];
    return parts.join(' ');
  }

  /// Перевіряє, чи ціль відповідає пошуковому запиту.
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    return name.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower) ||
        toSearchString().contains(lower);
  }

  // ─── CSV експорт ────────────────────────────────────────────────────

  /// Рядок CSV для експорту цілі.
  String toCsvRow() {
    final noteEscaped = note?.replaceAll('"', '""') ?? '';
    final tagsStr = tags.join(';');
    return [
      id,
      type.name,
      name.replaceAll(',', ';'),
      description.replaceAll(',', ';'),
      targetAmount.toStringAsFixed(2),
      currentAmount.toStringAsFixed(2),
      status.name,
      category.name,
      priority.name,
      streakDays,
      depositCount,
      createdAt.toIso8601String(),
      targetDate?.toIso8601String() ?? '',
      completedAt?.toIso8601String() ?? '',
      noteEscaped,
      tagsStr,
      iconEmoji ?? '',
    ].join(',');
  }

  /// Заголовок CSV для експорту цілей.
  static String get csvHeader =>
      'ID,Тип,Назва,Опис,Ціль,Поточна,Статус,Категорія,Пріоритет,Стрік,Внесків,Створено,Цільова дата,Завершено,Нотатки,Теги,Іконка';

  /// Повна CSV-строка з заголовком.
  String toFullCsv() => '$csvHeader\n${toCsvRow()}';

  // ─── Додаткові порівняння ─────────────────────────────────────────

  /// Порівнює дати створення. Повертає >0 якщо this створена раніше.
  int compareCreatedDateTo(Goal other) =>
      createdAt.compareTo(other.createdAt);

  /// Порівнює цільові дати. Повертає >0 якщо у this дедлайн ближчий.
  int compareTargetDateTo(Goal other) {
    if (targetDate == null && other.targetDate == null) return 0;
    if (targetDate == null) return 1;
    if (other.targetDate == null) return -1;
    return targetDate!.compareTo(other.targetDate!);
  }

  /// Порівнює streakDays. Повертає >0 якщо this має довший стрік.
  int compareStreakTo(Goal other) =>
      longestStreak.compareTo(other.longestStreak);

  /// Порівнює за сумою заощаджень. Повертає >0 якщо this має більше.
  int compareAmountTo(Goal other) =>
      currentAmount.compareTo(other.currentAmount);

  // ─── Оператори рівності ────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal && other.id == id;
  }

  @override
  int get hashCode => Object.hash(id, type, name, createdAt);

  // ─── Приватний форматування ───────────────────────────────────────

  /// Форматує число з пробілами для тисяч і додає " грн".
  static String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(intPart[i]);
    }
    buffer.write('.');
    buffer.write(parts[1]);
    return '$buffer грн';
  }

  @override
  String toString() =>
      'Goal(id: $id, name: $name, type: $type, progress: ${formattedProgress})';

  // ─── Статичні утилітарні методи ────────────────────────────────────

  /// Фільтрує цілі за категорією.
  static List<Goal> filterByCategory(
      List<Goal> goals, GoalCategory category) {
    return goals.where((g) => g.category == category).toList();
  }

  /// Фільтрує цілі за пріоритетом.
  static List<Goal> filterByPriority(
      List<Goal> goals, GoalPriority priority) {
    return goals.where((g) => g.priority == priority).toList();
  }

  /// Фільтрує цілі за статусом.
  static List<Goal> filterByStatus(
      List<Goal> goals, GoalStatus status) {
    return goals.where((g) => g.status == status).toList();
  }

  /// Фільтрує цілі за наявністю тегу.
  static List<Goal> filterByTag(
      List<Goal> goals, String tag) {
    return goals.where((g) => g.tags.contains(tag)).toList();
  }

  /// Фільтрує заморожені цілі.
  static List<Goal> filterFrozen(List<Goal> goals) {
    return goals.where((g) => g.isFrozen).toList();
  }

  /// Фільтрує прострочені цілі.
  static List<Goal> filterOverdue(List<Goal> goals) {
    return goals.where((g) => g.isOverdue).toList();
  }

  /// Фільтрує активні цілі.
  static List<Goal> filterActive(List<Goal> goals) {
    return goals.where((g) => g.isActive).toList();
  }

  /// Пошук цілей за назвою (без врахування регістру).
  static List<Goal> searchByName(
      List<Goal> goals, String query) {
    if (query.isEmpty) return goals;
    final lower = query.toLowerCase();
    return goals.where((g) => g.name.toLowerCase().contains(lower)).toList();
  }

  /// Пошук цілей за повним текстовим вмістом.
  static List<Goal> search(List<Goal> goals, String query) {
    if (query.isEmpty) return goals;
    final lower = query.toLowerCase();
    return goals
        .where((g) => g.toSearchString().contains(lower))
        .toList();
  }

  /// Сортує цілі за пріоритетом (найвищі перші).
  static List<Goal> sortByPriority(List<Goal> goals) {
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) =>
        b.priority.sortOrder.compareTo(a.priority.sortOrder));
    return sorted;
  }

  /// Сортує цілі за прогресом (найбільший перший).
  static List<Goal> sortByProgress(List<Goal> goals) {
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) => b.progress.compareTo(a.progress));
    return sorted;
  }

  /// Сортує цілі за streak (найдовший перший).
  static List<Goal> sortByStreak(List<Goal> goals) {
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) => b.longestStreak.compareTo(a.longestStreak));
    return sorted;
  }

  /// Сортує цілі за датою створення (найновіші перші).
  static List<Goal> sortByCreatedDate(List<Goal> goals) {
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Сортує цілі за цільовою датою (найближчі перші).
  static List<Goal> sortByTargetDate(List<Goal> goals) {
    final sorted = List<Goal>.from(goals)
        .where((g) => g.targetDate != null)
        .toList();
    sorted.sort((a, b) =>
        a.targetDate!.compareTo(b.targetDate!));
    return sorted;
  }

  /// Сортує цілі за priorityScore (найвищий перший).
  static List<Goal> sortByPriorityScore(List<Goal> goals) {
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return sorted;
  }

  /// Обчислює середній прогрес набору цілей.
  static double getAverageProgress(List<Goal> goals) {
    if (goals.isEmpty) return 0;
    return goals.fold<double>(0, (sum, g) => sum + g.progress) / goals.length;
  }

  /// Обчислює загальну суму заощаджень усіх цілей.
  static double getTotalSaved(List<Goal> goals) {
    return goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
  }

  /// Обчислює загальну цільову суму усіх цілей.
  static double getTotalTarget(List<Goal> goals) {
    return goals.fold<double>(0, (sum, g) => sum + g.targetAmount);
  }

  /// Обчислює загальну суму, що залишилася.
  static double getTotalRemaining(List<Goal> goals) {
    return goals.fold<double>(0, (sum, g) => sum + g.remaining);
  }

  /// Обчислює загальну кількість внесків.
  static int getTotalDeposits(List<Goal> goals) {
    return goals.fold<int>(0, (sum, g) => sum + g.depositCount);
  }

  /// Кількість активних цілей.
  static int activeGoalsCount(List<Goal> goals) =>
      goals.where((g) => g.isActive).length;

  /// Кількість завершених цілей.
  static int completedGoalsCount(List<Goal> goals) =>
      goals.where((g) => g.isCompleted).length;

  /// Кількість заморожених цілей.
  static int frozenGoalsCount(List<Goal> goals) =>
      goals.where((g) => g.isFrozen).length;

  /// Кількість прострочених цілей.
  static int overdueGoalsCount(List<Goal> goals) =>
      goals.where((g) => g.isOverdue).length;

  /// Загальна кількість підцілей.
  static int totalSubGoalsCount(List<Goal> goals) =>
      goals.fold<int>(0, (sum, g) => sum + g.subGoals.length);

  /// Загальна кількість мікро-цілей.
  static int totalMicroGoalsCount(List<Goal> goals) =>
      goals.fold<int>(0, (sum, g) => sum + g.microGoals.length);

  /// Формований звіт по набору цілей.
  static String getGoalsSummary(List<Goal> goals) {
    if (goals.isEmpty) return '📭 Ще ще немає цілей';
    final active = goals.where((g) => g.isActive).length;
    final completed = goals.where((g) => g.isCompleted).length;
    final total = goals.fold<double>(0, (s, g) => s + g.currentAmount);
    return '🎯 Цілей: ${goals.length} (активних: $active, завершено: $completed) · '
        '💰 Загалом: ${_fmt(total)} грн';
  }

  static String _fmt(double v) {
    final f = v.toStringAsFixed(0);
    final parts = f.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
      buf.write(intPart[i]);
    }
    return buf.toString();
  }
}

/// Підціль (етап всередині головної цілі).
///
/// Підцілі дозволяють розбити велику ціль на менші керовані частини.
/// Кожна підціль має власну цільову суму та може бути паралельною
/// (виконується одночасно з іншими) або послідовною.
class SubGoal {
  final String id;
  final String goalId;
  final String name;
  final double targetAmount;
  double currentAmount;
  final bool isParallel;
  final int order;

  SubGoal({
    required this.id,
    required this.goalId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.isParallel = false,
    required this.order,
  });

  double get progress {
    if (targetAmount <= 0) return 1.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remaining {
    final r = targetAmount - currentAmount;
    return r < 0 ? 0 : r;
  }

  bool get isCompleted => currentAmount >= targetAmount;

  /// Форматований прогрес.
  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  /// Форматована поточна сума.
  String get formattedCurrentAmount => '${currentAmount.toStringAsFixed(0)} грн';

  /// Форматована цільова сума.
  String get formattedTargetAmount => '${targetAmount.toStringAsFixed(0)} грн';

  /// Форматована сума, що залишилася.
  String get formattedRemaining {
    final rem = remaining;
    return '${rem.toStringAsFixed(0)} грн';
  }

  /// Порядковий номер для відображення, наприклад "Крок 2".
  String get displayOrder => 'Крок $order';

  /// Емодзі статусу підцілі.
  String get statusEmoji => isCompleted ? '✅' : '⬜';

  factory SubGoal.fromJson(Map<String, dynamic> json) {
    return SubGoal(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      isParallel: (json['isParallel'] as bool?) ?? false,
      order: (json['order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'isParallel': isParallel,
      'order': order,
    };
  }

  SubGoal copyWith({
    String? id,
    String? goalId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    bool? isParallel,
    int? order,
  }) {
    return SubGoal(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      isParallel: isParallel ?? this.isParallel,
      order: order ?? this.order,
    );
  }
}

/// Мікро-ціль (маленьке завдання всередині цілі, секція 2.2.3 специфікації).
///
/// Мікро-цілі — це дрібні щоденні або разові завдання, які дають бонусний XP
/// та монети при виконанні. Використовуються для додаткової гейміфікації
/// та мотивації користувача до регулярних дій.
///
/// Приклади мікро-цілей:
/// - "Зроби внесок хоча б 10 грн сьогодні"
/// - "Відкрий додаток 3 дні поспіль"
/// - "Зроби внесок до 9:00 ранку"
class MicroGoal {
  final String id;
  final String goalId;
  final String title;
  final String description;
  final int xpReward;
  final int coinsReward;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;
  final MicroGoalDifficulty difficulty;

  MicroGoal({
    required this.id,
    required this.goalId,
    required this.title,
    this.description = '',
    this.xpReward = 10,
    this.coinsReward = 5,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.difficulty = MicroGoalDifficulty.easy,
  });

  /// Форматований опис нагороди.
  String get formattedReward {
    return '+$xpReward XP · +$coinsReward монет';
  }

  /// Короткий опис нагороди.
  String get formattedRewardShort => '+$xpReward XP';

  /// Чи виконано мікро-ціль.
  bool get isDone => isCompleted;

  /// Дійсність мікро-цілі (не завершена).
  bool get isPending => !isCompleted;

  /// Кількість днів з моменту створення.
  int get daysSinceCreation =>
      DateTime.now().difference(createdAt).inDays;

  /// Емодзі складності мікро-цілі.
  String get difficultyEmoji {
    switch (difficulty) {
      case MicroGoalDifficulty.easy: return '🟢';
      case MicroGoalDifficulty.medium: return '🟡';
      case MicroGoalDifficulty.hard: return '🔴';
    }
  }

  /// Множник нагороди залежно від складності.
  double get difficultyMultiplier {
    switch (difficulty) {
      case MicroGoalDifficulty.easy: return 1.0;
      case MicroGoalDifficulty.medium: return 1.5;
      case MicroGoalDifficulty.hard: return 2.0;
    }
  }

  /// Ефективна нагорода XP з урахуванням множника.
  int get effectiveXpReward => (xpReward * difficultyMultiplier).round();

  /// Ефективна нагорода монет з урахуванням множника.
  int get effectiveCoinsReward => (coinsReward * difficultyMultiplier).round();

  /// Відзначає мікро-ціль як виконану. Повертає true якщо було щойно виконано.
  bool markCompleted() {
    if (isCompleted) return false;
    isCompleted = true;
    completedAt = DateTime.now();
    return true;
  }

  /// Скидає мікро-ціль до невиконаного стану.
  void reset() {
    isCompleted = false;
    completedAt = null;
  }

  factory MicroGoal.fromJson(Map<String, dynamic> json) {
    return MicroGoal(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      xpReward: (json['xpReward'] as int?) ?? 10,
      coinsReward: (json['coinsReward'] as int?) ?? 5,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      difficulty: MicroGoalDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] ?? 'easy'),
        orElse: () => MicroGoalDifficulty.easy,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'coinsReward': coinsReward,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'difficulty': difficulty.name,
    };
  }

  MicroGoal copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    int? xpReward,
    int? coinsReward,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    MicroGoalDifficulty? difficulty,
  }) {
    return MicroGoal(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      coinsReward: coinsReward ?? this.coinsReward,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

/// Складність мікро-цілі.
enum MicroGoalDifficulty {
  /// Легка мікро-ціль (стандартна нагорода).
  easy,

  /// Середня мікро-ціль (1.5x нагорода).
  medium,

  /// Складна мікро-ціль (2x нагорода).
  hard;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case MicroGoalDifficulty.easy: return 'Легко';
      case MicroGoalDifficulty.medium: return 'Середньо';
      case MicroGoalDifficulty.hard: return 'Складно';
    }
  }
}
