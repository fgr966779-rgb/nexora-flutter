import 'dart:async';
import 'dart:math' as math;

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

/// Мінімальна сума внеску (грн).
const double _minDeposit = 10.0;

/// Максимальна сума внеску (грн).
const double _maxDeposit = 100000.0;

/// Пресети швидкого внеску (грн).
const List<double> _quickDepositPresets = [50.0, 100.0, 250.0, 500.0, 1000.0];

/// Максимальна кількість записів історії депозитів.
const int _maxHistorySize = 50;

/// Стан форми внеску.
class DepositState {
  /// Сума внеску.
  final double amount;

  /// Коментар до внеску.
  final String comment;

  /// Чи обробляється внесок наразі.
  final bool isProcessing;

  /// Чи є форма валідною для відправки.
  final bool isValid;

  /// Повідомлення про помилку валідації.
  final String? errorMessage;

  /// Історія депозитів поточної сесії.
  final List<DepositRecord> depositHistory;

  /// Сума останнього скасованого внеску (для можливості скасування).
  final double? lastUndoneAmount;

  /// Успішне повідомлення після внеску.
  final String? successMessage;

  /// Попередній залишок на рахунку (до останнього внеску).
  final double previousBalance;

  /// XP отримано за останній внесок.
  final int lastXpEarned;

  /// Монети отримано за останній внесок.
  final int lastCoinsEarned;

  /// Чи відбулося підвищення рівня.
  final bool didLevelUp;

  /// Повідомлення про ліміт (попередження).
  final String? limitWarning;

  /// Дозволене залишкове відхилення від ліміту.
  final double? depositLimitRemaining;

  /// Заплановані депозити (для повторюваних внесків).
  final List<ScheduledDeposit> scheduledDeposits;

  const DepositState({
    this.amount = 0,
    this.comment = '',
    this.isProcessing = false,
    this.isValid = false,
    this.errorMessage,
    this.depositHistory = const [],
    this.lastUndoneAmount,
    this.successMessage,
    this.previousBalance = 0,
    this.lastXpEarned = 0,
    this.lastCoinsEarned = 0,
    this.didLevelUp = false,
    this.limitWarning,
    this.depositLimitRemaining,
    this.scheduledDeposits = const [],
  });

  DepositState copyWith({
    double? amount,
    String? comment,
    bool? isProcessing,
    bool? isValid,
    String? errorMessage,
    List<DepositRecord>? depositHistory,
    double? lastUndoneAmount,
    String? successMessage,
    double? previousBalance,
    int? lastXpEarned,
    int? lastCoinsEarned,
    bool? didLevelUp,
    String? limitWarning,
    double? depositLimitRemaining,
    List<ScheduledDeposit>? scheduledDeposits,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearUndone = false,
    bool clearLimitWarning = false,
  }) {
    return DepositState(
      amount: amount ?? this.amount,
      comment: comment ?? this.comment,
      isProcessing: isProcessing ?? this.isProcessing,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      depositHistory: depositHistory ?? this.depositHistory,
      lastUndoneAmount: clearUndone ? null : (lastUndoneAmount ?? this.lastUndoneAmount),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      previousBalance: previousBalance ?? this.previousBalance,
      lastXpEarned: lastXpEarned ?? this.lastXpEarned,
      lastCoinsEarned: lastCoinsEarned ?? this.lastCoinsEarned,
      didLevelUp: didLevelUp ?? this.didLevelUp,
      limitWarning: clearLimitWarning ? null : (limitWarning ?? this.limitWarning),
      depositLimitRemaining: depositLimitRemaining ?? this.depositLimitRemaining,
      scheduledDeposits: scheduledDeposits ?? this.scheduledDeposits,
    );
  }
}

/// Запис про здійснений депозит.
class DepositRecord {
  /// ID транзакції.
  final String transactionId;

  /// Сума внеску.
  final double amount;

  /// Тип транзакції.
  final TransactionType type;

  /// Коментар до внеску.
  final String? comment;

  /// Час здійснення.
  final DateTime timestamp;

  /// XP, отриманий за цей внесок.
  final int xpEarned;

  /// Монети, отримані за цей внесок.
  final int coinsEarned;

  /// Чи було підвищення рівня.
  final bool leveledUp;

  const DepositRecord({
    required this.transactionId,
    required this.amount,
    required this.type,
    this.comment,
    required this.timestamp,
    this.xpEarned = 0,
    this.coinsEarned = 0,
    this.leveledUp = false,
  });

  /// Форматована сума запису (наприклад, «500 ₴»).
  String get formattedAmount => '${amount.toInt()} ₴';

  /// Чи цей депозит є першим у сесії.
  bool get isFirstInSession => false;
}

