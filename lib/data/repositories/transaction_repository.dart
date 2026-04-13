import 'package:nexora/core/constants/app_enums.dart';
import 'package:nexora/data/models/transaction_model.dart';

/// Репозиторій транзакцій (in-memory).
///
/// Забезпечує повне CRUD, фільтрацію за типом/датою/ціллю/категорією/сумою,
/// пагінацію, агрегацію, зведення за періодами, групування,
/// пошук, генерування даних для графіків, експорт/імпорт CSV,
/// статистичні методи, аналіз трендів та виявлення дублікатів.
///
/// Всі рядки-повідомлення українською.
class TransactionRepository {
  final List<Transaction> _transactions = [];

  /// Стек для скасування останніх операцій (undo).
  final List<Transaction> _undoStack = [];
  /// Максимальна глибина стеку скасувань.
  static const int _maxUndoDepth = 50;

  // ─── Базові CRUD ───────────────────────────────────────────────────

  /// Зберігає транзакцію та додає її в стек undo.
  void save(Transaction transaction) {
    _transactions.add(transaction);
    _addToUndoStack(transaction);
  }

  /// Зберігає транзакцію без додавання в стек undo (для імпорту).
  void saveSilent(Transaction transaction) {
    _transactions.add(transaction);
  }

  /// Масово зберігає транзакції (для імпорту).
  ///
  /// Всі транзакції додаються без undo.
  void saveAll(List<Transaction> transactions) {
    _transactions.addAll(transactions);
  }

