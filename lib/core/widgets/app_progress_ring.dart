import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ─── Ring Size Enum ─────────────────────────────────────────────────────────

/// Розмір кільця прогресу.
enum AppProgressRingSize {
  /// Дуже малий (32px) — для компактних індикаторів.
  xs(32.0),

  /// Малий (48px) — для компактних бейджів.
  small(48.0),

  /// Середній (80px) — стандартний для карток.
  medium(80.0),

  /// Великий (120px) — для виділених секцій.
  large(120.0),

  /// Дуже великий (160px) — для головних екранів.
  xl(160.0);

  const AppProgressRingSize(this.value);
  final double value;

  /// Розмір шрифту для числа всередині кільця.
  double get numberFontSize {
    switch (this) {
      case AppProgressRingSize.xs:
        return 10.0;
      case AppProgressRingSize.small:
        return 12.0;
      case AppProgressRingSize.medium:
        return 18.0;
      case AppProgressRingSize.large:
        return 26.0;
      case AppProgressRingSize.xl:
        return 34.0;
    }
  }

  /// Розмір шрифту для підпису під числом.
  double get labelFontSize {
    switch (this) {
      case AppProgressRingSize.xs:
        return 6.0;
      case AppProgressRingSize.small:
        return 8.0;
      case AppProgressRingSize.medium:
        return 11.0;
      case AppProgressRingSize.large:
        return 14.0;
      case AppProgressRingSize.xl:
        return 16.0;
    }
  }

  /// Розмір іконки-бейджа в центрі.
  double get badgeIconSize {
    switch (this) {
      case AppProgressRingSize.xs:
        return 10.0;
      case AppProgressRingSize.small:
        return 14.0;
      case AppProgressRingSize.medium:
        return 22.0;
      case AppProgressRingSize.large:
        return 32.0;
      case AppProgressRingSize.xl:
        return 40.0;
    }
  }

  /// Товщина обідка за замовчуванням.
  double get defaultThickness {
    switch (this) {
      case AppProgressRingSize.xs:
        return 3.0;
      case AppProgressRingSize.small:
        return 4.0;
      case AppProgressRingSize.medium:
        return 6.0;
      case AppProgressRingSize.large:
        return 8.0;
      case AppProgressRingSize.xl:
        return 10.0;
    }
  }

  /// Українська назва розміру.
  String get label {
    switch (this) {
      case AppProgressRingSize.xs:
        return 'Дуже малий';
      case AppProgressRingSize.small:
        return 'Малий';
      case AppProgressRingSize.medium:
        return 'Середній';
      case AppProgressRingSize.large:
        return 'Великий';
      case AppProgressRingSize.xl:
        return 'Дуже великий';
    }
  }
}

// ─── Ring Thickness Enum ────────────────────────────────────────────────────

/// Товщина обідка кільця.
enum AppProgressRingThickness {
  /// Тонкий (4px).
  thin(4.0),

  /// Стандартний (6px).
  normal(6.0),

  /// Товстий (10px).
  thick(10.0),

  /// Дуже товстий (14px).
  extraThick(14.0);

  const AppProgressRingThickness(this.value);
  final double value;

  /// Українська назва товщини.
  String get label {
    switch (this) {
      case AppProgressRingThickness.thin:
        return 'Тонкий';
      case AppProgressRingThickness.normal:
        return 'Стандартний';
      case AppProgressRingThickness.thick:
        return 'Товстий';
      case AppProgressRingThickness.extraThick:
        return 'Дуже товстий';
    }
  }
}

// ─── Ring Cap Style ─────────────────────────────────────────────────────────

/// Стиль кінців лінії кільця.
enum AppProgressRingCap {
  /// Заокруглені кінці.
  round,

  /// Прямі кінці.
  butt,

  /// Квадратні кінці.
  square;
}

/// Кільцевий індикатор прогресу з анімованим числом, градієнтом та бейджем.
///
/// Використовується для відображення рівня XP, прогресу цілей та кругових
/// індикаторів. Підтримує розміри, товщину, градієнт, свічення, багаторазове
/// кільце та іконку-бейдж у центрі.
class AppProgressRing extends StatefulWidget {
  const AppProgressRing({
    super.key,
    required this.progress,
    this.ringSize = AppProgressRingSize.medium,
    this.thickness = AppProgressRingThickness.normal,
    this.strokeWidth,
    this.size,
    this.color,
    this.gradientStart,
    this.gradientEnd,
    this.backgroundColor,
    this.isLightTheme = false,
    this.child,
    this.showGlow = false,
    this.showNumber = false,
    this.numberLabel,
    this.badgeIcon,
    this.animatedNumber = false,
    this.capStyle = AppProgressRingCap.round,
    this.startAngle = -90.0,
    this.reverse = false,
    this.semanticLabel,
  });

  /// Прогрес від 0.0 до 1.0.
  final double progress;

  /// Розмір кільця (перевизначає size).
  final AppProgressRingSize ringSize;

  /// Товщина обідка (перевизначає strokeWidth).
  final AppProgressRingThickness thickness;

  /// Кастомна товщина обідка (legacy).
  final double? strokeWidth;

  /// Кастомний розмір кільця (legacy).
  final double? size;

  /// Кастомний однотонний колір кільця.
  final Color? color;

  /// Кастомний початковий колір градієнта.
  final Color? gradientStart;

  /// Кастомний кінцевий колір градієнта.
  final Color? gradientEnd;

  /// Колір фонової доріжки.
  final Color? backgroundColor;

  /// Світла тема.
  final bool isLightTheme;

  /// Кастомний дочірній віджет у центрі кільця.
  final Widget? child;

  /// Показувати неонове свічення навколо кільця.
  final bool showGlow;

  /// Показувати анімоване число у центрі.
  final bool showNumber;

  /// Текст-підпис під числом (наприклад, «Рівень»).
  final String? numberLabel;

  /// Іконка-бейдж у центрі кільця.
  final IconData? badgeIcon;

  /// Анімувати число (count-up ефект).
  final bool animatedNumber;

  /// Стиль кінців лінії.
  final AppProgressRingCap capStyle;

  /// Початковий кут у градусах (замовчування -90 = верх).
  final double startAngle;

  /// Відображати прогрес у зворотному напрямку.
  final bool reverse;

  /// Семантична мітка для екранних читачів.
  final String? semanticLabel;

  @override
  State<AppProgressRing> createState() => _AppProgressRingState();
}