/// Запланований повторюваний депозит.
class ScheduledDeposit {
  /// ID запланованого депозиту.
  final String id;

  /// Сума депозиту.
  final double amount;

  /// Частота повторення.
  final DepositFrequency frequency;

  /// Коментар.
  final String? comment;

  /// Чи активний.
  final bool isActive;

  /// Дата створення.
  final DateTime createdAt;

  /// Дата останнього виконання.
  final DateTime? lastExecutedAt;

  /// Кількість виконань.
  int executionCount;

  const ScheduledDeposit({
    required this.id,
    required this.amount,
    required this.frequency,
    this.comment,
    this.isActive = true,
    required this.createdAt,
    this.lastExecutedAt,
    this.executionCount = 0,
  });

  ScheduledDeposit copyWith({
    bool? isActive,
    DateTime? lastExecutedAt,
    int? executionCount,
  }) {
    return ScheduledDeposit(
      id: id,
      amount: amount,
      frequency: frequency,
      comment: comment,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      executionCount: executionCount ?? this.executionCount,
    );
  }
}

/// Частота повторення депозиту.
enum DepositFrequency {
  /// Щодня.
  daily,

  /// Раз на тиждень.
  weekly,

  /// Двічі на місяць.
  biweekly,

  /// Раз на місяць.
  monthly,

  /// Раз на рік.
  yearly,
}

/// Опис частоти українською.
String depositFrequencyLabel(DepositFrequency frequency) {
  switch (frequency) {
    case DepositFrequency.daily:
      return 'Щодня';
    case DepositFrequency.weekly:
      return 'Щотижня';
    case DepositFrequency.biweekly:
      return 'Двічі на місяць';
    case DepositFrequency.monthly:
      return 'Щомісяця';
    case DepositFrequency.yearly:
      return 'Щороку';
  }
}

/// Нотифікатор для керування станом форми внеску.
class DepositNotifier extends StateNotifier<DepositState> {
  final GoalRepository _goalRepo;
  final TransactionRepository _transactionRepo;
  final UserRepository _userRepo;

  DepositNotifier({
    required GoalRepository goalRepo,
    required TransactionRepository transactionRepo,
    required UserRepository userRepo,
  })  : _goalRepo = goalRepo,
        _transactionRepo = transactionRepo,
        _userRepo = userRepo,
        super(const DepositState());

  // ─── Встановлення значень ─────────────────────────────────

  /// Встановлює суму внеску та автоматично валідує.
  void setAmount(double amount) {
    final newState = state.copyWith(
      amount: amount,
      clearError: true,
      clearSuccess: true,
      clearLimitWarning: true,
    );
    state = newState.copyWith(isValid: _validateState(newState));

    // Перевіряємо наближення до ліміту
    _checkDepositLimit(amount);
  }

  /// Додає суму до поточного значення.
  void addAmount(double addition) {
    setAmount(state.amount + addition);
  }

  /// Віднімає суму від поточного значення.
  void subtractAmount(double subtraction) {
    setAmount((state.amount - subtraction).clamp(0, _maxDeposit));
  }

  /// Встановлює коментар до внеску.
  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  /// Валідує поточний стан форми.
  void validate() {
    final error = validateAmount(state.amount);
    if (error != null) {
      state = state.copyWith(isValid: false, errorMessage: error);
    } else {
      state = state.copyWith(isValid: _validateState(state), clearError: true);
    }
  }

  /// Встановлює стан обробки.
  void _setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  /// Скидає форму до початкового стану (зберігаючи історію).
  void resetForm() {
    state = state.copyWith(
      amount: 0,
      comment: '',
      isValid: false,
      clearError: true,
      clearSuccess: true,
      clearLimitWarning: true,
      didLevelUp: false,
    );
  }

  /// Повністю скидає стан (включно з історією).
  void reset() {
    state = const DepositState();
  }

  // ─── Валідація ────────────────────────────────────────────

  /// Валідує суму та повертає повідомлення про помилку (або null).
  String? validateAmount(double amount) {
    if (amount <= 0) {
      return 'Внесок має бути більшим за 0 ₴';
    }
    if (amount < _minDeposit) {
      return 'Мінімальний внесок — $_minDeposit ₴';
    }
    if (amount > _maxDeposit) {
      return 'Максимальний внесок — $_maxDeposit ₴';
    }
    return null;
  }

  /// Перевіряє валідність стану.
  bool _validateState(DepositState s) {
    return validateAmount(s.amount) == null;
  }

