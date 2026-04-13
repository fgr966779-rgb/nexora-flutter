import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// Стан дашборду.
class DashboardState {
  /// Поточна активна ціль (null, якщо немає).
  final Goal? goal;

  /// Останні транзакції.
  final List<Transaction> recentTransactions;

  /// Усі транзакції для розрахунків.
  final List<Transaction> allTransactions;

  /// Поточна серія днів поспіль.
  final int currentStreak;

  /// Найбільша серія днів.
  final int longestStreak;

  /// Загальний XP користувача.
  final int xp;

  /// Загальна кількість монет.
  final int coins;

  /// Поточний рівень користувача.
  final int level;

  /// Чи завантажуються дані.
  final bool isLoading;

  /// Чи оновлюється дані (pull-to-refresh).
  final bool isRefreshing;

  /// Помилка (якщо є).
  final String? error;

  /// Адаптивний настрій дашборду.
  final DashboardMood mood;

  /// Термін пошуку транзакцій.
  final String searchQuery;

  /// Сортування транзакцій.
  final TransactionSortOption sortBy;

  /// Фільтр типу транзакцій.
  final TransactionType? filterByType;

  /// Кількість непрочитаних сповіщень.
  final int notificationBadgeCount;

  /// Список цілей користувача (включаючи завершені).
  final List<Goal> allGoals;

  /// Чи увімкнено режим реального часу.
  final bool isRealTimeEnabled;

  /// Остання активність користувача.
  final DateTime? lastActivityAt;

  /// Загальна кількість внесків за весь час.
  final int totalDepositsCount;

  /// Кількість завершених цілей.
  final int completedGoalsCount;

  /// Чи показувати поради по заощадженнях.
  final bool showSavingTips;

  /// Остання порада з заощаджень.
  final String? currentSavingTip;

  const DashboardState({
    this.goal,
    this.recentTransactions = const [],
    this.allTransactions = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xp = 0,
    this.coins = 0,
    this.level = 0,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.mood = DashboardMood.normal,
    this.searchQuery = '',
    this.sortBy = TransactionSortOption.newest,
    this.filterByType,
    this.notificationBadgeCount = 0,
    this.allGoals = const [],
    this.isRealTimeEnabled = true,
    this.lastActivityAt,
    this.totalDepositsCount = 0,
    this.completedGoalsCount = 0,
    this.showSavingTips = true,
    this.currentSavingTip,
  });

  DashboardState copyWith({
    Goal? goal,
    List<Transaction>? recentTransactions,
    List<Transaction>? allTransactions,
    int? currentStreak,
    int? longestStreak,
    int? xp,
    int? coins,
    int? level,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DashboardMood? mood,
    String? searchQuery,
    TransactionSortOption? sortBy,
    TransactionType? filterByType,
    int? notificationBadgeCount,
    List<Goal>? allGoals,
    bool? isRealTimeEnabled,
    DateTime? lastActivityAt,
    bool clearLastActivity = false,
    int? totalDepositsCount,
    int? completedGoalsCount,
    bool? showSavingTips,
    String? currentSavingTip,
    bool clearTip = false,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return DashboardState(
      goal: goal ?? this.goal,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      allTransactions: allTransactions ?? this.allTransactions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      mood: mood ?? this.mood,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      filterByType: clearFilter ? null : (filterByType ?? this.filterByType),
      notificationBadgeCount: notificationBadgeCount ?? this.notificationBadgeCount,
      allGoals: allGoals ?? this.allGoals,
      isRealTimeEnabled: isRealTimeEnabled ?? this.isRealTimeEnabled,
      lastActivityAt: clearLastActivity ? null : (lastActivityAt ?? this.lastActivityAt),
      totalDepositsCount: totalDepositsCount ?? this.totalDepositsCount,
      completedGoalsCount: completedGoalsCount ?? this.completedGoalsCount,
      showSavingTips: showSavingTips ?? this.showSavingTips,
      currentSavingTip: clearTip ? null : (currentSavingTip ?? this.currentSavingTip),
    );
  }
}

/// Опції сортування транзакцій.
enum TransactionSortOption {
  /// Найновіші перші.
  newest,

  /// Найстаріші перші.
  oldest,