class _AppProgressRingState extends State<AppProgressRing> {
  double _displayedProgress = 0.0;
  int _displayedNumber = 0;

  // ─── Computed Values ─────────────────────────────────────────────────

  double get _effectiveSize => widget.size ?? widget.ringSize.value;

  double get _effectiveThickness =>
      widget.strokeWidth ?? widget.thickness.value;

  Color get _ringColor =>
      widget.color ??
      (widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent);

  Color get _bgColor =>
      widget.backgroundColor ??
      (widget.isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border);

  Color get _gradientStartColor =>
      widget.gradientStart ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientStart
          : AppColorsPS5.gradientStart);

  Color get _gradientEndColor =>
      widget.gradientEnd ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientEnd
          : AppColorsPS5.gradientEnd);

  Color get _textColor =>
      widget.isLightTheme
          ? AppColorsMonitor.textPrimary
          : AppColorsPS5.textPrimary;

  Color get _textSecondary =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  StrokeCap get _strokeCap {
    switch (widget.capStyle) {
      case AppProgressRingCap.round:
        return StrokeCap.round;
      case AppProgressRingCap.butt:
        return StrokeCap.butt;
      case AppProgressRingCap.square:
        return StrokeCap.square;
    }
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _displayedProgress = widget.progress;
    _displayedNumber = (widget.progress * 100).toInt();
  }

  @override
  void didUpdateWidget(covariant AppProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animateProgress(oldWidget.progress, widget.progress);
    }
  }

  void _animateProgress(double from, double to) {
    final clampedTo = to.clamp(0.0, 1.0);
    final duration = AppDurations.countUp;

    final startNumber = (from * 100).toInt();
    final endNumber = (clampedTo * 100).toInt();

    if (widget.animatedNumber && widget.showNumber) {
      _animateNumber(startNumber, endNumber, duration);
    } else if (widget.showNumber) {
      setState(() => _displayedNumber = endNumber);
    }

    setState(() => _displayedProgress = clampedTo);
  }

  void _animateNumber(int from, int to, Duration duration) {
    final range = (to - from).abs();
    if (range == 0) {
      setState(() => _displayedNumber = to);
      return;
    }
    final stepDuration = duration.milliseconds ~/ range;
    final isIncreasing = to > from;
    var current = from;

    void step() {
      if ((isIncreasing && current >= to) ||
          (!isIncreasing && current <= to)) {
        setState(() => _displayedNumber = to);
        return;
      }
      current += isIncreasing ? 1 : -1;
      setState(() => _displayedNumber = current);
      Future.delayed(Duration(milliseconds: stepDuration), step);
    }

    step();
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Widget ring = SizedBox(
      width: _effectiveSize,
      height: _effectiveSize,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        decoration: widget.showGlow
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _ringColor.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            progress: widget.reverse
                ? (1.0 - _displayedProgress.clamp(0.0, 1.0))
                : _displayedProgress.clamp(0.0, 1.0),
            strokeWidth: _effectiveThickness,
            ringColor: widget.color,
            gradientStart: widget.gradientStart ?? _gradientStartColor,
            gradientEnd: widget.gradientEnd ?? _gradientEndColor,
            backgroundColor: _bgColor,
            strokeCap: _strokeCap,
            startAngle: widget.startAngle,
          ),
          child: _buildCenterContent(),
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      ring = Semantics(
        label: widget.semanticLabel!,
        value: '${(_displayedProgress * 100).toInt()}%',
        child: ring,
      );
    }

    return ring;
  }

  // ─── Center Content ──────────────────────────────────────────────────

  Widget? _buildCenterContent() {
    if (widget.child != null) {
      return Center(child: widget.child);
    }

    if (widget.badgeIcon != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _ringColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.badgeIcon,
            color: _ringColor,
            size: widget.ringSize.badgeIconSize,
          ),
        ),
      );
    }

    if (widget.showNumber) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_displayedNumber',
              style: AppTypography.monoMedium.copyWith(
                color: _textColor,
                fontSize: widget.ringSize.numberFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.numberLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.numberLabel!,
                style: AppTypography.labelSmall.copyWith(
                  color: _textSecondary,
                  fontSize: widget.ringSize.labelFontSize,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return null;
  }
}

// ─── Ring Theme Builder ───────────────────────────────────────────────────────

/// Будуєчий тем кольорів для кільця прогресу.
///
/// Центральний точка для визначення кольорів кільця залежно від теми,
/// стану прогресу та кастомних налаштувань.
class ProgressRingThemeBuilder {
  ProgressRingThemeBuilder._();

  /// Повертає колір кільця для заданої теми та прогресу.
  ///
  /// [progress] — поточний прогрес (0.0–1.0).
  /// [isLightTheme] — тема інтерфейсу.
  /// [customColor] — кастомний колір (якщо є).
  /// [gradientStart] — кастомний початковий колір градієнта.
  /// [gradientEnd] — кастомний кінцевий колір градієнта.
  static Color resolveRingColor({
    required double progress,
    required bool isLightTheme,
    Color? customColor,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    if (customColor != null) return customColor;

    // Залежність кольору від прогресу (зеленений → жовтий → помаранчевий)
    if (progress >= 0.9) {
      return isLightTheme
          ? AppColorsMonitor.success
          : AppColorsPS5.success;
    }
    return isLightTheme
        ? AppColorsMonitor.accent
        : AppColorsPS5.accent;
  }

  /// Повертає кольори градієнта кільця.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  /// [customStart] — кастомний початковий колір.
  /// [customEnd] — кастомний кінцевий колір.
  static ({Color start, Color end}) resolveGradientColors({
    required bool isLightTheme,
    Color? customStart,
    Color? customEnd,
  }) {
    return (
      start: customStart ??
          (isLightTheme
              ? AppColorsMonitor.gradientStart
              : AppColorsPS5.gradientStart),
      end: customEnd ??
          (isLightTheme
              ? AppColorsMonitor.gradientEnd
              : AppColorsPS5.gradientEnd),
    );
  }

  /// Повертає колір фонової доріжки кільця.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  /// [customBg] — кастомний колір фону.
  static Color resolveTrackColor({
    required bool isLightTheme,
    Color? customBg,
  }) {
    return customBg ??
        (isLightTheme
            ? AppColorsMonitor.border
            : AppColorsPS5.border);
  }

  /// Повертає кольори тексту для числа в центрі кільця.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  static ({Color primary, Color secondary}) resolveTextColors({
    required bool isLightTheme,
  }) {
    return (
      primary: isLightTheme
          ? AppColorsMonitor.textPrimary
          : AppColorsPS5.textPrimary,
      secondary: isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary,
    );
  }

  /// Повертає колір свічення навколо кільця.
  ///
  /// Свічення з'являється при високому прогресі.
  static Color resolveGlowColor({
    required bool isLightTheme,
    required Color ringColor,
    double progress = 1.0,
  }) {
    if (progress < 0.85) return Colors.transparent;
    final intensity = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
    return ringColor.withOpacity(0.3 * intensity);
  }

  /// Повертає тінь для кільця залежно від стану свічення.
  static BoxShadow resolveBoxShadow({
    required bool showGlow,
    required Color ringColor,
    required double progress,
    double blurRadius = 16.0,
    double spreadRadius = 4.0,
  }) {
    if (!showGlow || progress < 0.85) {
      return const BoxShadow(
        color: Colors.transparent,
        blurRadius: 0,
        spreadRadius: 0,
      );
    }
    final intensity = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
    return BoxShadow(
      color: ringColor.withOpacity(0.3 * intensity),
      blurRadius: blurRadius * intensity,
      spreadRadius: spreadRadius * intensity,
    );
  }
}

