import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Екран налаштування нового автоплатежу з повною валідацією,
/// анімованим сегмент-контролем, селектором днів та преглядом.
class SetupAutopayScreen extends StatefulWidget {
  const SetupAutopayScreen({super.key});

  static const String route = '/setup-autopay';

  @override
  State<SetupAutopayScreen> createState() => _SetupAutopayScreenState();
}

class _SetupAutopayScreenState extends State<SetupAutopayScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _limitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // ── State ──────────────────────────────────────────────────────────
  Frequency _frequency = Frequency.monthly;
  int? _selectedDayOfWeek;
  int? _selectedDayOfMonth;
  bool _onlyIfFunds = false;
  bool _showLimit = false;
  bool _isSaving = false;

  // ── Animation controllers ──────────────────────────────────────────
  late AnimationController _slideIndicatorController;
  late AnimationController _projectionController;
  late Animation<double> _slideIndicatorAnim;
  late Animation<double> _projectionFadeAnim;

  // ── Constants ──────────────────────────────────────────────────────
  static const _weekdays = [
    'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд',
  ];

  static const _frequencyLabels = [
    'Щодня', 'Щотижня', 'Раз на 2 тижні', 'Щомісяця',
  ];

  static const _frequencyValues = [
    Frequency.daily,
    Frequency.weekly,
    Frequency.biweekly,
    Frequency.monthly,
  ];

  bool get _showDayPicker =>
      _frequency == Frequency.weekly || _frequency == Frequency.biweekly;

  bool get _showMonthDayPicker => _frequency == Frequency.monthly;

  double? get _parsedAmount {
    final val = double.tryParse(_amountController.text);
    return val;
  }

  int get _monthlyPayments {
    switch (_frequency) {
      case Frequency.daily:
        return 30;
      case Frequency.weekly:
        return 4;
      case Frequency.biweekly:
        return 2;
      case Frequency.monthly:
        return 1;
    }
  }

  double get _monthlyProjection {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) return 0;
    return amount * _monthlyPayments;
  }

  double? get _parsedLimit {
    final val = double.tryParse(_limitController.text);
    return val;
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);

    // Slide indicator animation for segmented control
    _slideIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideIndicatorAnim = CurvedAnimation(
      parent: _slideIndicatorController,
      curve: AppEasings.standard,
    );

    // Projection fade animation
    _projectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _projectionFadeAnim = CurvedAnimation(
      parent: _projectionController,
      curve: Curves.easeOut,
    );
    _projectionController.forward();
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _limitController.dispose();
    _scrollController.dispose();
    _slideIndicatorController.dispose();
    _projectionController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    // Restart projection animation on amount change
    _projectionController.forward(from: 0);
  }

  void _onFrequencyChanged(int newIndex) {
    HapticService.selection();
    setState(() {
      _frequency = _frequencyValues[newIndex];
      // Reset day selection when changing to a type that doesn't need it
      if (!_showDayPicker && !_showMonthDayPicker) {
        _selectedDayOfWeek = null;
        _selectedDayOfMonth = null;
      }
    });
    _slideIndicatorController.forward(from: 0);
    // Restart projection
    _projectionController.forward(from: 0);
  }

  void _onToggleOnlyIfFunds() {
    HapticService.switchToggle();
    setState(() => _onlyIfFunds = !_onlyIfFunds);
  }

  void _onToggleShowLimit() {
    HapticService.lightTap();
    setState(() => _showLimit = !_showLimit);
  }

  String? _validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введи суму';
    final num = double.tryParse(v);
    if (num == null) return 'Невірний формат числа';
    if (num <= 0) return 'Сума має бути більшою за 0';
    if (num < 10) return 'Мінімальна сума — 10 грн';
    return null;
  }

  String? _validateLimit(String? v) {
    if (v == null || v.trim().isEmpty) return null; // Optional field
    final num = double.tryParse(v);
    if (num == null) return 'Невірний формат числа';
    if (num <= 0) return 'Ліміт має бути більшим за 0';
    if (_parsedAmount != null && num < _parsedAmount!) {
      return 'Ліміт не може бути меншим за суму внеску';
    }
    return null;
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticService.error();
      return;
    }
    // Additional validation: day must be selected for weekly/biweekly
    if (_showDayPicker && _selectedDayOfWeek == null) {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Обери день тижня для автоплатежу')),
      );
      return;
    }
    if (_showMonthDayPicker && _selectedDayOfMonth == null) {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Обери день місяця для автоплатежу')),
      );
      return;
    }

    // Validate limit if provided
    if (_showLimit && _limitController.text.isNotEmpty) {
      final limitError = _validateLimit(_limitController.text);
      if (limitError != null) {
        HapticService.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(limitError)),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    HapticService.success();

    // Simulate save delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Новий автоплатіж',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Spacing.base),
            child: Center(
              child: Text(
                '1/2',
                style: AppTypography.labelMedium.copyWith(
                  color: c.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.base),

                // ── Intro hint ───────────────────────────────────────
                _buildIntroHint(c).animate().fadeIn(
                  duration: 300.ms,
                  delay: 100.ms,
                ),

                const SizedBox(height: Spacing.xl),

                // ── Amount field with currency ──────────────────────
                _buildSectionTitle('Сума автоплатежу', c),
                const SizedBox(height: Spacing.sm),
                _buildAmountField(c),

                const SizedBox(height: Spacing.xl),

                // ── Frequency selector (custom segmented control) ──
                _buildSectionTitle('Частота', c),
                const SizedBox(height: Spacing.sm),
                _buildCustomSegmentedControl(c),

                const SizedBox(height: Spacing.xl),

                // ── Day picker (for weekly/biweekly) ────────────────
                AnimatedSize(
                  duration: AppDurations.medium,
                  curve: AppEasings.standard,
                  alignment: Alignment.topCenter,
                  child: _showDayPicker
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('День тижня', c),
                            const SizedBox(height: Spacing.sm),
                            _buildDayPicker(c),
                            if (_selectedDayOfWeek == null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: Spacing.xs,
                                ),
                                child: Text(
                                  'Обери день для автоматичного внеску',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: c.warning,
                                  ),
                                ),
                              ),
                            const SizedBox(height: Spacing.xl),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Month day picker ────────────────────────────────
                AnimatedSize(
                  duration: AppDurations.medium,
                  curve: AppEasings.standard,
                  alignment: Alignment.topCenter,
                  child: _showMonthDayPicker
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('День місяця', c),
                            const SizedBox(height: Spacing.sm),
                            _buildMonthDayPicker(c),
                            if (_selectedDayOfMonth == null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: Spacing.xs,
                                ),
                                child: Text(
                                  'Обери день для автоматичного внеску',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: c.warning,
                                  ),
                                ),
                              ),
                            const SizedBox(height: Spacing.xl),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Toggle «Тільки якщо є кошти» ────────────────────
                _buildToggleCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Тільки якщо є кошти',
                  subtitle: 'Пропускати, якщо недостатньо балансу',
                  value: _onlyIfFunds,
                  onTap: _onToggleOnlyIfFunds,
                  c: c,
                  isDark: isDark,
                ),
                const SizedBox(height: Spacing.base),

                // ── Limit per period ────────────────────────────────
                _buildLimitSection(c, isDark),

                const SizedBox(height: Spacing.xl),

                // ── Monthly projection preview ──────────────────────
                _buildProjectionCard(c, isDark),

                const SizedBox(height: Spacing.xxxl),

                // ── Save button ─────────────────────────────────────
                _buildSaveButton(c, isDark),

                const SizedBox(height: Spacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget builders ──────────────────────────────────────────────

  Widget _buildIntroHint(dynamic c) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: c.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: c.accent, size: 20),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              'Автоплатіж буде автоматично списувати вказану суму '
              'у вибраний день. Ти зможеш змінити або скасувати його у будь-який час.',
              style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, dynamic c) {
    return Text(
      title,
      style: AppTypography.heading3.copyWith(color: c.textPrimary),
    );
  }

  Widget _buildAmountField(dynamic c) {
    return AppTextField(
      controller: _amountController,
      hint: 'Введи суму',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      isLightTheme: Theme.of(context).brightness != Brightness.dark,
      prefixIcon: Icon(Icons.attach_money_rounded, color: c.textHint),
      suffixText: 'грн',
      suffixStyle: AppTypography.bodyLarge.copyWith(
        color: c.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      validator: _validateAmount,
    );
  }

  Widget _buildCustomSegmentedControl(dynamic c) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth =
            (constraints.maxWidth - (_frequencyLabels.length - 1) * 4) /
                _frequencyLabels.length;
        final selectedIndex = _frequencyValues.indexOf(_frequency);

        return AnimatedBuilder(
          animation: _slideIndicatorController,
          builder: (context, _) {
            return Container(
              height: 44,
              decoration: BoxDecoration(
                color: c.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: Stack(
                children: [
                  // Animated slide indicator
                  Positioned(
                    left: selectedIndex * (segmentWidth + 4),
                    top: 3,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: AppEasings.standard,
                      width: segmentWidth,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(Radii.md),
                        boxShadow: [
                          BoxShadow(
                            color: c.accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Labels
                  Row(
                    children: List.generate(_frequencyLabels.length, (index) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onFrequencyChanged(index),
                          child: Container(
                            alignment: Alignment.center,
                            height: 44,
                            child: Text(
                              _frequencyLabels[index],
                              style: AppTypography.labelMedium.copyWith(
                                color: index == selectedIndex
                                    ? Colors.white
                                    : c.textSecondary,
                                fontWeight: index == selectedIndex
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayPicker(dynamic c) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weekdays.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
        itemBuilder: (context, index) {
          final isSelected = _selectedDayOfWeek == (index + 1);
          final dayNumber = index + 1;
          return GestureDetector(
            onTap: () {
              HapticService.selection();
              setState(() => _selectedDayOfWeek = dayNumber);
            },
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppEasings.spring,
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(
                  color: isSelected ? c.accent : c.border,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: c.accent.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[index],
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : c.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthDayPicker(dynamic c) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 28,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = _selectedDayOfMonth == day;
          return GestureDetector(
            onTap: () {
              HapticService.selection();
              setState(() => _selectedDayOfMonth = day);
            },
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppEasings.spring,
              margin: const EdgeInsets.only(right: Spacing.xs),
              width: 40,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(
                  color: isSelected ? c.accent : c.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : c.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onTap,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (value ? c.accent : c.textHint).withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(
              icon,
              color: value ? c.accent : c.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge
                      .copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: c.textHint,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Switch(
              value: value,
              onChanged: (_) => onTap(),
              activeColor: c.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitSection(dynamic c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _onToggleShowLimit,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                'Обмеження за період',
                style: AppTypography.bodyLarge
                    .copyWith(color: c.textPrimary),
              ),
              const SizedBox(width: Spacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.xs),
                ),
                child: Text(
                  'Необов\'язково',
                  style: AppTypography.caption.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _showLimit
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: c.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
        if (_showLimit) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            'Максимальна сума, яку буде списано за один період. '
            'Після досягнення ліміту автоплатіж тимчасово зупиниться.',
            style: AppTypography.bodySmall.copyWith(
              color: c.textHint,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          AppTextField(
            controller: _limitController,
            hint: 'Максимальна сума за період',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isLightTheme: !isDark,
            prefixIcon: Icon(Icons.speed_rounded, color: c.textHint),
            suffixText: 'грн',
            suffixStyle: AppTypography.bodyLarge.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            validator: _validateLimit,
          ),
          const SizedBox(height: Spacing.sm),
          if (_parsedAmount != null && _parsedLimit != null && _parsedLimit! > 0)
            _buildLimitProgressBar(c),
        ],
      ],
    );
  }

  Widget _buildLimitProgressBar(dynamic c) {
    final ratio = (_parsedAmount! / _parsedLimit!).clamp(0.0, 1.0);
    final remaining = _parsedLimit! - _parsedAmount!;
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Один внесок = ${(ratio * 100).toStringAsFixed(0)}% ліміту',
                style: AppTypography.labelSmall.copyWith(color: c.textHint),
              ),
              Text(
                'Залишок: ${remaining.formatUAH()} грн',
                style: AppTypography.labelSmall.copyWith(
                  color: ratio > 0.8 ? c.warning : c.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.xs),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: c.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.8 ? c.warning : c.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(dynamic c, bool isDark) {
    final amount = _parsedAmount;
    final hasAmount = amount != null && amount > 0;

    return AnimatedBuilder(
      animation: _projectionController,
      builder: (context, _) {
        final opacity = _projectionFadeAnim.value;
        return Opacity(
          opacity: opacity,
          child: AppCard(
            isLightTheme: !isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: c.accent,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Прогноз на місяць',
                      style: AppTypography.heading3
                          .copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.base),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProjectionItem(
                      label: 'Кількість платежів',
                      value: '$_monthlyPayments',
                      icon: Icons.receipt_long_rounded,
                      c: c,
                    ),
                    _buildProjectionItem(
                      label: 'Сума за внесок',
                      value: hasAmount
                          ? '${amount!.formatUAH()} грн'
                          : '—',
                      icon: Icons.payments_rounded,
                      c: c,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.base,
                    vertical: Spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: c.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(
                      color: c.success.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Загалом за місяць',
                        style: AppTypography.bodyMedium
                            .copyWith(color: c.textSecondary),
                      ),
                      Text(
                        hasAmount
                            ? '~${_monthlyProjection.formatUAH()} грн'
                            : '—',
                        style: AppTypography.monoMedium.copyWith(
                          color: c.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_onlyIfFunds) ...[
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: c.accent,
                        size: 16,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        'Захист від нестачі коштів увімкнено',
                        style: AppTypography.labelSmall.copyWith(
                          color: c.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectionItem({
    required String label,
    required String value,
    required IconData icon,
    required dynamic c,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: c.textHint, size: 20),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: c.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(dynamic c, bool isDark) {
    return Column(
      children: [
        AppButtonPrimary(
          label: _isSaving ? 'Збереження...' : 'Зберегти',
          onPressed: _isSaving ? null : _onSave,
          isLightTheme: !isDark,
          icon: _isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.8),
                  ),
                )
              : Icons.check_rounded,
        ),
        const SizedBox(height: Spacing.md),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Скасувати',
            style: AppTypography.labelMedium.copyWith(
              color: c.textHint,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Autopay Validation Utilities (Утиліти валідації автоплатежу)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для валідації форми автоплатежу.
///
/// Містить статичні методи для перевірки сум, лімітів, днів та частоти.
class AutopayValidator {
  /// Константа — не дозволяємо створювати екземпляри.
  AutopayValidator._();

  /// Мінімальна сума автоплатежу (грн).
  static const double minAmount = 10.0;

  /// Максимальна сума автоплатежу (грн).
  static const double maxAmount = 50000.0;

  /// Максимальна кількість активних автоплатежів на користувача.
  static const int maxActiveAutopays = 5;

  /// Мінімальний ліміт за період (грн).
  static const double minPeriodLimit = 50.0;

  /// Максимальний ліміт за період (грн).
  static const double maxPeriodLimit = 200000.0;

  /// Валідує суму автоплатежу.
  ///
  /// Повертає повідомлення про помилку або `null` якщо сума коректна.
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть суму автоплатежу';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Невірний формат числа';
    }
    if (parsed <= 0) {
      return 'Сума має бути більшою за 0';
    }
    if (parsed < minAmount) {
      return 'Мінімальна сума — $minAmount грн';
    }
    if (parsed > maxAmount) {
      return 'Максимальна сума — ${maxAmount.toInt()} грн';
    }
    return null;
  }

  /// Валідує ліміт за період.
  ///
  /// [limitValue] — введене значення ліміту.
  /// [amountValue] — сума одного автоплатежу.
  static String? validatePeriodLimit(String? limitValue, double amountValue) {
    if (limitValue == null || limitValue.trim().isEmpty) return null;
    final parsed = double.tryParse(limitValue);
    if (parsed == null) {
      return 'Невірний формат числа';
    }
    if (parsed <= 0) {
      return 'Ліміт має бути більшим за 0';
    }
    if (parsed < minPeriodLimit) {
      return 'Мінімальний ліміт — $minPeriodLimit грн';
    }
    if (parsed > maxPeriodLimit) {
      return 'Максимальний ліміт — ${maxPeriodLimit.toInt()} грн';
    }
    if (parsed < amountValue) {
      return 'Ліміт не може бути меншим за суму внеску';
    }
    return null;
  }

  /// Валідує вибір дня тижня.
  ///
  /// Повертає `true` якщо день обраний коректно.
  static bool isValidDayOfWeek(int? day) {
    return day != null && day >= 1 && day <= 7;
  }

  /// Валідує вибір дня місяця.
  ///
  /// Повертає `true` якщо день обраний коректно (1-28).
  static bool isValidDayOfMonth(int? day) {
    return day != null && day >= 1 && day <= 28;
  }

  /// Валідує частоту автоплатежу для вибраного дня.
  ///
  /// Перевіряє, чи частота потребує вибору дня.
  static bool requiresDaySelection(Frequency frequency) {
    return frequency == Frequency.weekly ||
        frequency == Frequency.biweekly ||
        frequency == Frequency.monthly;
  }

  /// Обчислює відсоток споживання ліміту.
  ///
  /// Повертає значення від 0.0 до 1.0.
  static double limitUsageRatio(double amount, double limit) {
    if (limit <= 0) return 1.0;
    return (amount / limit).clamp(0.0, 1.0);
  }

  /// Визначає колір індикатора ліміту на основі споживання.
  ///
  /// < 50% — зелений, 50-80% — жовтий, > 80% — червоний.
  static String limitUsageLevel(double ratio) {
    if (ratio < 0.5) return 'low';
    if (ratio < 0.8) return 'medium';
    return 'high';
  }

  /// Перевіряє, чи можна створити ще один автоплатіж.
  ///
  /// [currentCount] — поточна кількість активних автоплатежів.
  static bool canCreateAutopay(int currentCount) {
    return currentCount < maxActiveAutopays;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Autopay Configuration Model (Конфігурація автоплатежу)
// ═══════════════════════════════════════════════════════════════════════════

/// Модель конфігурації автоплатежу для передачі між екранами.
///
/// Містить усі необхідні дані для створення запланованого платежу.
class AutopayConfiguration {
  /// ID автоплатежу.
  final String id;

  /// Сума кожного платежу.
  final double amount;

  /// Частота платежу.
  final Frequency frequency;

  /// День тижня (1=Пн, 7=Нд). Лише для weekly/biweekly.
  final int? dayOfWeek;

  /// День місяця (1-28). Лише для monthly.
  final int? dayOfMonth;

  /// Чи списувати лише за наявності коштів.
  final bool onlyIfFundsAvailable;

  /// Максимальний ліміт за період (null = без ліміту).
  final double? periodLimit;

  /// Коментар до автоплатежу.
  final String comment;

  /// Дата створення.
  final DateTime createdAt;

  /// Чи активний автоплатіж.
  final bool isActive;

  /// Кількість успішних виконань.
  final int executionCount;

  /// Дата останнього виконання.
  final DateTime? lastExecutedAt;

  const AutopayConfiguration({
    required this.id,
    required this.amount,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.onlyIfFundsAvailable = false,
    this.periodLimit,
    this.comment = '',
    required this.createdAt,
    this.isActive = true,
    this.executionCount = 0,
    this.lastExecutedAt,
  });

  /// Створює копію з оновленими полями.
  AutopayConfiguration copyWith({
    double? amount,
    Frequency? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    bool? onlyIfFundsAvailable,
    double? periodLimit,
    String? comment,
    bool? isActive,
    int? executionCount,
    DateTime? lastExecutedAt,
    bool clearLastExecuted = false,
  }) {
    return AutopayConfiguration(
      id: id,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      onlyIfFundsAvailable:
          onlyIfFundsAvailable ?? this.onlyIfFundsAvailable,
      periodLimit: periodLimit ?? this.periodLimit,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      executionCount: executionCount ?? this.executionCount,
      lastExecutedAt:
          clearLastExecuted ? null : (lastExecutedAt ?? this.lastExecutedAt),
    );
  }

  /// Обчислює кількість платежів за місяць на основі частоти.
  int get monthlyPayments {
    switch (frequency) {
      case Frequency.daily:
        return 30;
      case Frequency.weekly:
        return 4;
      case Frequency.biweekly:
        return 2;
      case Frequency.monthly:
        return 1;
    }
  }

  /// Обчислює прогнозовану суму за місяць.
  double get monthlyProjection {
    return amount * monthlyPayments;
  }

  /// Обчислює прогнозовану суму за рік.
  double get yearlyProjection {
    return monthlyProjection * 12;
  }

  /// Обчислює залишок ліміту за поточний період.
  ///
  /// Якщо ліміт не встановлено, повертає `null`.
  double? remainingLimit {
    if (periodLimit == null) return null;
    final spent = amount * executionCount;
    return (periodLimit! - spent).clamp(0, periodLimit!);
  }

  /// Чи наближається до ліміту (спожито > 80%).
  bool get isNearLimit {
    if (periodLimit == null) return false;
    return remainingLimit != null && (remainingLimit! / periodLimit!) < 0.2;
  }

  /// Чи ліміт вичерпано.
  bool get isLimitReached {
    if (periodLimit == null) return false;
    return remainingLimit != null && remainingLimit! <= 0;
  }

  /// Форматує опис частоти українською.
  String get frequencyLabel {
    switch (frequency) {
      case Frequency.daily:
        return 'Щодня';
      case Frequency.weekly:
        return 'Щотижня';
      case Frequency.biweekly:
        return 'Раз на 2 тижні';
      case Frequency.monthly:
        return 'Щомісяця';
    }
  }

  /// Форматує опис дня платежу українською.
  String get dayLabel {
    if (frequency == Frequency.monthly && dayOfMonth != null) {
      return '$dayOfMonth-го числа';
    }
    if ((frequency == Frequency.weekly ||
            frequency == Frequency.biweekly) &&
        dayOfWeek != null) {
      const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
      return days[dayOfWeek! - 1];
    }
    return '';
  }

  /// Повертає повний опис автоплатежу для UI.
  String get displaySummary {
    final buffer = StringBuffer();
    buffer.write('$frequencyLabel');
    if (dayLabel.isNotEmpty) {
      buffer.write(', $dayLabel');
    }
    buffer.write(' — ${amount.toInt()} грн');
    return buffer.toString();
  }

  /// Повертає детальний опис для екрана підтвердження.
  String get confirmationDetails {
    final buffer = StringBuffer();
    buffer.writeln('Сума: $amount грн');
    buffer.writeln('Частота: $frequencyLabel');
    if (dayLabel.isNotEmpty) {
      buffer.writeln('День: $dayLabel');
    }
    buffer.writeln('За місяць: ~${monthlyProjection.toInt()} грн');
    if (periodLimit != null) {
      buffer.writeln('Ліміт: ${periodLimit!.toInt()} грн/період');
    }
    if (onlyIfFundsAvailable) {
      buffer.writeln('Тільки за наявності коштів');
    }
    return buffer.toString().trimRight();
  }

  /// Перевіряє коректність конфігурації.
  bool get isValid {
    if (amount < AutopayValidator.minAmount) return false;
    if (amount > AutopayValidator.maxAmount) return false;
    if (frequency == Frequency.weekly ||
        frequency == Frequency.biweekly) {
      if (!AutopayValidator.isValidDayOfWeek(dayOfWeek)) return false;
    }
    if (frequency == Frequency.monthly) {
      if (!AutopayValidator.isValidDayOfMonth(dayOfMonth)) return false;
    }
    return true;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Autopay Theme Constants
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для екрану налаштування автоплатежу.
///
/// Включає розміри, тривалості анімацій, порогові значення.
class AutopayConstants {
  /// Константа — не дозволяємо створювати екземпляри.
  AutopayConstants._();

  /// Висота сегмент-контролю.
  static const double segmentControlHeight = 44.0;

  /// Відступ індикатора сегмент-контролю від верху.
  static const double segmentIndicatorTop = 3.0;

  /// Висота індикатора сегмент-контролю.
  static const double segmentIndicatorHeight = 38.0;

  /// Висота пікера днів тижня.
  static const double dayPickerHeight = 52.0;

  /// Ширина кнопки дня тижня.
  static const double dayButtonWidth = 48.0;

  /// Ширина кнопки дня місяця.
  static const double monthDayButtonWidth = 40.0;

  /// Висота кнопки дня місяця.
  static const double monthDayButtonHeight = 48.0;

  /// Розмір іконки toggle картки.
  static const double toggleIconSize = 22.0;

  /// Розмір контейнера іконки toggle.
  static const double toggleIconContainerSize = 40.0;

  /// Розмір іконки вводу.
  static const double inputIconSize = 20.0;

  /// Розмір іконки прогресу.
  static const double progressIconSize = 20.0;

  /// Розмір іконки секції прогностики.
  static const double insightIconSize = 20.0;

  /// Розмір іконки захисту.
  static const double shieldIconSize = 16.0;

  /// Кількість днів місяця, доступних для вибору.
  static const int monthDaysCount = 28;

  /// Відсоток порогу «близько до ліміту».
  static const double limitWarningThreshold = 0.8;

  /// Тривалість анімації індикатора сегмент-контролю.
  static const Duration segmentAnimationDuration = Duration(milliseconds: 300);

  /// Тривалість анімації прогностики.
  static const Duration projectionFadeDuration = Duration(milliseconds: 400);

  /// Тривалість анімації контейнерів.
  static const Duration containerAnimationDuration = Duration(milliseconds: 200);

  /// Тривалість затримки збереження (імітація).
  static const Duration saveSimulationDelay = Duration(milliseconds: 600);

  /// Мінімальна ширина екрану для адаптивної розмітки.
  static const double minScreenWidth = 360.0;

  /// Відступ між секціями (великий).
  static const double sectionSpacingLarge = Spacing.xl;

  /// Відступ між секціями (середній).
  static const double sectionSpacingMedium = Spacing.base;

  /// Максимальна кількість символів у коментарі.
  static const int maxCommentLength = 200;

  /// Кількість днів у стандартному місяці для розрахунку.
  static const int daysInMonth = 30;

  /// Кількість тижнів у місяці для розрахунку.
  static const int weeksInMonth = 4;

  /// Кількість би-тижнів у місяці.
  static const int biweeksInMonth = 2;

  /// Кількість місяців у році.
  static const int monthsInYear = 12;
}

// ═══════════════════════════════════════════════════════════════════════════
// Autopay Summary Helper (Допоміжний форматування)
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для форматування даних автоплатежу.
///
/// Надає методи для форматування сум, дат та описів.
class AutopayFormatter {
  /// Константа — не дозволяємо створювати екземпляри.
  AutopayFormatter._();

  /// Дні тижня українською (скорочено).
  static const List<String> weekdaysShort = [
    'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд',
  ];

  /// Дні тижня українською (повністю).
  static const List<String> weekdaysFull = [
    'Понеділок', 'Вівторок', 'Середа', 'Четвер', 'П\'ятниця', 'Субота', 'Неділя',
  ];

  /// Повертає назву дня тижня за номером (1=Пн, 7=Нд).
  static String weekdayName(int day, {bool short = true}) {
    if (day < 1 || day > 7) return '';
    return short
        ? weekdaysShort[day - 1]
        : weekdaysFull[day - 1];
  }

  /// Повертає порядковий номер дня місяця з суфіксом.
  ///
  /// Наприклад: «1-ше», «2-ге», «5-те», «10-те», «25-те».
  static String dayOfMonthWithSuffix(int day) {
    if (day < 1 || day > 31) return '';
    if (day == 1) return '$day-ше';
    if (day == 2) return '$day-ге';
    if (day == 3) return '$day-те';
    if (day == 4) return '$day-те';
    if (day >= 5 && day <= 20) return '$day-те';
    final lastDigit = day % 10;
    if (lastDigit == 1) return '$day-ше';
    if (lastDigit == 2) return '$day-ге';
    if (lastDigit == 3) return '$day-те';
    return '$day-те';
  }

  /// Форматує опис наступного платежу.
  ///
  /// Наприклад: «Щовівторка, 100 грн».
  static String formatNextPayment(AutopayConfiguration config) {
    final buffer = StringBuffer();
    if (config.frequency == Frequency.monthly && config.dayOfMonth != null) {
      buffer.write('Кожного ${dayOfMonthWithSuffix(config.dayOfMonth!)}');
    } else if (config.frequency == Frequency.weekly && config.dayOfWeek != null) {
      buffer.write('Що${_genitiveWeekday(config.dayOfWeek!)}');
    } else if (config.frequency == Frequency.biweekly && config.dayOfWeek != null) {
      buffer.write('Раз на два тижні, що${_genitiveWeekday(config.dayOfWeek!)}');
    } else {
      buffer.write(config.frequencyLabel);
    }
    buffer.write(' — ${config.amount.toInt()} грн');
    return buffer.toString();
  }

  /// Повертає назву дня тижня в родовому відмінку (для фрази «що [день]»).
  static String _genitiveWeekday(int day) {
    switch (day) {
      case 1: return 'понеділка';
      case 2: return 'вівторка';
      case 3: return 'середи';
      case 4: return 'четверга';
      case 5: return 'п\'ятниці';
      case 6: return 'суботи';
      case 7: return 'неділі';
      default: return '';
    }
  }

  /// Форматує розмір прогностики для відображення.
  static String formatProjection(double amount, int paymentsPerMonth) {
    final total = amount * paymentsPerMonth;
    if (total >= 1000) {
      return '~${(total / 1000).toStringAsFixed(1)} тис. грн/міс';
    }
    return '~${total.toInt()} грн/міс';
  }
}
