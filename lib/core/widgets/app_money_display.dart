import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_durations.dart';
import '../extensions/number_format_ext.dart';

// ─── Size Variants ──────────────────────────────────────────────────────────

/// Розміри відображення грошової суми.
///
/// Визначає типографіку та масштаб компонента.
enum MoneyDisplaySize {
  /// Надкомпактний розмір для inline тексту у списках.
  xs,

  /// Компактний розмір для списків та inline тексту.
  small,

  /// Стандартний розмір для карток та звичайних екранів.
  medium,

  /// Збільшений розмір для секцій з акцентом.
  large,

  /// Герой-розмір для головного екрану цілі.
  hero;

  /// Базовий розмір шрифту для кожного варіанту.
  double get fontSize {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 11.0;
      case MoneyDisplaySize.small:
        return 14.0;
      case MoneyDisplaySize.medium:
        return 20.0;
      case MoneyDisplaySize.large:
        return 28.0;
      case MoneyDisplaySize.hero:
        return 40.0;
    }
  }

  /// Вага шрифту.
  FontWeight get fontWeight {
    switch (this) {
      case MoneyDisplaySize.xs:
        return FontWeight.w400;
      case MoneyDisplaySize.small:
        return FontWeight.w500;
      case MoneyDisplaySize.medium:
        return FontWeight.w600;
      case MoneyDisplaySize.large:
        return FontWeight.w700;
      case MoneyDisplaySize.hero:
        return FontWeight.w800;
    }
  }

  /// Українська назва розміру.
  String get label {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 'Дуже малий';
      case MoneyDisplaySize.small:
        return 'Малий';
      case MoneyDisplaySize.medium:
        return 'Середній';
      case MoneyDisplaySize.large:
        return 'Великий';
      case MoneyDisplaySize.hero:
        return 'Герой';
    }
  }
}

/// Розташування символу валюти.
enum CurrencyPosition {
  /// Символ перед сумою: "грн 1 250"
  before,

  /// Символ після суми: "1 250 грн"
  after;
}

/// Режим відображення суми.
enum MoneyDisplayMode {
  /// Звичайний режим — повне число з розділювачами.
  standard,

  /// Компактний режим — скорочене число (12.4K, 1.2M).
  compact,

  /// Тільки монети — з іконкою.
  coinsOnly,
}

// ─── Widget ─────────────────────────────────────────────────────────────────

/// Анімований дисплей грошової суми з ефектом підрахунку.
///
/// Підтримує:
/// - Розміри [MoneyDisplaySize] (xs, small, medium, large, hero)
/// - Анімацію підрахунку вгору/вниз
/// - Компактний режим ("12.4K")
/// - Прогрес поточного/цільового значення
/// - Колір на основі суми (зелений / червоний)
/// - Закреслена стара сума
/// - Підпис та заголовок
/// - Порівняння початкової та поточної суми
/// - Відображення цілі накопичення
/// - Анімацію десяткових знаків
/// - Цільовий прогрес з текстом
class AppMoneyDisplay extends StatefulWidget {
  const AppMoneyDisplay({
    super.key,
    required this.amount,
    this.previousAmount,
    this.animate = true,
    this.isLightTheme = false,
    this.size = MoneyDisplaySize.medium,
    this.style,
    this.currencySuffix = 'грн',
    this.currencyPosition = CurrencyPosition.after,
    this.compact = false,
    this.targetAmount,
    this.showProgress = false,
    this.decimalPlaces = 0,
    this.strikethroughAmount,
    this.subtitle,
    this.label,
    this.colorByAmount = false,
    this.duration,
    this.startAmount,
    this.displayMode = MoneyDisplayMode.standard,
    this.savingsGoalText,
    this.showComparison = false,
  });

  /// Поточна сума для відображення.
  final double amount;

  /// Попередня сума для анімації переходу.
  final double? previousAmount;

  /// Початкова сума для порівняння (на початку накопичення).
  final double? startAmount;

  /// Увімкнути анімацію підрахунку.
  final bool animate;

  /// Використовувати світлу тему.
  final bool isLightTheme;

  /// Розмір компонента.
  final MoneyDisplaySize size;

  /// Кастомний стиль тексту (перевизначає [size]).
  final TextStyle? style;

  /// Суфікс валюти (наприклад, "грн").
  final String currencySuffix;

  /// Розташування символу валюти.
  final CurrencyPosition currencyPosition;

  /// Компактний режим — показувати "12.4K" замість повного числа.
  final bool compact;

  /// Цільова сума для прогрес-бару.
  final double? targetAmount;

  /// Показувати прогрес-бар поточного/цільового.
  final bool showProgress;

  /// Кількість десяткових знаків.
  final int decimalPlaces;

  /// Сума для закреслення (стара ціна).
  final double? strikethroughAmount;

