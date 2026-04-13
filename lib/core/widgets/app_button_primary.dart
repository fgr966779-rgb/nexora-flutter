import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_shadows.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [AppButtonPrimary].
class ButtonPrimaryDebugConfig {
  ButtonPrimaryDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати межі навколо кнопки.
  static bool showBounds = false;

  /// Показувати інформацію про стан кнопки.
  static bool showStateInfo = false;

  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[ButtonPrimary:$tag] ' : '[ButtonPrimary] ';
    debugPrint('$prefix$message');
  }
}

// ─── Button Size Enum ──────────────────────────────────────────────────────

/// Розмір кнопки.
///
/// Визначає типографіку, розмір іконки,spinner-розміри.
enum AppButtonSize {
  /// Дуже компактна кнопка (висота 28, шрифт 10).
  xs,

  /// Компактна кнопка (висота 36, шрифт 12).
  small,

  /// Стандартна кнопка (висота 48, шрифт 14).
  medium,

  /// Велика кнопка (висота 56, шрифт 16).
  large,

  /// Дуже велика кнопка (висота 64, шрифт 18).
  xl;

  /// Висота кнопки у пікселях.
  double get height {
    switch (this) {
      case AppButtonSize.xs:
        return 28.0;
      case AppButtonSize.small:
        return 36.0;
      case AppButtonSize.medium:
        return 48.0;
      case AppButtonSize.large:
        return 56.0;
      case AppButtonSize.xl:
        return 64.0;
    }
  }

  /// Розмір іконки.
  double get iconSize {
    switch (this) {
      case AppButtonSize.xs:
        return 12.0;
      case AppButtonSize.small:
        return 14.0;
      case AppButtonSize.medium:
        return 18.0;
      case AppButtonSize.large:
        return 22.0;
      case AppButtonSize.xl:
        return 26.0;
    }
  }

  /// Стиль тексту для кнопки.
  TextStyle get textStyle {
    switch (this) {
      case AppButtonSize.xs:
        return AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.small:
        return AppTypography.buttonSmall;
      case AppButtonSize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSize.large:
        return AppTypography.buttonLarge;
      case AppButtonSize.xl:
        return AppTypography.buttonLarge.copyWith(fontSize: 18);
    }
  }

  /// Горизонтальний відступ.
  double get horizontalPadding {
    switch (this) {
      case AppButtonSize.xs:
        return Spacing.sm;
      case AppButtonSize.small:
        return Spacing.md;
      case AppButtonSize.medium:
        return Spacing.lg;
      case AppButtonSize.large:
        return Spacing.xl;
      case AppButtonSize.xl:
        return Spacing.xxl;
    }
  }

  /// Розмір індикатора завантаження.
  double get spinnerSize {
    switch (this) {
      case AppButtonSize.xs:
        return 12.0;
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
      case AppButtonSize.xl:
        return 28.0;
    }
  }

  /// Товщина індикатора завантаження.
  double get spinnerStroke {
    switch (this) {
      case AppButtonSize.xs:
        return 1.5;
      case AppButtonSize.small:
        return 2.0;
      case AppButtonSize.medium:
        return 2.5;
      case AppButtonSize.large:
        return 3.0;
      case AppButtonSize.xl:
        return 3.5;
    }
  }

  /// Українська назва розміру.
  String get label {
    switch (this) {
      case AppButtonSize.xs:
        return 'Дуже мала';
      case AppButtonSize.small:
        return 'Мала';
      case AppButtonSize.medium:
        return 'Середня';
      case AppButtonSize.large:
        return 'Велика';
      case AppButtonSize.xl:
        return 'Дуже велика';
    }
  }

  /// Опис розміру для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case AppButtonSize.xs:
        return 'Дуже компактна кнопка';
      case AppButtonSize.small:
        return 'Компактна кнопка';
      case AppButtonSize.medium:
        return 'Стандартна кнопка';
      case AppButtonSize.large:
        return 'Велика кнопка';
      case AppButtonSize.xl:
        return 'Дуже велика кнопка';
    }
  }

  /// Обчислює розмір на основі піксельного значення.
  static AppButtonSize fromPixels(double pixels) {
    if (pixels <= 28) return AppButtonSize.xs;
    if (pixels <= 36) return AppButtonSize.small;
    if (pixels <= 48) return AppButtonSize.medium;
    if (pixels <= 56) return AppButtonSize.large;
    return AppButtonSize.xl;
  }
}

// ─── Gradient Presets ──────────────────────────────────────────────────────

/// Передвизначені градієнтні пресети для кнопок.
class AppButtonGradients {
  AppButtonGradients._();

