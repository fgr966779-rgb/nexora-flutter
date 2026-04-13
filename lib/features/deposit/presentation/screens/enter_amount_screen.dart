import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/deposit_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'confirm_deposit_screen.dart';

/// Екран введення суми внеску з пресетами, коментарем та попереднім балансом.
class EnterAmountScreen extends StatefulWidget {
  const EnterAmountScreen({super.key});

  static const String route = '/enter-amount';

  @override
  State<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends State<EnterAmountScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  final _amountFocusNode = FocusNode();

  double _enteredAmount = 0;
  bool _isCustom = false;
  bool _commentExpanded = false;
  bool _isSubmitting = false;
  bool _hasError = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  /// Клавіші num-pad для ручного введення.
  static const _numPadKeys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['000', '0', '⌫'],
  ];

  static const _presetsRow1 = [50.0, 100.0, 200.0, 500.0];
  static const _presetsRow2 = [1000.0, 2000.0, 5000.0];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _commentController.dispose();
    _amountFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final parsed = int.tryParse(raw) ?? 0;
    setState(() => _enteredAmount = parsed.toDouble());
  }

  /// Натискання кнопки пресету.
  void _selectPreset(double amount) {
    HapticService.selection();
    setState(() {
      _enteredAmount = amount;
      _isCustom = false;
      _hasError = false;
      _amountController.text = amount.toInt().toString();
    });
  }

  /// Перехід у режим ручного введення.
  void _selectCustom() {
    HapticService.selection();
    setState(() {
      _isCustom = true;
      _hasError = false;
    });
    _amountFocusNode.requestFocus();
  }

  /// Натискання цифри на num-pad.
  void _onNumPadKey(String key) {
    HapticService.lightTap();
    setState(() => _hasError = false);

    if (key == '⌫') {
      final text = _amountController.text;
      if (text.isNotEmpty) {
        _amountController.text = text.substring(0, text.length - 1);
        final parsed = int.tryParse(_amountController.text) ?? 0;
        setState(() => _enteredAmount = parsed.toDouble());
      }
      return;
    }

    final newText = _amountController.text + key;
    final parsed = int.tryParse(newText) ?? 0;
    if (parsed > 999999) return; // Максимальна сума

    _amountController.text = newText;
    setState(() => _enteredAmount = parsed.toDouble());
  }

  /// Показати помилку з shake-анімацією.
  void _showError() {
    HapticService.error();
    setState(() => _hasError = true);
    _shakeController.forward(from: 0);
  }

  /// Надіслати внесок.
  void _onSubmit() async {
    if (_enteredAmount < 10) {
      _showError();
      return;
    }

    HapticService.lightTap();
    setState(() => _isSubmitting = true);

    final depositProvider = context.read<DepositProvider>();
    depositProvider.setPending(
      amount: _enteredAmount,
      comment: _commentController.text.trim(),
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    AppBottomSheetConfirm.show(
      context,
      amount: _enteredAmount,
      comment: _commentController.text.trim(),
    );
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
          'Скільки відкладаємо?',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Spacing.xl),
              // ── Великий відображення суми (56pt) ──────────
              _buildAmountDisplay(c),
              const SizedBox(height: Spacing.sm),
              // ── Попередній баланс ───────────────────────
              _buildBalancePreview(c),
              const SizedBox(height: Spacing.xxl),
              // ── Ряд пресетів 1 ──────────────────────────
              _buildPresetsRow(_presetsRow1, c),
              const SizedBox(height: Spacing.sm),
              // ── Ряд пресетів 2 + Custom ─────────────────
              _buildPresetsRow2(c),
              const SizedBox(height: Spacing.xl),
              // ── Numpad (при ручному введенні) ────────────
              AnimatedSize(
                duration: AppDurations.medium,
                curve: AppEasings.standard,
                child: _isCustom ? _buildNumPad(c) : const SizedBox.shrink(),
              ),
              const SizedBox(height: Spacing.xl),
              // ── Поле коментаря ──────────────────────────
              _buildCommentField(c),
              const SizedBox(height: Spacing.xxl),
              // ── Кнопка «Додати» ─────────────────────────
              _buildSubmitButton(c),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  /// Велике відображення суми з 56pt шрифтом та анімацією slide-up.
  Widget _buildAmountDisplay(dynamic c) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = _hasError
            ? math.sin(_shakeAnimation.value * math.pi * 6) * 8
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() => _isCustom = true);
          _amountFocusNode.requestFocus();
        },
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: _enteredAmount,
              ),
              duration: const Duration(milliseconds: 300),
              curve: AppEasings.decelerate,
              builder: (context, value, _) {
                return Text(
                  value > 0 ? value.formatUAH() : '0',
                  style: AppTypography.monoLarge.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: _hasError
                        ? c.error
                        : (value > 0 ? c.textPrimary : c.textHint),
                    letterSpacing: -1.5,
                  ),
                );
              },
            )
                .animate(target: _enteredAmount > 0 ? 1 : 0)
                .slideY(
                  begin: 0.15,
                  end: 0,
                  duration: 250.ms,
                  curve: AppEasings.spring,
                ),
            const SizedBox(height: Spacing.xs),
            Text(
              'грн',
              style: AppTypography.bodyLarge.copyWith(color: c.textSecondary),
            ),
            if (_hasError) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                'Мінімальна сума — 10 грн',
                style: AppTypography.labelSmall.copyWith(color: c.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Попередній перегляд нового балансу.
  Widget _buildBalancePreview(dynamic c) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final current = provider.currentAmount;
        final newBalance = current + _enteredAmount;
        final target = provider.targetAmount;
        final newPct = target > 0
            ? ((newBalance / target) * 100).clamp(0, 100)
            : 0.0;

        if (_enteredAmount <= 0) return const SizedBox.shrink();

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _enteredAmount > 0 ? 1.0 : 0.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: c.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Radii.circular),
              border: Border.all(
                color: c.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    color: c.success, size: 16),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Новий баланс: ${newBalance.formatUAH()} грн',
                  style: AppTypography.labelMedium.copyWith(
                    color: c.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  '(${newPct.toStringAsFixed(1)}%)',
                  style: AppTypography.labelSmall.copyWith(
                    color: c.success.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(
              begin: -0.1,
              end: 0,
              duration: 200.ms,
            );
      },
    );
  }

  /// Ряд пресетів з анімацією fadeIn та scale.
  Widget _buildPresetsRow(List<double> values, dynamic c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: values.asMap().entries.map((entry) {
        final idx = entry.key;
        final val = entry.value;
        final isSelected = _enteredAmount == val && !_isCustom;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: GestureDetector(
            onTap: () => _selectPreset(val),
            child: AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppEasings.standard,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.circular),
                border: Border.all(
                  color: isSelected ? c.accent : c.border,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: c.accent.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                val.toInt().toString(),
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected ? Colors.white : c.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (idx * 60).ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                delay: (idx * 60).ms,
                curve: AppEasings.spring,
              ),
        );
      }).toList(),
    );
  }

  /// Другий ряд пресетів + кнопка «Своя».
  Widget _buildPresetsRow2(dynamic c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ..._presetsRow2.asMap().entries.map((entry) {
          final idx = entry.key;
          final val = entry.value;
          final isSelected = _enteredAmount == val && !_isCustom;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            child: GestureDetector(
              onTap: () => _selectPreset(val),
              child: AnimatedContainer(
                duration: AppDurations.medium,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? c.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.circular),
                  border: Border.all(
                    color: isSelected ? c.accent : c.border,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: c.accent.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  val.toInt().toString(),
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected ? Colors.white : c.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: ((idx + 4) * 60).ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                  delay: ((idx + 4) * 60).ms,
                  curve: AppEasings.spring,
                ),
          );
        }),
        // Кнопка «Своя»
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: GestureDetector(
            onTap: _selectCustom,
            child: AnimatedContainer(
              duration: AppDurations.medium,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.md,
              ),
              decoration: BoxDecoration(
                color: _isCustom ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.circular),
                border: Border.all(
                  color: _isCustom ? c.accent : c.border,
                  width: 1.5,
                ),
                boxShadow: _isCustom
                    ? [
                        BoxShadow(
                          color: c.accent.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: _isCustom ? Colors.white : c.textSecondary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Своя',
                    style: AppTypography.labelLarge.copyWith(
                      color: _isCustom ? Colors.white : c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 360.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                delay: 360.ms,
                curve: AppEasings.spring,
              ),
        ),
      ],
    );
  }

  /// Вбудований num-pad для ручного введення суми.
  Widget _buildNumPad(dynamic c) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        children: _numPadKeys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                return GestureDetector(
                  onTap: () => _onNumPadKey(key),
                  child: Container(
                    width: 72,
                    height: 48,
                    decoration: BoxDecoration(
                      color: key == '⌫' || key == '000'
                          ? c.border.withOpacity(0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Center(
                      child: key == '⌫'
                          ? Icon(Icons.backspace_outlined,
                              color: c.textSecondary, size: 22)
                          : Text(
                              key,
                              style: AppTypography.monoLarge.copyWith(
                                fontSize: 22,
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 250.ms,
          curve: AppEasings.standard,
        );
  }

  /// Поле коментаря з лічильником символів (макс. 80).
  Widget _buildCommentField(dynamic c) {
    final charCount = _commentController.text.length;
    final isNearLimit = charCount > 65;
    final isAtLimit = charCount >= 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _commentExpanded = true),
          child: AnimatedContainer(
            duration: AppDurations.medium,
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: _commentExpanded ? 100 : 48,
              maxHeight: 120,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: isAtLimit
                    ? c.error
                    : isNearLimit
                        ? c.warning
                        : c.border,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_commentExpanded)
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          color: c.textHint, size: 16),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Додати коментар (необовʼязково)',
                        style: AppTypography.bodyMedium
                            .copyWith(color: c.textHint),
                      ),
                    ],
                  ),
                if (_commentExpanded)
                  TextField(
                    controller: _commentController,
                    maxLength: 80,
                    maxLines: 3,
                    style: AppTypography.bodyLarge
                        .copyWith(color: c.textPrimary),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      hintText: 'Коментар до внеску...',
                      hintStyle: AppTypography.bodyMedium
                          .copyWith(color: c.textHint),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
              ],
            ),
          ),
        ),
        if (_commentExpanded)
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isNearLimit)
                      Icon(
                        isAtLimit ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                        color: isAtLimit ? c.error : c.warning,
                        size: 14,
                      ),
                    if (isNearLimit) const SizedBox(width: 4),
                    Text(
                      '$charCount/80',
                      style: AppTypography.labelSmall.copyWith(
                        color: isAtLimit
                            ? c.error
                            : isNearLimit
                                ? c.warning
                                : c.textHint,
                        fontWeight: isAtLimit ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  /// Кнопка «Додати» зі станами (disabled / submitting / enabled).
  Widget _buildSubmitButton(dynamic c) {
    final isValid = _enteredAmount >= 10 && !_isSubmitting;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AppButtonPrimary(
          label: _isSubmitting ? 'Обробка...' : 'Додати',
          icon: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icons.add_circle_outline_rounded,
          onPressed: isValid ? _onSubmit : null,
          isDisabled: !isValid,
          isLightTheme: Theme.of(context).brightness != Brightness.dark,
        ),
      ),
    ).animate(target: isValid ? 1 : 0).scale(
          begin: const Offset(0.98, 0.98),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: AppEasings.spring,
        );
  }
}