  /// Текст підпису під сумою.
  final String? subtitle;

  /// Текст заголовка над сумою.
  final String? label;

  /// Колір на основі суми: зелений для позитивних, червоний для негативних.
  final bool colorByAmount;

  /// Тривалість анімації.
  final Duration? duration;

  /// Режим відображення.
  final MoneyDisplayMode displayMode;

  /// Текст цілі накопичення (наприклад, "Ціль: PlayStation 5").
  final String? savingsGoalText;

  /// Показувати порівняння початкової та поточної суми.
  final bool showComparison;

  @override
  State<AppMoneyDisplay> createState() => _AppMoneyDisplayState();
}

class _AppMoneyDisplayState extends State<AppMoneyDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _progressAnimation;
  double _displayAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppDurations.countUp,
    );

    _displayAmount = widget.previousAmount ?? widget.amount;
    _setupAnimation();
  }

  void _setupAnimation() {
    if (widget.animate && widget.previousAmount != null) {
      final startVal = widget.previousAmount!;
      final endVal = widget.amount;

      _animation = Tween<double>(begin: startVal, end: endVal).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.forward(from: 0);
    } else if (widget.animate) {
      _animation = Tween<double>(begin: 0, end: widget.amount).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    } else {
      _animation = AlwaysStoppedAnimation(widget.amount);
    }

    // Анімація прогресу
    if (widget.showProgress && widget.targetAmount != null && widget.targetAmount! > 0) {
      final targetProgress = (widget.amount / widget.targetAmount!).clamp(0.0, 1.0);
      _progressAnimation = Tween<double>(begin: 0.0, end: targetProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
    } else {
      _progressAnimation = AlwaysStoppedAnimation(0.0);
    }
  }

  @override
  void didUpdateWidget(covariant AppMoneyDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount ||
        oldWidget.targetAmount != widget.targetAmount) {
      final startVal = _displayAmount;
      final endVal = widget.amount;

      _animation = Tween<double>(begin: startVal, end: endVal).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      if (widget.showProgress && widget.targetAmount != null && widget.targetAmount! > 0) {
        final targetProgress = (widget.amount / widget.targetAmount!).clamp(0.0, 1.0);
        _progressAnimation = Tween<double>(
          begin: oldWidget.targetAmount != null && oldWidget.targetAmount! > 0
              ? (oldWidget.amount / oldWidget.targetAmount!).clamp(0.0, 1.0)
              : 0.0,
          end: targetProgress,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
      }

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Форматування ─────────────────────────────────────────────────────

  /// Форматує число з урахуванням компактного режиму та десяткових знаків.
  String _formatAmount(double value) {
    if (widget.displayMode == MoneyDisplayMode.compact || widget.compact) {
      return _formatCompact(value);
    }

    if (widget.decimalPlaces > 0) {
      return _formatWithDecimals(value);
    }

    return value.formatUAH();
  }

  /// Компактне форматування: "12.4K", "1.2M".
  String _formatCompact(double value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1000000000) {
      return '${sign}${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (abs >= 1000000) {
      return '${sign}${(value / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      return '${sign}${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.formatUAH();
  }

  /// Форматування з десятковими знаками.
  String _formatWithDecimals(double value) {
    final abs = value.abs();
    final intPart = abs.toInt();
    final decPart = ((abs - intPart) * math.pow(10, widget.decimalPlaces)).round();
    final formatted = intPart.formatUAH();
    final decStr = decPart.toString().padLeft(widget.decimalPlaces, '0');
    final sign = value < 0 ? '-' : '';
    return '$sign$formatted,$decStr';
  }

  /// Форматує відсоток знаку.
  String _formatPercent(double progress) {
    return (progress * 100).toStringAsFixed(0);
  }

  /// Форматує різницю між сумами для порівняння.
  String _formatDifference(double current, double start) {
    final diff = current - start;
    if (diff == 0) return '+0';
    final sign = diff > 0 ? '+' : '';
    if (diff.abs() >= 1000000) {
      return '${sign}${(diff / 1000000).toStringAsFixed(1)}M';
    }
    if (diff.abs() >= 1000) {
      return '${sign}${(diff / 1000).toStringAsFixed(1)}K';
    }
    return '$sign${diff.toInt().formatUAH()}';
  }

  // ─── Кольори ──────────────────────────────────────────────────────────

  /// Визначає колір тексту суми.
  Color _getAmountColor() {
    if (widget.colorByAmount) {
      if (widget.amount > 0) return AppColorsPS5.success;
      if (widget.amount < 0) return AppColorsPS5.error;
    }
    return widget.isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;
  }

  Color get _textPrimaryColor => widget.isLightTheme
      ? AppColorsMonitor.textPrimary
      : AppColorsPS5.textPrimary;

  Color get _textSecondaryColor => widget.isLightTheme
      ? AppColorsMonitor.textSecondary
      : AppColorsPS5.textSecondary;

  Color get _textHintColor => widget.isLightTheme
      ? AppColorsMonitor.textHint
      : AppColorsPS5.textHint;

  Color get _accentColor => widget.isLightTheme
      ? AppColorsMonitor.accent
      : AppColorsPS5.accent;

  Color get _borderColor => widget.isLightTheme
      ? AppColorsMonitor.border
      : AppColorsPS5.border;

  Color get _successColor => AppColorsPS5.success;

  // ─── Стилі ────────────────────────────────────────────────────────────

  TextStyle get _baseStyle {
    if (widget.style != null) return widget.style!;
    final color = widget.colorByAmount ? _getAmountColor() : _textPrimaryColor;
    return TextStyle(
      fontFamily: AppTypography.monoFontFamily,
      fontSize: widget.size.fontSize,
      fontWeight: widget.size.fontWeight,
      color: color,
      height: 1.2,
    );
  }

  TextStyle get _currencyStyle => AppTypography.monoCaption.copyWith(
        color: _textSecondaryColor,
        fontSize: (widget.size.fontSize * 0.5).clamp(8.0, 18.0),
      );

  TextStyle get _labelStyle => AppTypography.labelMedium.copyWith(
        color: _textSecondaryColor,
      );

  TextStyle get _subtitleStyle => AppTypography.bodySmall.copyWith(
        color: _textHintColor,
      );

  TextStyle get _strikethroughStyle => _baseStyle.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationColor: _textHintColor,
        color: _textHintColor,
        fontSize: (widget.size.fontSize * 0.7).clamp(10.0, 24.0),
      );

  TextStyle get _comparisonStyle => AppTypography.labelSmall.copyWith(
        color: _successColor,
        fontWeight: FontWeight.w600,
      );

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Заголовок над сумою
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: _labelStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
        ],

        // Закреслена стара сума
        if (widget.strikethroughAmount != null) ...[
          Text(
            _formatAmount(widget.strikethroughAmount!),
            style: _strikethroughStyle,
          ),
          const SizedBox(height: 2),
        ],

        // Текст цілі накопичення
        if (widget.savingsGoalText != null) ...[
          Text(
            widget.savingsGoalText!,
            style: AppTypography.labelSmall.copyWith(color: _accentColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
        ],

        // Основна сума з анімацією
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final currentVal = _animation.value;
            _displayAmount = currentVal;
            final formattedAmount = _formatAmount(currentVal);
            final suffix = widget.currencySuffix;

            final amountText = Text(
              formattedAmount,
              style: _baseStyle,
            );

            final suffixText = Text(
              suffix,
              style: _currencyStyle,
            );

            final amountAndSuffix = widget.currencyPosition == CurrencyPosition.after
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      amountText,
                      SizedBox(width: widget.size == MoneyDisplaySize.xs ? 3 : widget.size == MoneyDisplaySize.small ? 4 : 6),
                      suffixText,
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      suffixText,
                      SizedBox(width: widget.size == MoneyDisplaySize.xs ? 3 : widget.size == MoneyDisplaySize.small ? 4 : 6),
                      amountText,
                    ],
                  );

            return amountAndSuffix;
          },
        ),

        // Порівняння початкової та поточної суми
        if (widget.showComparison && widget.startAmount != null && widget.startAmount != widget.amount) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' було ${widget.startAmount!.toInt().formatUAH()}',
                style: AppTypography.monoCaption.copyWith(color: _textHintColor),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_formatDifference(widget.amount, widget.startAmount!)})',
                style: _comparisonStyle,
              ),
            ],
          ),
        ],

        // Прогрес-бар поточного/цільового
        if (widget.showProgress && widget.targetAmount != null) ...[
          const SizedBox(height: 8),
          _buildProgressBar(),
        ],

        // Підпис під сумою
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: _subtitleStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Прогрес-бар від поточної суми до цільової.
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final progressPercent = _formatPercent(progress);
        final remaining = widget.targetAmount! - widget.amount;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Прогрес-лінія
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accentColor,
                        _accentColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Текст прогресу
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.amount.formatUAH()} ${widget.currencySuffix}',
                  style: AppTypography.monoCaption.copyWith(
                    color: _accentColor,
                  ),
                ),
                Text(
                  '$progressPercent%',
                  style: AppTypography.monoCaption.copyWith(
                    color: _textHintColor,
                  ),
                ),
              ],
            ),
            // Залишилося
            if (remaining > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Залишилось ${remaining.toInt().formatUAH()} ${widget.currencySuffix}',
                  style: AppTypography.monoCaption.copyWith(
                    color: _textHintColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Convenience Constructors ───────────────────────────────────────────────

extension AppMoneyDisplayX on AppMoneyDisplay {
  /// Надкомпактний дисплей суми для inline тексту.
  static Widget xs({
    required double amount,
    bool isLightTheme = false,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: amount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.xs,
      currencySuffix: currencySuffix,
      animate: false,
    );
  }

  /// Компактний дисплей суми для списків.
  static Widget compact({
    required double amount,
    bool isLightTheme = false,
    double? previousAmount,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: amount,
      previousAmount: previousAmount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.small,
      compact: true,
      currencySuffix: currencySuffix,
      animate: previousAmount != null,
    );
  }

  /// Герой-дисплей суми для головного екрану цілі.
  static Widget hero({
    required double amount,
    double? targetAmount,
    bool isLightTheme = false,
    String? label,
    String? subtitle,
    String currencySuffix = 'грн',
    bool showProgress = true,
    double? startAmount,
    String? savingsGoalText,
  }) {
    return AppMoneyDisplay(
      amount: amount,
      targetAmount: targetAmount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.hero,
      label: label,
      subtitle: subtitle,
      currencySuffix: currencySuffix,
      showProgress: showProgress,
      animate: true,
      startAmount: startAmount,
      savingsGoalText: savingsGoalText,
      showComparison: startAmount != null,
    );
  }

  /// Дисплей суми з закресленою старою ціною.
  static Widget sale({
    required double currentAmount,
    required double oldAmount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: currentAmount,
      strikethroughAmount: oldAmount,
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      animate: true,
    );
  }

  /// Дисплей цілі накопичення з прогресом.
  static Widget savingsGoal({
    required double currentAmount,
    required double targetAmount,
    String? goalName,
    bool isLightTheme = false,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: currentAmount,
      targetAmount: targetAmount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.hero,
      label: goalName != null ? '🎯 $goalName' : 'Мета',
      subtitle: 'Накопичено з ${currentAmount.toInt().formatUAH()} з ${targetAmount.toInt().formatUAH()} $currencySuffix',
      currencySuffix: currencySuffix,
      showProgress: true,
      animate: true,
      savingsGoalText: goalName,
    );
  }

  /// Порівняльний дисплей (старт vs поточна сума).
  static Widget comparison({
    required double currentAmount,
    required double startAmount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: currentAmount,
      startAmount: startAmount,
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      animate: true,
      showComparison: true,
    );
  }

  /// Дисплей з анімованими десятковими знаками.
  static Widget decimal({
    required double amount,
    int decimalPlaces = 2,
    bool isLightTheme = false,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: amount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.medium,
      decimalPlaces: decimalPlaces,
      currencySuffix: currencySuffix,
      animate: true,
    );
  }
}

// ─── Money Display Constants ───────────────────────────────────────────────

/// Сталі значення для [AppMoneyDisplay].
///
/// Містить усі магічні числа та порогові значення,
/// що використовуються у компоненті відображення грошей.
class MoneyDisplayConstants {
  MoneyDisplayConstants._();

  /// Мінімальна сума для відображення негативного кольору.
  static const double negativeThreshold = 0.0;

  /// Максимальна кількість десяткових знаків.
  static const int maxDecimalPlaces = 6;

  /// Мінімальна кількість десяткових знаків.
  static const int minDecimalPlaces = 0;

  /// Порог для форматування «K» (тисячі).
  static const double kiloThreshold = 1000.0;

  /// Порог для форматування «M» (мільйони).
  static const double megaThreshold = 1000000.0;

  /// Порог для форматування «B» (мільярди).
  static const double gigaThreshold = 1000000000.0;

  /// Мінімальна тривалість анімації підрахунку.
  static const Duration minAnimationDuration = Duration(milliseconds: 200);

  /// Максимальна тривалість анімації підрахунку.
  static const Duration maxAnimationDuration = Duration(milliseconds: 3000);

  /// Стандартна висота прогрес-бару.
  static const double defaultProgressBarHeight = 4.0;

  /// Мінімальна ширина прогресу для відображення тексту.
  static const double minProgressForText = 0.05;

  /// Відступ між сумою та підписом.
  static const double subtitleSpacing = 4.0;

  /// Відступ між заголовком та сумою.
  static const double labelSpacing = 4.0;

  /// Відступ між сумою та валютою (xs розмір).
  static const double xsCurrencySpacing = 3.0;

  /// Відступ між сумою та валютою (small розмір).
  static const double smallCurrencySpacing = 4.0;

  /// Відступ між сумою та валютою (середній та більше).
  static const double defaultCurrencySpacing = 6.0;

  /// Коефіцієнт для strike-through розміру шрифту.
  static const double strikethroughFontScale = 0.7;

  /// Мінімальний розмір шрифту strike-through.
  static const double minStrikethroughFontSize = 10.0;

  /// Максимальний розмір шрифту strike-through.
  static const double maxStrikethroughFontSize = 24.0;
}

// ─── Validation & Formatting Helpers ────────────────────────────────────────

/// Допоміжні методи для валідації та форматування [AppMoneyDisplay].
class MoneyDisplayValidators {
  MoneyDisplayValidators._();

  /// Валідує параметри компонента перед відображенням.
  ///
  /// Повертає список помилок. Порожній список — компонент валідний.
  static List<String> validate({
    required double amount,
    double? targetAmount,
    double? previousAmount,
    int decimalPlaces = 0,
  }) {
    final errors = <String>[];
    if (decimalPlaces < MoneyDisplayConstants.minDecimalPlaces ||
        decimalPlaces > MoneyDisplayConstants.maxDecimalPlaces) {
      errors.add(
        'Decimal places must be between '
        '${MoneyDisplayConstants.minDecimalPlaces} and '
        '${MoneyDisplayConstants.maxDecimalPlaces}',
      );
    }
    if (targetAmount != null && targetAmount <= 0) {
      errors.add('Target amount must be positive');
    }
    if (amount.isNaN || amount.isInfinite) {
      errors.add('Amount must be a finite number');
    }
    if (previousAmount != null && previousAmount.isNaN) {
      errors.add('Previous amount must be a finite number');
    }
    return errors;
  }

  /// Перевіряє, чи сума достатня для прогрес-бару.
  static bool hasProgress(double? amount, double? target) {
    if (amount == null || target == null || target <= 0) return false;
    return amount > 0 && amount < target;
  }

  /// Перевіряє, чи сума досягла цілі.
  static bool isGoalReached(double amount, double target) {
    return amount >= target && target > 0;
  }

  /// Обчислює відсоток прогресу.
  static double computeProgress(double amount, double target) {
    if (target <= 0) return 0.0;
    return (amount / target).clamp(0.0, 1.0);
  }

  /// Обчислює залишок до цілі.
  static double remainingAmount(double amount, double target) {
    if (target <= 0) return 0.0;
    return (target - amount).clamp(0.0, target);
  }

  /// Форматує залишок для відображення.
  static String formatRemaining(double remaining, String currencySuffix) {
    if (remaining <= 0) return 'Ціль досягнуто!';
    return 'Залишилось ${remaining.toInt()} $currencySuffix';
  }
}

// ─── Additional Convenience Constructors ───────────────────────────────────

/// Додаткові фабричні методи для [AppMoneyDisplay].
extension AppMoneyDisplayAdditionalX on AppMoneyDisplay {
  /// Негативний дисплей (червоний, для витрат).
  static Widget expense({
    required double amount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String currencySuffix = 'грн',
    String? subtitle,
  }) {
    return AppMoneyDisplay(
      amount: -amount.abs(),
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      colorByAmount: true,
      animate: true,
      subtitle: subtitle,
    );
  }

  /// Дохідний дисплей (зелений, для доходів).
  static Widget income({
    required double amount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String currencySuffix = 'грн',
    String? subtitle,
  }) {
    return AppMoneyDisplay(
      amount: amount.abs(),
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      colorByAmount: true,
      animate: true,
      subtitle: subtitle,
    );
  }

  /// Баланс з індикатором позитивного/негативного.
  static Widget balance({
    required double amount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.large,
    String currencySuffix = 'грн',
    String? label,
  }) {
    return AppMoneyDisplay(
      amount: amount,
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      colorByAmount: true,
      animate: true,
      label: label ?? 'Баланс',
      showProgress: false,
    );
  }

  /// Дисплей ціни товару зі знижкою.
  static Widget discountPrice({
    required double currentPrice,
    required double originalPrice,
    double discountPercent = 0,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String currencySuffix = 'грн',
  }) {
    final saved = originalPrice - currentPrice;
    final subtitle = discountPercent > 0
        ? '-$discountPercent% (економія ${saved.toInt()} $currencySuffix)'
        : 'Економія ${saved.toInt()} $currencySuffix';
    return AppMoneyDisplay(
      amount: currentPrice,
      strikethroughAmount: originalPrice,
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      animate: true,
      subtitle: subtitle,
    );
  }

  /// Дисплей бюджету з прогресом витрат.
  static Widget budget({
    required double spent,
    required double budget,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.hero,
    String currencySuffix = 'грн',
    String? label,
  }) {
    return AppMoneyDisplay(
      amount: spent,
      targetAmount: budget,
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      label: label ?? 'Бюджет',
      subtitle: 'Витрачено з $budget.toInt() $currencySuffix',
      showProgress: true,
      animate: true,
    );
  }
}

// ─── Computed Properties Extension ─────────────────────────────────────────

/// Розширення для [MoneyDisplaySize] з обчислюваними властивостями.
extension MoneyDisplaySizeExtension on MoneyDisplaySize {
  /// Чи розмір підходить для inline використання.
  bool get isInline => index <= MoneyDisplaySize.small.index;

  /// Чи розмір підходить для виділеної секції.
  bool get isProminent => index >= MoneyDisplaySize.large.index;

  /// Коефіцієнт масштабу для щільності тексту.
  double get lineHeightMultiplier {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 1.1;
      case MoneyDisplaySize.small:
        return 1.15;
      case MoneyDisplaySize.medium:
        return 1.2;
      case MoneyDisplaySize.large:
        return 1.2;
      case MoneyDisplaySize.hero:
        return 1.1;
    }
  }

  /// Відступ між сумою та валютою.
  double get currencySpacing {
    switch (this) {
      case MoneyDisplaySize.xs:
        return MoneyDisplayConstants.xsCurrencySpacing;
      case MoneyDisplaySize.small:
        return MoneyDisplayConstants.smallCurrencySpacing;
      case MoneyDisplaySize.medium:
      case MoneyDisplaySize.large:
      case MoneyDisplaySize.hero:
        return MoneyDisplayConstants.defaultCurrencySpacing;
    }
  }

  /// Опис для дебагу.
  String get debugDescription {
    return 'MoneyDisplaySize.$name (fontSize: $fontSize, fontWeight: $fontWeight)';
  }
}

/// Розширення для [CurrencyPosition] з додатковими методами.
extension CurrencyPositionExtension on CurrencyPosition {
  /// Опис позиції валюти для дебагу.
  String get debugDescription {
    switch (this) {
      case CurrencyPosition.before:
        return 'Before amount (грн 1 250)';
      case CurrencyPosition.after:
        return 'After amount (1 250 грн)';
    }
  }

  /// Чи валюта перед сумою.
  bool get isBefore => this == CurrencyPosition.before;

  /// Чи валюта після суми.
  bool get isAfter => this == CurrencyPosition.after;
}

// ─── Money Display Accessibility ───────────────────────────────────────────

/// Допоміжні методи для доступності [AppMoneyDisplay].
///
/// Надає семантичні мітки, описи сум та підказки для скрінрідерів.
class MoneyDisplayAccessibility {
  MoneyDisplayAccessibility._();

  /// Генерує семантичну мітку для суми.
  static String buildSemanticsLabel({
    required double amount,
    required String currencySuffix,
    required MoneyDisplaySize size,
    MoneyDisplayMode displayMode = MoneyDisplayMode.standard,
    bool colorByAmount = false,
    bool showProgress = false,
    double? targetAmount,
    String? label,
  }) {
    final parts = <String>[];
    if (label != null) parts.add(label);
    parts.add('${amount.toStringAsFixed(0)} $currencySuffix');
    if (showProgress && targetAmount != null) {
      final percent = ((amount / targetAmount) * 100).toInt().clamp(0, 100);
      parts.add('прогрес $percent%');
    }
    if (colorByAmount) {
      parts.add(amount >= 0 ? 'додатний' : 'від\'ємний');
    }
    return parts.join('. ');
  }

  /// Генерує опис розміру для скрінрідера.
  static String sizeDescription(MoneyDisplaySize size) {
    switch (size) {
      case MoneyDisplaySize.xs:
        return 'Дуже малий дисплей суми';
      case MoneyDisplaySize.small:
        return 'Малий дисплей суми';
      case MoneyDisplaySize.medium:
        return 'Стандартний дисплей суми';
      case MoneyDisplaySize.large:
        return 'Великий дисплей суми';
      case MoneyDisplaySize.hero:
        return 'Герой-дисплей суми';
    }
  }

  /// Генерує підказку для режиму відображення.
  static String displayModeHint(MoneyDisplayMode mode) {
    switch (mode) {
      case MoneyDisplayMode.standard:
        return 'Повне число з розділювачами';
      case MoneyDisplayMode.compact:
        return 'Скорочене число';
      case MoneyDisplayMode.coinsOnly:
        return 'Тільки монети';
    }
  }
}

// ─── Money Formatting Extensions ──────────────────────────────────────────

/// Розширення для [double] з методами форматування грошей.
extension MoneyFormattingExtension on double {
  /// Форматує число як UAH з розділювачами.
  String formatAsMoney({String currencySuffix = 'грн'}) {
    if (abs() >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B $currencySuffix';
    } else if (abs() >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M $currencySuffix';
    } else if (abs() >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K $currencySuffix';
    }
    return '${toInt()} $currencySuffix';
  }

  /// Форматує число з відсотком прогресу.
  String formatAsProgress(double target) {
    if (target <= 0) return '0%';
    final percent = ((this / target) * 100).clamp(0, 100);
    return '${percent.toStringAsFixed(0)}%';
  }

  /// Форматує різницю від іншого значення.
  String formatDifference(double other) {
    final diff = this - other;
    if (diff == 0) return '+0';
    final sign = diff > 0 ? '+' : '';
    return '$sign${diff.toInt()}';
  }

  /// Повертає емодзі-позначку тренду.
  String trendEmoji({double? previous}) {
    if (previous == null) return '';
    if (this > previous) return '📈';
    if (this < previous) return '📉';
    return '➡️';
  }
}

// ─── Money Display Theme Builder ───────────────────────────────────────────

/// Утиліта для створення [AppMoneyDisplay] з темою.
///
/// Надає готові конфігурації для різних контекстів використання.
class MoneyDisplayThemeBuilder {
  MoneyDisplayThemeBuilder._();

  /// Створює дисплей суми для картки з темою.
  static AppMoneyDisplay forCard({
    required double amount,
    bool isLightTheme = false,
    String? label,
    String? subtitle,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: amount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.large,
      label: label,
      subtitle: subtitle,
      currencySuffix: currencySuffix,
      animate: true,
    );
  }

  /// Створює дисплей суми для списку з темою.
  static AppMoneyDisplay forList({
    required double amount,
    bool isLightTheme = false,
    String currencySuffix = 'грн',
    double? previousAmount,
  }) {
    return AppMoneyDisplay(
      amount: amount,
      previousAmount: previousAmount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.small,
      currencySuffix: currencySuffix,
      animate: previousAmount != null,
      compact: true,
    );
  }

  /// Створює дисплей суми для dashboard-картки.
  static AppMoneyDisplay forDashboard({
    required double amount,
    double? targetAmount,
    bool isLightTheme = false,
    String? label,
    String currencySuffix = 'грн',
    bool showProgress = true,
  }) {
    return AppMoneyDisplay(
      amount: amount,
      targetAmount: targetAmount,
      isLightTheme: isLightTheme,
      size: MoneyDisplaySize.hero,
      label: label,
      currencySuffix: currencySuffix,
      showProgress: showProgress,
      animate: true,
    );
  }

  /// Створює дисплей витрати (негативний, червоний).
  static AppMoneyDisplay forExpense({
    required double amount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String? subtitle,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: -amount.abs(),
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      colorByAmount: true,
      animate: true,
      subtitle: subtitle,
    );
  }

  /// Створює дисплей доходу (позитивний, зелений).
  static AppMoneyDisplay forIncome({
    required double amount,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String? subtitle,
    String currencySuffix = 'грн',
  }) {
    return AppMoneyDisplay(
      amount: amount.abs(),
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      colorByAmount: true,
      animate: true,
      subtitle: subtitle,
    );
  }

  /// Створює дисплей ціни зі знижкою.
  static AppMoneyDisplay forSale({
    required double currentPrice,
    required double originalPrice,
    double discountPercent = 0,
    bool isLightTheme = false,
    MoneyDisplaySize size = MoneyDisplaySize.medium,
    String currencySuffix = 'грн',
  }) {
    final saved = originalPrice - currentPrice;
    final subtitle = discountPercent > 0
        ? '-$discountPercent% (економія ${saved.toInt()} $currencySuffix)'
        : 'Економія ${saved.toInt()} $currencySuffix';
    return AppMoneyDisplay(
      amount: currentPrice,
      strikethroughAmount: originalPrice,
      isLightTheme: isLightTheme,
      size: size,
      currencySuffix: currencySuffix,
      animate: true,
      subtitle: subtitle,
    );
  }
}

// ─── Money Display Validation ─────────────────────────────────────────────

/// Розширені методи валідації для [AppMoneyDisplay].
class MoneyDisplayExtendedValidators {
  MoneyDisplayExtendedValidators._();

  /// Повна валідація всіх параметрів компонента.
  ///
  /// Повертає список помилок. Порожній — компонент валідний.
  static List<String> validateFull({
    required double amount,
    double? targetAmount,
    double? previousAmount,
    double? startAmount,
    double? strikethroughAmount,
    int decimalPlaces = 0,
    String currencySuffix = 'грн',
  }) {
    final errors = <String>[];
    errors.addAll(MoneyDisplayValidators.validate(
      amount: amount,
      targetAmount: targetAmount,
      previousAmount: previousAmount,
      decimalPlaces: decimalPlaces,
    ));

    if (strikethroughAmount != null && strikethroughAmount!.isNaN) {
      errors.add('Strikethrough amount must be a finite number');
    }
    if (startAmount != null && startAmount!.isNaN) {
      errors.add('Start amount must be a finite number');
    }
    if (currencySuffix.isEmpty) {
      errors.add('Currency suffix must not be empty');
    }
    if (targetAmount != null && targetAmount! <= amount) {
      // Warning: target should be greater than current
    }
    return errors;
  }

  /// Перевіряє, чи параметри прогресу коректні.
  static bool isValidProgress({
    required double amount,
    required double target,
  }) {
    return target > 0 && amount >= 0;
  }

  /// Перевіряє, чи компактний режим доречний для суми.
  static bool shouldUseCompact(double amount) {
    return amount.abs() >= MoneyDisplayConstants.kiloThreshold;
  }

  /// Перевіряє, чи потрібен прогрес-бар.
  static bool needsProgressBar({
    double? targetAmount,
    double amount = 0,
  }) {
    if (targetAmount == null || targetAmount <= 0) return false;
    return amount > 0 && amount < targetAmount;
  }

  /// Рекомендує розмір залежно від контексту.
  static MoneyDisplaySize recommendSize({
    bool isInline = false,
    bool isInCard = false,
    bool isHero = false,
    bool isInList = false,
  }) {
    if (isHero) return MoneyDisplaySize.hero;
    if (isInCard) return MoneyDisplaySize.large;
    if (isInList) return MoneyDisplaySize.small;
    if (isInline) return MoneyDisplaySize.xs;
    return MoneyDisplaySize.medium;
  }
}

// ─── Additional Computed Extensions ────────────────────────────────────────

/// Розширення для [MoneyDisplayMode] з додатковими властивостями.
extension MoneyDisplayModeExtension on MoneyDisplayMode {
  /// Опис режиму для дебагу.
  String get debugDescription {
    switch (this) {
      case MoneyDisplayMode.standard:
        return 'Standard — повне число з розділювачами';
      case MoneyDisplayMode.compact:
        return 'Compact — скорочене число (K/M/B)';
      case MoneyDisplayMode.coinsOnly:
        return 'CoinsOnly — тільки монети з іконкою';
    }
  }

  /// Чи цей режим показує повне число.
  bool get isFullNumber => this == MoneyDisplayMode.standard;

  /// Чи цей режим використовує скорочення.
  bool get usesAbbreviation => this == MoneyDisplayMode.compact;

  /// Поріг для переключення на компактний режим.
  double get compactThreshold {
    switch (this) {
      case MoneyDisplayMode.standard:
        return double.infinity;
      case MoneyDisplayMode.compact:
        return MoneyDisplayConstants.kiloThreshold;
      case MoneyDisplayMode.coinsOnly:
        return 0;
    }
  }
}

/// Розширення для [MoneyDisplaySize] з додатковими стилями.
extension MoneyDisplaySizeStyleExtension on MoneyDisplaySize {
  /// Повертає відступ від прогрес-бару до тексту.
  double get progressTopSpacing {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 2.0;
      case MoneyDisplaySize.small:
        return 4.0;
      case MoneyDisplaySize.medium:
        return 6.0;
      case MoneyDisplaySize.large:
        return 8.0;
      case MoneyDisplaySize.hero:
        return 12.0;
    }
  }

  /// Повертає висоту прогрес-бару залежно від розміру.
  double get progressHeight {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 2.0;
      case MoneyDisplaySize.small:
        return 3.0;
      case MoneyDisplaySize.medium:
        return 4.0;
      case MoneyDisplaySize.large:
        return 6.0;
      case MoneyDisplaySize.hero:
        return 8.0;
    }
  }

  /// Повертає розмір шрифту для підпису (subtitle).
  double get subtitleFontSize {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 9.0;
      case MoneyDisplaySize.small:
        return 10.0;
      case MoneyDisplaySize.medium:
        return 12.0;
      case MoneyDisplaySize.large:
        return 14.0;
      case MoneyDisplaySize.hero:
        return 16.0;
    }
  }

  /// Повертає розмір шрифту для заголовка (label).
  double get labelFontSize {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 9.0;
      case MoneyDisplaySize.small:
        return 11.0;
      case MoneyDisplaySize.medium:
        return 13.0;
      case MoneyDisplaySize.large:
        return 15.0;
      case MoneyDisplaySize.hero:
        return 18.0;
    }
  }

  /// Коефіцієнт масштабу для strike-through тексту.
  double get strikethroughScale {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 0.8;
      case MoneyDisplaySize.small:
        return 0.75;
      case MoneyDisplaySize.medium:
        return 0.7;
      case MoneyDisplaySize.large:
        return 0.7;
      case MoneyDisplaySize.hero:
        return 0.65;
    }
  }

  /// Рекомендує кількість десяткових знаків для розміру.
  int get recommendedDecimalPlaces {
    switch (this) {
      case MoneyDisplaySize.xs:
        return 0;
      case MoneyDisplaySize.small:
        return 0;
      case MoneyDisplaySize.medium:
        return 2;
      case MoneyDisplaySize.large:
        return 2;
      case MoneyDisplaySize.hero:
        return 2;
    }
  }

  /// Чи розмір підтримує декоративні елементи (прогрес, strike).
  bool get supportsDecoration =>
      index >= MoneyDisplaySize.medium.index;
}