  /// Стандартний градієнт PS5 (синій → блакитний).
  static const LinearGradient ps5Default = LinearGradient(
    colors: [AppColorsPS5.gradientStart, AppColorsPS5.gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт успіху (зелений).
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт попередження (оранжевий).
  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFFF9100), Color(0xFFFFB300)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт помилки (червоний).
  static const LinearGradient error = LinearGradient(
    colors: [Color(0xFFFF1744), Color(0xFFFF4B6E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт XP (золотий → помаранжевий).
  static const LinearGradient xp = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFFFF9100)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт Monitor (синій → світло-синій).
  static const LinearGradient monitorDefault = LinearGradient(
    colors: [AppColorsMonitor.gradientStart, AppColorsMonitor.gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Фіолетовий градієнт для преміум-дій.
  static const LinearGradient premium = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Темний градієнт для видалення.
  static const LinearGradient destructive = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Блакитний градієнт для інформаційних кнопок.
  static const LinearGradient info = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Створює кастомний градієнт з двома кольорами.
  static LinearGradient custom(Color start, Color end) {
    return LinearGradient(
      colors: [start, end],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// Створює градієнт з вертикальною орієнтацією.
  static LinearGradient vertical(Color top, Color bottom) {
    return LinearGradient(
      colors: [top, bottom],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

// ─── Button Animation Config ────────────────────────────────────────────────────

/// Конфігурація анімацій для [AppButtonPrimary].
class ButtonAnimationConfig {
  const ButtonAnimationConfig({
    this.pressScale = 0.97,
    this.pressDuration = AppDurations.fast,
    this.pressCurve = AppEasings.standard,
    this.successDuration = const Duration(milliseconds: 1500),
    this.pulseBegin = const Offset(1.0, 1.0),
    this.pulseEnd = const Offset(1.02, 1.02),
    this.pulseDuration = AppDurations.pulse,
    this.progressSize = 32.0,
    this.progressStrokeWidth = 2.5,
  });

  /// Масштаб при натисканні.
  final double pressScale;

  /// Тривалість натискання.
  final Duration pressDuration;

  /// Крива натискання.
  final Curve pressCurve;

  /// Тривалість відображення стану успіху.
  final Duration successDuration;

  /// Початковий масштаб пульсації.
  final Offset pulseBegin;

  /// Кінцевий масштаб пульсації.
  final Offset pulseEnd;

  /// Тривалість пульсації.
  final Duration pulseDuration;

  /// Розмір індикатора прогресу.
  final double progressSize;

  /// Товщина ліній прогресу.
  final double progressStrokeWidth;

  /// Стандартна конфігурація.
  static const ButtonAnimationConfig standard = ButtonAnimationConfig();

  /// Швидка конфігурація.
  static const ButtonAnimationConfig fast = ButtonAnimationConfig(
    pressDuration: Duration(milliseconds: 80),
    successDuration: Duration(milliseconds: 800),
  );

  /// Без пульсації.
  static const ButtonAnimationConfig noPulse = ButtonAnimationConfig(
    pulseBegin: const Offset(1.0, 1.0),
    pulseEnd: const Offset(1.0, 1.0),
  );
}

/// Градієнтна основна кнопка з багатьма станами та ефектами.
///
/// Підтримує розміри, завантаження, прогрес, іконки, градієнти, неонове
/// свічення, пульс-анімацію, тактильний відгук та кастомізацію кольорів.
class AppButtonPrimary extends StatefulWidget {
  const AppButtonPrimary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.progress,
    this.isDisabled = false,
    this.isSuccess = false,
    this.showGlow = false,
    this.showPulse = false,
    this.showRipple = true,
    this.enableHaptic = true,
    this.isLightTheme = false,
    this.icon,
    this.iconRight,
    this.isFullWidth = false,
    this.gradientStart,
    this.gradientEnd,
    this.customColor,
    this.borderRadius,
    this.gradientPreset,
    this.loadingLabel,
    this.semanticLabel,
    this.tooltip,
    this.onLongPress,
    this.enableFocusOutline = true,
    this.animationConfig = const ButtonAnimationConfig.standard,
  });

  /// Створює кнопку «Зберегти».
  static AppButtonPrimary save({
    required String? label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
    IconData? icon,
  }) =>
      AppButtonPrimary(
        label: label ?? 'Зберегти',
        onPressed: onPressed,
        isLoading: isLoading,
        isLightTheme: isLightTheme,
        isFullWidth: isFullWidth,
        icon: icon ?? Icons.check_rounded,
      );

  /// Створює кнопку «Продовжити».
  static AppButtonPrimary continueAction({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = true,
  }) =>
      AppButtonPrimary(
        label: 'Продовжити',
        onPressed: onPressed,
        isLoading: isLoading,
        isLightTheme: isLightTheme,
        isFullWidth: isFullWidth,
        iconRight: Icons.arrow_forward_rounded,
      );

  /// Створює кнопку «Додати внесок».
  static AppButtonPrimary addDeposit({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
  }) =>
      AppButtonPrimary(
        label: 'Додати внесок',
        onPressed: onPressed,
        isLoading: isLoading,
        isLightTheme: isLightTheme,
        icon: Icons.add_circle_outline_rounded,
        gradientPreset: AppButtonGradients.xp,
      );

  /// Створює іконкову кнопку (без тексту).
  static AppButtonPrimary iconOnly({
    required IconData icon,
    VoidCallback? onPressed,
    Color? customColor,
    bool isLightTheme = false,
    double? size,
    String? tooltip,
  }) =>
      AppButtonPrimary(
        label: '',
        onPressed: onPressed,
        icon: icon,
        customColor: customColor,
        isLightTheme: isLightTheme,
        size: size != null
            ? (size <= 32
                ? AppButtonSize.xs
                : size <= 40
                    ? AppButtonSize.small
                    : AppButtonSize.medium)
            : AppButtonSize.medium,
        tooltip: tooltip,
        enableFocusOutline: false,
      );

  /// Створює кнопку «Прийняти виклик».
  static AppButtonPrimary acceptChallenge({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
  }) =>
      AppButtonPrimary(
        label: 'Прийняти виклик',
        onPressed: onPressed,
        isLoading: isLoading,
        isLightTheme: isLightTheme,
        icon: Icons.emoji_events_rounded,
        gradientPreset: AppButtonGradients.premium,
      );

  /// Створює кнопку «Видалити».
  static AppButtonPrimary delete({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
  }) =>
      AppButtonPrimary(
        label: 'Видалити',
        onPressed: onPressed,
        isLoading: isLoading,
        isLightTheme: isLightTheme,
        icon: Icons.delete_outline_rounded,
        gradientPreset: AppButtonGradients.destructive,
      );

  /// Створює кнопку з кастомним текстом.
  static AppButtonPrimary custom({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? iconRight,
    LinearGradient? gradient,
    Color? color,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
    double? borderRadius,
    bool showGlow = false,
    bool showPulse = false,
  }) =>
      AppButtonPrimary(
        label: label,
        onPressed: onPressed,
        icon: icon,
        iconRight: iconRight,
        gradientPreset: gradient,
        customColor: color,
        isLoading: isLoading,
        isLightTheme: isLightTheme,
        isFullWidth: isFullWidth,
        borderRadius: borderRadius,
        showGlow: showGlow,
        showPulse: showPulse,
      );

  /// Створює кнопку з прогресом.
  static AppButtonPrimary withProgress({
    required String label,
    VoidCallback? onPressed,
    required double progress,
    VoidCallback? onTapProgress,
    IconData? icon,
    double? progressSize,
    double? progressStrokeWidth,
  }) =>
      AppButtonPrimary(
        label: label,
        onPressed: onPressed,
        progress: progress,
        icon: icon,
        progressSize: progressSize,
        progressStrokeWidth: progressStrokeWidth,
      );

  /// Текст кнопки.
  final String label;

  /// Зворотний виклик при натисканні.
  final VoidCallback? onPressed;

  /// Зворотний виклик при довгому натисканні.
  final VoidCallback? onLongPress;

  /// Розмір кнопки.
  final AppButtonSize size;

  /// Показувати індикатор завантаження.
  final bool isLoading;

  /// Текст під час завантаження (замінює [label]).
  final String? loadingLabel;

  /// Прогрес від 0.0 до 1.0.
  final double? progress;

  /// Вимкнена кнопка (напівпрозора, без натискання).
  final bool isDisabled;

  /// Стан успіху.
  final bool isSuccess;

  /// Неонове свічення.
  final bool showGlow;

  /// Пульс-анімація.
  final bool showPulse;

  /// Ripple ефект.
  final bool showRipple;

  /// Тактильний відгук.
  final bool enableHaptic;

  /// Світла тема.
  final bool isLightTheme;

  /// Іконка зліва.
  final IconData? icon;

  /// Іконка справа.
  final IconData? iconRight;

  /// На всю ширину.
  final bool isFullWidth;

  /// Початковий колір градієнта.
  final Color? gradientStart;

  /// Кінцевий колір градієнта.
  final Color? gradientEnd;

  /// Однотонний колір (замість градієнта).
  final Color? customColor;

  /// Кастомний радіус.
  final double? borderRadius;

  /// Передвизначений градієнт.
  final LinearGradient? gradientPreset;

  /// Семантична мітка.
  final String? semanticLabel;

  /// Підказка.
  final String? tooltip;

  /// Обведення при фокусі.
  final bool enableFocusOutline;

  /// Конфігурація анімацій.
  final ButtonAnimationConfig animationConfig;

  @override
  State<AppButtonPrimary> createState() => _AppButtonPrimaryState();
}

class _AppButtonPrimaryState extends State<AppButtonPrimary> {
  bool _isPressed = false;
  bool _isFocused = false;
  bool _showSuccess = false;

  bool get _isEffectivelyDisabled =>
      widget.isDisabled || widget.isLoading || _showSuccess;

  // ─── Color Getters ───────────────────────────────────────────────────

  Color get _gradientStart =>
      widget.gradientStart ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientStart
          : AppColorsPS5.gradientStart);

  Color get _gradientEnd =>
      widget.gradientEnd ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientEnd
          : AppColorsPS5.gradientEnd);

  Color get _textColor => Colors.white;

  Color get _successColor =>
      widget.isLightTheme ? AppColorsMonitor.success : AppColorsPS5.success;

  Color get _disabledTextColor =>
      widget.isLightTheme ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;

  // ─── Lifecycle ───────────────────────────────────────────────────────

  @override
  void didUpdateWidget(covariant AppButtonPrimary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _triggerSuccessState();
    }
  }

  /// Запускає стан успіху з автоматичним скиданням.
  void _triggerSuccessState() {
    setState(() => _showSuccess = true);
    ButtonPrimaryDebugConfig.log('Success state triggered', tag: 'state');
    Future.delayed(widget.animationConfig.successDuration, () {
      if (mounted) {
        setState(() => _showSuccess = false);
      }
    });
  }

  /// Обробляє натискання з тактильним відгуком.
  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
    ButtonPrimaryDebugConfig.log('Tap', tag: 'gesture');
  }

  /// Обробляє початок довгого натискання.
  void _handleLongPressStart(LongPressStartDetails details) {
    setState(() => _isPressed = true);
  }

  /// Обробляє кінець довгого натискання.
  void _handleLongPressEnd(LongPressEndDetails details) {
    setState(() => _isPressed = false);
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  // ─── Validation ───────────────────────────────────────────────────────

  /// Перевіряє коректність параметрів кнопки.
  void _validateParams() {
    assert(
      widget.progress == null ||
          (widget.progress! >= 0.0 && widget.progress! <= 1.0),
      'progress must be between 0.0 and 1.0',
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _validateParams();

    Widget button = GestureDetector(
      onTapDown: _isEffectivelyDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: _isEffectivelyDisabled
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: _isEffectivelyDisabled
          ? null
          : () => setState(() => _isPressed = false),
      onTap: _isEffectivelyDisabled ? null : _handleTap,
      onLongPressStart: widget.onLongPress != null && !_isEffectivelyDisabled
          ? _handleLongPressStart
          : null,
      onLongPressEnd: widget.onLongPress != null && !_isEffectivelyDisabled
          ? _handleLongPressEnd
          : null,
      child: AnimatedOpacity(
        duration: AppDurations.fast,
        opacity: _isEffectivelyDisabled ? 0.5 : 1.0,
        child: AnimatedScale(
          scale: _isPressed ? widget.animationConfig.pressScale : 1.0,
          duration: widget.animationConfig.pressDuration,
          curve: widget.animationConfig.pressCurve,
          child: _buildButton(),
        ),
      ),
    );

    // Пульсація
    if (widget.showPulse) {
      button = button
          .animate(target: widget.showPulse ? 1 : 0)
          .scale(
            begin: widget.animationConfig.pulseBegin,
            end: widget.animationConfig.pulseEnd,
            duration: widget.animationConfig.pulseDuration,
            curve: Curves.easeInOut,
          );
    }

    // Focus обведення
    if (widget.enableFocusOutline && _isFocused) {
      button = Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(widget.borderRadius ?? Radii.button),
            border: Border.all(
              color: _gradientStart,
              width: 2,
            ),
          ),
          child: button,
        ),
      );
    }

    // Tooltip
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    // Semantics
    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: !_isEffectivelyDisabled,
      child: button,
    );
  }

  /// Будує основну кнопку.
  Widget _buildButton() {
    final effectiveRadius = widget.borderRadius ?? Radii.button;

    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppEasings.standard,
      height: widget.size.height,
      width: widget.isFullWidth ? double.infinity : null,
      decoration: _buildDecoration(effectiveRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: _buildContent(),
      ),
    );
  }

  /// Будує декорацію кнопки.
  BoxDecoration _buildDecoration(double radius) {
    // Стан успіху — зелений градієнт
    if (_showSuccess) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [_successColor, _successColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.successGlow(),
      );
    }

    // Передвизначений пресет градієнта
    if (widget.gradientPreset != null) {
      return BoxDecoration(
        gradient: widget.gradientPreset,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: widget.showGlow
            ? AppShadows.glow(widget.gradientPreset!.colors.first)
            : null,
      );
    }

    // Кастомний однотонний колір
    if (widget.customColor != null) {
      return BoxDecoration(
        color: widget.customColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: widget.showGlow
            ? AppShadows.glow(widget.customColor!)
            : null,
      );
    }

    // Стандартний градієнт
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [_gradientStart, _gradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: widget.showGlow ? AppShadows.glow(_gradientStart) : null,
    );
  }