// ─── Ring Accessibility Helpers ───────────────────────────────────────────────────

/// Допоміжні методи для доступності кільця прогресу.
///
/// Надає семантичні мітки, описи та значення для екранних читачів.
class ProgressRingAccessibility {
  ProgressRingAccessibility._();

  /// Форматує семантичну мітку для кільця прогресу.
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  /// [semanticLabel] — кастомна мітка.
  /// [numberLabel] — текст-підпис (наприклад, «XP»).
  static String formatSemanticLabel({
    required double progress,
    String? semanticLabel,
    String? numberLabel,
  }) {
    if (semanticLabel != null) return semanticLabel;
    final percent = (progress * 100).toInt();
    if (numberLabel != null) {
      return '$numberLabel: $percent%';
    }
    return 'Прогрес: $percent%';
  }

  /// Форматує значення для екранних читачів.
  static String formatValue(double progress) {
    return '${(progress * 100).toInt()} відсотків';
  }

  /// Повертає опис прогресу для людей з вадами зору.
  ///
  /// Використовується для Semantics.value.
  static String accessibilityValue(double progress) {
    final percent = (progress * 100).toInt();
    if (percent >= 100) return 'Завершено';
    if (percent >= 75) return 'Майже завершено';
    if (percent >= 50) return 'Більше половини';
    if (percent >= 25) return 'Чверть пройдено';
    if (percent > 0) return 'Розпочато';
    return 'Ще не почато';
  }

  /// Повертає опис кроку для прогресу цілі.
  ///
  /// [progress] — значення прогресу.
  /// [goalName] — назва цілі (наприклад, «PS5»).
  static String goalProgressLabel(double progress, String goalName) {
    final percent = (progress * 100).toInt();
    return '$goalName: $percent% виконано';
  }

  /// Форматує повідомлення про зміну прогресу.
  static String progressChangeMessage({
    required double oldValue,
    required double newValue,
    String? context,
  }) {
    final oldPercent = (oldValue * 100).toInt();
    final newPercent = (newValue * 100).toInt();
    final diff = newPercent - oldPercent;
    final sign = diff >= 0 ? '+' : '';
    final prefix = context != null ? '$context: ' : '';
    return '${prefix}Прогрес $sign$diff% ($newPercent%)';
  }
}

// ─── Ring Validation ────────────────────────────────────────────────────────────

/// Методи валідації для кільця прогресу.
///
/// Перевіряє коректність параметрів перед відображенням.
class ProgressRingValidation {
  ProgressRingValidation._();

  /// Перевіряє, чи прогрес знаходиться в допустимих межах.
  ///
  /// [progress] — значення прогресу.
  /// Повертає `true`, якщо 0.0 <= progress <= 1.0.
  static bool isValidProgress(double progress) {
    return !progress.isNaN && progress >= 0.0 && progress <= 1.0;
  }

  /// Перевіряє, чи розмір кільця знаходиться в допустимих межах.
  ///
  /// [size] — розмір кільця у пікселях.
  /// Повертає `true`, якщо розмір в межах 20–200 пікселів.
  static bool isValidSize(double size) {
    return size >= 20.0 && size <= 200.0;
  }

  /// Перевіряє, чи товщина обідка знаходиться в допустимих межах.
  ///
  /// [thickness] — товщина обідка.
  /// Повертає `true`, якщо товщина в межах 1.0–20.0.
  static bool isValidThickness(double thickness) {
    return thickness >= 1.0 && thickness <= 20.0;
  }

  /// Перевіряє, чи початковий кут в допустимих межах.
  ///
  /// [angle] — кут у градусах.
  /// Повертає `true`, якщо кут в межах -360–360.
  static bool isValidStartAngle(double angle) {
    return angle >= -360.0 && angle <= 360.0;
  }

  /// Повертає виправлений прогрес (обмежений 0.0–1.0).
  static double clampProgress(double progress) {
    if (progress.isNaN) return 0.0;
    return progress.clamp(0.0, 1.0);
  }

  /// Повертає опис помилки валідації.
  static String validationError(String field, dynamic value) {
    return 'Некоректне значення $field: $value';
  }

  /// Повертає список усіх помилок валідації для кільця.
  ///
  /// Повертає список рядків з описом помилок.
  static List<String> validateAll({
    double? progress,
    double? size,
    double? thickness,
    double? startAngle,
  }) {
    final errors = <String>[];
    if (progress != null && !isValidProgress(progress)) {
      errors.add('Прогрес має бути в межах 0.0–1.0');
    }
    if (size != null && !isValidSize(size)) {
      errors.add('Розмір має бути в межах 20–200 пікселів');
    }
    if (thickness != null && !isValidThickness(thickness)) {
      errors.add('Товщина має бути в межах 1–20 пікселів');
    }
    if (startAngle != null && !isValidStartAngle(startAngle)) {
      errors.add('Кут має бути в межах -360–360°');
    }
    return errors;
  }
}

// ─── Ring Size Calculator ────────────────────────────────────────────────────────

/// Обчислює оптимальні розміри кільця залежно від контексту.
///
/// Допомагає вибрати розмір кільця для різних сценаріїв.
class RingSizeCalculator {
  RingSizeCalculator._();