  /// Перевіряє наближення до ліміту цілі.
  void _checkDepositLimit(double amount) {
    final goal = _goalRepo.getActiveGoal();
    if (goal == null) return;

    final newTotal = goal.currentAmount + amount;

    // Якщо внесок перевищує залишок
    if (newTotal > goal.targetAmount) {
      final excess = newTotal - goal.targetAmount;
      state = state.copyWith(
        limitWarning: 'Внесок перевищує залишок на $excess ₴',
        depositLimitRemaining: goal.remaining,
      );
    } else if (newTotal == goal.targetAmount) {
      state = state.copyWith(
        limitWarning: '🎉 Цей внесок завершить ціль!',
        depositLimitRemaining: 0,
      );
    } else if (newTotal >= goal.targetAmount * 0.9) {
      state = state.copyWith(
        limitWarning: 'Майже досягли цілі!',
        depositLimitRemaining: goal.targetAmount - newTotal,
      );
    }
  }

  // ─── Основні методи внесків ───────────────────────────────

  /// Здійснює внесок — створює транзакцію, оновлює ціль, нараховує XP/монети.
  ///
  /// Повертає `true`, якщо внесок успішний.
  Future<bool> deposit({
    double? customAmount,
    String? customComment,
    TransactionType type = TransactionType.manual,
  }) async {
    final amount = customAmount ?? state.amount;
    final comment = customComment ?? state.comment;

    // Валідація.
    final error = validateAmount(amount);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return false;
    }

    final goal = _goalRepo.getActiveGoal();
    if (goal == null) {
      state = state.copyWith(errorMessage: 'Немає активної цілі для внеску');
      return false;
    }

    _setProcessing(true);
    state = state.copyWith(clearError: true, clearSuccess: true);

