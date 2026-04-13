import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_particle_bg.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../providers/onboarding_provider.dart';

/// Екран встановлення суми та назви цілі.
///
/// Вміщує поле суми з префіксом «грн», пресети залежно від типу цілі,
/// поле назви, вибір дати, попередній розрахунок щоденної суми,
/// валідацію, індикатор прогресу (крок 3 з 4), milestone-пропозиції,
/// розумні рекомендації, генератор назв, pickер таймлайну,
/// попередній перегляд цілі, кількісний вибір з тегами,
/// анімований числовий ввід, повідомлення валідації українською,
/// прев'ю для поширення, розумні рекомендації суми, порівняння цілей,
/// категорію цілей, індикатор складності, відсоток від дня, розмір цілі,
/// опціональний вибір дати в українській локалі.
class SetGoalScreen extends ConsumerStatefulWidget {
  const SetGoalScreen({super.key});

  @override
  ConsumerState<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends ConsumerState<SetGoalScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  double? _selectedPreset;
  DateTime? _selectedDate;
  int _displayedAmount = 0;
  Timer? _countUpTimer;
  int _countUpTarget = 0;
  bool _isCountingUp = false;
  bool _showMilestones = false;
  bool _showRecommendations = false;
  bool _showTimelinePicker = false;
  bool _showGoalPreview = false;
  bool _showSharePreview = false;
  bool _showComparison = false;
  String _goalNameSuggestion = '';
  String _selectedTimelineLabel = '3 місяці';
  int _selectedTimelineDays = 90;
  String? _validationMessage;
  bool _hasValidationWarning = false;

  static const _milestoneSuggestions = [
    _Milestone(percent: 10, label: 'Початок!', emoji: '🌱'),
    _Milestone(percent: 25, label: 'Чверть шляху!', emoji: '🏃'),
    _Milestone(percent: 50, label: 'Половина!', emoji: '🔥'),
    _Milestone(percent: 75, label: 'Майже там!', emoji: '🌟'),
    _Milestone(percent: 90, label: 'Фінішна пряма!', emoji: '🚀'),
    _Milestone(percent: 100, label: 'Ціль досягнуто!', emoji: '🏆'),
  ];

  static const _smartRecommendations = [
    '💡 Щоденна кава ≈ 50 грн/день → 1 500 грн/місяць',
    '💰 10% від зарплати — найкращий початок',
    '🎯 Почни з малого — 100 грн вже є внесок',
    '📅 200 грн/день = 6 000 грн/місяць',
    '📊 500 грн/тиждень = 2 000 грн/місяць',
    '🧮 Автоплатіж 50 грн/день = 1 500 грн/місяць',
    '🏠 Відклади 5% від оренди щомісяця',
    '☕ Заміни 2 кави на тиждень → 400 грн/місяць',
  ];

  static const _nameSuggestions = {
    GoalType.ps5: ['Моя PS5', 'Ігрова мрія', 'PS5 Diamond', 'Нова консоль', 'PlayStation 5 Pro', 'Геймінг Станція'],
    GoalType.monitor: ['Мій монітор', '4K мрія', 'Робочий монітор', 'UltraWide', 'Кристально чіткий', 'Продуктивність'],
    GoalType.custom: ['Моя ціль', 'Велика мрія', 'Фінансова ціль', 'Накопичення', 'Перший крок', 'Майбутнє'],
  };

  static const _timelineOptions = [
    ('1 тиждень', 7),
    ('2 тижні', 14),
    ('1 місяць', 30),
    ('2 місяці', 60),
    ('3 місяці', 90),
    ('6 місяців', 180),
    ('9 місяців', 270),
    ('1 рік', 365),
  ];

  static const _goalCategories = [
    ('🎮 Геймінг', 'Ігрові консолі та аксесуари'),
    ('🖥️ Техніка', 'Монітори, ноутбуки, гаджети'),
    ('✈️ Подорожі', 'Відпустки та мандрівки'),
    ('🚗 Авто', 'Автомобіль та запчастини'),
    ('📚 Освіта', 'Курси, книги, тренінги'),
    ('🏠 Житло', 'Ремонт, меблі, техніка'),
    ('📱 Гаджети', 'Телефони, навушники, планшети'),
    ('💰 Інвестиції', 'Акції, облігації, депозити'),
  ];