  /// Обчислює розмір кільця для картки.
  ///
  /// [cardWidth] — ширина картки.
  /// [cardHeight] — висота картки.
  static double forCard(double cardWidth, double cardHeight) {
    final minDimension = math.min(cardWidth, cardHeight);
    return (minDimension * 0.5).clamp(32.0, 120.0);
  }

  /// Обчислює розмір кільця для списку.
  ///
  /// [listItemHeight] — висота елемента списку.
  static double forListItem(double listItemHeight) {
    return (listItemHeight * 0.6).clamp(24.0, 48.0);
  }

  /// Обчислює розмір кільця для головного екрана.
  ///
  /// [screenWidth] — ширина екрана.
  static double forMainScreen(double screenWidth) {
    if (screenWidth < 360) return 64.0;
    if (screenWidth < 600) return 80.0;
    return 120.0;
  }

  /// Обчислює розмір кільця для діалогу.
  ///
  /// [dialogWidth] — ширина діалогу.
  static double forDialog(double dialogWidth) {
    return (dialogWidth * 0.35).clamp(48.0, 160.0);
  }

  /// Обчислює розмір кільця для бейджа/картки.
  ///
  /// [badgeDimension] — розмір бейджу.
  static double forBadge(double badgeDimension) {
    return badgeDimension * 0.8;
  }

  /// Обчислює товщину обідка залежно від розміру кільця.
  ///
  /// Більші кільця — товстіший обідок.
  static double thicknessForSize(double ringSize) {
    if (ringSize < 40) return 3.0;
    if (ringSize < 60) return 4.0;
    if (ringSize < 100) return 6.0;
    if (ringSize < 140) return 8.0;
    return 10.0;
  }

  /// Обчислює розмір шрифту для числа залежно від розміру кільця.
  static double fontSizeForSize(double ringSize) {
    return (ringSize * 0.22).clamp(10.0, 34.0);
  }

  /// Обчислює розмір шрифту для підпису залежно від розміру кільця.
  static double labelFontSizeForSize(double ringSize) {
    return (ringSize * 0.12).clamp(6.0, 16.0);
  }
}

// ─── Ring Animation Curve Builder ─────────────────────────────────────────────────

/// Будує криві анімації для кільця прогресу.
///
/// Надає готові криві для різних ефектів анімації кільця.
class RingAnimationCurves {
  RingAnimationCurves._();

  /// Плавна крива для анімації прогресу кільця.
  ///
  /// Використовується для плавного заповнення кільця.
  static Curve get smoothFill => Curves.easeInOutCubic;

  /// Пружинна крива для bounce-ефекту при досягненні 100%.
  static Curve get celebrationBounce => Curves.elasticOut;

  /// Лінійна крива для точного відображення прогресу.
  static Curve get linear => Curves.linear;

  /// Затухаюча крива для повільної зміни.
  static Curve get gentle => Curves.easeOut;

  /// Швидка крива для миттєвого оновлення.
  static Curve get fast => Curves.easeIn;

  /// Пружинна крива для интерактивного зміщення.
  static Curve get interactive => Curves.easeOutBack;

  /// Повертає криву залежно від швидкості зміни.
  ///
  /// [percentDiff] — різниця у відсотках між старим та новим значенням.
  static Curve curveForSpeed(double percentDiff) {
    if (percentDiff < 5) return Curves.linear;
    if (percentDiff < 20) return Curves.easeOut;
    if (percentDiff < 50) return Curves.easeInOutCubic;
    return Curves.easeInOut;
  }

  /// Повертає криву для святкування.
  ///
  /// Використовує пружинний ефект для привернення уваги.
  static Curve celebrationCurve(bool isCompleted) {
    return isCompleted
        ? Curves.elasticOut
        : Curves.easeInOutCubic;
  }
}

// ─── Ring Tick Marks Painter ──────────────────────────────────────────────────────

/// CustomPainter для малювання міток-поділоків на кільці прогресу.
///
/// Малює короткі лінії на кільці для візуалізації етапів.
class RingTickMarksPainter extends CustomPainter {
  RingTickMarksPainter({
    required this.progress,
    this.tickCount = 12,
    this.tickLength = 4.0,
    this.tickWidth = 1.5,
    this.tickColor,
    this.activeTickColor,
    this.startAngle = -90.0,
  });

  /// Прогрес (0.0–1.0).
  final double progress;

  /// Кількість міток.
  final int tickCount;

  /// Довжина кожної мітки.
  final double tickLength;

  /// Товщина кожної мітки.
  final double tickWidth;

  /// Колір неактивної мітки.
  final Color? tickColor;

  /// Колір активної (пройденої) мітки.
  final Color? activeTickColor;

  /// Початковий кут у градусах.
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - tickWidth) / 2;
    final inactiveColor = tickColor ?? Colors.white.withOpacity(0.15);
    final activeColor = activeTickColor ?? Colors.white.withOpacity(0.6);
    final startRad = (startAngle * math.pi) / 180;
    final fullSweep = 2 * math.pi;

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = tickWidth;

    for (var i = 0; i < tickCount; i++) {
      final fraction = i / tickCount;
      final angle = startRad + fullSweep * fraction;
      final tickProgress = fraction;

      tickPaint.color =
          tickProgress <= progress ? activeColor : inactiveColor;

      final innerR = radius - tickLength;
      final outerR = radius + tickLength;
      final dx1 = center.dx + math.cos(angle) * innerR;
      final dy1 = center.dy + math.sin(angle) * innerR;
      final dx2 = center.dx + math.cos(angle) * outerR;
      final dy2 = center.dy + math.sin(angle) * outerR;

      canvas.drawLine(
        Offset(dx1, dy1),
        Offset(dx2, dy2),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RingTickMarksPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tickCount != tickCount ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.activeTickColor != activeTickColor;
  }
}