  /// Будує вміст кнопки.
  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildLoadingContent();
    }

    if (_showSuccess) {
      return _buildSuccessContent();
    }

    // Іконкова кнопка без тексту
    if (widget.icon != null && widget.iconRight == null && widget.label.isEmpty) {
      return Center(
        child: Icon(
          widget.icon,
          color: _textColor,
          size: widget.size.iconSize,
        ),
      );
    }

    return _buildStandardContent();
  }

  /// Будує контент стану завантаження.
  Widget _buildLoadingContent() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.size.spinnerSize,
            height: widget.size.spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: widget.size.spinnerStroke,
              valueColor: AlwaysStoppedAnimation<Color>(_textColor),
            ),
          ),
          if (widget.loadingLabel != null) ...[
            SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                widget.loadingLabel!,
                style: widget.size.textStyle.copyWith(color: _textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Будує контент стану успіху (галочка).
  Widget _buildSuccessContent() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_rounded,
            color: _textColor,
            size: widget.size.iconSize + 4,
          ),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              'Збережено!',
              style: widget.size.textStyle.copyWith(color: _textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує стандартний контент (текст + іконки).
  Widget _buildStandardContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.size.horizontalPadding,
        ),
        child: Row(
          mainAxisSize: widget.isFullWidth
              ? MainAxisSize.max
              : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: _textColor,
                size: widget.size.iconSize,
              ),
              SizedBox(width: Spacing.sm),
            ],
            Flexible(
              child: Text(
                widget.label,
                style: widget.size.textStyle.copyWith(color: _textColor),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.iconRight != null) ...[
              SizedBox(width: Spacing.sm),
              Icon(
                widget.iconRight,
                color: _textColor,
                size: widget.size.iconSize,
              ),
            ],
            // Індикатор прогресу
            if (widget.progress != null && !widget.isLoading) ...[
              SizedBox(width: Spacing.sm),
              _buildProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  /// Будує індикатор прогресу.
  Widget _buildProgressIndicator() {
    final effectiveProgressSize = widget.progressSize ?? ButtonAnimationConfig.standard.progressSize;
    final effectiveStrokeWidth = widget.progressStrokeWidth ?? ButtonAnimationConfig.standard.progressStrokeWidth;
    final clampedProgress = widget.progress!.clamp(0.0, 1.0);

    return SizedBox(
      width: effectiveProgressSize,
      height: effectiveProgressSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: effectiveStrokeWidth,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_textColor),
            ),
          ),
          Center(
            child: Text(
              '${(clampedProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Utility Extensions ─────────────────────────────────────────────────────

/// Розширення для [AppButtonSize] з додатковими методами.
extension AppButtonSizeExtension on AppButtonSize {
  /// Обчислює відступ залежно від розміру.
  double get effectiveHorizontalPadding {
    switch (this) {
      case AppButtonSize.xs:
        return Spacing.sm;
      case AppButtonSize.small:
        return Spacing.md;
      case AppButtonSize.medium:
        return Spacing.lg;
      case AppButtonSize.large:
        return Spacing.xl;
      case AppButtonSize.xl:
        return Spacing.xxl;
    }
  }

  /// Чи розмір підходить для маленьких екранів.
  bool get isCompact => index <= AppButtonSize.small.index;
}

/// Розширення для [AppButtonGradients] з додатковими пресетами.
extension AppButtonGradientsExtension on AppButtonGradients {
  /// Пресет для кнопок копіювання/поділитися.
  static LinearGradient get share =>
      const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF78C8FF)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// Пресет для кнопок повідомлень.
  static LinearGradient get notification =>
      const LinearGradient(
        colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
}

// ─── Button Primary Constants ──────────────────────────────────────────────

/// Сталі значення для [AppButtonPrimary].
///
/// Забезпечує єдине джерело істини для магічних чисел,
/// що використовуються у компоненті кнопки.
class ButtonPrimaryConstants {
  ButtonPrimaryConstants._();

  /// Мінімальна довжина тексту кнопки (0 символів для iconOnly).
  static const int minLabelLength = 0;

  /// Максимальна рекомендована довжина тексту.
  static const int maxLabelLength = 40;

  /// Мінімальний коефіцієнт масштабу при натисканні.
  static const double minPressScale = 0.85;

  /// Максимальний коефіцієнт масштабу при натисканні.
  static const double maxPressScale = 1.0;

  /// Мінімальна тривалість анімації натискання.
  static const Duration minPressDuration = Duration(milliseconds: 50);

  /// Максимальна тривалість анімації натискання.
  static const Duration maxPressDuration = Duration(milliseconds: 300);

  /// Мінімальна тривалість стану успіху.
  static const Duration minSuccessDuration = Duration(milliseconds: 500);

  /// Максимальна тривалість стану успіху.
  static const Duration maxSuccessDuration = Duration(milliseconds: 3000);

  /// Стандартна тривалість стану успіху.
  static const Duration defaultSuccessDuration = Duration(milliseconds: 1500);

  /// Мінімальний розмір прогрес-індикатора.
  static const double minProgressSize = 20.0;

  /// Максимальний розмір прогрес-індикатора.
  static const double maxProgressSize = 48.0;

  /// Мінімальна товщина ліній прогресу.
  static const double minProgressStroke = 1.5;

  /// Максимальна товщина ліній прогресу.
  static const double maxProgressStroke = 4.0;

  /// Максимальне значення прогресу.
  static const double maxProgressValue = 1.0;

  /// Мінімальне значення прогресу.
  static const double minProgressValue = 0.0;

  /// Допустима кількість символів для compact-відображення.
  static const int compactLabelThreshold = 12;

  /// Розмір іконки трохсекундного таймера успіху.
  static const double successIconSizeBonus = 4.0;
}

/// Допоміжні методи для кнопок.
class AppButtonPrimaryHelpers {
  AppButtonPrimaryHelpers._();

  /// Створює FocusNode для кнопки з обробкою клавіатури.
  static FocusNode createFocusNode() => FocusNode();

  /// Обчислює оптимальний розмір для контексту.
  static AppButtonSize recommendSize(BuildContext context, {bool isFullWidth = false}) {
    if (isFullWidth) return AppButtonSize.large;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return AppButtonSize.small;
    if (screenWidth < 600) return AppButtonSize.medium;
    return AppButtonSize.large;
  }

  /// Обчислює ширину кнопки залежно від розміру.
  static double buttonWidth(AppButtonSize size, {int textLength = 0}) {
    final baseWidth = size.horizontalPadding * 2;
    final charWidth = 8.0;
    final textWidth = textLength * charWidth;
    return baseWidth + textWidth + (size.iconSize > 0 ? size.iconSize + Spacing.sm : 0);
  }

  /// Обчислює мінімальну ширину кнопки.
  static double minButtonWidth(AppButtonSize size) => size.horizontalPadding * 2 + size.iconSize;

  /// Перевіряє, чи кнопка змінюється після білду (для оптимізації).
  static bool shouldRebuild({
    required String oldLabel,
    required String newLabel,
    required bool oldLoading,
    required bool newLoading,
    required bool oldDisabled,
    required bool newDisabled,
  }) {
    return oldLabel != newLabel ||
        oldLoading != newLoading ||
        oldDisabled != newDisabled;
  }

  /// Обчислює оптимальний borderRadius залежно від розміру.
  static double recommendRadius(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.xs:
        return 14.0;
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return Radii.button;
      case AppButtonSize.large:
        return Radii.button + 2;
      case AppButtonSize.xl:
        return Radii.button + 4;
    }
  }

  /// Валідує параметри кнопки перед білдом.
  ///
  /// Повертає список помилок. Порожній список — кнопка валідна.
  static List<String> validate({
    required String label,
    double? progress,
    double? borderRadius,
  }) {
    final errors = <String>[];
    if (label.length > ButtonPrimaryConstants.maxLabelLength) {
      errors.add(
        'Label exceeds ${ButtonPrimaryConstants.maxLabelLength} chars '
        '(${label.length})',
      );
    }
    if (progress != null) {
      if (progress < ButtonPrimaryConstants.minProgressValue ||
          progress > ButtonPrimaryConstants.maxProgressValue) {
        errors.add('Progress must be between 0.0 and 1.0');
      }
    }
    if (borderRadius != null && borderRadius < 0) {
      errors.add('Border radius cannot be negative');
    }
    return errors;
  }

  /// Форматує відсоток прогресу для відображення.
  static String formatProgress(double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    return '${(clamped * 100).toInt()}%';
  }

  /// Обчислює ширину кнопки на основі тексту та розміру.
  static double estimateWidth(AppButtonSize size, String label, {bool hasIcon = false}) {
    final baseWidth = size.horizontalPadding * 2;
    final charWidth = 8.0;
    final textWidth = label.length * charWidth;
    final iconWidth = hasIcon ? size.iconSize + Spacing.sm : 0;
    return baseWidth + textWidth + iconWidth;
  }
}

// ─── Additional Factory Constructors ─────────────────────────────────────

/// Додаткові фабричні конструктори для [AppButtonPrimary].
///
/// Забезпечують зручні скорочення для поширених сценаріїв використання.
extension AppButtonPrimaryFactories on AppButtonPrimary {
  /// Створює кнопку «Відправити» з іконкою відправки.
  static AppButtonPrimary submit({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = true,
  }) {
    return AppButtonPrimary(
      label: 'Відправити',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.send_rounded,
      enableHaptic: true,
    );
  }

  /// Створює кнопку «Підтвердити» з іконкою перевірки.
  static AppButtonPrimary confirm({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
    String? label,
  }) {
    return AppButtonPrimary(
      label: label ?? 'Підтвердити',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.check_circle_outline_rounded,
      gradientPreset: AppButtonGradients.success,
    );
  }

  /// Створює кнопку «Повторити» з іконкою оновлення.
  static AppButtonPrimary retry({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
  }) {
    return AppButtonPrimary(
      label: 'Повторити',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      icon: Icons.refresh_rounded,
      enableHaptic: true,
    );
  }

  /// Створює кнопку «Пропустити» з м'яким стилем.
  static AppButtonPrimary skip({
    VoidCallback? onPressed,
    bool isLightTheme = false,
    bool isFullWidth = true,
  }) {
    return AppButtonPrimary(
      label: 'Пропустити',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      customColor: isLightTheme
          ? AppColorsMonitor.textSecondary.withOpacity(0.1)
          : AppColorsPS5.textSecondary.withOpacity(0.1),
    );
  }

  /// Створює кнопку «Оплатити» з градієнтом XP.
  static AppButtonPrimary pay({
    required String amount,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = true,
  }) {
    return AppButtonPrimary(
      label: 'Оплатити $amount грн',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.payment_rounded,
      gradientPreset: AppButtonGradients.xp,
      showGlow: true,
    );
  }

  /// Створює кнопку «Отримати винагороду» з преміум-градієнтом.
  static AppButtonPrimary claimReward({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    String? label,
  }) {
    return AppButtonPrimary(
      label: label ?? 'Отримати винагороду',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      icon: Icons.card_giftcard_rounded,
      gradientPreset: AppButtonGradients.premium,
      showGlow: true,
      showPulse: true,
    );
  }

  /// Створює кнопку «Далі» зі стрілкою.
  static AppButtonPrimary next({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = true,
  }) {
    return AppButtonPrimary(
      label: 'Далі',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      iconRight: Icons.arrow_forward_rounded,
      enableHaptic: true,
    );
  }

  /// Створює кнопку «Назад» зі стрілкою ліворуч.
  static AppButtonPrimary back({
    VoidCallback? onPressed,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonPrimary(
      label: 'Назад',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.arrow_back_rounded,
    );
  }
}

// ─── Theme-Aware Gradient Resolver ────────────────────────────────────────

/// Утиліта для вибору градієнта залежно від теми.
///
/// Автоматично підбирає градієнт на основі стану кнопки та теми.
class ButtonGradientResolver {
  ButtonGradientResolver._();

  /// Визначає ефективний градієнт для кнопки.
  ///
  /// Пріоритет: preset > customColor > theme default.
  static LinearGradient resolve({
    LinearGradient? preset,
    Color? customColor,
    Color? gradientStart,
    Color? gradientEnd,
    bool isLightTheme = false,
  }) {
    if (preset != null) return preset;
    if (customColor != null) {
      return LinearGradient(
        colors: [customColor, customColor.withOpacity(0.85)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    if (gradientStart != null && gradientEnd != null) {
      return LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return isLightTheme ? AppButtonGradients.monitorDefault : AppButtonGradients.ps5Default;
  }

  /// Визначає градієнт для стану успіху.
  static LinearGradient successGradient(bool isLightTheme) {
    return isLightTheme
        ? const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : AppButtonGradients.success;
  }

  /// Визначає градієнт для вимкненого стану.
  static LinearGradient disabledGradient(bool isLightTheme) {
    final baseColor = isLightTheme
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;
    return LinearGradient(
      colors: [baseColor.withOpacity(0.3), baseColor.withOpacity(0.2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}

// ─── Accessibility Helpers ────────────────────────────────────────────────

/// Допоміжні методи для доступності (accessibility) [AppButtonPrimary].
///
/// Надає семантичні мітки, описи станів та підказки для скрінрідерів.
class ButtonPrimaryAccessibility {
  ButtonPrimaryAccessibility._();

  /// Генерує семантичну мітку для кнопки залежно від стану.
  ///
  /// Включає інформацію про завантаження, успіх, вимкнений стан.
  static String buildSemanticsLabel({
    required String label,
    bool isLoading = false,
    bool isDisabled = false,
    bool isSuccess = false,
    String? customSemanticLabel,
  }) {
    if (customSemanticLabel != null) return customSemanticLabel;
    if (isLoading) return '$label. Завантаження…';
    if (isSuccess) return '$label. Виконано.';
    if (isDisabled) return '$label. Недоступно.';
    return label;
  }

  /// Генерує підказку (hint) для кнопки.
  ///
  /// Включає інформацію про довге натискання, якщо воно доступне.
  static String buildHint({
    bool hasLongPress = false,
    bool isFullWidth = false,
  }) {
    final parts = <String>['Натисніть для дії'];
    if (hasLongPress) {
      parts.add('довге натискання для додаткових опцій');
    }
    return parts.join(', ');
  }

  /// Повертає опис розміру для скрінрідера.
  static String sizeDescription(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.xs:
        return 'Дуже мала кнопка';
      case AppButtonSize.small:
        return 'Мала кнопка';
      case AppButtonSize.medium:
        return 'Стандартна кнопка';
      case AppButtonSize.large:
        return 'Велика кнопка';
      case AppButtonSize.xl:
        return 'Дуже велика кнопка';
    }
  }

  /// Повертає категорію кнопки для semantics.
  static String semanticCategory({
    bool isDestructive = false,
    bool isPrimary = true,
    bool isSuccess = false,
  }) {
    if (isDestructive) return 'Деструктивна дія';
    if (isSuccess) return 'Підтвердження';
    if (isPrimary) return 'Основна дія';
    return 'Кнопка';
  }

  /// Створює Map з semantics-атрибутами.
  static Map<String, String> semanticsAttributes({
    required String label,
    bool isEnabled = true,
    bool isLoading = false,
  }) {
    return {
      'role': 'button',
      'label': label,
      'state': isLoading ? 'busy' : (isEnabled ? 'enabled' : 'disabled'),
      'component': 'AppButtonPrimary',
    };
  }
}

// ─── Button State Machine ─────────────────────────────────────────────────

/// Стан кнопки для керування переходами.
///
/// Забезпечує контрольовані переходи між станами
/// (idle → loading → success → idle) з перевірками.
enum ButtonPrimaryState {
  /// Базовий стан — кнопка готова до натискання.
  idle,

  /// Кнопка у процесі завантаження.
  loading,

  /// Кнопка успішно виконала дію.
  success,

  /// Кнопка вимкнена.
  disabled;

  /// Чи кнопка готова до натискання.
  bool get isInteractive => this == ButtonPrimaryState.idle;

  /// Чи можна розпочати завантаження.
  bool get canStartLoading => this == ButtonPrimaryState.idle;

  /// Чи можна показати успіх.
  bool get canShowSuccess => this == ButtonPrimaryState.loading;

  /// Опис стану для дебагу.
  String get debugLabel {
    switch (this) {
      case ButtonPrimaryState.idle:
        return 'Idle — готова до натискання';
      case ButtonPrimaryState.loading:
        return 'Loading — завантаження';
      case ButtonPrimaryState.success:
        return 'Success — успіх';
      case ButtonPrimaryState.disabled:
        return 'Disabled — вимкнена';
    }
  }

  /// Чи цей стан блокує натискання.
  bool get blocksInteraction =>
      this == ButtonPrimaryState.loading ||
      this == ButtonPrimaryState.success ||
      this == ButtonPrimaryState.disabled;

  /// Перевіряє, чи можна перейти з поточного стану до цільового.
  bool canTransitionTo(ButtonPrimaryState target) {
    switch (this) {
      case ButtonPrimaryState.idle:
        return target != ButtonPrimaryState.success;
      case ButtonPrimaryState.loading:
        return target == ButtonPrimaryState.success ||
            target == ButtonPrimaryState.idle ||
            target == ButtonPrimaryState.disabled;
      case ButtonPrimaryState.success:
        return target == ButtonPrimaryState.idle ||
            target == ButtonPrimaryState.disabled;
      case ButtonPrimaryState.disabled:
        return target == ButtonPrimaryState.idle;
    }
  }
}

// ─── Press Scale Presets ───────────────────────────────────────────────────

/// Передвизначені конфігурації масштабу натискання для різних контекстів.
///
/// Використовується для швидкого налаштування поведінки натискання
/// без створення повного [ButtonAnimationConfig].
class ButtonPressPresets {
  ButtonPressPresets._();

  /// Легке натискання — мінімальний масштаб, для делікатних кнопок.
  static const double subtle = 0.99;

  /// Стандартне натискання — баланс між відчуттям та візуалом.
  static const double standard = 0.97;

  /// Помітне натискання — для акцентних кнопок (CTA).
  static const double pronounced = 0.94;

  /// Сильне натискання — для ігрових кнопок.
  static const double heavy = 0.90;

  /// Обчислює оптимальний pressScale залежно від розміру кнопки.
  ///
  /// Більші кнопки використовують помітніший ефект.
  static double forSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.xs:
        return subtle;
      case AppButtonSize.small:
        return 0.98;
      case AppButtonSize.medium:
        return standard;
      case AppButtonSize.large:
        return pronounced;
      case AppButtonSize.xl:
        return heavy;
    }
  }

  /// Обчислює pressScale на основі категорії кнопки.
  static double forCategory(ButtonCategory category) {
    switch (category) {
      case ButtonCategory.primary:
        return standard;
      case ButtonCategory.cta:
        return pronounced;
      case ButtonCategory.utility:
        return subtle;
      case ButtonCategory.destructive:
        return standard;
      case ButtonCategory.game:
        return heavy;
    }
  }
}

// ─── Button Category Enum ─────────────────────────────────────────────────

/// Категорія кнопки для семантичної класифікації.
///
/// Визначає візуальну вагу та поведінку кнопки.
enum ButtonCategory {
  /// Основна кнопка для стандартних дій.
  primary,

  /// Кнопка заклику до дії (Call to Action).
  cta,

  /// Утилітарна кнопка для другорядних дій.
  utility,

  /// Деструктивна кнопка (видалення тощо).
  destructive,

  /// Ігрова кнопка з вираженим натисканням.
  game;

  /// Опис категорії для дебагу.
  String get description {
    switch (this) {
      case ButtonCategory.primary:
        return 'Основна кнопка для стандартних дій';
      case ButtonCategory.cta:
        return 'Кнопка заклику до дії (CTA)';
      case ButtonCategory.utility:
        return 'Утилітарна кнопка';
      case ButtonCategory.destructive:
        return 'Деструктивна кнопка';
      case ButtonCategory.game:
        return 'Ігрова кнопка';
    }
  }

  /// Чи ця категорія потребує підвищеної уваги.
  bool get requiresAttention =>
      this == ButtonCategory.cta || this == ButtonCategory.destructive;

  /// Рекомендований gradient для категорії.
  LinearGradient? get recommendedGradient {
    switch (this) {
      case ButtonCategory.primary:
        return null;
      case ButtonCategory.cta:
        return AppButtonGradients.premium;
      case ButtonCategory.utility:
        return null;
      case ButtonCategory.destructive:
        return AppButtonGradients.destructive;
      case ButtonCategory.game:
        return AppButtonGradients.xp;
    }
  }

  /// Рекомендований showGlow для категорії.
  bool get recommendedGlow {
    switch (this) {
      case ButtonCategory.primary:
        return false;
      case ButtonCategory.cta:
        return true;
      case ButtonCategory.utility:
        return false;
      case ButtonCategory.destructive:
        return false;
      case ButtonCategory.game:
        return true;
    }
  }
}

// ─── Haptic Strategy ──────────────────────────────────────────────────────

/// Стратегія тактильного відгуку для кнопок.
///
/// Надає різні інтенсивності та типи вібрації
/// залежно від контексту використання кнопки.
class ButtonHapticStrategy {
  ButtonHapticStrategy._();

  /// Легкий відгук для звичайних кнопок.
  static void light() => HapticFeedback.lightImpact();

  /// Середній відгук для кнопок підтвердження.
  static void medium() => HapticFeedback.mediumImpact();

  /// Сильний відгук для деструктивних дій.
  static void heavy() => HapticFeedback.heavyImpact();

  /// Вібрація-вибір для довгого натискання.
  static void selection() => HapticFeedback.selectionClick();

  /// Вібрація успіху.
  static void success() => HapticFeedback.lightImpact();

  /// Помилкова вібрація.
  static void error() => HapticFeedback.heavyImpact();

  /// Обирає стратегію на основі категорії кнопки.
  static void forCategory(ButtonCategory category) {
    switch (category) {
      case ButtonCategory.primary:
        light();
        break;
      case ButtonCategory.cta:
        medium();
        break;
      case ButtonCategory.utility:
        selection();
        break;
      case ButtonCategory.destructive:
        heavy();
        break;
      case ButtonCategory.game:
        medium();
        break;
    }
  }

  /// Обирає стратегію на основі стану кнопки.
  static void forState(ButtonPrimaryState state) {
    switch (state) {
      case ButtonPrimaryState.idle:
        light();
        break;
      case ButtonPrimaryState.loading:
        selection();
        break;
      case ButtonPrimaryState.success:
        success();
        break;
      case ButtonPrimaryState.disabled:
        break;
    }
  }
}

// ─── Computed Properties Extension ─────────────────────────────────────────

/// Розширення для [AppButtonSize] з обчислюваними властивостями.
extension AppButtonSizeComputedExtension on AppButtonSize {
  /// Чи розмір підходить для виділеної секції.
  bool get isProminent => index >= AppButtonSize.large.index;

  /// Чи розмір підходить для tight-компонування.
  bool get isTight => index <= AppButtonSize.small.index;

  /// Повертає мінімальну ширину контейнера для цього розміру.
  double get minContainerWidth {
    switch (this) {
      case AppButtonSize.xs:
        return 48.0;
      case AppButtonSize.small:
        return 64.0;
      case AppButtonSize.medium:
        return 80.0;
      case AppButtonSize.large:
        return 100.0;
      case AppButtonSize.xl:
        return 120.0;
    }
  }

  /// Повертає максимальну кількість символів для label.
  int get maxLabelChars {
    switch (this) {
      case AppButtonSize.xs:
        return 4;
      case AppButtonSize.small:
        return 8;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 30;
      case AppButtonSize.xl:
        return 40;
    }
  }

  /// Коефіцієнт opacity для вимкненого стану.
  double get disabledOpacity {
    switch (this) {
      case AppButtonSize.xs:
        return 0.6;
      case AppButtonSize.small:
        return 0.5;
      case AppButtonSize.medium:
        return 0.5;
      case AppButtonSize.large:
        return 0.45;
      case AppButtonSize.xl:
        return 0.4;
    }
  }

  /// Опис для дебагу.
  String get debugDescription =>
      'AppButtonSize.$name (height: $height, iconSize: $iconSize, '
      'hPadding: $horizontalPadding)';
}

/// Розширення для [ButtonAnimationConfig] з додатковими обчисленнями.
extension ButtonAnimationConfigExtension on ButtonAnimationConfig {
  /// Чи конфігурація включає пульсацію.
  bool get hasPulse =>
      pulseBegin != pulseEnd &&
      (pulseEnd.dx - pulseBegin.dx).abs() > 0.001;

  /// Чи конфігурація швидка.
  bool get isFast =>
      pressDuration.inMilliseconds < 100;

  /// Чи pressScale в межах безпеки.
  bool get isPressScaleSafe =>
      pressScale >= ButtonPrimaryConstants.minPressScale &&
      pressScale <= ButtonPrimaryConstants.maxPressScale;

  /// Копіює конфігурацію з новим pressScale.
  ButtonAnimationConfig withPressScale(double scale) {
    return ButtonAnimationConfig(
      pressScale: scale,
      pressDuration: pressDuration,
      pressCurve: pressCurve,
      successDuration: successDuration,
      pulseBegin: pulseBegin,
      pulseEnd: pulseEnd,
      pulseDuration: pulseDuration,
      progressSize: progressSize,
      progressStrokeWidth: progressStrokeWidth,
    );
  }
}