/// Стиль для «Ручний внесок» — відкриває модальне підтвердження.
class AppBottomSheetConfirm {
  static Future<void> show(
    BuildContext context, {
    required double amount,
    required String comment,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmDepositScreen(
        amount: amount,
        comment: comment,
        isLightTheme: !isDark,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи екрану введення суми
// ═══════════════════════════════════════════════════════════════════════════

/// Мінімальна сума внеску (грн).
const int _kMinDepositAmount = 10;

/// Максимальна сума внеску (грн).
const int _kMaxDepositAmount = 999999;

/// Максимальна довжина коментаря (символи).
const int _kMaxCommentLength = 80;

/// Поріг «близько до ліміту» коментаря (символи).
const int _kCommentNearLimit = 65;

/// Мінімальна тривалість сесії для аналітики (мілісекунди).
const int _kMinSessionDurationMs = 5000;

/// Затримка анімації появи пресетів (мілісекунди).
const int _kPresetAnimBaseDelayMs = 60;

/// Кількість «рекомендованих» сум для badge.
const int _kRecommendedPresetCount = 3;

/// Мінімальна сума для «великого» внеску (підсвічування).
const double _kLargeAmountThreshold = 5000.0;

/// Мінімальна сума для «середнього» внеску.
const double _kMediumAmountThreshold = 1000.0;

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні функції та розширення для екрану введення суми
// ═══════════════════════════════════════════════════════════════════════════

/// Перевіряє, чи сума є валідною для внеску.
///
/// Сума має бути >= [_kMinDepositAmount] та <= [_kMaxDepositAmount].
bool _isValidDepositAmount(double amount) {
  return amount >= _kMinDepositAmount && amount <= _kMaxDepositAmount;
}

/// Перевіряє, чи сума є «великою».
///
/// «Велика» сума >= [_kLargeAmountThreshold].
bool _isLargeAmount(double amount) {
  return amount >= _kLargeAmountThreshold;
}

/// Перевіряє, чи сума є «середньою».
bool _isMediumAmount(double amount) {
  return amount >= _kMediumAmountThreshold &&
      amount < _kLargeAmountThreshold;
}

/// Перевіряє, чи сума є «малою» (менше за мінімальну).
bool _isSmallAmount(double amount) {
  return amount < _kMinDepositAmount;
}

/// Обчислює XP за суму внеску (1 XP за 100 грн, min 5, max 50).
///
/// Формула: `amount ~/ 100`, обмежено діапазоном [5, 50].
int _computeXPForAmount(double amount) {
  return (amount ~/ 100).clamp(5, 50);
}

/// Обчислює монети за суму внеску (1 монета за 200 грн, min 1, max 25).
///
/// Формула: `amount ~/ 200`, обмежено діапазоном [1, 25].
int _computeCoinsForAmount(double amount) {
  return (amount ~/ 200).clamp(1, 25);
}

/// Обчислює відсоток від цільової суми.
///
/// Повертає 0.0, якщо поточний або цільовий баланс <= 0.
double _computeProgressPercentage(double current, double target) {
  if (target <= 0) return 0.0;
  return ((current / target) * 100).clamp(0.0, 100.0);
}

/// Обчислює ефективність внеску (XP + монети за 100 грн).
double _computeDepositEfficiency(double amount) {
  final xp = _computeXPForAmount(amount).toDouble();
  final coins = _computeCoinsForAmount(amount).toDouble();
  final unit = amount / 100;
  if (unit <= 0) return 0.0;
  return (xp + coins) / unit;
}

/// Форматує суму з розрядками та знаком валюти.
///
/// Наприклад: «1 234 грн».
String _formatAmountWithSpaces(double amount) {
  final formatted = amount.toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < formatted.length; i++) {
    if (i > 0 && (formatted.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(formatted[i]);
  }
  return '$buffer грн';
}

/// Форматує XP за суму як зручний рядок.
///
/// Наприклад: «+15 XP».
String _formatXPForAmount(double amount) {
  final xp = _computeXPForAmount(amount);
  return '+$xp XP';
}

/// Форматує монети за суму як зручний рядок.
///
/// Наприклад: «+7 🪙».
String _formatCoinsForAmount(double amount) {
  final coins = _computeCoinsForAmount(amount);
  return '+$coins 🪙';
}

/// Повертає описовий рядок розміру суми.
///
/// Наприклад: «Великий внесок», «Середній внесок», «Звичайний внесок».
String _amountSizeDescription(double amount) {
  if (_isLargeAmount(amount)) return 'Великий внесок 🔥';
  if (_isMediumAmount(amount)) return 'Середній внесок 💪';
  if (amount >= _kMinDepositAmount) return 'Звичайний внесок';
  return 'Замало';
}

/// Повертає іконку розміру суми.
IconData _amountSizeIcon(double amount) {
  if (_isLargeAmount(amount)) return Icons.local_fire_department_rounded;
  if (_isMediumAmount(amount)) return Icons.trending_up_rounded;
  if (amount >= _kMinDepositAmount) return Icons.check_circle_outline_rounded;
  return Icons.error_outline_rounded;
}

/// Обчислює найближчий пресет до суми.
///
/// Повертає суму пресету, яка найближча до вказаної, або 0, якщо немає пресетів.
double _findClosestPreset(double amount) {
  final allPresets = [..._presetsRow1, ..._presetsRow2];
  if (allPresets.isEmpty) return 0;
  double closest = allPresets.first;
  double minDiff = (amount - closest).abs();
  for (final preset in allPresets) {
    final diff = (amount - preset).abs();
    if (diff < minDiff) {
      minDiff = diff;
      closest = preset;
    }
  }
  return closest;
}

/// Обчислює відсоток різниці між сумою та найближчим пресетом.
///
/// Корисно для підсвічування «близького до пресету».
double _presetDifferencePercentage(double amount) {
  final closest = _findClosestPreset(amount);
  if (closest <= 0) return 100.0;
  return ((amount - closest) / closest * 100).abs();
}

/// Перевіряє, чи сума є пресетом (точне співпадіння).
bool _isPresetAmount(double amount) {
  return [..._presetsRow1, ..._presetsRow2].contains(amount);
}

/// Обчислює кількість пресетів, які менші за суму.
int _presetCountBelowAmount(double amount) {
  final allPresets = [..._presetsRow1, ..._presetsRow2];
  return allPresets.where((p) => p < amount).length;
}

/// Повертає відсоток ліміту коментаря (0-100).
double _commentLimitPercentage(int currentLength) {
  if (_kMaxCommentLength <= 0) return 100.0;
  return (currentLength / _kMaxCommentLength * 100).clamp(0.0, 100.0);
}

/// Валідує коментар на предмет заборонених символів.
///
/// Повертає `true`, якщо коментар містить лише допустимі символи.
bool _isCommentValid(String comment) {
  // Допускаємо букви, цифри, пробіли та базову пунктуацію.
  final pattern = RegExp(r'^[\p{L}\p{N}\s\.\,\!\?\-\:\;]+$', unicode: true);
  return pattern.hasMatch(comment);
}

/// Обчислює оцінку суми (1-5) на основі розміру.
///
/// Більша сума — вища оцінка.
int _amountScore(double amount) {
  if (amount >= 10000) return 5;
  if (amount >= 5000) return 4;
  if (amount >= 1000) return 3;
  if (amount >= 100) return 2;
  if (amount >= _kMinDepositAmount) return 1;
  return 0;
}

/// Форматує оцінку суми як рядок із зірочками.
///
/// Наприклад: «★★★☆☆».
String _formatAmountScore(double amount) {
  final score = _amountScore(amount);
  final stars = '★' * score + '☆' * (5 - score);
  return stars;
}

/// Обчислює добові заощадження (припускаючи щоденний внесок).
///
/// Корисно для порівняння з іншими сумами.
double _computeDailySavingsProjection(double amount, int days) {
  if (days <= 0) return 0.0;
  return amount * days;
}

/// Сортує пресети за близькістю до суми (найближчі перші).
List<double> _sortPresetsByProximity(double amount) {
  final allPresets = [..._presetsRow1, ..._presetsRow2];
  final sorted = List<double>.from(allPresets);
  sorted.sort((a, b) =>
      (a - amount).abs().compareTo((b - amount).abs()));
  return sorted;
}

/// Обчислює суму для досягнення цільового прогресу.
///
/// Повертає необхідну суму для досягнення [targetProgress]%.
double _computeAmountForTargetProgress(
  double currentBalance,
  double targetBalance,
  double targetProgress,
) {
  if (targetProgress <= 0 || targetProgress >= 100) return 0;
  final needed = targetBalance * (targetProgress / 100) - currentBalance;
  return needed < 0 ? 0 : needed;
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширені валідатори та утиліти для коментарів
// ═══════════════════════════════════════════════════════════════════════════

/// Перевіряє, чи коментар досяг ліміту.
///
/// Повертає `true`, якщо довжина >= [_kMaxCommentLength].
bool _isCommentAtLimit(int length) {
  return length >= _kMaxCommentLength;
}

/// Перевіряє, чи коментар близько до ліміту.
///
/// Повертає `true`, якщо довжина >= [_kCommentNearLimit] та < [_kMaxCommentLength].
bool _isCommentNearLimit(int length) {
  return length >= _kCommentNearLimit && length < _kMaxCommentLength;
}

/// Обчислює залишок символів коментаря.
///
/// Повертає додатне число — скільки символів ще можна ввести.
int _commentCharsRemaining(int currentLength) {
  return (_kMaxCommentLength - currentLength).clamp(0, _kMaxCommentLength);
}

/// Форматує лічильник символів коментаря.
///
/// Наприклад: «42/80» або «65/80 (майже)».
String _formatCommentCounter(int currentLength) {
  if (_isCommentAtLimit(currentLength)) {
    return '$currentLength/$_kMaxCommentLength (ліміт)';
  }
  if (_isCommentNearLimit(currentLength)) {
    return '$currentLength/$_kMaxCommentLength (майже)';
  }
  return '$currentLength/$_kMaxCommentLength';
}

/// Обрізає коментар до [_kMaxCommentLength] символів.
///
/// Повертає обрізаний рядок, якщо він перевищує ліміт.
String _truncateComment(String comment) {
  if (comment.length <= _kMaxCommentLength) return comment;
  return '${comment.substring(0, _kMaxCommentLength - 1)}…';
}

/// Перевіряє, чи коментар порожній або містить лише пробіли.
bool _isCommentEmpty(String comment) {
  return comment.trim().isEmpty;
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові утиліти для пресетів
// ═══════════════════════════════════════════════════════════════════════════

/// Обчислює середнє значення всіх пресетів.
///
/// Корисно для «типового» внеску.
double _averagePresetAmount() {
  final allPresets = [..._presetsRow1, ..._presetsRow2];
  if (allPresets.isEmpty) return 0;
  return allPresets.reduce((a, b) => a + b) / allPresets.length;
}

/// Обчислює медіанну суму пресетів.
double _medianPresetAmount() {
  final allPresets = [..._presetsRow1, ..._presetsRow2]..sort();
  if (allPresets.isEmpty) return 0;
  final mid = allPresets.length ~/ 2;
  if (allPresets.length % 2 == 0) {
    return (allPresets[mid - 1] + allPresets[mid]) / 2;
  }
  return allPresets[mid];
}

/// Повертає мінімальний пресет.
double _minPresetAmount() {
  final allPresets = [..._presetsRow1, ..._presetsRow2];
  if (allPresets.isEmpty) return 0;
  return allPresets.reduce((a, b) => a < b ? a : b);
}

/// Повертає максимальний пресет.
double _maxPresetAmount() {
  final allPresets = [..._presetsRow1, ..._presetsRow2];
  if (allPresets.isEmpty) return 0;
  return allPresets.reduce((a, b) => a > b ? a : b);
}

/// Форматує опис пресету з інформацією про XP та монети.
///
/// Наприклад: «500 грн — +5 XP, +2 🪙».
String _formatPresetWithRewards(double amount) {
  final xp = _computeXPForAmount(amount);
  final coins = _computeCoinsForAmount(amount);
  return '$amount грн — +$xp XP, +$coins 🪙';
}

/// Форматує суму для відображення в пресеті.
///
/// Використовує формат з розрядками для сум >= 1000.
String _formatPresetLabel(double amount) {
  if (amount >= 1000) {
    final formatted = amount.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(formatted[i]);
    }
    return buffer.toString();
  }
  return amount.toInt().toString();
}

/// Обчислює відсоток суми від максимального пресету.
///
/// Корисно для відображення «наскільки велика ця сума».
double _percentageOfMaxPreset(double amount) {
  final maxPreset = _maxPresetAmount();
  if (maxPreset <= 0) return 100.0;
  return (amount / maxPreset * 100).clamp(0.0, 100.0);
}

// ═══════════════════════════════════════════════════════════════════════════
// Утиліти для роботи з num-pad та введенням
// ═══════════════════════════════════════════════════════════════════════════

/// Перевіряє, чи рядок містить лише цифри.
///
/// Використовується для валідації введення num-pad.
bool _isNumericString(String input) {
  return RegExp(r'^\d+$').hasMatch(input);
}

/// Обчислює довжину введеного числа в цифрах.
///
/// Корисно для обмеження довжини введення.
int _inputDigitCount(String input) {
  return input.replaceAll(RegExp(r'[^\d]'), '').length;
}

/// Перевіряє, чи num-pad кнопка є функціональною (не цифра).
///
/// Функціональні кнопки: '⌫', '000'.
bool _isFunctionKey(String key) {
  return key == '⌫' || key == '000';
}

/// Обчислює максимальну кількість цифр для введення.
///
/// Базується на [_kMaxDepositAmount] (999999 = 6 цифр).
int _maxInputDigits() {
  return _kMaxDepositAmount.toString().length;
}

/// Форматує введене число для відображення.
///
/// Додає розрядки для чисел >= 10000.
String _formatInputDisplay(String rawInput) {
  final numeric = rawInput.replaceAll(RegExp(r'[^\d]'), '');
  if (numeric.isEmpty) return '0';
  final parsed = int.tryParse(numeric) ?? 0;
  return parsed.toString();
}