// ─── Ring Painter ───────────────────────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.ringColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.backgroundColor,
    this.strokeCap = StrokeCap.round,
    this.startAngle = -90.0,
  });

  final double progress;
  final double strokeWidth;
  final Color? ringColor;
  final Color gradientStart;
  final Color gradientEnd;
  final Color backgroundColor;
  final StrokeCap strokeCap;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // ── Background Ring ──
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    canvas.drawCircle(center, radius, bgPaint);

    // ── Progress Arc ──
    if (progress > 0) {
      final startAngleRad = (startAngle * math.pi) / 180;
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngleRad,
          endAngle: startAngleRad + 2 * math.pi,
          colors: ringColor != null
              ? [ringColor!, ringColor!.withOpacity(0.7)]
              : [gradientStart, gradientEnd],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngleRad,
        sweepAngle,
        false,
        progressPaint,
      );

      // ── Glow dot at end of progress ──
      if (progress > 0.01 && progress < 0.99 && strokeCap == StrokeCap.round) {
        final endAngle = startAngleRad + sweepAngle;
        final dotCenter = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );
        final dotPaint = Paint()
          ..color = (ringColor ?? gradientEnd).withOpacity(0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(dotCenter, strokeWidth * 0.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gradientStart != gradientStart ||
        oldDelegate.gradientEnd != gradientEnd ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.startAngle != startAngle;
  }
}

// ─── Arc Ring (півкільце) ──────────────────────────────────────────────────

/// Напівкільцевий індикатор прогресу.
///
/// Корисний для відображення прогресу у вигляді дуги зверху чи знизу.
class AppArcRing extends StatelessWidget {
  const AppArcRing({
    super.key,
    required this.progress,
    this.sweepAngle = 180.0,
    this.strokeWidth = 8.0,
    this.color,
    this.backgroundColor,
    this.size = 120.0,
    this.isLightTheme = false,
    this.startAngle = -180.0,
    this.showGlow = false,
    this.child,
  });

  /// Прогрес від 0.0 до 1.0.
  final double progress;
  /// Кут дуги у градусах (180 = напівкільце).
  final double sweepAngle;
  /// Товщина лінії.
  final double strokeWidth;
  /// Колір заповнення.
  final Color? color;
  /// Колір фону.
  final Color? backgroundColor;
  /// Розмір контейнера.
  final double size;
  /// Світла тема.
  final bool isLightTheme;
  /// Початковий кут.
  final double startAngle;
  /// Показувати свічення.
  final bool showGlow;
  /// Вміст у центрі.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent);
    final effectiveBg = backgroundColor ??
        (isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border);

    return SizedBox(
      width: size,
      height: size * (sweepAngle / 360.0) + strokeWidth,
      child: CustomPaint(
        painter: _ArcRingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          color: effectiveColor,
          backgroundColor: effectiveBg,
          sweepAngle: sweepAngle,
          startAngle: startAngle,
          showGlow: showGlow,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _ArcRingPainter extends CustomPainter {
  _ArcRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
    required this.sweepAngle,
    required this.startAngle,
    required this.showGlow,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final double sweepAngle;
  final double startAngle;
  final bool showGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width - strokeWidth) / 2;
    final startRad = (startAngle * math.pi) / 180;
    final sweepRad = (sweepAngle * math.pi) / 180;

    // Фонова дуга
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepRad,
      false,
      bgPaint,
    );

    // Дуга прогресу
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (showGlow) {
        progressPaint
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRad,
        sweepRad * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

// ─── Multi-Ring Support ─────────────────────────────────────────────────────

/// Віджет для відображення кількох кілець прогресу один на одному.
///
/// Корисно для відображення паралельних цілей або багаторівневого прогресу.
class AppMultiProgressRing extends StatelessWidget {
  const AppMultiProgressRing({
    super.key,
    required this.rings,
    this.size = 120.0,
    this.centerWidget,
    this.isLightTheme = false,
    this.semanticLabel,
  });

  /// Список кілець прогресу (від найбільшого до найменшого).
  final List<AppMultiRingLayer> rings;

  /// Загальний розмір контейнера.
  final double size;

  /// Віджет у центрі всіх кілець.
  final Widget? centerWidget;

  /// Світла тема.
  final bool isLightTheme;

  /// Семантична мітка.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget stack = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...rings.map((ring) {
            return AppProgressRing(
              progress: ring.progress,
              size: size - ring.offset * 2,
              strokeWidth: ring.thickness,
              color: ring.color,
              gradientStart: ring.gradientStart,
              gradientEnd: ring.gradientEnd,
              backgroundColor: ring.trackColor,
              isLightTheme: isLightTheme,
              showGlow: ring.showGlow,
            );
          }),
          if (centerWidget != null) Center(child: centerWidget!),
        ],
      ),
    );

    if (semanticLabel != null) {
      stack = Semantics(label: semanticLabel!, child: stack);
    }

    return stack;
  }
}

/// Опис одного шару багаторазового кільця.
class AppMultiRingLayer {
  const AppMultiRingLayer({
    required this.progress,
    this.thickness = 6.0,
    this.offset = 0.0,
    this.color,
    this.gradientStart,
    this.gradientEnd,
    this.trackColor,
    this.showGlow = false,
    this.label,
  });

  /// Прогрес шару.
  final double progress;

  /// Товщина обідка.
  final double thickness;

  /// Зсув від краю (щоб кільця не накладались).
  final double offset;

  /// Однотонний колір.
  final Color? color;

  /// Початковий колір градієнта.
  final Color? gradientStart;

  /// Кінцевий колір градієнта.
  final Color? gradientEnd;

  /// Колір доріжки.
  final Color? trackColor;

  /// Неонове свічення.
  final bool showGlow;

  /// Назва шару (для відображення в легенді).
  final String? label;
}

// ─── Convenience Helpers ────────────────────────────────────────────────────

/// Фабричні методи для швидкого створення кільць прогресу.
extension AppProgressRingFactory on AppProgressRing {
  /// Кільце для XP прогресу (золотий градієнт).
  static AppProgressRing xp({
    required double progress,
    AppProgressRingSize size = AppProgressRingSize.medium,
    bool isLightTheme = false,
    bool animatedNumber = true,
  }) {
    return AppProgressRing(
      progress: progress,
      ringSize: size,
      isLightTheme: isLightTheme,
      animatedNumber: animatedNumber,
      showNumber: true,
      numberLabel: 'XP',
      gradientStart: const Color(0xFFFFD600),
      gradientEnd: const Color(0xFFFF9100),
      semanticLabel: 'Прогрес досвіду: ${(progress * 100).toInt()}%',
    );
  }

  /// Кільце для прогресу цілі (синій градієнт).
  static AppProgressRing goal({
    required double progress,
    AppProgressRingSize size = AppProgressRingSize.large,
    bool isLightTheme = false,
    bool animatedNumber = true,
  }) {
    return AppProgressRing(
      progress: progress,
      ringSize: size,
      isLightTheme: isLightTheme,
      animatedNumber: animatedNumber,
      showNumber: true,
      numberLabel: 'Прогрес',
      showGlow: progress >= 0.85,
      semanticLabel: 'Прогрес цілі: ${(progress * 100).toInt()}%',
    );
  }

