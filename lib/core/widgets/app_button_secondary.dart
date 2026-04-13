import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [AppButtonSecondary].
class ButtonSecondaryDebugConfig {
  ButtonSecondaryDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати межі навколо кнопки.
  static bool showBounds = false;

  /// Показувати інформацію про варіант кнопки.
  static bool showVariantInfo = false;

  /// Логувати зміни стану.
  static bool logStateChanges = false;

  /// Виводити debug-повідомлення.
  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[ButtonSecondary:$tag] ' : '[ButtonSecondary] ';
    debugPrint('$prefix$message');
  }

  /// Логувати зміну стану.
  static void logStateChange(String propertyName, dynamic oldValue, dynamic newValue) {
    if (!logStateChanges) return;
    debugPrint('[ButtonSecondary:state] $propertyName: $oldValue → $newValue');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Button Secondary Constants (Сталі значення)
// ═══════════════════════════════════════════════════════════════════════════

/// Сталі значення для [AppButtonSecondary].
///
/// Забезпечує єдине джерело істини для всіх магічних чисел
/// та порогових значень, що використовуються у компоненті.
class ButtonSecondaryConstants {
  ButtonSecondaryConstants._();

  /// Мінімальна висота кнопки (xs).
  static const double minHeight = 26.0;

  /// Максимальна висота кнопки (large).
  static const double maxHeight = 52.0;

  /// Мінімальна товщина рамки.
  static const double minBorderWidth = 0.5;

  /// Максимальна товщина рамки.
  static const double maxBorderWidth = 3.0;

  /// Стандартний коефіцієнт масштабу при натисканні.
  static const double pressScaleFactor = 0.97;

  /// Тривалість анімації стану успіху.
  static const Duration successStateDuration = Duration(milliseconds: 1500);

  /// Тривалість анімації стану попередження.
  static const Duration warningStateDuration = Duration(milliseconds: 1500);

  /// Максимальна довжина тексту для мітки кнопки.
  static const int maxLabelLength = 50;

  /// Мінімальна тривалість анімації появи focus.
  static const Duration focusAnimationDuration = Duration(milliseconds: 150);

  /// Коефіцієнт прозорості для hover-ефекту (soft variant).
  static const double hoverOpacitySoft = 0.12;

  /// Коефіцієнт прозорості для press-ефекту (soft variant).
  static const double pressOpacitySoft = 0.20;

  /// Коефіцієнт прозорості для hover-ефекту (pill variant).
  static const double hoverOpacityPill = 0.10;

  /// Коефіцієнт прозорості для press-ефекту (pill variant).
  static const double pressOpacityPill = 0.15;

  /// Коефіцієнт прозорості для ghost-variant при натисканні.
  static const double pressOpacityGhost = 0.08;

  /// Коефіцієнт прозорості для outlined-variant при hover.
  static const double hoverOpacityOutlined = 0.06;

  /// Коефіцієнт прозорості для outlined-variant при натисканні.
  static const double pressOpacityOutlined = 0.12;

  /// Відступ focus-обведення від кнопки.
  static const double focusOutlinePadding = 3.0;

  /// Товщина focus-обведення.
  static const double focusOutlineWidth = 2.0;

  /// Коефіцієнт прозорості focus-обведення.
  static const double focusOutlineOpacity = 0.5;

  /// Мінімальна тривалість спіндера завантаження.
  static const double minSpinnerStroke = 1.5;

  /// Максимальна тривалість спіндера завантаження.
  static const double maxSpinnerStroke = 3.0;
}

import '../constants/app_shadows.dart';

// ─── Secondary Button Size Enum ─────────────────────────────────────────────

/// Розмір вторинної кнопки.
enum AppButtonSecondarySize {
  /// Надкомпактний розмір (висота 26, шрифт 10).
  xs,

  /// Компактна (висота 34, шрифт 12).
  small,

  /// Стандартна (висота 44, шрифт 14).
  medium,

  /// Велика (висота 52, шрифт 16).
  large;

  /// Висота кнопки.
  double get height {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 26.0;
      case AppButtonSecondarySize.small:
        return 34.0;
      case AppButtonSecondarySize.medium:
        return 44.0;
      case AppButtonSecondarySize.large:
        return 52.0;
    }
  }

  /// Розмір іконки.
  double get iconSize {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 12.0;
      case AppButtonSecondarySize.small:
        return 14.0;
      case AppButtonSecondarySize.medium:
        return 18.0;
      case AppButtonSecondarySize.large:
        return 22.0;
    }
  }

  /// Стиль тексту.
  TextStyle get textStyle {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return AppTypography.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w500);
      case AppButtonSecondarySize.small:
        return AppTypography.buttonSmall;
      case AppButtonSecondarySize.medium:
        return AppTypography.buttonMedium;
      case AppButtonSecondarySize.large:
        return AppTypography.buttonLarge;
    }
  }

  /// Горизонтальний відступ.
  double get horizontalPadding {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return Spacing.sm;
      case AppButtonSecondarySize.small:
        return Spacing.md;
      case AppButtonSecondarySize.medium:
        return Spacing.lg;
      case AppButtonSecondarySize.large:
        return Spacing.xl;
    }
  }

  /// Товщина рамки.
  double get borderWidth {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 0.8;
      case AppButtonSecondarySize.small:
        return 1.0;
      case AppButtonSecondarySize.medium:
        return 1.5;
      case AppButtonSecondarySize.large:
        return 2.0;
    }
  }

  /// Українська назва розміру.
  String get label {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 'Дуже мала';
      case AppButtonSecondarySize.small:
        return 'Мала';
      case AppButtonSecondarySize.medium:
        return 'Середня';
      case AppButtonSecondarySize.large:
        return 'Велика';
    }
  }
}