    try {
      // Імітація затримки обробки.
      await Future.delayed(const Duration(milliseconds: 800));

      final user = _userRepo.getUser();
      final isFirst = _transactionRepo.count == 0;
      final xpEarned = XPCalculator.calculateXp(
        type,
        isFirstDeposit: isFirst,
        streakDays: goal.streakDays,
      );
      final coinsEarned = XPCalculator.calculateCoins(
        type,
        leveledUp: user.currentLevel < XPCalculator.getLevelForXp(user.xp + xpEarned),
      );

      // Створюємо транзакцію.
      final transaction = Transaction(
        id: const Uuid().v4(),
        goalId: goal.id,
        type: type,
        amount: amount,
        createdAt: DateTime.now(),
        comment: comment.isNotEmpty ? comment : null,
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
      );

      _transactionRepo.save(transaction);

      // Оновлюємо ціль.
      final streakData = StreakCalculator.updateStreak(
        lastDepositDate: goal.lastDepositDate,
        currentStreak: goal.streakDays,
        longestStreak: goal.longestStreak,
        isHolidayModeActive: goal.isHolidayModeActive,
        isNewDeposit: true,
      );

      goal.currentAmount += amount;
      goal.lastDepositDate = DateTime.now();
      goal.streakDays = streakData['current']!;
      goal.longestStreak = streakData['longest']!;

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

      // Додаємо запис до історії.
      final record = DepositRecord(
        transactionId: transaction.id,
        amount: amount,
        type: type,
        comment: comment.isNotEmpty ? comment : null,
        timestamp: DateTime.now(),
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        leveledUp: leveledUp,
      );
      final updatedHistory = [record, ...state.depositHistory];
      // Зберігаємо лише останні записи.
      final trimmedHistory = updatedHistory.length > _maxHistorySize
          ? updatedHistory.sublist(0, _maxHistorySize)
          : updatedHistory;

      final newBalance = goal.currentAmount;
      final progress = (goal.progress * 100).toStringAsFixed(1);
      String successMsg = 'Внесок $amount ₴ успішно додано! Прогрес: $progress%';
      if (leveledUp) {
        successMsg += ' 🎉 Новий рівень!';
      }
      if (goalReached) {
        successMsg += ' 🏆 Ціль досягнуто!';
      }

      state = state.copyWith(
        isProcessing: false,
        isValid: false,
        successMessage: successMsg,
        depositHistory: trimmedHistory,
        previousBalance: newBalance,
        lastXpEarned: xpEarned,
        lastCoinsEarned: coinsEarned,
        didLevelUp: leveledUp,
        amount: 0,
        comment: '',
        clearLimitWarning: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Помилка внеску: $e',
      );
      return false;
    }
  }

  /// Здійснює внесок з коментарем.
  Future<bool> depositWithComment(double amount, String comment) {
    return deposit(customAmount: amount, customComment: comment);
  }

  /// Швидкий внесок одним натисканням (з пресетів).
  Future<bool> quickDeposit(double amount) {
    setAmount(amount);
    return deposit(customAmount: amount);
  }

  /// Пакетний внесок — кілька внесків одразу.
  ///
  /// Застосовується для автоматичного округлення або пакетних операцій.
  /// Повертає кількість успішних внесків.
  Future<int> batchDeposit(List<Map<String, dynamic>> deposits) async {
    int successCount = 0;

    for (final dep in deposits) {
      final amount = dep['amount'] as double? ?? 0;
      final comment = dep['comment'] as String?;
      final type = dep['type'] as TransactionType? ?? TransactionType.manual;

      final success = await deposit(
        customAmount: amount,
        customComment: comment,
        type: type,
      );
      if (success) successCount++;
    }

    return successCount;
  }

  /// Логіка округлення до найближчого (наприклад, при витраті 87 грн округлити до 100).
  ///
  /// [spentAmount] — витрачена сума.
  /// [roundTo] — крок округлення (наприклад, 10, 50, 100).
  ///
  /// Повертає різницю для внеску (наприклад, 13 грн).
  double autoRoundUp(double spentAmount, int roundTo) {
    if (roundTo <= 0) return 0;
    final remainder = spentAmount % roundTo;
    if (remainder == 0) return 0;
    return roundTo - remainder;
  }

  /// Здійснює внесок на основі округлення.
  Future<bool> depositRoundUp(double spentAmount, int roundTo) {
    final roundUpAmount = autoRoundUp(spentAmount, roundTo);
    if (roundUpAmount < _minDeposit) {
      state = state.copyWith(
        errorMessage: 'Різниця округлення ($roundUpAmount ₴) менша за мінімум ($_minDeposit ₴)',
      );
      return Future.value(false);
    }
    return deposit(
      customAmount: roundUpAmount,
      customComment: 'Округлення від $spentAmount ₴ до ${spentAmount + roundUpAmount} ₴',
      type: TransactionType.roundUp,
    );
  }

  /// Здійснює внесок із підтвердженням (для екрана підтвердження).
  ///
  /// Спочатку валідує, потім виконує депозит.
  /// Повертає карту з результатами операції.
  Future<Map<String, dynamic>> depositWithConfirmation() async {
    final amount = state.amount;

    // Валідація
    final validationError = validateAmount(amount);
    if (validationError != null) {
      return {'success': false, 'error': validationError};
    }

    final goal = _goalRepo.getActiveGoal();
    if (goal == null) {
      return {'success': false, 'error': 'Немає активної цілі'};
    }

    // Попередній перегляд
    final preview = {
      'current_balance': goal.currentAmount,
      'new_balance': goal.currentAmount + amount,
      'progress_before': goal.progress,
      'progress_after': (goal.currentAmount + amount) / goal.targetAmount,
    };

    // Виконуємо депозит
    final success = await deposit();
    return {
      'success': success,
      'preview': preview,
      'amount': amount,
    };
  }

  // ─── Попередній перегляд ──────────────────────────────────

  /// Повертає новий залишок після попереднього внеску (без збереження).
  double getNewBalance() {
    final goal = _goalRepo.getActiveGoal();
    if (goal == null) return 0;
    final currentAmount = goal.currentAmount;
    final newAmount = currentAmount + state.amount;
    return newAmount.clamp(0, goal.targetAmount);
  }

  /// Повертає прогрес після попереднього внеску (без збереження).
  double getNewProgress() {
    final goal = _goalRepo.getActiveGoal();
    if (goal == null) return 0;
    if (goal.targetAmount <= 0) return 1.0;
    final newAmount = goal.currentAmount + state.amount;
    return (newAmount / goal.targetAmount).clamp(0.0, 1.0);
  }

  /// Повертає розрахований XP за попередній внесок.
  int get estimatedXp {
    final goal = _goalRepo.getActiveGoal();
    if (goal == null) return 0;
    final user = _userRepo.getUser();
    final isFirst = _transactionRepo.count == 0;
    return XPCalculator.calculateXp(
      TransactionType.manual,
      isFirstDeposit: isFirst,
      streakDays: goal.streakDays,
    );
  }

  /// Повертає розраховані монети за попередній внесок.
  int get estimatedCoins {
    final user = _userRepo.getUser();
    return XPCalculator.calculateCoins(
      TransactionType.manual,
      leveledUp: user.currentLevel < XPCalculator.getLevelForXp(user.xp + estimatedXp),
    );
  }

  // ─── Скасування останнього внеску ─────────────────────────

  /// Скасовує останній внесок.
  ///
  /// Повертає `true`, якщо скасування успішне.
  Future<bool> undoLastDeposit() async {
    final history = state.depositHistory;
    if (history.isEmpty) {
      state = state.copyWith(errorMessage: 'Немає внесків для скасування');
      return false;
    }

    final lastRecord = history.first;
    final goal = _goalRepo.getActiveGoal();
    if (goal == null) {
      state = state.copyWith(errorMessage: 'Немає активної цілі');
      return false;
    }

    _setProcessing(true);

    try {
      // Видаляємо транзакцію.
      _transactionRepo.delete(lastRecord.transactionId);

      // Оновлюємо ціль (віднімаємо суму).
      goal.currentAmount -= lastRecord.amount;
      if (goal.currentAmount < 0) goal.currentAmount = 0;

      // Якщо ціль була завершена — розблоковуємо.
      if (goal.status == GoalStatus.completed) {
        goal.status = GoalStatus.active;
        goal.completedAt = null;
      }

      _goalRepo.updateGoal(goal);

      // Оновлюємо користувача (віднімаємо XP та монети).
      final user = _userRepo.getUser();
      user.xp = (user.xp - lastRecord.xpEarned).clamp(0, user.xp);
      user.coins = (user.coins - lastRecord.coinsEarned).clamp(0, user.coins);
      user.recalculateLevel();
      _userRepo.save(user);

      // Видаляємо запис з історії.
      final updatedHistory = history.sublist(1);

      state = state.copyWith(
        isProcessing: false,
        depositHistory: updatedHistory,
        lastUndoneAmount: lastRecord.amount,
        successMessage: 'Внесок ${lastRecord.amount} ₴ скасовано',
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Помилка скасування: $e',
      );
      return false;
    }
  }

  /// Повертає можливість скасувати (чи є записи).
  bool get canUndo => state.depositHistory.isNotEmpty;

  // ─── Повторювані депозити ─────────────────────────────────

  /// Створює запланований повторюваний депозит.
  ///
  /// Повертає `true`, якщо успішно.
  bool scheduleDeposit({
    required double amount,
    required DepositFrequency frequency,
    String? comment,
  }) {
    if (amount < _minDeposit) return false;

    final scheduled = ScheduledDeposit(
      id: const Uuid().v4(),
      amount: amount,
      frequency: frequency,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final updatedList = [...state.scheduledDeposits, scheduled];
    state = state.copyWith(scheduledDeposits: updatedList);

    return true;
  }

  /// Відключає запланований депозит.
  void cancelScheduledDeposit(String id) {
    final updatedList = state.scheduledDeposits
        .map((s) => s.id == id ? s.copyWith(isActive: false) : s)
        .toList();
    state = state.copyWith(scheduledDeposits: updatedList);
  }

  /// Видаляє запланований депозит.
  void removeScheduledDeposit(String id) {
    final updatedList = state.scheduledDeposits
        .where((s) => s.id != id)
        .toList();
    state = state.copyWith(scheduledDeposits: updatedList);
  }

  /// Повертає активні заплановані депозити.
  List<ScheduledDeposit> get activeScheduledDeposits {
    return state.scheduledDeposits.where((s) => s.isActive).toList();
  }

  /// Обчислює щомісячну суму від запланованих депозитів.
  double get scheduledMonthlyTotal {
    double monthlyTotal = 0;
    for (final scheduled in activeScheduledDeposits) {
      switch (scheduled.frequency) {
        case DepositFrequency.daily:
          monthlyTotal += scheduled.amount * 30;
          break;
        case DepositFrequency.weekly:
          monthlyTotal += scheduled.amount * 4;
          break;
        case DepositFrequency.biweekly:
          monthlyTotal += scheduled.amount * 2;
          break;
        case DepositFrequency.monthly:
          monthlyTotal += scheduled.amount;
          break;
        case DepositFrequency.yearly:
          monthlyTotal += scheduled.amount / 12;
          break;
      }
    }
    return monthlyTotal;
  }

  // ─── Відновлення помилок ──────────────────────────────────

  /// Повертає депозит з помилкового стану.
  ///
  /// Спробує повторити останній невдалий депозит.
  Future<bool> retryLastFailedDeposit() async {
    if (state.depositHistory.isEmpty) {
      state = state.copyWith(errorMessage: 'Немає депозитів для повтору');
      return false;
    }

    final lastRecord = state.depositHistory.first;
    return deposit(
      customAmount: lastRecord.amount,
      customComment: lastRecord.comment ?? 'Повторний внесок',
      type: lastRecord.type,
    );
  }

  // ─── Пресети ──────────────────────────────────────────────

  /// Доступні пресети швидкого внеску.
  List<double> get quickPresets => List.unmodifiable(_quickDepositPresets);

  /// Загальна сума внесків за поточну сесію.
  double get sessionTotal {
    return state.depositHistory.fold<double>(
      0.0,
      (sum, record) => sum + record.amount,
    );
  }

  /// Кількість внесків за поточну сесію.
  int get sessionDepositCount => state.depositHistory.length;

  /// Загальний XP за поточну сесію.
  int get sessionTotalXp {
    return state.depositHistory.fold<int>(
      0,
      (sum, record) => sum + record.xpEarned,
    );
  }

  /// Загальні монети за поточну сесію.
  int get sessionTotalCoins {
    return state.depositHistory.fold<int>(
      0,
      (sum, record) => sum + record.coinsEarned,
    );
  }

  /// Середня сума внеску за сесію.
  double get sessionAverageDeposit {
    if (state.depositHistory.isEmpty) return 0;
    return sessionTotal / sessionDepositCount;
  }

  /// Найбільший внесок за сесію.
  double get sessionMaxDeposit {
    if (state.depositHistory.isEmpty) return 0;
    return state.depositHistory
        .map((r) => r.amount)
        .fold<double>(0, (max, v) => v > max ? v : max);
  }

  /// Найменший внесок за сесію.
  double get sessionMinDeposit {
    if (state.depositHistory.isEmpty) return 0;
    return state.depositHistory
        .map((r) => r.amount)
        .fold<double>(double.infinity, (min, v) => v < min ? v : min);
  }

  /// Повертає форматовану суму (наприклад, «1 000 ₴»).
  String formatDepositAmount(double amount) {
    final formatted = amount.toInt().toString();
    final buffer = StringBuffer();
    final chars = formatted.split('').reversed.toList();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(chars[i]);
    }
    return '${buffer.toString().split('').reversed.join()} ₴';
  }
}