  /// Кільце для серії (вогняний градієнт).
  static AppProgressRing streak({
    required double progress,
    AppProgressRingSize size = AppProgressRingSize.small,
    bool isLightTheme = false,
  }) {
    return AppProgressRing(
      progress: progress,
      ringSize: size,
      isLightTheme: isLightTheme,
      color: const Color(0xFFFF9100),
      showGlow: true,
      badgeIcon: Icons.local_fire_department_rounded,
      semanticLabel: 'Серія: ${(progress * 100).toInt()}%',
    );
  }
}

// ─── Ring Constants ──────────────────────────────────────────────────────────

/// Статичні константи для кільця прогресу.
///
/// Центральне місце для всіх магічних чисел та меж кільця.
class RingConstants {
  RingConstants._();

  /// Мінімально допустимий розмір кільця в пікселях.
  static const double minSize = 20.0;

  /// Максимально допустимий розмір кільця в пікселях.
  static const double maxSize = 200.0;

  /// Мінімально допустима товщина обідка в пікселях.
  static const double minThickness = 1.0;

  /// Максимально допустима товщина обідка в пікселях.
  static const double maxThickness = 20.0;

  /// Мінімально допустимий прогрес.
  static const double minProgress = 0.0;

  /// Максимально допустимий прогрес.
  static const double maxProgress = 1.0;

  /// Мінімально допустимий кут у градусах.
  static const double minAngle = -360.0;

  /// Максимально допустимий кут у градусах.
  static const double maxAngle = 360.0;

  /// Стандартний початковий кут (верх = -90°).
  static const double defaultStartAngle = -90.0;

  /// Поріг свічення (при якому прогресу активується glow).
  static const double glowThreshold = 0.85;

  /// Максимальна кількість міток-поділоків на кільці.
  static const int maxTickMarks = 60;

  /// Мінімальна кількість міток-поділоків на кільці.
  static const int minTickMarks = 2;

  /// Стандартний розмір радіуса свічення (px).
  static const double defaultGlowBlurRadius = 16.0;

  /// Стандартний spread свічення (px).
  static const double defaultGlowSpreadRadius = 4.0;

  /// Максимальна кількість шарів у багаторазовому кільці.
  static const int maxMultiRingLayers = 5;

  /// Стандартна кількість сегментів кільця для сегментованого відображення.
  static const int defaultSegmentCount = 4;

  /// Коефіцієнт розміру шрифту числа відносно кільця.
  static const double numberFontScale = 0.22;

  /// Коефіцієнт розміру шрифту підпису відносно кільця.
  static const double labelFontScale = 0.12;

  /// Стандартний зсув між шарами багаторазового кільця (px).
  static const double multiRingLayerGap = 4.0;

  /// Мінімальний прогрес для відображення числа всередині кільця.
  static const double minProgressForNumberDisplay = 0.01;

  /// Кількість градієнтних зупинок для кільця.
  static const int gradientStopCount = 2;
}

// ─── Ring Progress Formatter ────────────────────────────────────────────────

/// Форматування значень прогресу кільця.
///
/// Надає методи для перетворення double прогресу у зручні текстові
/// представлення: відсотки, дроби, час та інші формати.
class RingProgressFormatter {
  RingProgressFormatter._();

  /// Форматує прогрес як цілий відсоток (наприклад, «75%»).
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  static String asPercent(double progress) {
    return '${(progress.clamp(0.0, 1.0) * 100).round()}%';
  }

  /// Форматує прогрес як відсоток з одним десятковим знаком.
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  static String asPercentDetailed(double progress) {
    return '${(progress.clamp(0.0, 1.0) * 100).toStringAsFixed(1)}%';
  }

  /// Форматує прогрес як дріб (наприклад, «3/4»).
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  /// [totalSteps] — загальна кількість кроків.
  static String asFraction(double progress, int totalSteps) {
    final completed = (progress.clamp(0.0, 1.0) * totalSteps).round();
    return '$completed/$totalSteps';
  }

  /// Форматує прогрес як текстовий опис для прогресу цілі.
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  /// [goalName] — назва цілі.
  static String asGoalText(double progress, String goalName) {
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    return '$goalName: $percent%';
  }

  /// Форматує прогрес як оцінний час залишку.
  ///
  /// [progress] — поточний прогрес (0.0–1.0).
  /// [totalDuration] — загальна тривалість у хвилинах.
  static String asTimeRemaining(double progress, int totalDuration) {
    if (progress >= 1.0) return 'Завершено';
    final remaining = (totalDuration * (1.0 - progress)).round();
    if (remaining < 60) return '$remaining хв';
    final hours = remaining ~/ 60;
    final mins = remaining % 60;
    return '$hours год $mins хв';
  }

  /// Повертає Unicode-символ прогресу для компактного відображення.
  ///
  /// Десятиступенева шкала: от ∅ до ●.
  static String asUnicodeProgress(double progress) {
    final percent = (progress.clamp(0.0, 1.0) * 10).round();
    const symbols = ['∅', '▪', '▫', '◃', '◬', '◴', '◷', '▹', '▶', '◉', '●'];
    return symbols[percent.clamp(0, 10)];
  }

  /// Повертає Emoji-індикатор рівня прогресу.
  ///
  /// Чотири рівня: невиконано, розпочато, наполовину, майже, завершено.
  static String asEmojiLevel(double progress) {
    final percent = (progress * 100).round();
    if (percent == 0) return '⬜';
    if (percent < 25) return '🟥';
    if (percent < 50) return '🟨';
    if (percent < 75) return '🟧';
    if (percent < 100) return '🟩';
    return '✅';
  }

  /// Форматує значення прогресу для відображення в сповіщенні.
  ///
  /// [progress] — поточний прогрес.
  /// [previousProgress] — попередній прогрес.
  /// [context] — контекст (наприклад, «XP»).
  static String asNotificationText(
    double progress,
    double previousProgress,
    String context,
  ) {
    final newPercent = (progress.clamp(0.0, 1.0) * 100).round();
    final oldPercent = (previousProgress.clamp(0.0, 1.0) * 100).round();
    final diff = newPercent - oldPercent;
    final sign = diff >= 0 ? '+' : '';
    return '$context: $sign$diff% → $newPercent%';
  }
}

