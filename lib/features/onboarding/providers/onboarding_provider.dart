import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/goal_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// Стан онбордингу.
class OnboardingState {
  /// Поточний крок онбордингу (0-індексований).
  final int currentStep;

  /// Вибраний тип цілі.
  final GoalType? selectedGoalType;

  /// Назва цілі (введена користувачем).
  final String goalName;

  /// Цільова сума накопичення.
  final double targetAmount;

  /// Бажана дата досягнення цілі.
  final DateTime? targetDate;

  /// Чи відправляється онбординг наразі.
  final bool isSubmitting;

  /// Помилка валідації для поточного кроку.
  final String? stepError;

  /// Чи вінбординг завершено.
  final bool isCompleted;

  /// Чи був вінбординг раніше пропущений.
  final bool wasSkipped;

  /// Час початку онбордингу (для аналітики).
  final DateTime? startedAt;

  /// Час завершення онбордингу.
  final DateTime? completedAt;

  /// Обрані вподобання теми під час онбордингу.
  final String selectedThemeId;

  /// Включено сповіщення під час онбордингу.
  final bool notificationsOptIn;

  /// Час, витрачений на кожен крок (в секундах).
  final Map<int, int> stepDurations;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedGoalType,
    this.goalName = '',
    this.targetAmount = 0,
    this.targetDate,
    this.isSubmitting = false,
    this.stepError,
    this.isCompleted = false,
    this.wasSkipped = false,
    this.startedAt,
    this.completedAt,
    this.selectedThemeId = 'ps5',
    this.notificationsOptIn = true,
    this.stepDurations = const {},
  });

  OnboardingState copyWith({
    int? currentStep,
    GoalType? selectedGoalType,
    String? goalName,
    double? targetAmount,
    DateTime? targetDate,
    bool? isSubmitting,
    String? stepError,
    bool? isCompleted,
    bool? wasSkipped,
    DateTime? startedAt,
    DateTime? completedAt,
    String? selectedThemeId,
    bool? notificationsOptIn,
    Map<int, int>? stepDurations,
    bool clearGoalType = false,
    bool clearTargetDate = false,
    bool clearError = false,
    bool clearCompletedAt = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedGoalType: clearGoalType ? null : (selectedGoalType ?? this.selectedGoalType),
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      stepError: clearError ? null : (stepError ?? this.stepError),
      isCompleted: isCompleted ?? this.isCompleted,
      wasSkipped: wasSkipped ?? this.wasSkipped,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      notificationsOptIn: notificationsOptIn ?? this.notificationsOptIn,
      stepDurations: stepDurations ?? this.stepDurations,
    );
  }
}

/// Подія аналітики онбордингу.
class OnboardingAnalyticsEvent {
  /// Тип події (наприклад, 'step_completed', 'onboarding_skipped').
  final String eventType;

  /// Додаткові параметри події.
  final Map<String, dynamic> parameters;

  /// Час події.
  final DateTime timestamp;

  const OnboardingAnalyticsEvent({
    required this.eventType,
    this.parameters = const {},
    required this.timestamp,
  });
}