// ─── Secondary Button Variant ───────────────────────────────────────────────

/// Варіант відображення вторинної кнопки.
enum AppButtonSecondaryVariant {
  /// Контурна кнопка з рамкою.
  outlined,

  /// Прозора кнопка-привид (тільки текст).
  ghost,

  /// Кнопка з м'якою заливкою.
  soft,

  /// Кнопка-пігул (невелика з закругленими кутами).
  pill,
}

/// Контурна вторинна кнопка з різними станами та варіантами.
///
/// Підтримує розміри, завантаження, іконки, кастомні кольори, деструктивний
/// варіант (червоний), налаштування рамки, hover-стан та анімацію натискання.
/// Додатково: варіанти pill, xs розмір, анімована рамка, фокус-стан,
/// стан натискання, анімація вимкненого стану.
class AppButtonSecondary extends StatefulWidget {
  const AppButtonSecondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSecondarySize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isDestructive = false,
    this.isLightTheme = false,
    this.icon,
    this.iconRight,
    this.isFullWidth = false,
    this.borderColor,
    this.textColor,
    this.hoverColor,
    this.enableHaptic = true,
    this.borderRadius,
    this.variant = AppButtonSecondaryVariant.outlined,
    this.semanticLabel,
    this.tooltip,
    this.onLongPress,
    this.showFocusOutline = true,
    this.animatedBorder = false,
    this.successState = false,
    this.warningState = false,
    this.focusNode,
  });

  /// Текст кнопки.
  final String label;

  /// Зворотний виклик при натисканні.
  final VoidCallback? onPressed;

  /// Зворотний виклик при довгому натисканні.
  final VoidCallback? onLongPress;

  /// Розмір кнопки.
  final AppButtonSecondarySize size;

  /// Показувати індикатор завантаження.
  final bool isLoading;

  /// Вимкнена кнопка.
  final bool isDisabled;

  /// Деструктивний варіант (червоний — для видалення тощо).
  final bool isDestructive;

  /// Світла тема.
  final bool isLightTheme;

  /// Іконка зліва.
  final IconData? icon;

  /// Іконка справа.
  final IconData? iconRight;

  /// Кнопка на всю ширину.
  final bool isFullWidth;

  /// Кастомний колір рамки.
  final Color? borderColor;

  /// Кастомний колір тексту.
  final Color? textColor;

  /// Кастомний колір при наведенні (hover-ефект натискання).
  final Color? hoverColor;

  /// Тактильний відгук при натисканні.
  final bool enableHaptic;

  /// Кастомний радіус закруглення.
  final double? borderRadius;

  /// Варіант відображення кнопки.
  final AppButtonSecondaryVariant variant;

  /// Семантична мітка для екранних читачів.
  final String? semanticLabel;

  /// Підказка при наведенні/довгому натисканні.
  final String? tooltip;

  /// Увімкнути обведення при фокусі клавіатурою.
  final bool showFocusOutline;

  /// Анімована рамка при наведенні.
  final bool animatedBorder;

  /// Стан успіху — тимчасово зелений колір.
  final bool successState;

  /// Стан попередження — тимчасово жовтий колір.
  final bool warningState;

  /// Вузол фокусу для керування з клавіатури.
  final FocusNode? focusNode;

  @override
  State<AppButtonSecondary> createState() => _AppButtonSecondaryState();
}