// ─── Ring Gradient Helper ───────────────────────────────────────────────────

/// Будуєчий градієнтів для кільця прогресу.
///
/// Надає готові градієнтні конфігурації для різних сценаріїв
/// та методи для кастомних градієнтів.
class RingGradientHelper {
  RingGradientHelper._();

  /// Створює SweepGradient для кільця прогресу.
  ///
  /// [startAngle] — початковий кут у радіанах.
  /// [center] — центр кільця.
  /// [radius] — радіус кільця.
  /// [startColor] — початковий колір градієнта.
  /// [endColor] — кінцевий колір градієнта.
  static SweepGradient createSweepGradient({
    required double startAngle,
    required Offset center,
    required double radius,
    required Color startColor,
    required Color endColor,
  }) {
    return SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: [startColor, endColor],
      stops: const [0.0, 1.0],
    );
  }

  /// Створює SweepGradient з трьома кольорами.
  ///
  /// Корисно для багаторівневого кольорового індикатора.
  static SweepGradient createTriSweepGradient({
    required double startAngle,
    required Color startColor,
    required Color midColor,
    required Color endColor,
  }) {
    return SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: [startColor, midColor, endColor],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Створює SweepGradient для кільця з неоновим ефектом.
  ///
  /// Використовує основний колір з прозорим кінцем.
  static SweepGradient createNeonGradient({
    required double startAngle,
    required Color neonColor,
  }) {
    return SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: [neonColor, neonColor.withOpacity(0.7)],
      stops: const [0.0, 1.0],
    );
  }

  /// Повертає кольори для XP-градієнта (золотий → помаранчевий).
  static ({Color start, Color end}) get xpGradient => (
        start: const Color(0xFFFFD600),
        end: const Color(0xFFFF9100),
      );

  /// Повертає кольори для прогресу цілі (синій → бірюзовий).
  static ({Color start, Color end}) get goalGradient => (
        start: const Color(0xFF00E5FF),
        end: const Color(0xFF2979FF),
      );

  /// Повертає кольори для серії (помаранчевий → червоний).
  static ({Color start, Color end}) get streakGradient => (
        start: const Color(0xFFFF9100),
        end: const Color(0xFFFF1744),
      );

  /// Повертає кольори для успіху (зелений → смарагдовий).
  static ({Color start, Color end}) get successGradient => (
        start: const Color(0xFF00E676),
        end: const Color(0xFF00C853),
      );

  /// Повертає кольори для попередження (жовтий → оранжевий).
  static ({Color start, Color end}) get warningGradient => (
        start: const Color(0xFFFFEA00),
        end: const Color(0xFFFF9100),
      );

  /// Повертає кольори для небезпеки (червоний → темний червоний).
  static ({Color start, Color end}) get dangerGradient => (
        start: const Color(0xFFFF5252),
        end: const Color(0xFFD50000),
      );

  /// Обчислює колір між двома кольорами залежно від прогресу.
  ///
  /// [progress] — значення 0.0–1.0.
  static Color lerp(Color start, Color end, double progress) {
    return Color.lerp(start, end, progress.clamp(0.0, 1.0))!;
  }

  /// Обчислює колір для прогресу з трьома точками переходу.
  ///
  /// Червоний (0%) → Жовтий (50%) → Зелений (100%).
  static Color progressColor(double progress) {
    final p = progress.clamp(0.0, 1.0);
    if (p < 0.5) {
      return Color.lerp(const Color(0xFFFF5252), const Color(0xFFFFEA00), p * 2)!;
    }
    return Color.lerp(const Color(0xFFFFEA00), const Color(0xFF00E676), (p - 0.5) * 2)!;
  }
}

// ─── Ring Dashed Track Painter ──────────────────────────────────────────────

/// CustomPainter для малювання пунктирної фонової доріжки кільця.
///
/// Використовується замість суцільного фону для створення більш
/// стильного вигляду кільця прогресу.
class RingDashedTrackPainter extends CustomPainter {
  RingDashedTrackPainter({
    required this.strokeWidth,
    this.dashCount = 36,
    this.dashGapRatio = 0.4,
    this.color,
    this.startAngle = -90.0,
  });

  /// Товщина обідка.
  final double strokeWidth;

  /// Кількість штрихів.
  final int dashCount;

  /// Співвідношення проміжку до штриха (0.0–0.9).
  final double dashGapRatio;

  /// Колір штрихів.
  final Color? color;

  /// Початковий кут у градусах.
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final dashColor = color ?? Colors.white.withOpacity(0.1);
    final startRad = (startAngle * math.pi) / 180;

    final paint = Paint()
      ..color = dashColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fullAngle = 2 * math.pi;
    final dashAngle = fullAngle / dashCount;
    final gapAngle = dashAngle * dashGapRatio;
    final drawAngle = dashAngle - gapAngle;

    for (var i = 0; i < dashCount; i++) {
      final angleStart = startRad + dashAngle * i + gapAngle / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angleStart,
        drawAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RingDashedTrackPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount ||
        oldDelegate.dashGapRatio != dashGapRatio ||
        oldDelegate.color != color ||
        oldDelegate.startAngle != startAngle;
  }
}

// ─── Ring Segment Painter ───────────────────────────────────────────────────

/// CustomPainter для малювання сегментованого кільця прогресу.
///
/// Розбиває кільце на окремі сегменти, кожен з яких може бути
/// заповнений або порожній, створюючи ефект «п'єци».
class RingSegmentPainter extends CustomPainter {
  RingSegmentPainter({
    required this.progress,
    required this.strokeWidth,
    required this.segmentCount,
    this.segmentGap = 2.0,
    this.filledColor,
    this.emptyColor,
    this.startAngle = -90.0,
    this.roundedCaps = true,
  });

  /// Поточний прогрес (0.0–1.0).
  final double progress;

  /// Товщина обідка.
  final double strokeWidth;

  /// Кількість сегментів.
  final int segmentCount;

  /// Відстань між сегментами в пікселях.
  final double segmentGap;

  /// Колір заповненого сегмента.
  final Color? filledColor;

  /// Колір порожнього сегмента.
  final Color? emptyColor;

  /// Початковий кут у градусах.
  final double startAngle;