  /// Повертає всі транзакції (найновіші першими).
  List<Transaction> getAll() {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  /// Повертає останні [limit] транзакцій.
  List<Transaction> getRecent(int limit) {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (sorted.length > limit) {
      return List.unmodifiable(sorted.sublist(0, limit));
    }
    return List.unmodifiable(sorted);
  }

  /// Повертає транзакції для конкретної цілі (синонім getForGoal).
  List<Transaction> getByGoalId(String goalId) {
    return _transactions
        .where((t) => t.goalId == goalId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Знаходить транзакцію за ID.
  Transaction? getById(String id) {
    for (final t in _transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Оновлює існуючу транзакцію за ID.
  void update(Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      _transactions[index] = transaction;
    }
  }

  /// Видаляє транзакцію за ID. Повертає видалену транзакцію або null.
  Transaction? delete(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index < 0) return null;
    final removed = _transactions.removeAt(index);
    return removed;
  }

  /// Масово видаляє транзакції за списком ID.
  /// Повертає кількість видалених транзакцій.
  int deleteAll(List<String> ids) {
    var removed = 0;
    for (final id in ids) {
      if (delete(id) != null) removed++;
    }
    return removed;
  }

  /// Скасовує останню транзакцію (undo). Повертає скасовану транзакцію.
  Transaction? undo() {
    if (_undoStack.isEmpty) return null;
    final last = _undoStack.removeLast();
    final removed = delete(last.id);
    return removed;
  }

  /// Повертає кількість транзакцій, які можна скасувати.
  int get undoAvailable => _undoStack.length;

  /// Очищає стек скасувань.
  void clearUndoStack() {
    _undoStack.clear();
  }

  /// Кількість транзакцій у репозиторії.
  int get count => _transactions.length;

  /// Чи репозиторій порожній.
  bool get isEmpty => _transactions.isEmpty;

  /// Чи репозиторій не порожній.
  bool get isNotEmpty => _transactions.isNotEmpty;

  /// Очищає всі транзакції (без можливості відновлення).
  void clearAll() {
    _transactions.clear();
    _undoStack.clear();
  }

  // ─── Фільтрація ────────────────────────────────────────────────────

  /// Фільтрує транзакції за типом.
  List<Transaction> filterByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Фільтрує транзакції за діапазоном дат (включно).
  List<Transaction> filterByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    return _transactions
        .where((t) => !t.createdAt.isBefore(from) && !t.createdAt.isAfter(to))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Фільтрує транзакції за категорією.
  ///
  /// [category] — назва категорії для порівняння (без регістру).
  List<Transaction> filterByCategory(String category) {
    if (category.isEmpty) return getAll();
    final lower = category.toLowerCase();
    return _transactions
        .where((t) =>
            t.comment != null &&
            t.comment!.toLowerCase().contains(lower))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Фільтрує транзакції за діапазоном сум.
  ///
  /// [minAmount] — мінімальна сума (включно).
  /// [maxAmount] — максимальна сума (включно).
  List<Transaction> filterByAmountRange({
    double minAmount = 0,
    double maxAmount = double.infinity,
  }) {
    return _transactions
        .where((t) => t.amount >= minAmount && t.amount <= maxAmount)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Фільтрує транзакції для конкретної цілі.
  List<Transaction> getForGoal(String goalId) {
    return getByGoalId(goalId);
  }

  /// Пошук транзакцій за коментарем (без регістру).
  List<Transaction> search(String query) {
    if (query.isEmpty) return getAll();
    final lower = query.toLowerCase();
    return _transactions
        .where((t) =>
            (t.comment != null && t.comment!.toLowerCase().contains(lower)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Пошук транзакцій за сумою (точне або наближене).
  ///
  /// [amount] — шукана сума.
  /// [tolerance] — допустиме відхилення (за замовчуванням 0.01).
  List<Transaction> searchByAmount(double amount, {double tolerance = 0.01}) {
    return _transactions
        .where((t) => (t.amount - amount).abs() <= tolerance)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Комбінована фільтрація: тип + діапазон дат + ціль + пошук + сума.
  List<Transaction> filterCombined({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? goalId,
    String? query,
    double? minAmount,
    double? maxAmount,
  }) {
    var result = List<Transaction>.from(_transactions);

    if (type != null) {
      result = result.where((t) => t.type == type).toList();
    }
    if (from != null && to != null) {
      result = result
          .where((t) => !t.createdAt.isBefore(from) && !t.createdAt.isAfter(to))
          .toList();
    }
    if (goalId != null && goalId.isNotEmpty) {
      result = result.where((t) => t.goalId == goalId).toList();
    }
    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result
          .where((t) =>
              t.comment != null && t.comment!.toLowerCase().contains(lower))
          .toList();
    }
    if (minAmount != null) {
      result = result.where((t) => t.amount >= minAmount).toList();
    }
    if (maxAmount != null) {
      result = result.where((t) => t.amount <= maxAmount).toList();
    }

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  /// Повертає кількість транзакцій від [since] до зараз.
  int getCountSince(DateTime since) {
    return _transactions.where((t) => t.createdAt.isAfter(since)).length;
  }

  /// Повертає кількість транзакцій за тип.
  int countByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).length;
  }

  /// Повертає кількість транзакцій у вказаному діапазоні дат.
  int countByDateRange({required DateTime from, required DateTime to}) {
    return _transactions
        .where((t) => !t.createdAt.isBefore(from) && !t.createdAt.isAfter(to))
        .length;
  }

  // ─── Виявлення дублікатів ──────────────────────────────────────────

  /// Знаходить дублікати транзакції за сумою та датою.
  ///
  /// Вважає дублікатами транзакції з однаковою сумою
  /// та датою з точністю до [timeTolerance].
  List<List<Transaction>> findDuplicates({Duration timeTolerance = const Duration(minutes: 1)}) {
    final groups = <String, List<Transaction>>{};
    for (final t in _transactions) {
      // Формуємо ключ з суми та округленої дати
      final amountKey = t.amount.toStringAsFixed(2);
      final dateKey = t.createdAt.millisecondsSinceEpoch ~/ timeTolerance.inMilliseconds;
      final key = '$amountKey-$dateKey';

      groups.putIfAbsent(key, () => []).add(t);
    }
    // Повертаємо лише групи з >1 елементом
    return groups.values.where((g) => g.length > 1).toList();
  }

  /// Видаляє дублікати транзакцій, залишаючи лише найновішу в кожній групі.
  ///
  /// Повертає кількість видалених дублікатів.
  int removeDuplicates() {
    final duplicates = findDuplicates();
    var removed = 0;
    for (final group in duplicates) {
      // Сортуємо за датою (найновіша перша)
      group.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Видаляємо всі, крім найновішої
      for (var i = 1; i < group.length; i++) {
        if (delete(group[i].id) != null) removed++;
      }
    }
    return removed;
  }

  /// Перевіряє, чи є транзакція дублікатом існуючих.
  ///
  /// [transaction] — транзакція для перевірки.
  /// [timeTolerance] — допустима різниця в часі.
  bool isDuplicate(
    Transaction transaction, {
    Duration timeTolerance = const Duration(minutes: 1),
  }) {
    return _transactions.any((t) {
      if (t.id == transaction.id) return false;
      if ((t.amount - transaction.amount).abs() > 0.01) return false;
      final timeDiff = (t.createdAt.difference(transaction.createdAt)).abs();
      return timeDiff <= timeTolerance;
    });
  }

  // ─── Пагінація ─────────────────────────────────────────────────────

  /// Повертає сторінку транзакцій. [page] починається з 0.
  List<Transaction> getPage({
    required int page,
    required int pageSize,
    List<Transaction>? filteredList,
  }) {
    final list = filteredList ?? getAll();
    final start = page * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  /// Загальна кількість сторінок.
  int totalPages({int pageSize = 20, List<Transaction>? filteredList}) {
    final list = filteredList ?? _transactions;
    return (list.length / pageSize).ceil();
  }

  /// Чи є наступна сторінка.
  bool hasNextPage({
    required int page,
    required int pageSize,
    List<Transaction>? filteredList,
  }) {
    return (page + 1) < totalPages(
      pageSize: pageSize,
      filteredList: filteredList,
    );
  }

  /// Чи є попередня сторінка.
  bool hasPreviousPage({required int page}) {
    return page > 0;
  }

  // ─── Агрегація ─────────────────────────────────────────────────────

  /// Загальна сума всіх транзакцій.
  double get totalAmount {
    return _transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Загальна сума транзакцій певного типу.
  double getTotalByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Загальна сума транзакцій для конкретної цілі.
  double getTotalForGoal(String goalId) {
    return _transactions
        .where((t) => t.goalId == goalId)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Загальна сума за діапазон дат.
  double getTotalByDateRange({required DateTime from, required DateTime to}) {
    return _transactions
        .where((t) => !t.createdAt.isBefore(from) && !t.createdAt.isAfter(to))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Загальна сума за діапазон сум (наприклад, для аналізу сегментів).
  double getTotalByAmountRange({
    double minAmount = 0,
    double maxAmount = double.infinity,
  }) {
    return _transactions
        .where((t) => t.amount >= minAmount && t.amount <= maxAmount)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Середня сума всіх транзакцій.
  double get averageAmount {
    if (_transactions.isEmpty) return 0;
    return totalAmount / _transactions.length;
  }

  /// Максимальна сума транзакції.
  double get maxAmount {
    if (_transactions.isEmpty) return 0;
    return _transactions.fold(0.0, (max, t) => t.amount > max ? t.amount : max);
  }

  /// Мінімальна сума транзакції.
  double get minAmount {
    if (_transactions.isEmpty) return 0;
    return _transactions.fold(
      double.infinity,
      (min, t) => t.amount < min ? t.amount : min,
    );
  }

  /// Кількість транзакцій (синонім count).
  int get totalCount => _transactions.length;

  /// Загальна кількість XP, зароблених через транзакції.
  int get totalXpEarned {
    return _transactions.fold(0, (sum, t) => sum + t.xpEarned);
  }

  /// Загальна кількість монет, зароблених через транзакції.
  int get totalCoinsEarned {
    return _transactions.fold(0, (sum, t) => sum + t.coinsEarned);
  }

  /// Середня сума за вказаний період.
  double averageForPeriod({required DateTime from, required DateTime to}) {
    final filtered = filterByDateRange(from: from, to: to);
    if (filtered.isEmpty) return 0;
    return filtered.fold(0.0, (sum, t) => sum + t.amount) / filtered.length;
  }

  /// Медіанна сума всіх транзакцій.
  double get medianAmount {
    if (_transactions.isEmpty) return 0;
    final sorted = List<double>.from(
      _transactions.map((t) => t.amount),
    )..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Повертає транзакцію з максимальною сумою.
  Transaction? get transactionWithMaxAmount {
    if (_transactions.isEmpty) return null;
    return _transactions.reduce(
      (a, b) => a.amount > b.amount ? a : b,
    );
  }

  /// Повертає транзакцію з мінімальною сумою.
  Transaction? get transactionWithMinAmount {
    if (_transactions.isEmpty) return null;
    return _transactions.reduce(
      (a, b) => a.amount < b.amount ? a : b,
    );
  }

  /// Стандартне відхилення сум транзакцій.
  double get standardDeviation {
    if (_transactions.length < 2) return 0;
    final avg = averageAmount;
    final variance = _transactions.fold(
      0.0,
      (sum, t) => sum + math.pow(t.amount - avg, 2),
    ) / _transactions.length;
    return math.sqrt(variance);
  }

  // ─── Аналіз трендів ────────────────────────────────────────────────

  /// Порівнює суму поточного періоду з попереднім.
  ///
  /// [periodDays] — тривалість періоду в днях.
  /// Повертає Map з відсотком зміни та сумами.
  Map<String, dynamic> comparePeriods(int periodDays) {
    final now = DateTime.now();
    final currentStart = now.subtract(Duration(days: periodDays));
    final previousStart = currentStart.subtract(Duration(days: periodDays));

    final currentTotal = getTotalByDateRange(
      from: currentStart,
      to: now,
    );
    final previousTotal = getTotalByDateRange(
      from: previousStart,
      to: currentStart,
    );

    final changePercent = previousTotal == 0
        ? (currentTotal > 0 ? 100.0 : 0.0)
        : ((currentTotal - previousTotal) / previousTotal * 100);

    return {
      'currentTotal': currentTotal,
      'previousTotal': previousTotal,
      'changePercent': changePercent,
      'changeAmount': currentTotal - previousTotal,
      'isIncrease': currentTotal > previousTotal,
      'currentCount': countByDateRange(from: currentStart, to: now),
      'previousCount': countByDateRange(from: previousStart, to: currentStart),
    };
  }

  /// Серійне порівняння за кількома періодами.
  ///
  /// [periodDays] — тривалість кожного періоду.
  /// [periods] — кількість періодів для порівняння.
  List<Map<String, dynamic>> multiPeriodComparison({
    int periodDays = 7,
    int periods = 4,
  }) {
    final results = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (var i = 0; i < periods; i++) {
      final to = now.subtract(Duration(days: periodDays * i));
      final from = now.subtract(Duration(days: periodDays * (i + 1)));

      results.add({
        'period': '${from.day}.${from.month} — ${to.day}.${to.month}',
        'total': getTotalByDateRange(from: from, to: to),
        'count': countByDateRange(from: from, to: to),
        'average': averageForPeriod(from: from, to: to),
        'index': i,
      });
    }

    return results;
  }

  /// Знаходить день з максимальною сумою транзакцій.
  ///
  /// [days] — кількість днів для аналізу (найновіші).
  Map<String, dynamic>? topDay({int days = 30}) {
    final summary = dailySummary(days: days);
    if (summary.isEmpty) return null;

    String? bestDay;
    double bestAmount = double.negativeInfinity;

    summary.forEach((day, amount) {
      if (amount > bestAmount) {
        bestAmount = amount;
        bestDay = day;
      }
    });

    return {
      'date': bestDay,
      'amount': bestAmount,
      'label': bestDay != null ? 'Найкращий день: $bestDay' : '',
    };
  }

  /// Знаходить день з мінімальною сумою транзакцій (тільки дні з транзакціями).
  Map<String, dynamic>? worstDay({int days = 30}) {
    final summary = dailySummary(days: days);
    if (summary.isEmpty) return null;

    String? worstDay;
    double worstAmount = double.infinity;

    summary.forEach((day, amount) {
      if (amount < worstAmount) {
        worstAmount = amount;
        worstDay = day;
      }
    });

    return {
      'date': worstDay,
      'amount': worstAmount,
      'label': worstDay != null ? 'Найгірший день: $worstDay' : '',
    };
  }

  // ─── Зведення за періодами ─────────────────────────────────────────

  /// Щоденне зведення сум за останні [days] днів.
  Map<String, double> dailySummary({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = _transactions
        .where((t) => t.createdAt.isAfter(cutoff))
        .toList();
    final summary = <String, double>{};
    for (final t in filtered) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}-${t.createdAt.day.toString().padLeft(2, '0')}';
      summary[key] = (summary[key] ?? 0) + t.amount;
    }
    return summary;
  }

  /// Щотижневе зведення сум за останні [weeks] тижнів.
  Map<String, double> weeklySummary({int weeks = 12}) {
    final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
    final filtered = _transactions
        .where((t) => t.createdAt.isAfter(cutoff))
        .toList();
    final summary = <String, double>{};
    for (final t in filtered) {
      final weekStart =
          t.createdAt.subtract(Duration(days: t.createdAt.weekday - 1));
      final key =
          '${weekStart.year}-W${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      summary[key] = (summary[key] ?? 0) + t.amount;
    }
    return summary;
  }

  /// Щомісячне зведення сум за останні [months] місяців.
  Map<String, double> monthlySummary({int months = 12}) {
    final cutoff = DateTime.now().subtract(Duration(days: months * 30));
    final filtered = _transactions
        .where((t) => t.createdAt.isAfter(cutoff))
        .toList();
    final summary = <String, double>{};
    for (final t in filtered) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}';
      summary[key] = (summary[key] ?? 0) + t.amount;
    }
    return summary;
  }

  /// Щоденне зведення з кількістю транзакцій.
  Map<String, Map<String, dynamic>> dailySummaryWithCount({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = _transactions
        .where((t) => t.createdAt.isAfter(cutoff))
        .toList();
    final summary = <String, Map<String, dynamic>>{};
    for (final t in filtered) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}-${t.createdAt.day.toString().padLeft(2, '0')}';
      if (!summary.containsKey(key)) {
        summary[key] = {'amount': 0.0, 'count': 0};
      }
      summary[key]!['amount'] = (summary[key]!['amount'] as double) + t.amount;
      summary[key]!['count'] = (summary[key]!['count'] as int) + 1;
    }
    return summary;
  }

  // ─── Групування ────────────────────────────────────────────────────

  /// Групує транзакції за датою (формат «12 січня 2025»).
  Map<String, List<Transaction>> groupByDate() {
    return Transaction.groupByDate(_transactions);
  }

  /// Групує транзакції за типом.
  Map<TransactionType, List<Transaction>> groupByType() {
    final map = <TransactionType, List<Transaction>>{};
    for (final t in _transactions) {
      map.putIfAbsent(t.type, () => []).add(t);
    }
    return map;
  }

  /// Групує транзакції за цілю.
  Map<String, List<Transaction>> groupByGoal() {
    final map = <String, List<Transaction>>{};
    for (final t in _transactions) {
      map.putIfAbsent(t.goalId, () => []).add(t);
    }
    return map;
  }

  /// Групує транзакції за місяцем (формат «2025-01»).
  Map<String, List<Transaction>> groupByMonth() {
    final map = <String, List<Transaction>>{};
    for (final t in _transactions) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  /// Групує транзакції за тижнем.
  Map<String, List<Transaction>> groupByWeek() {
    final map = <String, List<Transaction>>{};
    for (final t in _transactions) {
      final weekStart =
          t.createdAt.subtract(Duration(days: t.createdAt.weekday - 1));
      final key =
          '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  // ─── Дані для графіків ─────────────────────────────────────────────

  /// Дані для лінійного графіка (щоденні суми за [days] днів).
  List<Map<String, dynamic>> chartDataDaily({int days = 30}) {
    final summary = dailySummary(days: days);
    final keys = summary.keys.toList()..sort();
    return keys.map((key) {
      return {'date': key, 'amount': summary[key]};
    }).toList();
  }

  /// Дані для стовпчикового графіка (типи транзакцій).
  List<Map<String, dynamic>> chartDataByType() {
    final byType = groupByType();
    return byType.entries.map((entry) {
      return {
        'type': entry.key.label,
        'typeKey': entry.key.name,
        'amount': entry.value.fold(0.0, (sum, t) => sum + t.amount),
        'count': entry.value.length,
      };
    }).toList();
  }

  /// Дані для кругової діаграми (розподіл за цілями).
  List<Map<String, dynamic>> chartDataByGoal() {
    final byGoal = groupByGoal();
    return byGoal.entries.map((entry) {
      return {
        'goalId': entry.key,
        'amount': entry.value.fold(0.0, (sum, t) => sum + t.amount),
        'count': entry.value.length,
      };
    }).toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }

  /// Дані для графіка тенденцій (тижневі суми).
  List<Map<String, dynamic>> chartDataWeekly({int weeks = 12}) {
    final summary = weeklySummary(weeks: weeks);
    final keys = summary.keys.toList()..sort();
    return keys.map((key) {
      return {'week': key, 'amount': summary[key]};
    }).toList();
  }

  /// Дані для графіка тенденцій (місячні суми).
  List<Map<String, dynamic>> chartDataMonthly({int months = 12}) {
    final summary = monthlySummary(months: months);
    final keys = summary.keys.toList()..sort();
    return keys.map((key) {
      return {'month': key, 'amount': summary[key]};
    }).toList();
  }

  // ─── Експорт / Імпорт ─────────────────────────────────────────────

  /// Експортує транзакції у CSV-формат з заголовком.
  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Ціль ID,Тип,Сума,Дата,Коментар,XP,Монети');

    final transactions = getAll();
    for (final t in transactions) {
      final date = t.createdAt.toIso8601String();
      final comment = t.comment?.replaceAll('"', '""') ?? '';
      final line = [
        t.id,
        t.goalId,
        t.type.name,
        t.amount.toStringAsFixed(2),
        date,
        comment,
        t.xpEarned,
        t.coinsEarned,
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Експортує транзакції для конкретної цілі у CSV.
  String exportToCsvForGoal(String goalId) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Тип,Сума,Дата,Коментар,XP,Монети');

    final transactions = getByGoalId(goalId);
    for (final t in transactions) {
      final date = t.createdAt.toIso8601String();
      final comment = t.comment?.replaceAll('"', '""') ?? '';
      final line = [
        t.id,
        t.type.name,
        t.amount.toStringAsFixed(2),
        date,
        comment,
        t.xpEarned,
        t.coinsEarned,
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Експортує транзакції за діапазон дат у CSV.
  String exportToCsvByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Тип,Сума,Дата,Коментар,XP,Монети');

    final transactions = filterByDateRange(from: from, to: to);
    for (final t in transactions) {
      final date = t.createdAt.toIso8601String();
      final comment = t.comment?.replaceAll('"', '""') ?? '';
      final line = [
        t.id,
        t.type.name,
        t.amount.toStringAsFixed(2),
        date,
        comment,
        t.xpEarned,
        t.coinsEarned,
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Повертає кількість рядків у CSV-експорті.
  int get csvRowCount => count + 1; // +1 для заголовка

  /// Повертає статистичний зведення репозиторію.
  Map<String, dynamic> get statistics {
    return {
      'totalAmount': totalAmount,
      'totalCount': count,
      'averageAmount': averageAmount,
      'medianAmount': medianAmount,
      'maxAmount': maxAmount,
      'minAmount': minAmount,
      'standardDeviation': standardDeviation,
      'totalXpEarned': totalXpEarned,
      'totalCoinsEarned': totalCoinsEarned,
      'hasDuplicates': findDuplicates().isNotEmpty,
      'duplicateGroups': findDuplicates().length,
    };
  }

  // ─── Приватні методи ───────────────────────────────────────────────

  /// Додає транзакцію в стек undo з обмеженням глибини.
  void _addToUndoStack(Transaction transaction) {
    if (_undoStack.length >= _maxUndoDepth) {
      _undoStack.removeAt(0);
    }
    _undoStack.add(transaction);
  }
}

// Імпорт для math.sqrt
import 'dart:math' as math;