class _AppButtonSecondaryState extends State<AppButtonSecondary> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;
  bool _showSuccess = false;
  bool _showWarning = false;
  late FocusNode _internalFocusNode;

  // ─── Lifecycle ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _internalFocusNode.hasFocus);
  }

  @override
  void didUpdateWidget(covariant AppButtonSecondary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _internalFocusNode.removeListener(_onFocusChange);
      _internalFocusNode = widget.focusNode ?? FocusNode();
      _internalFocusNode.addListener(_onFocusChange);
    }
    if (widget.successState && !oldWidget.successState) {
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    }
    if (widget.warningState && !oldWidget.warningState) {
      setState(() => _showWarning = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showWarning = false);
      });
    }
  }

  // ─── Color Getters ───────────────────────────────────────────────────

  Color get _borderColor {
    if (widget.borderColor != null) return widget.borderColor!;
    if (widget.isDestructive) return AppColorsPS5.error;
    if (_showSuccess) return AppColorsPS5.success;
    if (_showWarning) return AppColorsPS5.warning;
    return widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  Color get _textColor {
    if (widget.textColor != null) return widget.textColor!;
    if (widget.isDestructive) return AppColorsPS5.error;
    if (_showSuccess) return AppColorsPS5.success;
    if (_showWarning) return AppColorsPS5.warning;
    return widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  Color get _fillColor {
    if (widget.hoverColor != null) return widget.hoverColor!;
    if (widget.isDestructive) return AppColorsPS5.error;
    if (_showSuccess) return AppColorsPS5.success;
    if (_showWarning) return AppColorsPS5.warning;
    return widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  Color get _textSecondary =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  Color get _focusOutlineColor {
    if (widget.isDestructive) return AppColorsPS5.error;
    if (_showSuccess) return AppColorsPS5.success;
    return widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  // ─── Handlers ────────────────────────────────────────────────────────

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  void _handleLongPressStart() {
    setState(() => _isPressed = true);
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleLongPressEnd() {
    setState(() => _isPressed = false);
    widget.onLongPress?.call();
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectivelyDisabled = widget.isDisabled || widget.isLoading;
    final effectiveRadius = widget.variant == AppButtonSecondaryVariant.pill
        ? widget.size.height / 2
        : widget.borderRadius ?? Radii.md;

    Widget button = GestureDetector(
      onTapDown: effectivelyDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: effectivelyDisabled
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: effectivelyDisabled
          ? null
          : () => setState(() => _isPressed = false),
      onTap: effectivelyDisabled ? null : _handleTap,
      onLongPressStart: effectivelyDisabled || widget.onLongPress == null
          ? null
          : (_) => _handleLongPressStart(),
      onLongPressEnd: effectivelyDisabled || widget.onLongPress == null
          ? null
          : () => _handleLongPressEnd(),
      child: AnimatedOpacity(
        duration: AppDurations.fast,
        opacity: effectivelyDisabled ? 0.5 : 1.0,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: AppDurations.fast,
          curve: AppEasings.standard,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: AppEasings.standard,
            height: widget.size.height,
            width: widget.isFullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.size.horizontalPadding,
            ),
            decoration: _buildDecoration(effectiveRadius),
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );

    // Tooltip
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    // Focus outline
    if (widget.showFocusOutline && _isFocused) {
      button = AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveRadius + 3),
          border: Border.all(
            color: _focusOutlineColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: button,
      );
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: !effectivelyDisabled,
      child: Focus(
        focusNode: _internalFocusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            if (!effectivelyDisabled) {
              _handleTap();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: button,
      ),
    );
  }

  BoxDecoration _buildDecoration(double radius) {
    final isOutlined = widget.variant == AppButtonSecondaryVariant.outlined;
    final isGhost = widget.variant == AppButtonSecondaryVariant.ghost;
    final isSoft = widget.variant == AppButtonSecondaryVariant.soft;
    final isPill = widget.variant == AppButtonSecondaryVariant.pill;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: isGhost || isPill
          ? isPill
              ? Border.all(
                  color: _borderColor.withOpacity(_isHovered ? 0.6 : 0.3),
                  width: widget.animatedBorder && _isHovered
                      ? widget.size.borderWidth + 0.5
                      : widget.size.borderWidth,
                )
              : null
          : Border.all(
              color: _borderColor,
              width: widget.animatedBorder && _isHovered
                  ? widget.size.borderWidth + 0.5
                  : widget.size.borderWidth,
            ),
      color: isSoft
          ? _fillColor.withOpacity(
              _isPressed ? 0.2 : _isHovered ? 0.12 : 0.08,
            )
          : isGhost
              ? _isPressed
                  ? _fillColor.withOpacity(0.08)
                  : Colors.transparent
              : isPill
                  ? _fillColor.withOpacity(
                      _isPressed ? 0.15 : _isHovered ? 0.1 : 0.05,
                    )
                  : _isPressed
                      ? _fillColor.withOpacity(0.12)
                      : _isHovered
                          ? _fillColor.withOpacity(0.06)
                          : Colors.transparent,
      boxShadow: isOutlined && _isHovered
          ? [
              BoxShadow(
                color: _borderColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: widget.size.iconSize + 4,
        height: widget.size.iconSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(_textColor),
        ),
      );
    }

    if (widget.icon != null && widget.label.isEmpty) {
      // Іконкова кнопка без тексту
      return Icon(widget.icon, color: _textColor, size: widget.size.iconSize);
    }

    return Row(
      mainAxisSize: widget.isFullWidth
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: _textColor, size: widget.size.iconSize),
          SizedBox(width: Spacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: widget.size.textStyle.copyWith(color: _textColor),
            overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  // ─── Destructive Variant Info ────────────────────────────────────────

  /// Опис деструктивної кнопки (для екранних читачів).
  static String get destructiveSemanticsLabel => 'Деструктивна дія';

  /// Підказка для кнопки підтвердження видалення.
  static String get deleteConfirmLabel => 'Підтвердити видалення';

  /// Опис кнопки «Скасувати».
  static String get cancelSemanticsLabel => 'Скасувати дію';

  /// Опис кнопки «Детальніше».
  static String get detailsSemanticsLabel => 'Показати деталі';

  /// Опис кнопки «Зберегти».
  static String get saveSemanticsLabel => 'Зберегти зміни';
}

// ─── Convenience Constructors ──────────────────────────────────────────────

/// Розширення для зручного створення конкретних варіантів кнопок.
extension AppButtonSecondaryExtensions on AppButtonSecondary {
  /// Створює деструктивну кнопку «Видалити».
  static AppButtonSecondary delete({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Видалити',
      onPressed: onPressed,
      isDestructive: true,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.delete_outline_rounded,
      semanticLabel: 'Видалити елемент',
    );
  }

  /// Створює кнопку «Скасувати».
  static AppButtonSecondary cancel({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Скасувати',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      semanticLabel: 'Скасувати дію',
    );
  }

  /// Створює кнопку «Детальніше».
  static AppButtonSecondary details({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Детальніше',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      iconRight: Icons.chevron_right_rounded,
      semanticLabel: 'Показати деталі',
    );
  }

  /// Створює кнопку-привид «Налаштувати».
  static AppButtonSecondary settings({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Налаштувати',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      icon: Icons.settings_outlined,
      variant: AppButtonSecondaryVariant.ghost,
    );
  }

  /// Створює кнопку-привид «Редагувати».
  static AppButtonSecondary edit({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Редагувати',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      icon: Icons.edit_outlined,
      variant: AppButtonSecondaryVariant.ghost,
    );
  }

  /// Створює кнопку з м'якою заливкою «Спробувати».
  static AppButtonSecondary tryAction({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Спробувати',
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      icon: Icons.play_arrow_rounded,
      variant: AppButtonSecondaryVariant.soft,
    );
  }

  /// Створює іконкову кнопку з привид-варіантом.
  static AppButtonSecondary iconOnly({
    required IconData icon,
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
    String? tooltip,
  }) {
    return AppButtonSecondary(
      label: '',
      onPressed: onPressed,
      icon: icon,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      variant: AppButtonSecondaryVariant.ghost,
      tooltip: tooltip,
      showFocusOutline: false,
    );
  }

  /// Створює кнопку-пігул з тегом.
  static AppButtonSecondary tag({
    required String label,
    VoidCallback? onPressed,
    bool isSelected = false,
    bool isLightTheme = false,
    IconData? icon,
  }) {
    return AppButtonSecondary(
      label: label,
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: icon,
      size: AppButtonSecondarySize.small,
      variant: AppButtonSecondaryVariant.pill,
      borderColor: isSelected ? null : null,
      textColor: isSelected ? null : null,
    );
  }

  /// Створює кнопку «Зберегти» з м'якою заливкою.
  static AppButtonSecondary save({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Зберегти',
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.save_outlined,
      variant: AppButtonSecondaryVariant.soft,
      semanticLabel: 'Зберегти зміни',
    );
  }

  /// Створює кнопку «Копіювати» з іконкою.
  static AppButtonSecondary copy({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Копіювати',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      icon: Icons.copy_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
    );
  }

  /// Створює кнопку «Поділитися» з іконкою.
  static AppButtonSecondary share({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Поділитися',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      icon: Icons.share_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
    );
  }

  /// Створює кнопку «Увійти» з іконкою.
  static AppButtonSecondary login({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Увійти',
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.login_rounded,
      semanticLabel: 'Увійти в обліковий запис',
    );
  }

  /// Створює кнопку «Зареєструватися».
  static AppButtonSecondary register({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Зареєструватися',
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      variant: AppButtonSecondaryVariant.soft,
      icon: Icons.person_add_rounded,
      semanticLabel: 'Створити новий обліковий запис',
    );
  }

  /// Створює кнопку «Більше» (три крапки) — іконкова.
  static AppButtonSecondary more({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isLightTheme = false,
    String? tooltip,
  }) {
    return AppButtonSecondary(
      label: '',
      onPressed: onPressed,
      isDisabled: isDisabled,
      isLightTheme: isLightTheme,
      icon: Icons.more_horiz_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      tooltip: tooltip ?? 'Більше опцій',
      showFocusOutline: false,
    );
  }

  /// Створює кнопку «Закрити» — іконкова хрестик.
  static AppButtonSecondary close({
    VoidCallback? onPressed,
    bool isLightTheme = false,
    String? tooltip,
  }) {
    return AppButtonSecondary(
      label: '',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: Icons.close_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      tooltip: tooltip ?? 'Закрити',
      showFocusOutline: false,
    );
  }
}

// ─── Validation Helpers ────────────────────────────────────────────────────

/// Допоміжні методи для валідації [AppButtonSecondary].
class ButtonSecondaryValidators {
  ButtonSecondaryValidators._();

  /// Валідує параметри кнопки.
  ///
  /// Повертає список помилок. Порожній список означає валідність.
  static List<String> validate({
    required String label,
    required AppButtonSecondarySize size,
    required AppButtonSecondaryVariant variant,
    double? borderRadius,
  }) {
    final errors = <String>[];
    if (label.length > ButtonSecondaryConstants.maxLabelLength) {
      errors.add(
        'Label exceeds ${ButtonSecondaryConstants.maxLabelLength} chars '
        '(${label.length})',
      );
    }
    if (borderRadius != null && borderRadius < 0) {
      errors.add('Border radius cannot be negative');
    }
    return errors;
  }

  /// Перевіряє, чи варіант підтримує рамку.
  static bool variantSupportsBorder(AppButtonSecondaryVariant variant) {
    return variant != AppButtonSecondaryVariant.ghost;
  }

  /// Перевіряє, чи варіант підтримує заливку.
  static bool variantSupportsFill(AppButtonSecondaryVariant variant) {
    return variant == AppButtonSecondaryVariant.soft ||
        variant == AppButtonSecondaryVariant.pill;
  }

  /// Перевіряє, чи варіант підтримує бейдж.
  static bool variantSupportsBadge(AppButtonSecondaryVariant variant) {
    return variant != AppButtonSecondaryVariant.ghost;
  }

  /// Обчислює ефективний borderRadius для варіанту pill.
  static double effectiveRadius({
    required AppButtonSecondaryVariant variant,
    required double height,
    double? customRadius,
  }) {
    if (customRadius != null) return customRadius;
    if (variant == AppButtonSecondaryVariant.pill) return height / 2;
    return Radii.md;
  }
}

// ─── Computed Properties Extension ─────────────────────────────────────────

/// Розширення для [AppButtonSecondaryVariant] з обчислюваними властивостями.
extension AppButtonSecondaryVariantExtension on AppButtonSecondaryVariant {
  /// Чи цей варіант відображає рамку.
  bool get hasBorder => this != AppButtonSecondaryVariant.ghost;

  /// Чи цей варіант має фонову заливку.
  bool get hasFill =>
      this == AppButtonSecondaryVariant.soft ||
      this == AppButtonSecondaryVariant.pill;

  /// Чи цей варіант повністю прозорий (без рамки і заливки).
  bool get isTransparent => this == AppButtonSecondaryVariant.ghost;

  /// Опис варіанту для дебагу.
  String get debugDescription {
    switch (this) {
      case AppButtonSecondaryVariant.outlined:
        return 'Outlined — контурна кнопка з рамкою';
      case AppButtonSecondaryVariant.ghost:
        return 'Ghost — прозора кнопка без рамки';
      case AppButtonSecondaryVariant.soft:
        return 'Soft — кнопка з м\'якою заливкою';
      case AppButtonSecondaryVariant.pill:
        return 'Pill — кнопка-пігул з закругленими кутами';
    }
  }

  /// Коефіцієнт прозорості заливки при наведенні.
  double get hoverFillOpacity {
    switch (this) {
      case AppButtonSecondaryVariant.outlined:
        return ButtonSecondaryConstants.hoverOpacityOutlined;
      case AppButtonSecondaryVariant.ghost:
        return 0.0;
      case AppButtonSecondaryVariant.soft:
        return ButtonSecondaryConstants.hoverOpacitySoft;
      case AppButtonSecondaryVariant.pill:
        return ButtonSecondaryConstants.hoverOpacityPill;
    }
  }

  /// Коефіцієнт прозорості заливки при натисканні.
  double get pressFillOpacity {
    switch (this) {
      case AppButtonSecondaryVariant.outlined:
        return ButtonSecondaryConstants.pressOpacityOutlined;
      case AppButtonSecondaryVariant.ghost:
        return ButtonSecondaryConstants.pressOpacityGhost;
      case AppButtonSecondaryVariant.soft:
        return ButtonSecondaryConstants.pressOpacitySoft;
      case AppButtonSecondaryVariant.pill:
        return ButtonSecondaryConstants.pressOpacityPill;
    }
  }
}

// ─── Theme-Aware Builder ───────────────────────────────────────────────────

/// Утиліта для створення кнопок, адаптованих до поточної теми.
class ButtonSecondaryThemeBuilder {
  ButtonSecondaryThemeBuilder._();

  /// Створює вторинну кнопку з кольорами, адаптованими до теми.
  static AppButtonSecondary themed({
    required String label,
    VoidCallback? onPressed,
    bool isLightTheme = false,
    IconData? icon,
    IconData? iconRight,
    AppButtonSecondaryVariant variant = AppButtonSecondaryVariant.outlined,
    AppButtonSecondarySize size = AppButtonSecondarySize.medium,
  }) {
    return AppButtonSecondary(
      label: label,
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: icon,
      iconRight: iconRight,
      variant: variant,
      size: size,
    );
  }

  /// Створює кнопку «Згорнути» з адаптацією до теми.
  static AppButtonSecondary collapse({
    VoidCallback? onPressed,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Згорнути',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: Icons.expand_less_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
    );
  }

  /// Створює кнопку «Розгорнути» з адаптацією до теми.
  static AppButtonSecondary expand({
    VoidCallback? onPressed,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Розгорнути',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: Icons.expand_more_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
    );
  }

  /// Створює кнопку «Фільтрувати» з адаптацією до теми.
  static AppButtonSecondary filter({
    VoidCallback? onPressed,
    bool isLightTheme = false,
    int? activeFilterCount,
  }) {
    return AppButtonSecondary(
      label: activeFilterCount != null && activeFilterCount > 0
          ? 'Фільтри ($activeFilterCount)'
          : 'Фільтри',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: Icons.filter_list_rounded,
      variant: AppButtonSecondaryVariant.outlined,
      size: AppButtonSecondarySize.small,
    );
  }
}

// ─── Accessibility Helpers ────────────────────────────────────────────────

/// Допоміжні методи для доступності [AppButtonSecondary].
///
/// Генерує семантичні мітки, підказки та описи для скрінрідерів,
/// враховуючи варіант, розмір та стан кнопки.
class ButtonSecondaryAccessibility {
  ButtonSecondaryAccessibility._();

  /// Генерує семантичну мітку для кнопки залежно від стану.
  static String buildSemanticsLabel({
    required String label,
    required AppButtonSecondaryVariant variant,
    bool isLoading = false,
    bool isDisabled = false,
    bool isDestructive = false,
    String? customSemanticLabel,
  }) {
    if (customSemanticLabel != null) return customSemanticLabel;
    if (isLoading) return '$label. Завантаження…';
    if (isDisabled) return '$label. Недоступно.';
    if (isDestructive) return '$label. Деструктивна дія.';
    final variantDesc = _variantSuffix(variant);
    return '$label.$variantDesc';
  }

  /// Повертає суфікс варіанту для семантичної мітки.
  static String _variantSuffix(AppButtonSecondaryVariant variant) {
    switch (variant) {
      case AppButtonSecondaryVariant.outlined:
        return ' Контурна кнопка.';
      case AppButtonSecondaryVariant.ghost:
        return ' Текстова кнопка.';
      case AppButtonSecondaryVariant.soft:
        return ' М\'яка кнопка.';
      case AppButtonSecondaryVariant.pill:
        return ' Кнопка-пігул.';
    }
  }

  /// Генерує підказку (hint) для кнопки.
  static String buildHint({
    bool hasLongPress = false,
    bool isDestructive = false,
  }) {
    final parts = <String>['Натисніть для дії'];
    if (hasLongPress) {
      parts.add('довге натискання для додаткових опцій');
    }
    if (isDestructive) {
      parts.add('деструктивна дія');
    }
    return parts.join(', ');
  }

  /// Повертає опис розміру для скрінрідера.
  static String sizeDescription(AppButtonSecondarySize size) {
    switch (size) {
      case AppButtonSecondarySize.xs:
        return 'Дуже мала вторинна кнопка';
      case AppButtonSecondarySize.small:
        return 'Мала вторинна кнопка';
      case AppButtonSecondarySize.medium:
        return 'Стандартна вторинна кнопка';
      case AppButtonSecondarySize.large:
        return 'Велика вторинна кнопка';
    }
  }
}

// ─── Computed Size Properties ─────────────────────────────────────────────

/// Розширення для [AppButtonSecondarySize] з обчислюваними властивостями.
extension AppButtonSecondarySizeComputedExtension on AppButtonSecondarySize {
  /// Чи розмір підходить для tight-компонування.
  bool get isCompact => index <= AppButtonSecondarySize.small.index;

  /// Чи розмір підходить для виділеної секції.
  bool get isProminent => index >= AppButtonSecondarySize.large.index;

  /// Повертає мінімальну ширину контейнера для цього розміру.
  double get minContainerWidth {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 40.0;
      case AppButtonSecondarySize.small:
        return 56.0;
      case AppButtonSecondarySize.medium:
        return 72.0;
      case AppButtonSecondarySize.large:
        return 96.0;
    }
  }

  /// Коефіцієнт opacity для вимкненого стану.
  double get disabledOpacity {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 0.55;
      case AppButtonSecondarySize.small:
        return 0.50;
      case AppButtonSecondarySize.medium:
        return 0.50;
      case AppButtonSecondarySize.large:
        return 0.45;
    }
  }

  /// Максимальна кількість символів для label.
  int get maxLabelChars {
    switch (this) {
      case AppButtonSecondarySize.xs:
        return 6;
      case AppButtonSecondarySize.small:
        return 12;
      case AppButtonSecondarySize.medium:
        return 24;
      case AppButtonSecondarySize.large:
        return 36;
    }
  }

  /// Опис для дебагу.
  String get debugDescription =>
      'AppButtonSecondarySize.$name (height: $height, iconSize: $iconSize, '
      'borderWidth: $borderWidth, hPadding: $horizontalPadding)';
}

// ─── Theme-Aware Decoration Builder ────────────────────────────────────────

/// Утиліта для створення декорацій [AppButtonSecondary],
/// адаптованих до теми та варіанту.
///
/// Централізує логіку обчислення кольорів рамки, заливки та тіней.
class ButtonSecondaryDecorationBuilder {
  ButtonSecondaryDecorationBuilder._();

  /// Обчислює ефективний колір рамки.
  ///
  /// Пріоритет: custom > destructive > success/warning > theme.
  static Color resolveBorderColor({
    Color? customColor,
    bool isDestructive = false,
    bool showSuccess = false,
    bool showWarning = false,
    bool isLightTheme = false,
  }) {
    if (customColor != null) return customColor;
    if (isDestructive) return AppColorsPS5.error;
    if (showSuccess) return AppColorsPS5.success;
    if (showWarning) return AppColorsPS5.warning;
    return isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  /// Обчислює ефективний колір тексту.
  static Color resolveTextColor({
    Color? customColor,
    bool isDestructive = false,
    bool showSuccess = false,
    bool showWarning = false,
    bool isLightTheme = false,
  }) {
    if (customColor != null) return customColor;
    if (isDestructive) return AppColorsPS5.error;
    if (showSuccess) return AppColorsPS5.success;
    if (showWarning) return AppColorsPS5.warning;
    return isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  /// Обчислює ефективний колір заливки.
  static Color resolveFillColor({
    Color? customColor,
    bool isDestructive = false,
    bool showSuccess = false,
    bool showWarning = false,
    bool isLightTheme = false,
  }) {
    if (customColor != null) return customColor;
    if (isDestructive) return AppColorsPS5.error;
    if (showSuccess) return AppColorsPS5.success;
    if (showWarning) return AppColorsPS5.warning;
    return isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  /// Обчислює ефективний колір focus-обведення.
  static Color resolveFocusColor({
    bool isDestructive = false,
    bool showSuccess = false,
    bool isLightTheme = false,
  }) {
    if (isDestructive) return AppColorsPS5.error;
    if (showSuccess) return AppColorsPS5.success;
    return isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  /// Обчислює opacity заливки залежно від стану та варіанту.
  static double fillOpacity({
    required AppButtonSecondaryVariant variant,
    required bool isPressed,
    required bool isHovered,
  }) {
    switch (variant) {
      case AppButtonSecondaryVariant.outlined:
        if (isPressed) return ButtonSecondaryConstants.pressOpacityOutlined;
        if (isHovered) return ButtonSecondaryConstants.hoverOpacityOutlined;
        return 0.0;
      case AppButtonSecondaryVariant.ghost:
        if (isPressed) return ButtonSecondaryConstants.pressOpacityGhost;
        return 0.0;
      case AppButtonSecondaryVariant.soft:
        if (isPressed) return ButtonSecondaryConstants.pressOpacitySoft;
        if (isHovered) return ButtonSecondaryConstants.hoverOpacitySoft;
        return 0.08;
      case AppButtonSecondaryVariant.pill:
        if (isPressed) return ButtonSecondaryConstants.pressOpacityPill;
        if (isHovered) return ButtonSecondaryConstants.hoverOpacityPill;
        return 0.05;
    }
  }
}

// ─── Additional Factory Constructors ───────────────────────────────────────

/// Додаткові фабричні конструктори для специфічних сценаріїв.
extension AppButtonSecondaryAdditionalFactories on AppButtonSecondary {
  /// Створює кнопку «Вивантажити» з іконкою.
  static AppButtonSecondary download({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Завантажити',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.download_rounded,
      variant: AppButtonSecondaryVariant.outlined,
    );
  }

  /// Створює кнопку «Видалити» (ghost) для списків.
  static AppButtonSecondary remove({
    VoidCallback? onPressed,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: '',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      icon: Icons.close_rounded,
      isDestructive: true,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
      tooltip: 'Видалити',
      showFocusOutline: false,
    );
  }

  /// Створює кнопку «Оновити» з іконкою.
  static AppButtonSecondary refresh({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Оновити',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      icon: Icons.refresh_rounded,
      variant: AppButtonSecondaryVariant.ghost,
    );
  }

  /// Створює кнопку «Додати» з плюсом.
  static AppButtonSecondary add({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Додати',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.add_rounded,
      variant: AppButtonSecondaryVariant.outlined,
    );
  }

  /// Створює кнопку «Керувати» для секцій.
  static AppButtonSecondary manage({
    VoidCallback? onPressed,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Керувати',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      iconRight: Icons.chevron_right_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
    );
  }

  /// Створює кнопку «Показати все».
  static AppButtonSecondary showAll({
    VoidCallback? onPressed,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Показати все',
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      iconRight: Icons.arrow_forward_rounded,
      variant: AppButtonSecondaryVariant.ghost,
      size: AppButtonSecondarySize.small,
    );
  }

  /// Створює кнопку «Змінити пароль».
  static AppButtonSecondary changePassword({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isLightTheme = false,
  }) {
    return AppButtonSecondary(
      label: 'Змінити пароль',
      onPressed: onPressed,
      isLoading: isLoading,
      isLightTheme: isLightTheme,
      icon: Icons.lock_outline_rounded,
      variant: AppButtonSecondaryVariant.outlined,
    );
  }

  /// Створює кнопку «Вийти».
  static AppButtonSecondary logout({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDestructive = false,
    bool isLightTheme = false,
    bool isFullWidth = false,
  }) {
    return AppButtonSecondary(
      label: 'Вийти',
      onPressed: onPressed,
      isLoading: isLoading,
      isDestructive: isDestructive,
      isLightTheme: isLightTheme,
      isFullWidth: isFullWidth,
      icon: Icons.logout_rounded,
      semanticLabel: 'Вийти з облікового запису',
    );
  }
}

// ─── Additional Validation Methods ─────────────────────────────────────────

/// Розширені методи валідації для [AppButtonSecondary].
class ButtonSecondaryExtendedValidators {
  ButtonSecondaryExtendedValidators._();

  /// Валідує параметри кнопки з додатковими перевірками.
  ///
  /// Повертає список помилок. Порожній — кнопка валідна.
  static List<String> validateFull({
    required String label,
    required AppButtonSecondarySize size,
    required AppButtonSecondaryVariant variant,
    double? borderRadius,
    bool isFullWidth = false,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    final errors = <String>[];
    errors.addAll(ButtonSecondaryValidators.validate(
      label: label,
      size: size,
      variant: variant,
      borderRadius: borderRadius,
    ));

    // Перевірка: pill з focus-обведенням може виглядати дивно
    if (variant == AppButtonSecondaryVariant.pill && borderRadius != null) {
      // Pill має автоматичний borderRadius — кастомний можеconflict
      // Це warning, не error
    }

    // Перевірка: destructive ghost може бути непомітним
    if (isDestructive && variant == AppButtonSecondaryVariant.ghost) {
      // Допустимо, але занотуємо
    }

    return errors;
  }

  /// Перевіряє, чи label підходить для розміру.
  static bool isLabelFitting({
    required String label,
    required AppButtonSecondarySize size,
    bool hasIcon = false,
    bool hasIconRight = false,
  }) {
    final maxChars = size.maxLabelChars;
    final iconOverhead = (hasIcon ? 1 : 0) + (hasIconRight ? 1 : 0);
    final effectiveMax = maxChars - iconOverhead;
    return label.length <= effectiveMax;
  }

  /// Обчислює рекомендований варіант залежно від контексту.
  static AppButtonSecondaryVariant recommendVariant({
    bool isInline = false,
    bool isInList = false,
    bool isInCard = false,
    bool isStandalone = false,
  }) {
    if (isInline) return AppButtonSecondaryVariant.ghost;
    if (isInList) return AppButtonSecondaryVariant.outlined;
    if (isInCard) return AppButtonSecondaryVariant.soft;
    if (isStandalone) return AppButtonSecondaryVariant.outlined;
    return AppButtonSecondaryVariant.outlined;
  }

  /// Обчислює рекомендований розмір залежно від контексту.
  static AppButtonSecondarySize recommendSize({
    bool isCompact = false,
    bool isStandalone = false,
    bool isInSection = false,
  }) {
    if (isCompact) return AppButtonSecondarySize.xs;
    if (isStandalone) return AppButtonSecondarySize.large;
    if (isInSection) return AppButtonSecondarySize.medium;
    return AppButtonSecondarySize.medium;
  }
}

// ─── Haptic Helpers for Secondary ──────────────────────────────────────────

/// Утиліта тактильного відгуку для вторинних кнопок.
///
/// Надає адаптивну стратегію залежно від варіанту кнопки.
class ButtonSecondaryHaptic {
  ButtonSecondaryHaptic._();

  /// Викликає тактильний відгук для звичайного натискання.
  static void onTap(bool enableHaptic) {
    if (!enableHaptic) return;
    HapticFeedback.lightImpact();
  }

  /// Викликає тактильний відгук для довгого натискання.
  static void onLongPress(bool enableHaptic) {
    if (!enableHaptic) return;
    HapticFeedback.mediumImpact();
  }

  /// Обирає інтенсивність залежно від варіанту.
  static void forVariant(
    AppButtonSecondaryVariant variant, {
    bool enableHaptic = true,
  }) {
    if (!enableHaptic) return;
    switch (variant) {
      case AppButtonSecondaryVariant.outlined:
        HapticFeedback.lightImpact();
        break;
      case AppButtonSecondaryVariant.ghost:
        HapticFeedback.selectionClick();
        break;
      case AppButtonSecondaryVariant.soft:
        HapticFeedback.lightImpact();
        break;
      case AppButtonSecondaryVariant.pill:
        HapticFeedback.selectionClick();
        break;
    }
  }
}