// ─── Провайдери залежностей ─────────────────────────────────────────

/// Провайдер для GoalRepository.
final depositGoalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(),
);

/// Провайдер для TransactionRepository.
final depositTransactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

/// Провайдер для UserRepository.
final depositUserRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

// ─── Головний провайдер ─────────────────────────────────────────────

/// Riverpod провайдер для стану форми внеску.
final depositProvider =
    StateNotifierProvider<DepositNotifier, DepositState>(
  (ref) => DepositNotifier(
    goalRepo: ref.watch(depositGoalRepositoryProvider),
    transactionRepo: ref.watch(depositTransactionRepositoryProvider),
    userRepo: ref.watch(depositUserRepositoryProvider),
  ),
);

// ═══════════════════════════════════════════════════════════════════════════
// Deposit Helpers & Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні розширення для [DepositState].
extension DepositStateExtensions on DepositState {
  /// Чи форма порожня (немає суми та коментаря).
  bool get isEmpty => amount == 0 && comment.isEmpty;

  /// Чи є активні заплановані депозити.
  bool get hasScheduledDeposits => scheduledDeposits.isNotEmpty;

  /// Чи є попередження про ліміт.
  bool get hasLimitWarning => limitWarning != null && limitWarning!.isNotEmpty;

  /// Чи є повідомлення про успіх.
  bool get hasSuccessMessage => successMessage != null && successMessage!.isNotEmpty;

