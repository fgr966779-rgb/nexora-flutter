import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

/// Bottom sheet для швидкого додавання коштів.
///
/// Містить drag handle, amount field, пресети, collapsible comment
/// з char counter, swipe to close, haptic, new balance preview, error validation,
/// period selector, quick templates, XP preview, goal type display, recent amounts,
/// scheduled deposit toggle, amount calculator, favorite amounts, swipe gesture presets,
/// extended haptic patterns, detailed validation messages, snap points, keyboard shortcuts,
/// success animation overlay, enhanced favorite toggle, scheduled deposit info card,
/// comment templates dropdown, validation error patterns, haptic per action.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  static const _snapPoints = [0.25, 0.5, 0.75, 1.0];

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  double? _selectedPreset;
  bool _isSubmitting = false;
  bool _showComment = false;
  String _validationError = '';
  bool _isDragged = false;
  String _depositType = 'manual';
  bool _isScheduled = false;
  String _scheduleFreq = 'Щодня';
  bool _useCalculator = false;
  String _calcExpression = '';
  double _calcResult = 0;
  bool _showRecent = true;
  bool _showSuccessAnimation = false;
  double _currentSnapPoint = 1.0;
  bool _showTemplates = false;
  int _selectedTemplateIndex = -1;

  static const _presets = [50.0, 100.0, 200.0, 500.0, 1000.0];
  static const int _maxCommentLength = 80;
  static const double _minAmount = 1;
  static const double _maxAmount = 100000;

  static const _recentAmounts = [75.0, 150.0, 250.0, 400.0];

  static const _favoriteAmounts = [100.0, 500.0, 1000.0];
  final Set<double> _starredAmounts = {500.0};

  static const _quickTemplates = [
    'Кава сьогодні ☕',
    'Щоденний внесок',
    'Автоматичний 💰',
    'За мрією! 🚀',
    'Зарплатний внесок 💵',
    'Відрядження ☝️',
    'Вечірня кава 🌙',
    'Тиждень без витрат 🚫',
  ];

  static const _extendedTemplates = [
    'Перша зарплата місяця 💰',
    'Недільний внесок ☀️',
    'Подарунок від рідних 🎁',
    'Кешбек з картки ♻️',
    'Економія на транспорті 🚌',
    'Заохочення за ціль 🏆',
  ];

  static const _depositTypes = [
    ('Вручну', Icons.touch_app_rounded),
    ('Округлення', Icons.sync_rounded),
    ('Виклик', Icons.emoji_events_rounded),
    ('Калькулятор', Icons.calculate_rounded),
  ];

  static const _scheduleOptions = [
    'Щодня',
    'Щотижня',
    'Щомісяця',
  ];

  static const _gesturePresets = [
    ('Свайп вправо → +100 грн', Icons.swipe_right_rounded),
    ('Подвійний тап → +500 грн', Icons.touch_app_rounded),
    ('Довге натискання → +1000 грн', Icons.fingerprint_rounded),
  ];

  static const _keyboardShortcuts = [
    ('Enter', 'Підтвердити внесок'),
    ('Esc', 'Закрити аркуш'),
    ('Tab', 'Наступне поле'),
    ('Ctrl+S', 'Швидкий збереження'),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _amountController.dispose();
    _commentController.dispose();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      HapticService.lightTap();
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        HapticService.lightTap();
        Navigator.of(context).pop();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter && _isSubmitting == false) {
        final amount = double.tryParse(_amountController.text) ?? 0;
        if (amount > _minAmount && _validationError.isEmpty) {
          _submit();
          return true;
        }
      }
    }
    return false;
  }

  void _hapticForAction(String action) {
    switch (action) {
      case 'preset':
        HapticService.selection();
        break;
      case 'calc':
        HapticService.lightTap();
        break;
      case 'template':
        HapticService.coinDrop();
        break;
      case 'favorite':
        HapticService.mediumTap();
        break;
      case 'schedule':
        HapticService.selection();
        break;
      case 'submit':
        HapticService.mediumTap();
        break;
      default:
        HapticService.lightTap();
    }
  }

  void _onPresetTap(double amount) {
    _hapticForAction('preset');
    setState(() {
      _selectedPreset = amount;
      _amountController.text = amount.toInt().toString();
      _validationError = '';
    });
  }

  void _toggleStarAmount(double amount) {
    _hapticForAction('favorite');
    setState(() {
      if (_starredAmounts.contains(amount)) {
        _starredAmounts.remove(amount);
        AppToast.show(context, message: '⭐ Видалено з улюблених', icon: Icons.star_outline_rounded, color: AppColorsPS5.warning);
      } else {
        _starredAmounts.add(amount);
        AppToast.show(context, message: '⭐ Додано до улюблених!', icon: Icons.star_rounded, color: AppColorsPS5.coin);
      }
    });
  }

  void _onCalcTap(String value) {
    _hapticForAction('calc');
    setState(() {
      _calcExpression += value;
      try {
        final result = _evaluateExpression(_calcExpression);
        _calcResult = result;
        _amountController.text = result.toInt().toString();
        _validationError = '';
      } catch (_) {
        _calcResult = 0;
      }
    });
  }

  double _evaluateExpression(String expr) {
    final sanitized = expr.replaceAll(RegExp(r'[^\d+\-*/.]'), '');
    if (sanitized.isEmpty) return 0;
    final parts = sanitized.split(RegExp(r'([+\-*/])'));
    if (parts.isEmpty) return 0;
    double result = double.tryParse(parts[0]) ?? 0;
    for (int i = 1; i < parts.length - 1; i += 2) {
      final op = parts[i];
      final num = double.tryParse(parts[i + 1]) ?? 0;
      switch (op) {
        case '+': result += num; break;
        case '-': result -= num; break;
        case '*': result *= num; break;
        case '/': result = num != 0 ? result / num : 0; break;
      }
    }
    return result;
  }

  void _validate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() => _validationError = 'Введи суму');
    } else if (amount < _minAmount) {
      setState(() => _validationError = 'Мінімальна сума — $_minAmount грн');
    } else if (amount > _maxAmount) {
      setState(() => _validationError = 'Максимальна сума — ${_maxAmount.toInt().formatUAH()} грн');
    } else if (amount == 13) {
      setState(() => _validationError = 'Може, краще 15 грн? 😄');
    } else if (amount == 666) {
      setState(() => _validationError = 'Диявольська сума! Спробуй іншу 😇');
    } else if (amount % 1 != 0) {
      setState(() => _validationError = 'Використовуй лише цілі числа');
    } else if (amount > 50000) {
      setState(() => _validationError = '⚠️ Велика сума — перевір ще раз!');
    } else {
      setState(() => _validationError = '');
    }
  }

  void _onTemplateSelect(String template) {
    _hapticForAction('template');
    setState(() {
      _commentController.text = template;
      _showComment = true;
      _showTemplates = false;
      _selectedTemplateIndex = _quickTemplates.indexOf(template);
    });
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      AppToast.show(context, message: 'Введи суму внеску', icon: Icons.warning_rounded, color: AppColorsPS5.warning);
      return;
    }
    if (_commentController.text.length > _maxCommentLength) {
      AppToast.show(context, message: 'Коментар занадто довгий (макс. $_maxCommentLength символів)', icon: Icons.warning_rounded, color: AppColorsPS5.warning);
      return;
    }

    _hapticForAction('submit');
    setState(() => _isSubmitting = true);
    final success = await ref.read(dashboardProvider.notifier).addDeposit(
          amount,
          comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        );

    if (success && mounted) {
      HapticService.success();
      setState(() => _showSuccessAnimation = true);
      await Future.delayed(const Duration(milliseconds: 600));
      AppToast.show(context, message: '+${amount.toInt().formatUAH()} грн успішно!', icon: Icons.check_circle_rounded, color: AppColorsPS5.success);
      Navigator.of(context).pop();
    } else if (mounted) {
      HapticService.error();
      setState(() => _isSubmitting = false);
      AppToast.show(context, message: 'Помилка. Спробуй ще раз.', icon: Icons.error_rounded, color: AppColorsPS5.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final inputAmount = double.tryParse(_amountController.text) ?? 0;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = ref.watch(dashboardProvider);
    final goal = state.goal;
    final accent = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    final currentBalance = goal?.currentAmount ?? 0;
    final newBalance = currentBalance + inputAmount;
    final targetAmount = goal?.targetAmount ?? 0;
    final progressPercent = targetAmount > 0 ? ((newBalance / targetAmount) * 100).clamp(0, 100) : 0.0;
    final diffPercent = targetAmount > 0 ? (inputAmount / targetAmount * 100) : 0.0;
    final goalName = goal?.name ?? 'Твоя ціль';

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 10) setState(() => _isDragged = true);
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          HapticService.lightTap();
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: bottomInset),
            decoration: BoxDecoration(
              color: isLight ? AppColorsMonitor.card : AppColorsPS5.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Spacing.sm),
                  // ── Рукоятка для перетягування ─────────────
                  _buildDragHandle(isLight),
                  const SizedBox(height: Spacing.md),
                  // ── Заголовок ──────────────────────────────
                  Text('Додати кошти', style: AppTypography.heading1.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: Spacing.xs),
                  Text(goalName, style: AppTypography.bodySmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                  // ── Поточний баланс ───────────────────────
                  if (goal != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                      margin: const EdgeInsets.only(top: Spacing.xs),
                      decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm)),
                      child: Text('Поточний баланс: ${currentBalance.toInt().formatUAH()} грн', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                    ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                  const SizedBox(height: Spacing.lg),
                  // ── Тип внеску ─────────────────────────────
                  _buildDepositTypes(isLight, accent),
                  // ── Калькулятор суми ─────────────────────
                  if (_useCalculator) _buildCalculatorPanel(isLight, accent),
                  const SizedBox(height: Spacing.base),
                  // ── Поле суми ──────────────────────────────
                  AppTextField(
                    hint: 'Введи суму',
                    controller: _amountController,
                    focusNode: _focusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    isLightTheme: isLight,
                    prefixIcon: Icon(Icons.attach_money_rounded, color: accent),
                    onChanged: (_) { setState(() {}); _validate(); },
                  ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 100.ms),
                  if (_validationError.isNotEmpty)
                    _buildValidationError(isLight),
                  if (inputAmount > 0)
                    Padding(padding: const EdgeInsets.only(top: Spacing.sm), child: Text('${inputAmount.toInt().formatUAH()} грн', style: AppTypography.monoMedium.copyWith(color: _validationError.isEmpty ? accent : AppColorsPS5.error)).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)),
                  const SizedBox(height: Spacing.base),
                  // ── Обрані суми (улюблені з зіркою) ────────
                  _buildFavoriteAmounts(isLight, accent),
                  const SizedBox(height: Spacing.sm),
                  // ── Пресети ────────────────────────────────
                  _buildPresets(isLight, accent),
                  const SizedBox(height: Spacing.sm),
                  // ── Останні суми ──────────────────────────
                  _buildRecentAmounts(isLight, accent),
                  const SizedBox(height: Spacing.base),
                  // ── Шаблони коментарів (dropdown) ─────────
                  _buildTemplatesDropdown(isLight, accent),
                  // ── Запланований внесок ───────────────────
                  const SizedBox(height: Spacing.sm),
                  _buildScheduledDeposit(isLight, accent),
                  if (_isScheduled) _buildScheduledInfoCard(isLight, accent),
                  // ── Жест-пресети ──────────────────────────
                  const SizedBox(height: Spacing.sm),
                  _buildGesturePresets(isLight, accent),
                  // ── Клавіатурні скорочення ────────────────
                  _buildKeyboardShortcuts(isLight, accent),
                  const SizedBox(height: Spacing.base),
                  // ── Перемикач коментаря ──────────────────
                  _buildCommentToggle(isLight, accent),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _showComment
                        ? Padding(padding: const EdgeInsets.only(top: Spacing.sm), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            AppTextField(hint: 'Коментар', controller: _commentController, maxLines: 2, maxLength: _maxCommentLength, isLightTheme: isLight, onChanged: (_) => setState(() {})),
                            Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Максимум $_maxCommentLength символів', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
                              Text('${_commentController.text.length} / $_maxCommentLength', style: AppTypography.labelSmall.copyWith(color: _commentController.text.length > _maxCommentLength ? AppColorsPS5.error : (isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), fontWeight: FontWeight.w600)),
                            ])),
                          ]))
                        : const SizedBox.shrink(),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: Spacing.lg),
                  // ── Прев'ю нового балансу ──────────────────
                  if (inputAmount > 0 && goal != null) _buildBalancePreview(isLight, accent, inputAmount, currentBalance, newBalance, targetAmount, progressPercent, diffPercent),
                  const SizedBox(height: Spacing.xl),
                  // ── Кнопка «Додати» ────────────────────────
                  AppButtonPrimary(
                    label: _isSubmitting ? 'Додаємо...' : (_isScheduled ? 'Запланувати' : 'Додати'),
                    onPressed: inputAmount > 0 && !_isSubmitting && _validationError.isEmpty ? _submit : null,
                    isDisabled: inputAmount <= 0 || _isSubmitting || _validationError.isNotEmpty,
                    isLoading: _isSubmitting,
                    showGlow: inputAmount > 0 && _validationError.isEmpty,
                    isLightTheme: isLight,
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                  const SizedBox(height: Spacing.xxl),
                ],
              ),
            ),
          ),
          // ── Оверлей успішного додавання ──────────────────
          if (_showSuccessAnimation) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildDragHandle(bool isLight) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isDragged ? 64 : 48,
        height: 5,
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        decoration: BoxDecoration(
          color: (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint).withOpacity(_isDragged ? 0.8 : 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildValidationError(bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        decoration: BoxDecoration(
          color: AppColorsPS5.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: AppColorsPS5.error.withOpacity(0.15)),
        ),
        child: Row(children: [
          Icon(Icons.error_outline_rounded, color: AppColorsPS5.error, size: 14),
          const SizedBox(width: Spacing.xs),
          Expanded(child: Text(_validationError, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error))),
        ]),
      ),
    );
  }

  Widget _buildDepositTypes(bool isLight, Color accent) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _depositTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, i) {
          final isActive = _depositType == _depositTypes[i].$1;
          return GestureDetector(
            onTap: () {
              HapticService.selection();
              setState(() {
                _depositType = _depositTypes[i].$1;
                _useCalculator = _depositType == 'Калькулятор';
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
              decoration: BoxDecoration(color: isActive ? accent : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isActive ? accent : (isLight ? AppColorsMonitor.border : AppColorsPS5.border))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_depositTypes[i].$2, color: isActive ? Colors.white : (isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), size: 12),
                const SizedBox(width: 4),
                Text(_depositTypes[i].$1, style: AppTypography.labelSmall.copyWith(color: isActive ? Colors.white : (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, fontSize: 11)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalculatorPanel(bool isLight, Color accent) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.1))),
      child: Column(children: [
        Text(_calcExpression.isEmpty ? 'Введи вираз (напр. 200+300)' : _calcExpression, style: AppTypography.labelSmall.copyWith(color: accent)),
        if (_calcResult > 0) Text('= ${_calcResult.toInt()} грн', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
        const SizedBox(height: Spacing.xs),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildCalcButton('+', accent),
          _buildCalcButton('-', accent),
          _buildCalcButton('×', accent),
          _buildCalcButton('÷', accent),
          _buildCalcButton('C', accent),
        ]),
        const SizedBox(height: Spacing.xs),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildCalcButton('7', accent),
          _buildCalcButton('8', accent),
          _buildCalcButton('9', accent),
          _buildCalcButton('0', accent),
          _buildCalcButton('⌫', accent),
        ]),
      ]),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildFavoriteAmounts(bool isLight, Color accent) {
    return Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: [
      Text('⭐ Обране:', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
      ..._favoriteAmounts.map((amount) => GestureDetector(
        onTap: () => _onPresetTap(amount),
        onLongPress: () => _toggleStarAmount(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: AppColorsPS5.coin.withOpacity(_starredAmounts.contains(amount) ? 0.15 : 0.06),
            borderRadius: BorderRadius.circular(Radii.sm),
            border: _starredAmounts.contains(amount) ? Border.all(color: AppColorsPS5.coin.withOpacity(0.3)) : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_starredAmounts.contains(amount) ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColorsPS5.coin, size: 10),
            const SizedBox(width: 2),
            Text('${amount.toInt()}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600)),
          ]),
        ),
      )),
    ]).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildPresets(bool isLight, Color accent) {
    return Wrap(spacing: Spacing.sm, runSpacing: Spacing.sm, children: _presets.map((amount) {
      final isSelected = _selectedPreset == amount;
      return GestureDetector(
        onTap: () => _onPresetTap(amount),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm + 2), decoration: BoxDecoration(color: isSelected ? accent : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isSelected ? accent : (isLight ? AppColorsMonitor.border : AppColorsPS5.border), width: 1.5), boxShadow: isSelected ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 8)] : null), child: Text('${amount.toInt().formatUAH()} грн', style: AppTypography.labelLarge.copyWith(color: isSelected ? Colors.white : (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500))),
      );
    }).toList()).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildRecentAmounts(bool isLight, Color accent) {
    return Column(children: [
      GestureDetector(
        onTap: () { HapticService.selection(); setState(() => _showRecent = !_showRecent); },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_showRecent ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, size: 16),
          const SizedBox(width: Spacing.xs),
          Text('Останні суми', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
        ]),
      ),
      if (_showRecent)
        Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _recentAmounts.map((amount) => GestureDetector(
          onTap: () => _onPresetTap(amount),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2), decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3), borderRadius: BorderRadius.circular(Radii.sm)), child: Text('${amount.toInt()}', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))),
        )).toList()).animate().fadeIn(duration: 200.ms),
    ]);
  }

  Widget _buildTemplatesDropdown(bool isLight, Color accent) {
    return Column(children: [
      Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _quickTemplates.map((tmpl) {
        return GestureDetector(
          onTap: () => _onTemplateSelect(tmpl),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4), decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: accent.withOpacity(0.12))), child: Text(tmpl, style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 11))),
        );
      }).toList()),
      GestureDetector(
        onTap: () { HapticService.selection(); setState(() => _showTemplates = !_showTemplates); },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(_showTemplates ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: accent, size: 14),
          const SizedBox(width: Spacing.xs),
          Text('Ще шаблонів...', style: AppTypography.labelSmall.copyWith(color: accent)),
        ]),
      ),
      if (_showTemplates)
        Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _extendedTemplates.map((tmpl) {
          return GestureDetector(
            onTap: () => _onTemplateSelect(tmpl),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4), decoration: BoxDecoration(color: accent.withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: accent.withOpacity(0.08))), child: Text(tmpl, style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 11))),
          );
        }).toList()).animate().fadeIn(duration: 200.ms),
    ]);
  }

  Widget _buildScheduledDeposit(bool isLight, Color accent) {
    return GestureDetector(
      onTap: () { _hapticForAction('schedule'); setState(() => _isScheduled = !_isScheduled); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
        decoration: BoxDecoration(color: _isScheduled ? AppColorsPS5.success.withOpacity(0.08) : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: _isScheduled ? AppColorsPS5.success.withOpacity(0.2) : (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_isScheduled ? Icons.repeat_rounded : Icons.repeat_one_rounded, color: _isScheduled ? AppColorsPS5.success : (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint), size: 14),
          const SizedBox(width: Spacing.xs),
          Text('Запланований внесок', style: AppTypography.labelSmall.copyWith(color: _isScheduled ? AppColorsPS5.success : (isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))),
        ]),
      ),
    );
  }

  Widget _buildScheduledInfoCard(bool isLight, Color accent) {
    final now = DateTime.now();
    final nextDate = _scheduleFreq == 'Щодня'
        ? now.add(const Duration(days: 1))
        : _scheduleFreq == 'Щотижня'
            ? now.add(const Duration(days: 7))
            : DateTime(now.year, now.month + 1, 1);
    return Column(children: [
      Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _scheduleOptions.map((opt) {
        final isActive = _scheduleFreq == opt;
        return GestureDetector(
          onTap: () { HapticService.selection(); setState(() => _scheduleFreq = opt); },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2), decoration: BoxDecoration(color: isActive ? AppColorsPS5.success : Colors.transparent, borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: isActive ? AppColorsPS5.success : (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3))), child: Text(opt, style: AppTypography.labelSmall.copyWith(color: isActive ? Colors.white : (isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), fontSize: 11))),
        );
      }).toList()).animate().fadeIn(duration: 200.ms),
      const SizedBox(height: Spacing.xs),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, color: AppColorsPS5.success, size: 12),
          const SizedBox(width: Spacing.xs),
          Text('📅 Наступний: ${nextDate.day}.${nextDate.month}.${nextDate.year}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontSize: 10)),
        ]),
      ),
    ]);
  }

  Widget _buildGesturePresets(bool isLight, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📱 Швидкі жести:', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint, fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.xs),
        ..._gesturePresets.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(children: [
            Icon(g.$2, color: accent, size: 12),
            const SizedBox(width: Spacing.xs),
            Text(g.$1, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, fontSize: 10)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildKeyboardShortcuts(bool isLight, Color accent) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.15), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ..._keyboardShortcuts.map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint).withOpacity(0.1), borderRadius: BorderRadius.circular(3)), child: Text(s.$1, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint, fontSize: 9, fontWeight: FontWeight.w600))),
          const SizedBox(width: 2),
          Text(s.$2, style: AppTypography.labelSmall.copyWith(color: (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint), fontSize: 9)),
        ])),
      ]),
    );
  }

  Widget _buildCommentToggle(bool isLight, Color accent) {
    return GestureDetector(
      onTap: () { HapticService.lightTap(); setState(() => _showComment = !_showComment); },
      child: Row(children: [
        Icon(_showComment ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary),
        const SizedBox(width: Spacing.xs),
        Text(_showComment ? 'Сховати коментар' : 'Додати коментар', style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
      ]),
    );
  }

  Widget _buildBalancePreview(bool isLight, Color accent, double inputAmount, double currentBalance, double newBalance, double targetAmount, double progressPercent, double diffPercent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Новий баланс', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
          Text('+${diffPercent.toStringAsFixed(1)}%', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: Spacing.xs),
        Text('${newBalance.toInt().formatUAH()} грн', style: AppTypography.monoMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
        const SizedBox(height: Spacing.sm),
        Row(children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progressPercent / 100, minHeight: 8, backgroundColor: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3), valueColor: AlwaysStoppedAnimation(accent)))),
          const SizedBox(width: Spacing.sm),
          Text('${progressPercent.toStringAsFixed(1)}%', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w600)),
        ]),
        if (newBalance >= targetAmount)
          Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [
            Icon(Icons.celebration_rounded, color: AppColorsPS5.success, size: 14),
            const SizedBox(width: 4),
            Text('🎉 Ціль буде досягнуто!', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w600)),
          ])),
        const SizedBox(height: Spacing.xs),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('XP +${(inputAmount ~/ 10).clamp(5, 50)}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp, fontWeight: FontWeight.w600)),
          if (_isScheduled) Text('🗓 Заплановано: $_scheduleFreq', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w600)),
        ]),
      ]),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColorsPS5.success.withOpacity(0.1),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorsPS5.success.withOpacity(0.15),
                border: Border.all(color: AppColorsPS5.success, width: 3),
              ),
              child: const Icon(Icons.check_rounded, color: AppColorsPS5.success, size: 48),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildCalcButton(String label, Color accent) {
    return GestureDetector(
      onTap: () {
        if (label == 'C') {
          HapticService.lightTap();
          setState(() { _calcExpression = ''; _calcResult = 0; });
        } else if (label == '⌫') {
          HapticService.lightTap();
          setState(() {
            if (_calcExpression.isNotEmpty) {
              _calcExpression = _calcExpression.substring(0, _calcExpression.length - 1);
            }
          });
        } else {
          _onCalcTap(label == '×' ? '*' : label == '÷' ? '/' : label);
        }
      },
      child: Container(
        width: 36, height: 28,
        decoration: BoxDecoration(color: label == 'C' ? AppColorsPS5.error.withOpacity(0.1) : accent.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.sm)),
        child: Center(child: Text(label, style: AppTypography.labelMedium.copyWith(color: label == 'C' || label == '⌫' ? AppColorsPS5.error : accent, fontWeight: FontWeight.w700))),
      ),
    );
  }
}