  /// 5 підказок етапів для автозаповнення.
  static const _autoMilestones = [
    {'percent': 10, 'amount': 1000, 'label': 'Перший крок'},
    {'percent': 25, 'amount': 2500, 'label': 'Чверть шляху'},
    {'percent': 50, 'amount': 5000, 'label': 'Половина!'},
    {'percent': 75, 'amount': 7500, 'label': 'Майже там!'},
    {'percent': 100, 'amount': 10000, 'label': 'Ціль досягнуто!'},
  ];

  /// 5 подібних цілей для порівняння.
  static const _similarGoals = [
    {'name': 'PS5 Стандарт', 'amount': 25000, 'percent': 87},
    {'name': 'Монітор 27"', 'amount': 18000, 'percent': 72},
    {'name': 'PS5 Digital', 'amount': 22000, 'percent': 91},
  ];

  List<double> get _presets {
    final type = ref.read(onboardingProvider).selectedGoalType;
    if (type == GoalType.ps5) return [10000, 15000, 20000, 25000, 30000];
    if (type == GoalType.monitor) return [5000, 8000, 12000, 15000, 20000];
    return [1000, 5000, 10000, 15000, 20000];
  }

  String get _currencyPrefix => 'грн';

  String get _defaultNameHint {
    final type = ref.read(onboardingProvider).selectedGoalType;
    switch (type) {
      case GoalType.ps5: return 'Моя PS5';
      case GoalType.monitor: return 'Мій монітор';
      case GoalType.custom: return 'Моя ціль';
      default: return 'Моя ціль';
    }
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _nameController.text = state.goalName;
    _amountController.text = state.targetAmount > 0 ? state.targetAmount.toInt().toString() : '';
    _amountController.addListener(_onAmountChanged);
    _generateNameSuggestion();
  }