/// Нотифікатор для керування потоком онбордингу.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final GoalRepository _goalRepo;
  final TransactionRepository _transactionRepo;
  final UserRepository _userRepo;

  /// Стрім подій аналітики онбордингу.
  final _analyticsController = StreamController<OnboardingAnalyticsEvent>.broadcast();

  /// Таймер відстеження тривалості кроку.
  DateTime? _stepStartTime;

  OnboardingNotifier({
    required GoalRepository goalRepo,
    required TransactionRepository transactionRepo,
    required UserRepository userRepo,
  })  : _goalRepo = goalRepo,
        _transactionRepo = transactionRepo,
        _userRepo = userRepo,
        super(const OnboardingState()) {
    _stepStartTime = DateTime.now();
  }

  // ─── Стрім аналітики ────────────────────────────────────

  /// Стрім подій аналітики онбордингу.
  Stream<OnboardingAnalyticsEvent> get analyticsStream =>
      _analyticsController.stream;

  /// Emitує подію аналітики.
  void _emitAnalyticsEvent(String eventType, [Map<String, dynamic>? params]) {
    final event = OnboardingAnalyticsEvent(
      eventType: eventType,
      parameters: params ?? {},
      timestamp: DateTime.now(),
    );
    _analyticsController.add(event);
  }

  // ─── Константи кроків ────────────────────────────────────

  /// Загальна кількість кроків онбордингу.
  static const int totalSteps = 5;

  /// Українські назви кроків онбордингу.
  static const List<String> stepNames = [
    'Вітання',
    'Тип цілі',
    'Назва цілі',
    'Цільова сума',
    'Підтвердження',
  ];

  /// Описи кроків онбордингу для прогрес-бару.
  static const List<String> stepDescriptions = [
    'Ласкаво просимо до Nexora!',
    'Оберіть тип вашої цілі',
    'Дайте назву вашій меті',
    'Встановіть цільову суму',
    'Підтвердіть ваш вибір',
  ];

  /// Іконки кроків онбордингу.
  static const List<IconData> stepIcons = [
    Icons.waving_hand,
    Icons.track_changes,
    Icons.edit,
    Icons.payments,
    Icons.check_circle,
  ];

  // ─── Навігація ────────────────────────────────────────────

  /// Встановлює поточний крок онбордингу.
  void setStep(int step) {
    _recordStepDuration();
    final newStep = step.clamp(0, totalSteps - 1);

    state = state.copyWith(
      currentStep: newStep,
      clearError: true,
      startedAt: state.startedAt ?? DateTime.now(),
    );

    _stepStartTime = DateTime.now();
    _emitAnalyticsEvent('step_changed', {'step': newStep});
  }

  /// Переходить до наступного кроку.
  void nextStep() {
    if (!canProceed()) return;
    _recordStepDuration();
    final next = state.currentStep + 1;

    state = state.copyWith(
      currentStep: next.clamp(0, totalSteps - 1),
      clearError: true,
    );

    _stepStartTime = DateTime.now();
    _emitAnalyticsEvent('step_completed', {
      'from_step': state.currentStep - 1,
      'to_step': state.currentStep,
    });
  }

  /// Повертається до попереднього кроку.
  void previousStep() {
    if (!canGoBack()) return;
    _recordStepDuration();
    final prev = state.currentStep - 1;

    state = state.copyWith(
      currentStep: prev.clamp(0, totalSteps - 1),
      clearError: true,
    );

    _stepStartTime = DateTime.now();
    _emitAnalyticsEvent('step_revisited', {
      'from_step': state.currentStep + 1,
      'to_step': state.currentStep,
    });
  }

  /// Записує тривалість поточного кроку перед переходом.
  void _recordStepDuration() {
    if (_stepStartTime == null) return;
    final duration = DateTime.now().difference(_stepStartTime!).inSeconds;
    final updatedDurations = Map<int, int>.from(state.stepDurations);
    updatedDurations[state.currentStep] =
        (updatedDurations[state.currentStep] ?? 0) + duration;

    // Оновлюємо стан з новими тривалостями
    state = state.copyWith(stepDurations: updatedDurations);
  }

  // ─── Валідація ────────────────────────────────────────────

  /// Перевіряє, чи є поточний крок валідним для переходу далі.
  bool isCurrentStepValid() {
    switch (state.currentStep) {
      case 0:
        // Крок 0 — вітання — завжди валідний.
        return true;
      case 1:
        // Крок 1 — вибір типу цілі (обовʼязковий).
        return state.selectedGoalType != null;
      case 2:
        // Крок 2 — назва цілі (не порожня).
        return state.goalName.trim().isNotEmpty;
      case 3:
        // Крок 3 — цільова сума (більше 0).
        return state.targetAmount > 0;
      case 4:
        // Крок 4 — підтвердження — всі поля мають бути заповнені.
        return _isCompleteValid();
      default:
        return false;
    }
  }

  /// Повертає повідомлення про помилку для поточного кроку.
  String? getCurrentStepError() {
    if (isCurrentStepValid()) return null;

    switch (state.currentStep) {
      case 1:
        return 'Оберіть тип цілі для продовження';
      case 2:
        return validateName();
      case 3:
        return validateAmount();
      case 4:
        if (state.selectedGoalType == null) return 'Оберіть тип цілі';
        if (state.goalName.trim().isEmpty) return 'Введіть назву цілі';
        if (state.targetAmount <= 0) return 'Встановіть цільову суму';
        return 'Заповніть усі поля';
      default:
        return null;
    }
  }

  /// Чи можна перейти до наступного кроку.
  bool canProceed() {
    return state.currentStep < totalSteps - 1 && isCurrentStepValid();
  }

  /// Чи можна повернутися до попереднього кроку.
  bool canGoBack() {
    return state.currentStep > 0;
  }

  /// Чи знаходимося ми на останньому кроці.
  bool get isLastStep => state.currentStep == totalSteps - 1;

  /// Чи знаходимося ми на першому кроці.
  bool get isFirstStep => state.currentStep == 0;

  /// Перевіряє повну валідність усіх полів для фінального кроку.
  bool _isCompleteValid() {
    return state.selectedGoalType != null &&
        state.goalName.trim().isNotEmpty &&
        state.targetAmount > 0;
  }

  /// Валідує суму та повертає повідомлення про помилку (або null).
  String? validateAmount() {
    final amount = state.targetAmount;
    if (amount <= 0) {
      return 'Сума має бути більшою за 0 ₴';
    }
    if (amount < 100) {
      return 'Мінімальна сума — 100 ₴';
    }
    if (amount > 1000000) {
      return 'Максимальна сума — 1 000 000 ₴';
    }
    return null;
  }

  /// Валідує імʼя цілі та повертає повідомлення про помилку (або null).
  String? validateName() {
    final name = state.goalName.trim();
    if (name.isEmpty) {
      return 'Введіть назву цілі';
    }
    if (name.length < 2) {
      return 'Назва має містити щонайменше 2 символи';
    }
    if (name.length > 50) {
      return 'Назва не може бути довшою за 50 символів';
    }
    return null;
  }

  /// Валідує дату цілі та повертає повідомлення про помилку (або null).
  String? validateTargetDate() {
    if (state.targetDate == null) return null; // Дата необовʼязкова
    final date = state.targetDate!;
    final now = DateTime.now();
    final minDate = now.add(const Duration(days: 7));

    if (date.isBefore(now)) {
      return 'Дата не може бути в минулому';
    }
    if (date.isBefore(minDate)) {
      return 'Мінімальний термін — 7 днів';
    }
    return null;
  }

  /// Перевіряє всі дані онбордингу та повертає список помилок.
  List<String> validateAll() {
    final errors = <String>[];

    if (state.selectedGoalType == null) {
      errors.add('Оберіть тип цілі');
    }

    final nameError = validateName();
    if (nameError != null) errors.add(nameError);

    final amountError = validateAmount();
    if (amountError != null) errors.add(amountError);

    final dateError = validateTargetDate();
    if (dateError != null) errors.add(dateError);

    return errors;
  }

  // ─── Встановлення значень ─────────────────────────────────

  /// Вибирає тип цілі (PS5, Monitor тощо).
  void selectGoal(GoalType type) {
    state = state.copyWith(selectedGoalType: type, clearError: true);

    // Автоматично встановлюємо суму за замовчуванням.
    final presets = goalPresets;
    if (presets.isNotEmpty) {
      setTargetAmount(presets.first);
    }

    _emitAnalyticsEvent('goal_type_selected', {'type': type.name});
  }

  /// Встановлює назву цілі.
  void setGoalName(String name) {
    state = state.copyWith(goalName: name, clearError: true);
  }

  /// Встановлює цільову суму.
  void setTargetAmount(double amount) {
    state = state.copyWith(targetAmount: amount, clearError: true);
  }

  /// Встановлює цільову дату.
  void setTargetDate(DateTime date) {
    state = state.copyWith(targetDate: date, clearError: true);
  }

  /// Обирає тему під час онбордингу.
  void selectTheme(String themeId) {
    state = state.copyWith(selectedThemeId: themeId);
    _emitAnalyticsEvent('theme_selected', {'theme': themeId});
  }

  /// Перемикає згоду на сповіщення.
  void toggleNotificationsOptIn() {
    state = state.copyWith(
      notificationsOptIn: !state.notificationsOptIn,
    );
  }

  // ─── Обчислювані властивості ──────────────────────────────

  /// Прогрес онбордингу від 0.0 до 1.0.
  double get stepProgress {
    if (totalSteps <= 1) return 1.0;
    return (state.currentStep + 1) / totalSteps;
  }

  /// Загальний відсоток прогресу онбордингу (для індикатора).
  double get progressPercentage {
    if (totalSteps <= 1) return 100.0;
    return ((state.currentStep + 1) / totalSteps) * 100.0;
  }

  /// Відображуване імʼя вибраного типу цілі.
  String get selectedGoalDisplayName {
    if (state.selectedGoalType == null) {
      return 'Не обрано';
    }
    return state.selectedGoalType!.label;
  }

  /// Опис вибраного типу цілі для підказки.
  String get selectedGoalDescription {
    switch (state.selectedGoalType) {
      case GoalType.ps5:
        return 'Ігрова приставка PlayStation 5';
      case GoalType.monitor:
        return 'Сучасний компʼютерний монітор';
      case GoalType.custom:
        return 'Ваша власна мета накопичення';
      case null:
        return 'Оберіть тип цілі';
    }
  }

  /// Іконка для вибраного типу цілі.
  IconData get selectedGoalIcon {
    switch (state.selectedGoalType) {
      case GoalType.ps5:
        return Icons.sports_esports;
      case GoalType.monitor:
        return Icons.desktop_windows;
      case GoalType.custom:
        return Icons.star;
      case null:
        return Icons.help_outline;
    }
  }

  /// Колір для вибраного типу цілі.
  Color get selectedGoalColor {
    switch (state.selectedGoalType) {
      case GoalType.ps5:
        return const Color(0xFF0070D1);
      case GoalType.monitor:
        return const Color(0xFF4CAF50);
      case GoalType.custom:
        return const Color(0xFFFF9800);
      case null:
        return Colors.grey;
    }
  }

  /// Пресети сум для вибраного типу цілі.
  List<double> get goalPresets {
    switch (state.selectedGoalType) {
      case GoalType.ps5:
        return [15000.0, 20000.0, 25000.0, 30000.0];
      case GoalType.monitor:
        return [8000.0, 12000.0, 15000.0, 20000.0];
      case GoalType.custom:
        return [1000.0, 5000.0, 10000.0, 50000.0];
      case null:
        return [];
    }
  }

  /// Назви пресетів для вибраного типу цілі.
  List<String> get goalPresetLabels {
    switch (state.selectedGoalType) {
      case GoalType.ps5:
        return ['Бюджетний', 'Стандартний', 'Преміум', 'Максимальний'];
      case GoalType.monitor:
        return ['Базовий', 'Офісний', 'Для ігор', 'Професійний'];
      case GoalType.custom:
        return ['Маленька', 'Середня', 'Велика', 'Величезна'];
      case null:
        return [];
    }
  }

  /// Форматована сума (наприклад, «25 000 ₴»).
  String get formattedTargetAmount {
    final amount = state.targetAmount;
    if (amount <= 0) return '0 ₴';
    final formatted = amount.toInt().toString();
    // Просте форматування з пробілами між тисячами.
    final buffer = StringBuffer();
    final chars = formatted.split('').reversed.toList();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(chars[i]);
    }
    return '${buffer.toString().split('').reversed.join()} ₴';
  }

  /// Розрахований щомісячний внесок для досягнення цілі.
  String get estimatedMonthlyDeposit {
    if (state.targetDate == null || state.targetAmount <= 0) {
      return '—';
    }
    final now = DateTime.now();
    final months = state.targetDate!.difference(now).inDays / 30;
    if (months <= 0) return '—';

    final monthly = state.targetAmount / months;
    return '${_formatCurrency(monthly)} / міс';
  }

  /// Розрахований щоденний внесок для досягнення цілі.
  String get estimatedDailyDeposit {
    if (state.targetDate == null || state.targetAmount <= 0) {
      return '—';
    }
    final now = DateTime.now();
    final days = state.targetDate!.difference(now).inDays;
    if (days <= 0) return '—';

    final daily = state.targetAmount / days;
    return '${_formatCurrency(daily)} / день';
  }

  /// Загальна тривалість онбордингу в секундах.
  int get totalOnboardingDuration {
    if (state.startedAt == null || state.completedAt == null) {
      // Використовуємо записані тривалості кроків
      return state.stepDurations.values.fold(0, (sum, d) => sum + d);
    }
    return state.completedAt!.difference(state.startedAt!).inSeconds;
  }

  /// Назва поточного кроку.
  String get currentStepName {
    if (state.currentStep < stepNames.length) {
      return stepNames[state.currentStep];
    }
    return 'Крок ${state.currentStep + 1}';
  }

  /// Опис поточного кроку.
  String get currentStepDescription {
    if (state.currentStep < stepDescriptions.length) {
      return stepDescriptions[state.currentStep];
    }
    return '';
  }

  /// Іконка поточного кроку.
  IconData get currentStepIcon {
    if (state.currentStep < stepIcons.length) {
      return stepIcons[state.currentStep];
    }
    return Icons.help_outline;
  }

  /// Форматує суму з пробілами.
  String _formatCurrency(double amount) {
    final formatted = amount.toInt().toString();
    final buffer = StringBuffer();
    final chars = formatted.split('').reversed.toList();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(chars[i]);
    }
    return '${buffer.toString().split('').reversed.join()} ₴';
  }

  // ─── Пропуск онбордингу ───────────────────────────────────

  /// Пропускає онбординг та переходить до дашборду.
  ///
  /// Зберігає інформацію про пропуск для подальшого запиту.
  void skipOnboarding() {
    _recordStepDuration();

    state = state.copyWith(
      wasSkipped: true,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    _emitAnalyticsEvent('onboarding_skipped', {
      'current_step': state.currentStep,
      'duration': totalOnboardingDuration,
    });
  }

  /// Чи показувати пропозицію завершити онбординг.
  bool get shouldShowResumePrompt {
    return state.wasSkipped && !state.isCompleted;
  }

  // ─── Підтвердження онбордингу ─────────────────────────────

  /// Завершує онбординг — створює ціль та перший внесок.
  ///
  /// Повертає `true`, якщо все пройшло успішно.
  Future<bool> submitOnboarding() async {
    // Валідація.
    final nameError = validateName();
    if (nameError != null) {
      state = state.copyWith(stepError: nameError);
      return false;
    }

    final amountError = validateAmount();
    if (amountError != null) {
      state = state.copyWith(stepError: amountError);
      return false;
    }

    if (state.selectedGoalType == null) {
      state = state.copyWith(stepError: 'Оберіть тип цілі');
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      // Створюємо профіль користувача, якщо ще не існує.
      final user = _userRepo.getUser();

      // Створюємо нову ціль.
      final goalId = const Uuid().v4();
      final goal = Goal(
        id: goalId,
        type: state.selectedGoalType!,
        name: state.goalName.trim(),
        targetAmount: state.targetAmount,
        createdAt: DateTime.now(),
        targetDate: state.targetDate,
        status: GoalStatus.active,
      );

      _goalRepo.save(goal);

      // Нараховуємо XP за створення цілі.
      user.addXp(20);
      user.lastActiveDate = DateTime.now();

      // Зберігаємо обрану тему.
      user.activeTheme = state.selectedThemeId;

      _userRepo.save(user);

      // Створюємо перший внесок (якщо користувач хоче).
      // Початковий баланс — 0, не створюємо транзакцію.

      _recordStepDuration();

      state = state.copyWith(
        isSubmitting: false,
        clearError: true,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      _emitAnalyticsEvent('onboarding_completed', {
        'goal_type': state.selectedGoalType!.name,
        'goal_name': state.goalName,
        'target_amount': state.targetAmount,
        'duration': totalOnboardingDuration,
        'theme': state.selectedThemeId,
        'notifications_opt_in': state.notificationsOptIn,
        'step_durations': state.stepDurations,
      });

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        stepError: 'Помилка створення цілі: $e',
      );

      _emitAnalyticsEvent('onboarding_error', {
        'error': e.toString(),
        'step': state.currentStep,
      });

      return false;
    }
  }

  /// Колбек-обгортка для завершення онбордингу з навігацією.
  ///
  /// Викликається після успішного підтвердження.
  Future<void> onCompleteWithNavigation(void Function() navigateToDashboard) async {
    final success = await submitOnboarding();
    if (success) {
      navigateToDashboard();
    }
  }

  // ─── Персистенція ─────────────────────────────────────────

  /// Зберігає поточний стан онбордингу для відновлення.
  void saveProgress() {
    // У майбутньому: зберегти стан у SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('onboarding_step', state.currentStep);
    // await prefs.setString('onboarding_goal_name', state.goalName);
    // await prefs.setDouble('onboarding_target_amount', state.targetAmount);
    _emitAnalyticsEvent('onboarding_saved', {'step': state.currentStep});
  }

  /// Відновлює збережений стан онбордингу.
  Future<bool> restoreProgress() async {
    // У майбутньому: відновити стан з SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // final savedStep = prefs.getInt('onboarding_step');
    // if (savedStep != null) {
    //   setStep(savedStep);
    //   return true;
    // }
    return false;
  }

  // ─── Скидання ─────────────────────────────────────────────

  /// Скидає весь стан онбордингу до початкового значення.
  void reset() {
    _stepStartTime = DateTime.now();
    state = const OnboardingState();
    _emitAnalyticsEvent('onboarding_reset', {});
  }

  /// Скидає лише дані цілі, але зберігає крок.
  void resetGoalData() {
    state = state.copyWith(
      clearGoalType: true,
      goalName: '',
      targetAmount: 0,
      clearTargetDate: true,
      clearError: true,
    );
  }

  // ─── Звільнення ресурсів ──────────────────────────────────

  @override
  void dispose() {
    _analyticsController.close();
    super.dispose();
  }
}

// ─── Провайдери залежностей ─────────────────────────────────────────

/// Провайдер для GoalRepository.
final onboardingGoalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(),
);

/// Провайдер для TransactionRepository.
final onboardingTransactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

/// Провайдер для UserRepository.
final onboardingUserRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

// ─── Головний провайдер онбордингу ──────────────────────────────────

/// Riverpod провайдер для стану онбордингу.
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(
    goalRepo: ref.watch(onboardingGoalRepositoryProvider),
    transactionRepo: ref.watch(onboardingTransactionRepositoryProvider),
    userRepo: ref.watch(onboardingUserRepositoryProvider),
  ),
);