  /// За сумою (від більшої до меншої).
  amountHigh,

  /// За сумою (від меншої до більшої).
  amountLow,

  /// За XP (від більшого до меншого).
  xpHigh,
}

/// Подія аналітики дашборду.
class DashboardAnalyticsEvent {
  /// Тип події.
  final String type;

  /// Параметри події.
  final Map<String, dynamic> data;

  const DashboardAnalyticsEvent({required this.type, required this.data});
}

/// Нотифікатор для керування станом дашборду.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final GoalRepository _goalRepo;
  final TransactionRepository _transactionRepo;
  final UserRepository _userRepo;

  /// Таймер для періодичного оновлення даних.
  Timer? _realTimeTimer;

  /// Стрім подій аналітики дашборду.
  final _analyticsController =
      StreamController<DashboardAnalyticsEvent>.broadcast();

  /// Поради щодо заощаджень.
  static const List<String> _savingTips = [
    '💰 Спробуйте відкладати 10% від кожного доходу',
    '🎯 Встановіть автоматичний внесок для кращої дисципліни',
    '📊 Порівнюйте результати кожного тижня',
    '🔥 Тримайте серію внесків для бонусного XP',
    '⭐ Приймайте виклики для додаткових монет',
    '📅 Заплануйте свій бюджет на місяць наперед',
    '💡 Округлюйте залишки — це маленькі внески з великим ефектом',
    '🏆 Змагайтеся з друзями за кращі результати',
  ];

  DashboardNotifier({
    required GoalRepository goalRepo,
    required TransactionRepository transactionRepo,
    required UserRepository userRepo,
  })  : _goalRepo = goalRepo,
        _transactionRepo = transactionRepo,
        _userRepo = userRepo,
        super(const DashboardState()) {
    _startRealTimeUpdates();
  }

  // ─── Стрім аналітики ────────────────────────────────────

  /// Стрім подій аналітики дашборду.
  Stream<DashboardAnalyticsEvent> get analyticsStream =>
      _analyticsController.stream;

  /// Emitує подію аналітики.
  void _emitAnalytics(String type, [Map<String, dynamic>? data]) {
    if (!_analyticsController.isClosed) {
      _analyticsController.add(
        DashboardAnalyticsEvent(type: type, data: data ?? {}),
      );
    }
  }

  // ─── Основне завантаження ─────────────────────────────────

  /// Завантажує всі дані для дашборду.
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final goal = _goalRepo.getActiveGoal();
      final allGoals = _goalRepo.getAll();
      final user = _userRepo.getUser();
      final allTx = _transactionRepo.getAll();
      final recentTx = allTx.length > 10 ? allTx.sublist(0, 10) : allTx;

      int currentStreak = 0;
      int longestStreak = 0;

      if (goal != null) {
        final streakData = StreakCalculator.updateStreak(goal);
        currentStreak = streakData['current']!;
        longestStreak = streakData['longest']!;
      }

      final levelData = XPCalculator.checkLevelUp(user.xp);
      final level = levelData?['newLevel'] as int? ?? user.currentLevel;

      final mood = calculateMood(goal, allTx);
      final badgeCount = _calculateNotificationBadgeCount(goal, allTx, user);
      final completedGoals = allGoals.where((g) => g.isCompleted).length;

      final tip = _getRandomSavingTip();

      state = state.copyWith(
        goal: goal,
        allGoals: allGoals,
        recentTransactions: recentTx,
        allTransactions: allTx,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        xp: user.xp,
        coins: user.coins,
        level: level,
        isLoading: false,
        mood: mood,
        notificationBadgeCount: badgeCount,
        lastActivityAt: user.lastActiveDate,
        totalDepositsCount: allTx.length,
        completedGoalsCount: completedGoals,
        currentSavingTip: tip,
      );