  @override
  void dispose() {
    _countUpTimer?.cancel();
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0 && amount != _countUpTarget) {
      _startCountUp(amount.toInt());
      _clearValidation();
    } else if (amount == 0) {
      setState(() { _displayedAmount = 0; _isCountingUp = false; });
    }
    _validateAmount(amount);
  }

  void _validateAmount(double amount) {
    setState(() {
      if (amount > 0 && amount < 100) {
        _validationMessage = '⚠️ Мінімальна сума — 100 грн. Додай ще ${100 - amount.toInt()} грн!';
        _hasValidationWarning = true;
      } else if (amount > 1000000) {
        _validationMessage = '🤯 Wow, амбітно! Максимальна сума — 1 000 000 грн';
        _hasValidationWarning = true;
      } else if (amount > 0 && _selectedDate != null) {
        final daysLeft = _selectedDate!.difference(DateTime.now()).inDays;
        if (daysLeft > 0) {
          final daily = (amount / daysLeft).round();
          if (daily > 10000) {
            _validationMessage = '📊 Висока щоденна норма: $daily грн/день. Збільш термін.';
            _hasValidationWarning = true;
          } else {
            _validationMessage = null;
            _hasValidationWarning = false;
          }
        } else {
          _validationMessage = null;
          _hasValidationWarning = false;
        }
      } else {
        _validationMessage = null;
        _hasValidationWarning = false;
      }
    });
  }

  void _clearValidation() {
    if (_hasValidationWarning) {
      setState(() {
        _validationMessage = null;
        _hasValidationWarning = false;
      });
    }
  }

  void _startCountUp(int target) {
    _countUpTimer?.cancel();
    _countUpTarget = target;
    _isCountingUp = true;
    final start = _displayedAmount;
    final diff = target - start;
    final steps = 30;
    final stepValue = diff / steps;
    int current = 0;
    _countUpTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      current++;
      if (current >= steps) {
        setState(() { _displayedAmount = target; _isCountingUp = false; });
        timer.cancel();
      } else {
        setState(() => _displayedAmount = (start + stepValue * current).round());
      }
    });
  }

  void _generateNameSuggestion() {
    final type = ref.read(onboardingProvider).selectedGoalType ?? GoalType.custom;
    final names = _nameSuggestions[type] ?? _nameSuggestions[GoalType.custom]!;
    _goalNameSuggestion = names[DateTime.now().second % names.length];
  }

  void _onPresetTap(double amount) {
    HapticService.selection();
    setState(() { _selectedPreset = amount; _amountController.text = amount.toInt().toString(); });
    ref.read(onboardingProvider.notifier).setTargetAmount(amount);
  }

  void _selectTimeline(String label, int days) {
    HapticService.selection();
    setState(() {
      _selectedTimelineLabel = label;
      _selectedTimelineDays = days;
      _showTimelinePicker = false;
      _selectedDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    HapticService.lightTap();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('uk', 'UA'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: AppColorsPS5.accent, surface: AppColorsPS5.card, onSurface: AppColorsPS5.textPrimary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      ref.read(onboardingProvider.notifier).setTargetDate(picked);
      final amount = double.tryParse(_amountController.text) ?? 0;
      _validateAmount(amount);
    }
  }

  int? get _dailyAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedDate == null) return null;
    final daysLeft = _selectedDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return null;
    return (amount / daysLeft).round();
  }

  int? get _weeklyAmount {
    final daily = _dailyAmount;
    return daily != null ? daily * 7 : null;
  }

  int? get _monthlyAmount {
    final daily = _dailyAmount;
    return daily != null ? daily * 30 : null;
  }

  int get _daysLeft {
    if (_selectedDate == null) return 0;
    return _selectedDate!.difference(DateTime.now()).inDays;
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount >= 100 && _nameController.text.trim().isNotEmpty;
  }

  int? get _completionPercentage {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedDate == null) return null;
    final daysLeft = _selectedDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return null;
    return ((amount / daysLeft) * 100).round();
  }

  String? get _difficultyLabel {
    final daily = _dailyAmount;
    if (daily == null) return null;
    if (daily <= 50) return '🌱 Легка — по силам кожному';
    if (daily <= 200) return '💪 Помірна — потрібна дисципліна';
    if (daily <= 500) return '🔥 Серйозна — потрібен план';
    return '🏆 Амбітна — виклик для героя';
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 100) {
      HapticService.error();
      AppToast.show(context, message: 'Мінімальна сума — 100 грн', icon: Icons.warning_rounded, color: AppColorsPS5.warning);
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      HapticService.error();
      AppToast.show(context, message: 'Введи назву цілі', icon: Icons.warning_rounded, color: AppColorsPS5.warning);
      return;
    }

    HapticService.mediumTap();
    ref.read(onboardingProvider.notifier).setTargetAmount(amount);
    ref.read(onboardingProvider.notifier).setGoalName(_nameController.text);
    final success = await ref.read(onboardingProvider.notifier).saveGoalAndDeposit();
    if (success && mounted) {
      context.go('/first-deposit');
    } else if (mounted) {
      AppToast.show(context, message: 'Помилка збереження. Спробуй ще раз.', icon: Icons.error_rounded, color: AppColorsPS5.error);
    }
  }

  void _applySuggestion() {
    HapticService.selection();
    _nameController.text = _goalNameSuggestion;
    setState(() {});
  }

  void _refreshSuggestion() {
    HapticService.selection();
    final type = ref.read(onboardingProvider).selectedGoalType ?? GoalType.custom;
    final names = _nameSuggestions[type] ?? _nameSuggestions[GoalType.custom]!;
    _goalNameSuggestion = names[DateTime.now().millisecond % names.length];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(isLight),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Spacing.xl),
                    SizedBox(height: 120, child: Center(child: ParticleSilhouette(goalType: state.selectedGoalType ?? GoalType.ps5, progress: 0.0, isLightTheme: isLight))).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: Spacing.lg),
                    Text('Скільки потрібно накопичити?', style: AppTypography.heading1.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)).animate().slideY(begin: 0.2, end: 0, duration: 500.ms),
                    const SizedBox(height: Spacing.sm),
                    Text('Вкажи суму та назву — ми все порахуємо!', style: AppTypography.bodyMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: Spacing.xxl),
                    AppTextField(hint: 'Введи суму', controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), isLightTheme: isLight, prefixIcon: Icon(Icons.attach_money_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent), suffixText: 'грн').animate().slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 100.ms),
                    if (_displayedAmount > 0) Padding(padding: const EdgeInsets.only(top: Spacing.sm), child: Text('${_displayedAmount.formatUAH()} грн', style: AppTypography.monoLarge.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).shimmer(duration: 1200.ms, color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.2))),
                    if (_displayedAmount > 0) Container(
                      margin: const EdgeInsets.only(top: Spacing.xs),
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                      decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm)),
                      child: Text('💡 Це лише ${((_displayedAmount / 200).ceil())} внесків по 200 грн!', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)),
                    ),
                    if (_validationMessage != null) Container(
                      margin: const EdgeInsets.only(top: Spacing.xs),
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                      decoration: BoxDecoration(color: _hasValidationWarning ? AppColorsPS5.warning.withOpacity(0.1) : AppColorsPS5.success.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)),
                      child: Text(_validationMessage!, style: AppTypography.labelSmall.copyWith(color: _hasValidationWarning ? AppColorsPS5.warning : AppColorsPS5.success)),
                    ),
                    const SizedBox(height: Spacing.base),
                    Wrap(spacing: Spacing.sm, runSpacing: Spacing.sm, children: _presets.map((amount) {
                      final isSelected = _selectedPreset == amount;
                      return GestureDetector(onTap: () => _onPresetTap(amount), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm + 2), decoration: BoxDecoration(color: isSelected ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isSelected ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : (isLight ? AppColorsMonitor.border : AppColorsPS5.border), width: 1.5)), child: Text('${amount.formatUAH()} $_currencyPrefix', style: AppTypography.labelLarge.copyWith(color: isSelected ? Colors.white : (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)))));
                    }).toList()).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: Spacing.xl),
                    AppTextField(hint: _defaultNameHint, controller: _nameController, isLightTheme: isLight, prefixIcon: Icon(Icons.edit_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), onChanged: (_) => setState(() {})).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 300.ms),
                    Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [
                      Icon(Icons.auto_awesome_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 14),
                      const SizedBox(width: Spacing.xs),
                      GestureDetector(onTap: _applySuggestion, child: Text('Спробуй: «$_goalNameSuggestion»', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, decoration: TextDecoration.underline))),
                      const SizedBox(width: Spacing.xs),
                      GestureDetector(onTap: _refreshSuggestion, child: Icon(Icons.refresh_rounded, color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.5), size: 14)),
                    ])),
                    if (_nameController.text.trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [
                      Icon(Icons.check_circle_rounded, color: AppColorsPS5.success, size: 14),
                      const SizedBox(width: Spacing.xs),
                      Text('Назва: ${_nameController.text.trim()}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success)),
                    ])),
                    const SizedBox(height: Spacing.lg),
                    _buildTimelineSection(isLight),
                    const SizedBox(height: Spacing.base),
                    if (_dailyAmount != null) Container(margin: const EdgeInsets.only(top: Spacing.base), padding: const EdgeInsets.all(Spacing.base), decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.2))), child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.today_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 18), const SizedBox(width: Spacing.sm), Text('Щоденно ~${_dailyAmount!.formatUAH()} грн', style: AppTypography.bodySmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))]), Text('${_daysLeft} дн.', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, fontWeight: FontWeight.w600))]),
                      if (_weeklyAmount != null) Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [Icon(Icons.date_range_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16), const SizedBox(width: Spacing.sm), Text('Щотижня ~${_weeklyAmount!.formatUAH()} грн', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))])),
                      if (_monthlyAmount != null) Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [Icon(Icons.calendar_month_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16), const SizedBox(width: Spacing.sm), Text('Щомісяця ~${_monthlyAmount!.formatUAH()} грн', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))])),
                      if (_completionPercentage != null) Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [Icon(Icons.speed_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16), const SizedBox(width: Spacing.sm), Text('Це ${_completionPercentage!}% цілі за місяць', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success))])),
                      if (_difficultyLabel != null) Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [const SizedBox(width: Spacing.sm + 18), Text(_difficultyLabel!, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent))])),
                    ])).animate().fadeIn(duration: 400.ms)),
                    if (_displayedAmount > 0) _buildMilestonesPreview(isLight),
                    _buildSmartRecommendations(isLight),
                    _buildGoalCategories(isLight),
                    _buildGoalPreviewCard(isLight),
                    _buildSharePreview(isLight),
                    _buildSimilarGoals(isLight),
                    const SizedBox(height: Spacing.xxxl),
                    AppButtonPrimary(label: 'Готово', onPressed: _isValid ? _submit : null, isDisabled: !_isValid, isLoading: state.isSaving, isLightTheme: isLight).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                    const SizedBox(height: Spacing.md),
                    Center(child: AppButtonSecondary(label: 'Назад', isLightTheme: isLight, onPressed: () => context.go('/choose-goal')).animate().fadeIn(duration: 500.ms, delay: 600.ms)),
                    const SizedBox(height: Spacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () { HapticService.selection(); setState(() => _showTimelinePicker = !_showTimelinePicker); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: 16),
            decoration: BoxDecoration(color: isLight ? AppColorsMonitor.surface : AppColorsPS5.surface, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border, width: 1.5)),
            child: Row(children: [
              Icon(Icons.timeline_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, size: 20),
              const SizedBox(width: Spacing.base),
              Expanded(child: Text(_selectedDate != null ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}' : 'Цільова дата: $_selectedTimelineLabel', style: AppTypography.bodyLarge.copyWith(color: _selectedDate != null ? (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary) : (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)))),
              if (_selectedDate == null) Icon(Icons.chevron_right_rounded, color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint, size: 20),
            ])),
          ).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 400.ms),
        ),
        if (_showTimelinePicker) ...[
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Швидкий вибір терміну:', style: AppTypography.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xs,
                  children: _timelineOptions.map((opt) {
                    final isSelected = opt.$2 == _selectedTimelineDays;
                    return GestureDetector(
                      onTap: () => _selectTimeline(opt.$1, opt.$2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
                        decoration: BoxDecoration(color: isSelected ? accentColor : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isSelected ? accentColor : (isLight ? AppColorsMonitor.border : AppColorsPS5.border), width: 1.5)),
                        child: Text('${opt.$1} (${opt.$2} дн.)', style: AppTypography.labelSmall.copyWith(color: isSelected ? Colors.white : (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMilestonesPreview(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return GestureDetector(
      onTap: () { HapticService.selection(); setState(() => _showMilestones = !_showMilestones); },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.only(top: Spacing.base),
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.1))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🎯 Твої етапи (${_milestoneSuggestions.length})', style: AppTypography.labelMedium.copyWith(color: accentColor)), Icon(_showMilestones ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accentColor, size: 18)]),
            if (_showMilestones) ...[
              const SizedBox(height: Spacing.sm),
              ..._milestoneSuggestions.map((m) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
                Text('${m.emoji} ${m.label}', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                const Spacer(),
                Text('${m.percent}%', style: AppTypography.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
              ]))),
              const SizedBox(height: Spacing.sm),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.3, minHeight: 6, backgroundColor: accentColor.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(accentColor))),
              Text('Прогрес нараз збільшується з кожним внеском!', style: AppTypography.caption.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
            ],
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Widget _buildSmartRecommendations(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return GestureDetector(
      onTap: () { HapticService.selection(); setState(() => _showRecommendations = !_showRecommendations); },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.only(top: Spacing.base),
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.1))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🧠 Розумні поради', style: AppTypography.labelMedium.copyWith(color: accentColor)), Icon(_showRecommendations ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accentColor, size: 18)]),
            if (_showRecommendations) ...[
              const SizedBox(height: Spacing.sm),
              ..._smartRecommendations.map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(r, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, height: 1.4)))),
            ],
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildGoalCategories(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Container(
      margin: const EdgeInsets.only(top: Spacing.base),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.1))),
      child: Column(children: [
        Text('📌 Категорії цілей', style: AppTypography.labelMedium.copyWith(color: accentColor)),
        const SizedBox(height: Spacing.sm),
        ..._goalCategories.map((cat) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
          Text(cat.$1, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
          const SizedBox(width: Spacing.sm),
          Expanded(child: Text(cat.$2, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint))),
        ]))),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
  }

  Widget _buildGoalPreviewCard(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Моя ціль';
    final type = ref.read(onboardingProvider).selectedGoalType ?? GoalType.custom;
    return GestureDetector(
      onTap: () { HapticService.selection(); setState(() => _showGoalPreview = !_showGoalPreview); },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.only(top: Spacing.base),
          padding: const EdgeInsets.all(Spacing.base),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.1))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('📋 Прев\'ю цілі', style: AppTypography.labelMedium.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
              Icon(_showGoalPreview ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accentColor, size: 18),
            ]),
            if (_showGoalPreview) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: Spacing.sm),
                    Text('Тип: ${type == GoalType.ps5 ? 'PlayStation 5' : type == GoalType.monitor ? 'Монітор' : 'Власна ціль'}', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                    Text('Сума: ${amount > 0 ? amount.toInt().formatUAH() : '—'} грн', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                    Text('Термін: $_selectedTimelineLabel', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                    if (_dailyAmount != null) Text('Щоденно: ~${_dailyAmount!.formatUAH()} грн', style: AppTypography.labelSmall.copyWith(color: accentColor)),
                    const SizedBox(height: Spacing.xs),
                    Text('🎯 6 етапів від 10% до 100%', style: AppTypography.labelSmall.copyWith(color: accentColor)),
                  ],
                ),
              ),
            ],
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildSharePreview(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Моя ціль';
    return GestureDetector(
      onTap: () { HapticService.selection(); setState(() => _showSharePreview = !_showSharePreview); },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.only(top: Spacing.base),
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.1))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('📤 Поділитися ціллю', style: AppTypography.labelMedium.copyWith(color: accentColor)),
              Icon(_showSharePreview ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accentColor, size: 18),
            ]),
            if (_showSharePreview) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(color: isLight ? AppColorsMonitor.surface : AppColorsPS5.surface, borderRadius: BorderRadius.circular(Radii.md)),
                child: Column(children: [
                  Text('🎯 Я накопичую на «$name»', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
                  if (amount > 0) Text('Сума: ${amount.toInt().formatUAH()} грн', style: AppTypography.labelSmall.copyWith(color: accentColor)),
                  Text('Термін: $_selectedTimelineLabel', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                  const SizedBox(height: Spacing.sm),
                  Text('Долучайся до Nexora! 💎', style: AppTypography.labelSmall.copyWith(color: accentColor, fontStyle: FontStyle.italic)),
                ]),
              ),
            ],
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 550.ms);
  }

  Widget _buildSimilarGoals(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Container(
      margin: const EdgeInsets.only(top: Spacing.base),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: accentColor.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accentColor.withOpacity(0.08))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () { HapticService.selection(); setState(() => _showComparison = !_showComparison); },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📊 Порівняння з подібними', style: AppTypography.labelMedium.copyWith(color: accentColor)),
                Icon(_showComparison ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accentColor, size: 18),
              ],
            ),
          ),
          if (_showComparison) ...[
            const SizedBox(height: Spacing.sm),
            ..._similarGoals.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(g['name'] as String, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
                  ),
                  Text('${(g['amount'] as int).formatUAH()} грн — ${(g['percent'] as int)}% досягнуто', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                ],
              ),
            )),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildProgressIndicator(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final bgColor = isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Column(
        children: [
          const SizedBox(height: Spacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Крок 3 з 4', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
            Text('Налаштування цілі', style: AppTypography.labelMedium.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: Spacing.sm),
          Row(children: List.generate(4, (index) {
            final isCompleted = index < 2;
            final isActive = index == 2;
            return Expanded(child: Container(height: 3, margin: EdgeInsets.only(right: index < 3 ? Spacing.xs : 0), decoration: BoxDecoration(color: isCompleted ? accentColor : isActive ? accentColor.withOpacity(0.5) : bgColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2))));
          })),
        ],
      ),
    );
  }
}

class _Milestone {
  final int percent;
  final String label;
  final String emoji;
  const _Milestone({required this.percent, required this.label, required this.emoji});
}