  /// Заокруглені кінці сегментів.
  final bool roundedCaps;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final startRad = (startAngle * math.pi) / 180;
    final activeSegments = (progress.clamp(0.0, 1.0) * segmentCount).round();
    final fullAngle = 2 * math.pi;
    final gapRad = (segmentGap / radius).clamp(0.0, 0.1);
    final segmentAngle = (fullAngle - gapRad * segmentCount) / segmentCount;
    final activeColor = filledColor ?? Colors.white;
    final inactiveColor = emptyColor ?? Colors.white.withOpacity(0.15);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt;

    for (var i = 0; i < segmentCount; i++) {
      paint.color = i < activeSegments ? activeColor : inactiveColor;
      final angleStart = startRad + (segmentAngle + gapRad) * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angleStart,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RingSegmentPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.segmentCount != segmentCount ||
        oldDelegate.segmentGap != segmentGap ||
        oldDelegate.filledColor != filledColor ||
        oldDelegate.emptyColor != emptyColor;
  }
}

// ─── Ring Glow Effect Painter ───────────────────────────────────────────────

/// CustomPainter для малювання зовнішнього свічення кільця.
///
/// Малює м'яке неонове свічення навколо кільця, інтенсивність
/// якого залежить від прогресу.
class RingGlowEffectPainter extends CustomPainter {
  RingGlowEffectPainter({
    required this.progress,
    required this.glowColor,
    required this.strokeWidth,
    this.maxBlur = 20.0,
    this.maxSpread = 6.0,
    this.threshold = 0.85,
    this.startAngle = -90.0,
  });

  /// Прогрес кільця (визначає інтенсивність свічення).
  final double progress;

  /// Колір свічення.
  final Color glowColor;

  /// Товщина обідка кільця.
  final double strokeWidth;

  /// Максимальний радіус розмиття.
  final double maxBlur;

  /// Максимальний spread.
  final double maxSpread;

  /// Поріг активації свічення.
  final double threshold;

  /// Початковий кут кільця.
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < threshold) return;

    final intensity = ((progress - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final startRad = (startAngle * math.pi) / 180;
    final sweepAngle = 2 * math.pi * progress;

    // Малюємо свічення як розмиту дугу
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.4 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + maxSpread * intensity * 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxBlur * intensity);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startRad,
      sweepAngle,
      false,
      glowPaint,
    );

    // Додатковий м'який шар для більшого об'єму
    if (intensity > 0.5) {
      final outerGlow = Paint()
        ..color = glowColor.withOpacity(0.15 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + maxSpread * intensity * 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, maxBlur * 1.5 * intensity);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRad,
        sweepAngle,
        false,
        outerGlow,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RingGlowEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.maxBlur != maxBlur ||
        oldDelegate.maxSpread != maxSpread ||
        oldDelegate.threshold != threshold;
  }
}

// ─── Ring Animation Config ──────────────────────────────────────────────────

/// Конфігурація анімації для кільця прогресу.
///
/// Надає попередньо налаштовані параметри для різних типів анімації
/// та дозволяє створювати кастомні конфігурації.
class RingAnimationConfig {
  const RingAnimationConfig({
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOutCubic,
    this.delay = Duration.zero,
    this.repeat = false,
    this.reverseAnimation = false,
  });

  /// Стандартна конфігурація для плавного заповнення.
  factory RingAnimationConfig.smoothFill() {
    return const RingAnimationConfig(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Конфігурація для швидкого оновлення (малі зміни).
  factory RingAnimationConfig.quickUpdate() {
    return const RingAnimationConfig(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Конфігурація для святкування (bounce при 100%).
  factory RingAnimationConfig.celebration() {
    return const RingAnimationConfig(
      duration: Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      reverseAnimation: true,
    );
  }

  /// Конфігурація для початкового завантаження.
  factory RingAnimationConfig.initialLoad() {
    return const RingAnimationConfig(
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      delay: Duration(milliseconds: 200),
    );
  }

  /// Конфігурація для count-up числа.
  factory RingAnimationConfig.countUp() {
    return const RingAnimationConfig(
      duration: Duration(milliseconds: 1000),
      curve: Curves.linear,
    );
  }

  /// Конфігурація для повторюваної пульс-анімації.
  factory RingAnimationConfig.pulse() {
    return const RingAnimationConfig(
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      repeat: true,
      reverseAnimation: true,
    );
  }

  /// Тривалість анімації.
  final Duration duration;

  /// Крива анімації.
  final Curve curve;

  /// Затримка перед початком.
  final Duration delay;

  /// Чи повторювати анімацію.
  final bool repeat;

  /// Чи відтворювати анімацію у зворотному напрямку.
  final bool reverseAnimation;
}

// ─── Ring Computed Props Extension ──────────────────────────────────────────

/// Додаткові обчислювані властивості для AppProgressRing.
///
/// Розширює можливості кільця прогресу зручними гетерами.
extension RingComputedProps on AppProgressRing {
  /// Чи прогрес завершено (100%).
  bool get isComplete => progress >= 1.0;

  /// Чи прогрес порожній (0%).
  bool get isEmpty => progress <= 0.0;

  /// Чи прогрес близький до завершення (≥85%).
  bool get isNearComplete => progress >= 0.85 && progress < 1.0;

  /// Чи прогрес в останній чверті (75–99%).
  bool get isInLastQuarter => progress >= 0.75 && progress < 1.0;

  /// Чи прогрес в першій половині (0–49%).
  bool get isInFirstHalf => progress >= 0.0 && progress < 0.5;

  /// Чи кільце має валідні параметри.
  bool get isValid {
    if (progress.isNaN || progress < 0.0 || progress > 1.0) return false;
    final size = this.size ?? ringSize.value;
    if (size < RingConstants.minSize || size > RingConstants.maxSize) return false;
    return true;
  }

  /// Прогрес у відсотках (ціле число).
  int get percentValue => (progress.clamp(0.0, 1.0) * 100).round();

  /// Прогрес у відсотках (дробове число).
  double get percentDetailed => progress.clamp(0.0, 1.0) * 100.0;

  /// Ефективний розмір кільця в пікселях.
  double get effectiveSize => size ?? ringSize.value;

  /// Ефективна товщина обідка в пікселях.
  double get effectiveThickness => strokeWidth ?? thickness.value;

  /// Залишок до 100% (у одиницях прогресу).
  double get remaining => (1.0 - progress.clamp(0.0, 1.0));

  /// Кут дуги прогресу в радіанах.
  double get sweepAngleRadians => 2 * math.pi * progress.clamp(0.0, 1.0);
}