  /// Чи є помилка.
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Кількість активних запланованих депозитів.
  int get activeScheduleCount =>
      scheduledDeposits.where((s) => s.isActive).length;

  /// Загальна сума запланованих депозитів за місяць.
  double get totalScheduledMonthly {
    return scheduledDeposits
        .where((s) => s.isActive)
        .fold<double>(0.0, (sum, s) {
      switch (s.frequency) {
        case DepositFrequency.daily:
          return sum + s.amount * 30;
        case DepositFrequency.weekly:
          return sum + s.amount * 4;
        case DepositFrequency.biweekly:
          return sum + s.amount * 2;
        case DepositFrequency.monthly:
          return sum + s.amount;
        case DepositFrequency.yearly:
          return sum + s.amount / 12;
      }
    });
  }

  /// Повертає останній запис депозиту (або null).
  DepositRecord? get lastRecord =>
      depositHistory.isNotEmpty ? depositHistory.first : null;

  /// Чи був хоча б один deposit з підвищенням рівня.
  bool get hasLevelUpInHistory =>
      depositHistory.any((r) => r.leveledUp);
}

/// Допоміжні розширення для [DepositRecord].
extension DepositRecordExtensions on DepositRecord {
  /// Форматована дата запису (ДД.ММ.РРРР).
  String get formattedDate {
    final d = timestamp.day.toString().padLeft(2, '0');
    final m = timestamp.month.toString().padLeft(2, '0');
    return '$d.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year}';
  }

  /// Форматований час запису (ГГ:ХХ).
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Повний форматований час запису (ДД.ММ.РРРР ГГ:ХХ).
  String get formattedDateTime => '$formattedDate $formattedTime';

  /// Відносний час запису (наприклад, «5 хв тому»).
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return 'щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }

  /// Тип транзакції українською.
  String get typeLabel {
    switch (type) {
      case TransactionType.manual:
        return 'Вручну';
      case TransactionType.auto:
        return 'Авто';
      case TransactionType.roundUp:
        return 'Округлення';
    }
  }

  /// Чи цей запис сьогоднішній.
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Чи цей запис за останній тиждень.
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return timestamp.isAfter(weekAgo);
  }
}

/// Допоміжні розширення для [ScheduledDeposit].
extension ScheduledDepositExtensions on ScheduledDeposit {
  /// Форматований опис частоти.
  String get frequencyLabel => depositFrequencyLabel(frequency);

  /// Форматований опис для UI.
  String get displayLabel => '$frequencyLabel — $amount ₴';

  /// Днів до наступного виконання (приблизно).
  int get daysUntilNext {
    if (lastExecutedAt == null) return _daysBetweenFrequency;
    final daysSince = DateTime.now().difference(lastExecutedAt!).inDays;
    return (_daysBetweenFrequency - daysSince).clamp(0, _daysBetweenFrequency);
  }

  /// Приблизна кількість днів між виконаннями.
  int get _daysBetweenFrequency {
    switch (frequency) {
      case DepositFrequency.daily:
        return 1;
      case DepositFrequency.weekly:
        return 7;
      case DepositFrequency.biweekly:
        return 14;
      case DepositFrequency.monthly:
        return 30;
      case DepositFrequency.yearly:
        return 365;
    }
  }

  /// Чи виконувався сьогодні.
  bool get executedToday {
    if (lastExecutedAt == null) return false;
    final now = DateTime.now();
    return lastExecutedAt!.year == now.year &&
        lastExecutedAt!.month == now.month &&
        lastExecutedAt!.day == now.day;
  }

  /// Загальна сума, списана за цей scheduled deposit.
  double get totalSpent => amount * executionCount;
}

// ═══════════════════════════════════════════════════════════════════════════
// Deposit Validation Constants
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для валідації та лімітів депозитів.
class DepositLimits {
  /// Константа — не дозволяємо створювати екземпляри.
  DepositLimits._();

  /// Мінімальна сума внеску.
  static const double minAmount = _minDeposit;

  /// Максимальна сума внеску.
  static const double maxAmount = _maxDeposit;

  /// Максимальна кількість записів в історії.
  static const int maxHistoryRecords = _maxHistorySize;

  /// Доступні пресети швидкого внеску.
  static const List<double> quickPresets = _quickDepositPresets;

  /// Порогове значення для попередження про наближення до ліміту цілі (90%).
  static const double goalNearCompletionThreshold = 0.9;

  /// Кількість пресетів.
  static const int presetCount = _quickDepositPresets.length;

  /// Мінімальний пресет.
  static double get minPreset =>
      _quickDepositPresets.reduce((a, b) => a < b ? a : b);

  /// Максимальний пресет.
  static double get maxPreset =>
      _quickDepositPresets.reduce((a, b) => a > b ? a : b);