      _emitAnalytics('dashboard_loaded', {
        'has_goal': goal != null,
        'streak': currentStreak,
        'level': level,
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Помилка завантаження: $e',
      );
      _emitAnalytics('dashboard_error', {'error': e.toString()});
    }
  }

  /// Оновлює дані дашборду (без індикатора завантаження).
  Future<void> refreshData() async {
    try {
      final goal = _goalRepo.getActiveGoal();
      final allGoals = _goalRepo.getAll();
      final user = _userRepo.getUser();
      final allTx = _transactionRepo.getAll();
      final recentTx = allTx.length > 10 ? allTx.sublist(0, 10) : allTx;

      int currentStreak = 0;
      int longestStreak = 0;

      if (goal != null) {
        final streakData = StreakCalculator.updateStreak(goal);
        currentStreak = streakData['current']!;
        longestStreak = streakData['longest']!;
      }

      final levelData = XPCalculator.checkLevelUp(user.xp);
      final level = levelData?['newLevel'] as int? ?? user.currentLevel;

      final mood = calculateMood(goal, allTx);
      final badgeCount = _calculateNotificationBadgeCount(goal, allTx, user);
      final completedGoals = allGoals.where((g) => g.isCompleted).length;

      state = state.copyWith(
        goal: goal,
        allGoals: allGoals,
        recentTransactions: recentTx,
        allTransactions: allTx,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        xp: user.xp,
        coins: user.coins,
        level: level,
        mood: mood,
        clearError: true,
        notificationBadgeCount: badgeCount,
        totalDepositsCount: allTx.length,
        completedGoalsCount: completedGoals,
      );
    } catch (e) {
      // Тихо ігноруємо помилки при фоновому оновленні.
    }
  }

  /// Імітує pull-to-refresh з затримкою.
  Future<void> pullToRefresh() async {
    state = state.copyWith(isRefreshing: true);
    _emitAnalytics('pull_to_refresh');
    // Імітація затримки мережі.
    await Future.delayed(const Duration(milliseconds: 1200));
    await loadDashboard();
    state = state.copyWith(isRefreshing: false);
  }

  // ─── Реальний час ─────────────────────────────────────────

  /// Запускає періодичне оновлення даних у реальному часі.
  void _startRealTimeUpdates() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (state.isRealTimeEnabled && !state.isLoading && mounted) {
          refreshData();
        }
      },
    );
  }

  /// Перемикає режим реального часу.
  void toggleRealTimeUpdates() {
    final newValue = !state.isRealTimeEnabled;
    state = state.copyWith(isRealTimeEnabled: newValue);
    if (newValue) {
      _startRealTimeUpdates();
    } else {
      _realTimeTimer?.cancel();
    }
    _emitAnalytics('real_time_toggled', {'enabled': newValue});
  }

  // ─── Статистика за періоди ────────────────────────────────

  /// Загальна сума внесків за сьогодні.
  double get todayTotalDeposits {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.allTransactions
        .where((t) => t.createdAt.isAfter(today) || t.createdAt.isAtSameMomentAs(today))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Кількість внесків за сьогодні.
  int get todayDepositCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return state.allTransactions
        .where((t) => t.createdAt.isAfter(today) || t.createdAt.isAtSameMomentAs(today))
        .length;
  }

  /// Загальна сума внесків за цей тиждень.
  double get thisWeekTotalDeposits {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return state.allTransactions
        .where((t) => t.createdAt.isAfter(monday) || t.createdAt.isAtSameMomentAs(monday))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Загальна сума внесків за цей місяць.
  double get thisMonthTotalDeposits {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return state.allTransactions
        .where((t) => t.createdAt.isAfter(monthStart) || t.createdAt.isAtSameMomentAs(monthStart))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Загальна сума внесків за минулий місяць.
  double get lastMonthTotalDeposits {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    return state.allTransactions
        .where((t) => t.createdAt.isAfter(lastMonthStart) && t.createdAt.isBefore(thisMonthStart))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Різниця між цим та минулим місяцем у відсотках.
  double get monthOverMonthGrowth {
    final lastMonth = lastMonthTotalDeposits;
    if (lastMonth <= 0) return thisMonthTotalDeposits > 0 ? 100.0 : 0.0;
    final thisMonth = thisMonthTotalDeposits;
    return ((thisMonth - lastMonth) / lastMonth * 100);
  }

  /// Середній розмір внеску.
  double get averageDeposit {
    final deposits = state.allTransactions.where((t) => t.amount > 0).toList();
    if (deposits.isEmpty) return 0;
    final total = deposits.fold<double>(0, (sum, t) => sum + t.amount);
    return total / deposits.length;
  }

  /// Середній розмір внеску за останні 7 днів.
  double get weeklyAverageDeposit {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recent = state.allTransactions
        .where((t) => t.createdAt.isAfter(weekAgo))
        .toList();
    if (recent.isEmpty) return 0;
    final total = recent.fold<double>(0, (sum, t) => sum + t.amount);
    return total / recent.length;
  }

  /// Найкращий день (найбільша сума внесків за один день).
  String get bestDay {
    if (state.allTransactions.isEmpty) return 'Ще немає';

    final dailyTotals = <String, double>{};
    for (final tx in state.allTransactions) {
      final key = '${tx.createdAt.year}-${tx.createdAt.month}-${tx.createdAt.day}';
      dailyTotals[key] = (dailyTotals[key] ?? 0) + tx.amount;
    }

    if (dailyTotals.isEmpty) return 'Ще немає';

    String bestDateKey = '';
    double bestAmount = 0;
    for (final entry in dailyTotals.entries) {
      if (entry.value > bestAmount) {
        bestAmount = entry.value;
        bestDateKey = entry.key;
      }
    }

    if (bestDateKey.isEmpty) return 'Ще немає';
    final parts = bestDateKey.split('-');
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  /// Найкраща денна сума.
  double get bestDayAmount {
    if (state.allTransactions.isEmpty) return 0;

    final dailyTotals = <String, double>{};
    for (final tx in state.allTransactions) {
      final key = '${tx.createdAt.year}-${tx.createdAt.month}-${tx.createdAt.day}';
      dailyTotals[key] = (dailyTotals[key] ?? 0) + tx.amount;
    }

    return dailyTotals.values.fold<double>(0, (max, v) => v > max ? v : max);
  }

  /// Загальна кількість транзакцій (записів внесків).
  int get totalContributors => state.allTransactions.length;

  /// Загальна сума всіх внесків.
  double get totalAmount {
    return state.allTransactions.fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Загальний XP отриманий за всі транзакції.
  int get totalXpFromDeposits {
    return state.allTransactions.fold<int>(0, (sum, t) => sum + t.xpEarned);
  }

  /// Загальні монети отримані за всі транзакції.
  int get totalCoinsFromDeposits {
    return state.allTransactions.fold<int>(0, (sum, t) => sum + t.coinsEarned);
  }

  // ─── Розклад дашборду ─────────────────────────────────────

  /// Повертає розклад внесків за останні 7 днів.
  List<Map<String, dynamic>> get weeklyDepositChart {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTotal = state.allTransactions
          .where((t) => t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(dayEnd))
          .fold<double>(0, (sum, t) => sum + t.amount);

      result.add({
        'day': _getWeekdayName(day.weekday),
        'amount': dayTotal,
        'count': state.allTransactions
            .where((t) => t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(dayEnd))
            .length,
      });
    }

    return result;
  }

  /// Повертає назву дня тижня українською.
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Пн';
      case 2:
        return 'Вт';
      case 3:
        return 'Ср';
      case 4:
        return 'Чт';
      case 5:
        return 'Пт';
      case 6:
        return 'Сб';
      case 7:
        return 'Нд';
      default:
        return '';
    }
  }

  // ─── Внесок ───────────────────────────────────────────────

  /// Додає внесок до цілі.
  /// [isSilent] — якщо true, не активує глобальний індикатор завантаження (скелетон).
  Future<bool> addDeposit(double amount, {String? comment, bool isSilent = false}) async {
    final goal = state.goal;
    if (goal == null) {
      state = state.copyWith(error: 'Немає активної цілі');
      return false;
    }

    if (!isSilent) {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = _userRepo.getUser();
      final isFirst = _transactionRepo.count == 0;
      final xpEarned = XPCalculator.calculateXp(
        TransactionType.manual,
        isFirstDeposit: isFirst,
        streakDays: goal.streakDays,
      );
      final coinsEarned = XPCalculator.calculateCoins(
        TransactionType.manual,
        leveledUp: user.currentLevel < XPCalculator.getLevelForXp(user.xp + xpEarned),
      );

      final transaction = Transaction(
        id: const Uuid().v4(),
        goalId: goal.id,
        type: TransactionType.manual,
        amount: amount,
        createdAt: DateTime.now(),
        comment: comment,
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
      );

      _transactionRepo.save(transaction);

      // Оновлюємо ціль.
      goal.currentAmount += amount;
      goal.lastDepositDate = DateTime.now();
      goal.streakDays = StreakCalculator.updateStreak(goal)['current']!;
      if (goal.streakDays > goal.longestStreak) {
        goal.longestStreak = goal.streakDays;
      }

      // Перевіряємо досягнення цілі.
      bool goalReached = false;
      if (goal.currentAmount >= goal.targetAmount) {
        goal.status = GoalStatus.completed;
        goal.completedAt = DateTime.now();
        goalReached = true;
      }

      _goalRepo.updateGoal(goal);

      // Оновлюємо користувача.
      final leveledUp = user.addXp(xpEarned);
      user.addCoins(coinsEarned);
      user.lastActiveDate = DateTime.now();
      _userRepo.save(user);

      // Оновлюємо дані локально для миттєвого відгуку, якщо це "тихий" внесок
      if (isSilent) {
        await refreshData();
      } else {
        await loadDashboard();
      }

      _emitAnalytics('deposit_added', {
        'amount': amount,
        'goal_id': goal.id,
        'xp_earned': xpEarned,
        'coins_earned': coinsEarned,
        'leveled_up': leveledUp,
        'goal_reached': goalReached,
      });
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Помилка внеску: $e',
      );
      return false;
    }
  }

  /// Розморожує ціль (додає бонусний внесок після тривалої паузи).
  Future<void> unfreeze() async {
    final goal = state.goal;
    if (goal == null || !goal.needsUnfreeze) return;

    state = state.copyWith(mood: DashboardMood.unfreezing);

    // Нараховуємо бонус повернення.
    final bonusXp = XPCalculator.calculateXp(TransactionType.returnBonus);
    final user = _userRepo.getUser();
    user.addXp(bonusXp);
    _userRepo.save(user);

    _emitAnalytics('goal_unfreezed', {
      'goal_id': goal.id,
      'bonus_xp': bonusXp,
    });

    await loadDashboard();
  }

  // ─── Швидкі дії ──────────────────────────────────────────

  /// Швидкий внесок на стандартну суму без блокування інтерфейсу.
  Future<bool> quickDeposit(double amount) async {
    return await addDeposit(amount, isSilent: true);
  }

  /// Перемикає показ порад щодо заощаджень.
  void toggleSavingTips() {
    state = state.copyWith(showSavingTips: !state.showSavingTips);
  }

  /// Показує наступну пораду.
  void showNextTip() {
    final tip = _getRandomSavingTip();
    state = state.copyWith(currentSavingTip: tip);
  }

  /// Повертає випадкову пораду щодо заощаджень.
  String? _getRandomSavingTip() {
    if (_savingTips.isEmpty) return null;
    return _savingTips[DateTime.now().millisecond % _savingTips.length];
  }

  // ─── Прогрес підцілей ─────────────────────────────────────

  /// Повертає список прогресів підцілей.
  List<Map<String, dynamic>> get subGoalProgressUpdates {
    final goal = state.goal;
    if (goal == null || goal.subGoals.isEmpty) return [];

    return goal.subGoals.map((sub) {
      return {
        'id': sub.id,
        'name': sub.name,
        'currentAmount': sub.currentAmount,
        'targetAmount': sub.targetAmount,
        'progress': sub.progress,
        'isCompleted': sub.isCompleted,
        'remaining': sub.remaining,
      };
    }).toList();
  }

  /// Оновлює прогрес підцілі після внеску.
  void updateSubGoalProgress(double depositAmount) {
    final goal = state.goal;
    if (goal == null) return;

    for (final sub in goal.subGoals) {
      if (sub.isCompleted) continue;

      // Додаємо суму до підцілі, якщо вона ще не завершена.
      if (sub.currentAmount < sub.targetAmount) {
        final newAmount = sub.currentAmount + depositAmount;
        sub.currentAmount = newAmount.clamp(0, sub.targetAmount);
        break; // Додаємо лише до наступної незавершеної підцілі.
      }
    }

    _goalRepo.updateGoal(goal);
  }

  // ─── Пошук та фільтрація ──────────────────────────────────

  /// Встановлює пошуковий запит.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Встановлює порядок сортування.
  void setSortOption(TransactionSortOption option) {
    state = state.copyWith(sortBy: option);
  }

  /// Встановлює фільтр типу транзакцій.
  void setFilterType(TransactionType? type) {
    state = state.copyWith(filterByType: type, clearFilter: type == null);
  }

  /// Скидає всі фільтри та пошук.
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      sortBy: TransactionSortOption.newest,
      clearFilter: true,
    );
  }

  /// Повертає відфільтрований та відсортований список транзакцій.
  List<Transaction> get filteredTransactions {
    var transactions = List<Transaction>.from(state.recentTransactions);

    // Фільтр за типом.
    if (state.filterByType != null) {
      transactions = transactions
          .where((t) => t.type == state.filterByType)
          .toList();
    }

    // Пошук за коментарем.
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      transactions = transactions
          .where((t) =>
              (t.comment?.toLowerCase().contains(query) ?? false) ||
              t.amount.toString().contains(query) ||
              t.type.label.toLowerCase().contains(query))
          .toList();
    }

    // Сортування.
    switch (state.sortBy) {
      case TransactionSortOption.newest:
        transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TransactionSortOption.oldest:
        transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case TransactionSortOption.amountHigh:
        transactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSortOption.amountLow:
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case TransactionSortOption.xpHigh:
        transactions.sort((a, b) => b.xpEarned.compareTo(a.xpEarned));
        break;
    }

    return transactions;
  }

  // ─── Агрегація сповіщень ──────────────────────────────────

  /// Повертає список активних сповіщень для дашборду.
  List<Map<String, dynamic>> get activeNotifications {
    final notifications = <Map<String, dynamic>>[];
    final goal = state.goal;

    // Нагадування про розморожування.
    if (goal != null && goal.needsUnfreeze) {
      notifications.add({
        'type': 'unfreeze',
        'title': 'Час розморозити ціль!',
        'message': 'Ваша ціль «${goal.name}» заморожена. Зробіть внесок!',
        'icon': Icons.ac_unit,
        'priority': 3,
      });
    }

    // Нагадування про заморожену ціль.
    if (goal != null && goal.isFrozen && !goal.needsUnfreeze) {
      notifications.add({
        'type': 'frozen_warning',
        'title': 'Ціль заморожується',
        'message': 'Зробіть внесок протягом ${7 - (goal.frozenDays ?? 0)} днів',
        'icon': Icons.snowing,
        'priority': 2,
      });
    }

    // Близько до цілі (>80%).
    if (goal != null && goal.isAlmostThere && !goal.isCompleted) {
      notifications.add({
        'type': 'almost_there',
        'title': 'Майже досягли!',
        'message': 'Вже ${(goal.progress * 100).toStringAsFixed(0)}% цілі «${goal.name}»!',
        'icon': Icons.flag,
        'priority': 1,
      });
    }

    // Повідомлення про серію.
    if (state.currentStreak >= 3) {
      notifications.add({
        'type': 'streak',
        'title': 'Серія ${state.currentStreak} днів! 🔥',
        'message': 'Не зупиняйтеся — продовжуйте накопичувати!',
        'icon': Icons.local_fire_department,
        'priority': 1,
      });
    }

    return notifications;
  }

  // ─── Настрій дашборду ─────────────────────────────────────

  /// Визначає настрій дашборду на основі різних факторів.
  DashboardMood calculateMood(Goal? goal, List<Transaction> recentTx) {
    if (goal == null) return DashboardMood.normal;

    // Ціль досягнута.
    if (goal.isCompleted) return DashboardMood.completed;

    // Майже досягнуто (>90%).
    if (goal.progress >= 0.9) return DashboardMood.almostThere;

    // Заморожена (>7 днів без внесків).
    if (goal.isFrozen) return DashboardMood.frozen;

    // Перевіряємо частоту депозитів за останні 3 дні.
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final recentCount = recentTx
        .where((t) => t.createdAt.isAfter(threeDaysAgo))
        .length;

    // Швидкий прогрес — 3+ внески за 3 дні.
    if (recentCount >= 3) return DashboardMood.fastProgress;

    return DashboardMood.normal;
  }

  /// Повертає опис настрою дашборду українською.
  String get moodDescription {
    switch (state.mood) {
      case DashboardMood.normal:
        return 'Продовжуйте накопичувати!';
      case DashboardMood.fastProgress:
        return 'Вражаючий прогрес!';
      case DashboardMood.almostThere:
        return 'Майже на місці!';
      case DashboardMood.frozen:
        return 'Час зробити внесок...';
      case DashboardMood.completed:
        return '🎉 Ціль досягнуто!';
      case DashboardMood.unfreezing:
        return 'Розморожуємо ціль...';
    }
  }

  // ─── Нотифікації ──────────────────────────────────────────

  /// Обчислює кількість непрочитаних сповіщень.
  int _calculateNotificationBadgeCount(
    Goal? goal,
    List<Transaction> transactions,
    UserProfile user,
  ) {
    int count = 0;

    // Нагадування про розморожування.
    if (goal != null && goal.needsUnfreeze) {
      count++;
    }

    // Нагадування про заморожену ціль.
    if (goal != null && goal.isFrozen && !goal.needsUnfreeze) {
      count++;
    }

    // Близько до цілі (>80%).
    if (goal != null && goal.isAlmostThere && !goal.isCompleted) {
      count++;
    }

    // Бейджі для розблокування.
    if (user.currentStreak == 7 && !user.hasBadge('weeklyStreak')) {
      count++;
    }
    if (user.currentStreak == 30 && !user.hasBadge('monthlyMarathon')) {
      count++;
    }

    return count;
  }

  // ─── Допоміжні методи ─────────────────────────────────────

  /// Повертає форматовану суму цілі.
  String get formattedGoalAmount {
    final goal = state.goal;
    if (goal == null) return '0 ₴';
    return '${_formatNumber(goal.currentAmount.toInt())} / ${_formatNumber(goal.targetAmount.toInt())} ₴';
  }

  /// Повертає форматовану залишкову суму.
  String get formattedRemaining {
    final goal = state.goal;
    if (goal == null) return '—';
    return '${_formatNumber(goal.remaining.toInt())} ₴';
  }

  /// Повертає прогрес цілі у відсотках.
  String get formattedProgress {
    final goal = state.goal;
    if (goal == null) return '0%';
    return '${(goal.progress * 100).toStringAsFixed(1)}%';
  }

  /// Повертає кількість днів з початку цілі.
  int get daysSinceGoalStart {
    final goal = state.goal;
    if (goal == null) return 0;
    return DateTime.now().difference(goal.createdAt).inDays;
  }

  /// Повертає форматовану тривалість цілі.
  String get goalDuration {
    final days = daysSinceGoalStart;
    if (days < 1) return 'Почато сьогодні';
    if (days < 7) return '$days дн.';
    if (days < 30) return '${(days / 7).floor()} тижн.';
    if (days < 365) return '${(days / 30).floor()} міс.';
    return '${(days / 365).floor()} р.';
  }

  /// Форматує число з пробілами між тисячами.
  String _formatNumber(int number) {
    if (number == 0) return '0';
    final buffer = StringBuffer();
    final chars = number.abs().toString().split('').reversed.toList();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(chars[i]);
    }
    final result = buffer.toString().split('').reversed.join();
    return number < 0 ? '-$result' : result;
  }

  // ─── Звільнення ресурсів ──────────────────────────────────

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _analyticsController.close();
    super.dispose();
  }
}

// ─── Провайдери залежностей ─────────────────────────────────────────

/// Провайдер для GoalRepository.
final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(),
);

/// Провайдер для TransactionRepository.
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

/// Провайдер для UserRepository.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

// ─── Головний провайдер дашборду ────────────────────────────────────

/// Riverpod провайдер для стану дашборду.
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(
    goalRepo: ref.watch(goalRepositoryProvider),
    transactionRepo: ref.watch(transactionRepositoryProvider),
    userRepo: ref.watch(userRepositoryProvider),
  ),
);