  /// Чи сума входить в діапазон допустимих значень.
  static bool isAmountInRange(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  /// Повертає найближчий пресет до вказаної суми.
  ///
  /// Якщо сума дорівнює пресету — повертає цей пресет.
  /// Інакше — найближчий більший. Якщо такого немає — найменший.
  static double nearestPreset(double amount) {
    if (_quickDepositPresets.contains(amount)) return amount;

    final greater = _quickDepositPresets
        .where((p) => p >= amount)
        .toList()
      ..sort();
    if (greater.isNotEmpty) return greater.first;

    return minPreset;
  }

  /// Повертає пресет за індексом (з циклічним повторенням).
  ///
  /// Індекси за межами діапазону обертаються.
  static double presetAtIndex(int index) {
    final safeIndex = index % _quickDepositPresets.length;
    return _quickDepositPresets[safeIndex];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Deposit Statistics Calculator
// ═══════════════════════════════════════════════════════════════════════════

/// Калькулятор статистики депозитів для сесії.
///
/// Надає розширені методи аналізу історії депозитів.
class DepositStatisticsCalculator {
  /// Константа — не дозволяємо створювати екземпляри.
  DepositStatisticsCalculator._();

  /// Обчислює медіанну суму депозиту.
  ///
  /// [history] — список записів депозитів.
  static double median(List<DepositRecord> history) {
    if (history.isEmpty) return 0;
    final amounts = history.map((r) => r.amount).toList()..sort();
    final mid = amounts.length ~/ 2;
    if (amounts.length % 2 == 1) return amounts[mid];
    return (amounts[mid - 1] + amounts[mid]) / 2;
  }

  /// Обчислює стандартне відхилення сум депозитів.
  ///
  /// [history] — список записів депозитів.
  static double standardDeviation(List<DepositRecord> history) {
    if (history.isEmpty) return 0;
    final avg = history.fold<double>(0, (s, r) => s + r.amount) /
        history.length;
    final variance = history.fold<double>(0, (s, r) {
      final diff = r.amount - avg;
      return s + diff * diff;
    }) / history.length;
    return math.sqrt(variance);
  }

  /// Обчислює загальний XP за вказаний період.
  ///
  /// [history] — список записів депозитів.
  /// [since] — початкова дата періоду (null = всі).
  static int totalXpInPeriod(
    List<DepositRecord> history, {
    DateTime? since,
  }) {
    final filtered = since != null
        ? history.where((r) => r.timestamp.isAfter(since)).toList()
        : history;
    return filtered.fold<int>(0, (sum, r) => sum + r.xpEarned);
  }

  /// Обчислює загальні монети за вказаний період.
  ///
  /// [history] — список записів депозитів.
  /// [since] — початкова дата періоду (null = всі).
  static int totalCoinsInPeriod(
    List<DepositRecord> history, {
    DateTime? since,
  }) {
    final filtered = since != null
        ? history.where((r) => r.timestamp.isAfter(since)).toList()
        : history;
    return filtered.fold<int>(0, (sum, r) => sum + r.coinsEarned);
  }

  /// Групує депозити за днями.
  ///
  /// Повертає карту, де ключ — дата (РРРР-ММ-ДД), значення — список записів.
  static Map<String, List<DepositRecord>> groupByDay(
      List<DepositRecord> history) {
    final map = <String, List<DepositRecord>>{};
    for (final record in history) {
      final key = '${record.timestamp.year}-'
          '${record.timestamp.month.toString().padLeft(2, '0')}-'
          '${record.timestamp.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(record);
    }
    return map;
  }

  /// Обчислює суму депозитів за день.
  ///
  /// [history] — список записів депозитів.
  static Map<String, double> dailyTotals(List<DepositRecord> history) {
    final grouped = groupByDay(history);
    return grouped.map(
      (key, records) => MapEntry(
        key,
        records.fold<double>(0, (sum, r) => sum + r.amount),
      ),
    );
  }

  /// Повертає типи транзакцій з їх кількістю.
  static Map<TransactionType, int> transactionTypeCounts(
      List<DepositRecord> history) {
    final counts = <TransactionType, int>{};
    for (final record in history) {
      counts[record.type] = (counts[record.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Визначає найпопулярніший тип транзакції.
  static TransactionType? mostCommonType(List<DepositRecord> history) {
    if (history.isEmpty) return null;
    final counts = transactionTypeCounts(history);
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Deposit Formatting Utilities
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для форматування даних депозитів.
class DepositFormatter {
  /// Константа — не дозволяємо створювати екземпляри.
  DepositFormatter._();

  /// Форматує суму з роздільниками (наприклад, «1 000 ₴»).
  static String formatAmount(double amount) {
    final formatted = amount.toInt().toString();
    final buffer = StringBuffer();
    final chars = formatted.split('').reversed.toList();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(chars[i]);
    }
    return '${buffer.toString().split('').reversed.join()} ₴';
  }

  /// Форматує відсоток прогресу цілі.
  ///
  /// Наприклад: «45.2%».
  static String formatProgress(double progress) {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  /// Форматує залишок до цілі.
  ///
  /// Наприклад: «Залишилось 5 500 ₴».
  static String formatRemaining(double remaining) {
    return 'Залишилось ${formatAmount(remaining)}';
  }

  /// Форматує повідомлення про успішний внесок.
  static String formatSuccessMessage({
    required double amount,
    required double progress,
    bool leveledUp = false,
    bool goalReached = false,
  }) {
    final buffer = StringBuffer(
      'Внесок ${amount.toInt()} ₴ успішно додано! '
      'Прогрес: ${formatProgress(progress)}',
    );
    if (leveledUp) buffer.write(' 🎉 Новий рівень!');
    if (goalReached) buffer.write(' 🏆 Ціль досягнуто!');
    return buffer.toString();
  }

  /// Форматує повідомлення про скасування.
  static String formatUndoMessage(double amount) {
    return 'Внесок ${amount.toInt()} ₴ скасовано';
  }

  /// Форматує повідомлення про помилку округлення.
  static String formatRoundUpError(double roundUpAmount) {
    return 'Різниця округлення (${roundUpAmount.toInt()} ₴) '
        'менша за мінімум (${_minDeposit.toInt()} ₴)';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Import for math.sqrt (used in statistics)
// ═══════════════════════════════════════════════════════════════════════════
