import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_radii.dart';
import '../constants/app_shadows.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

// ─── FAB Size Enum ──────────────────────────────────────────────────────────

/// Розмір плаваючої кнопки дії.
enum AppFabSize {
  /// Дуже малий (36px) — для compact-інтерфейсів.
  xs(36.0, 14.0),

  /// Малий (44px) — для compact-інтерфейсів.
  small(44.0, 16.0),

  /// Стандартний (56px) — стандартний Material FAB.
  medium(56.0, 24.0),

  /// Великий (68px) — для виділених дій.
  large(68.0, 30.0);

  const AppFabSize(this.dimension, this.iconSize);

  /// Розмір кнопки у пікселях.
  final double dimension;

  /// Розмір іконки.
  final double iconSize;

  /// Українська назва розміру.
  String get label {
    switch (this) {
      case AppFabSize.xs:
        return 'Дуже малий';
      case AppFabSize.small:
        return 'Малий';
      case AppFabSize.medium:
        return 'Середній';
      case AppFabSize.large:
        return 'Великий';
    }
  }
}

// ─── FAB Variant ─────────────────────────────────────────────────────────────

/// Варіант відображення FAB.
enum AppFabVariant {
  /// Стандартний FAB.
  standard,

  /// Міні-FAB (без тіні, менший).
  mini,

  /// Розширений FAB (з текстом).
  extended,

  /// FAB з бейджем сповіщень.
  notification,

  /// Speed Dial FAB (з підменю дій).
  speedDial,

  /// FAB з бейджем та станом завантаження.
  loading;

  /// Українська назва варіанту.
  String get label {
    switch (this) {
      case AppFabVariant.standard:
        return 'Стандартний';
      case AppFabVariant.mini:
        return 'Міні';
      case AppFabVariant.extended:
        return 'Розширений';
      case AppFabVariant.notification:
        return 'Сповіщення';
      case AppFabVariant.speedDial:
        return 'Швидкий набір';
      case AppFabVariant.loading:
        return 'Завантаження';
    }
  }
}

// ─── FAB Theme Variant ───────────────────────────────────────────────────────

/// Кольорова тема FAB.
enum AppFabTheme {
  /// Основний акцентний колір.
  primary,

  /// Вторинний акцентний колір.
  secondary,

  /// Акцентний колір XP.
  accent,

  /// Колір успіху.
  success,

  /// Колір попередження.
  warning,

  /// Колір помилки.
  error;

  /// Українська назва теми.
  String get label {
    switch (this) {
      case AppFabTheme.primary:
        return 'Основний';
      case AppFabTheme.secondary:
        return 'Вторинний';
      case AppFabTheme.accent:
        return 'Акцентний';
      case AppFabTheme.success:
        return 'Успіх';
      case AppFabTheme.warning:
        return 'Попередження';
      case AppFabTheme.error:
        return 'Помилка';
    }
  }

  /// Повертає колір для темної теми.
  Color darkColor(AppFabSize size) {
    switch (this) {
      case AppFabTheme.primary:
        return AppColorsPS5.accent;
      case AppFabTheme.secondary:
        return AppColorsPS5.accentLight;
      case AppFabTheme.accent:
        return AppColorsPS5.xp;
      case AppFabTheme.success:
        return AppColorsPS5.success;
      case AppFabTheme.warning:
        return AppColorsPS5.warning;
      case AppFabTheme.error:
        return AppColorsPS5.error;
    }
  }

  /// Повертає колір для світлої теми.
  Color lightColor(AppFabSize size) {
    switch (this) {
      case AppFabTheme.primary:
        return AppColorsMonitor.accent;
      case AppFabTheme.secondary:
        return AppColorsMonitor.accentLight;
      case AppFabTheme.accent:
        return AppColorsMonitor.xp;
      case AppFabTheme.success:
        return AppColorsMonitor.success;
      case AppFabTheme.warning:
        return AppColorsMonitor.warning;
      case AppFabTheme.error:
        return AppColorsMonitor.error;
    }
  }
}

// ─── Speed Dial Action ──────────────────────────────────────────────────────

/// Дія для speed dial FAB.
class SpeedDialAction {
  const SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  /// Іконка дії.
  final IconData icon;

  /// Текстова мітка.
  final String label;

  /// Зворотний виклик.
  final VoidCallback onTap;

  /// Кастомний колір.
  final Color? color;

  /// Підказка.
  final String? tooltip;
}

/// Плаваюча кнопка дії (FAB) з багатьма функціями.
///
/// Підтримує розміри, лічильник бейджів, текстову мітку, кастомні іконки,
/// кольори, bounce-анімацію, tooltip та анімацію показу/сховання.
/// Варіанти: standard, mini, extended, notification, speedDial, loading.
/// Теми: primary, secondary, accent, success, warning, error.
class AppFab extends StatefulWidget {
  const AppFab({
    super.key,
    required this.onPressed,
    this.isLightTheme = false,
    this.size = AppFabSize.medium,
    this.icon,
    this.label,
    this.isExtended = false,
    this.fabColor,
    this.badgeCount,
    this.tooltipText,
    this.enableHaptic = true,
    this.showBounce = true,
    this.isVisible = true,
    this.notchOffset,
    this.variant = AppFabVariant.standard,
    this.semanticLabel,
    this.onLongPress,
    this.speedDialActions,
    this.isLoading = false,
    this.fabTheme = AppFabTheme.primary,
    this.longPressLabel,
  });

  /// Зворотний виклик при натисканні.
  final VoidCallback onPressed;

  /// Зворотний виклик при довгому натисканні.
  final VoidCallback? onLongPress;

  /// Світла тема.
  final bool isLightTheme;

  /// Розмір кнопки.
  final AppFabSize size;

  /// Кастомна іконка (замість «+»).
  final IconData? icon;

  /// Текстова мітка для розгорнутого FAB.
  final String? label;

  /// Розгорнути FAB з текстом.
  final bool isExtended;

  /// Кастомний колір кнопки.
  final Color? fabColor;

  /// Лічильник бейджів на кнопці.
  final int? badgeCount;

  /// Текст підказки при тривалому натисканні.
  final String? tooltipText;

  /// Тактильний відгук при натисканні.
  final bool enableHaptic;

  /// Показувати bounce-анімацію.
  final bool showBounce;

  /// Видимість кнопки (з анімацією показу/сховання).
  final bool isVisible;

  /// Зміщення від нижнього виїмки (notch) навігаційної панелі.
  final double? notchOffset;

  /// Варіант відображення.
  final AppFabVariant variant;

  /// Семантична мітка для екранних читачів.
  final String? semanticLabel;

  /// Дії для speed dial варіанту.
  final List<SpeedDialAction>? speedDialActions;

  /// Чи кнопка в стані завантаження.
  final bool isLoading;

  /// Кольорова тема FAB.
  final AppFabTheme fabTheme;

  /// Мітка, що з'являється при довгому натисканні.
  final String? longPressLabel;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _appearController;
  late AnimationController _speedDialController;
  late AnimationController _longPressController;
  bool _wasPressed = false;
  bool _isSpeedDialOpen = false;
  bool _showLongPressLabel = false;

  // ─── Color Getters ───────────────────────────────────────────────────

  Color get _effectiveColor =>
      widget.fabColor ??
      (widget.isLightTheme
          ? widget.fabTheme.lightColor(widget.size)
          : widget.fabTheme.darkColor(widget.size));

  Color get _textColor => Colors.white;

  Color get _bgColor => widget.isLightTheme
      ? AppColorsMonitor.background
      : AppColorsPS5.background;

  // ─── Lifecycle ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: AppDurations.bounce,
    );
    _appearController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
      value: widget.isVisible ? 1.0 : 0.0,
    );
    _speedDialController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _longPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant AppFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _appearController.forward();
      } else {
        _appearController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _appearController.dispose();
    _speedDialController.dispose();
    _longPressController.dispose();
    super.dispose();
  }

  // ─── Handlers ────────────────────────────────────────────────────────

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }

    if (widget.showBounce) {
      setState(() => _wasPressed = true);
      _bounceController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() => _wasPressed = false);
        }
      });
    }

    // Speed Dial toggle
    if (widget.variant == AppFabVariant.speedDial) {
      setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
      if (_isSpeedDialOpen) {
        _speedDialController.forward();
      } else {
        _speedDialController.reverse();
      }
      return;
    }

    if (!widget.isLoading) {
      widget.onPressed();
    }
  }

  void _showTooltip() {
    if (widget.tooltipText == null) return;
    HapticFeedback.longPress();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.tooltipText!),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
    );
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _longPressController.forward();
    setState(() => _showLongPressLabel = true);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _longPressController.reverse();
    setState(() => _showLongPressLabel = false);
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else {
      _showTooltip();
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveDimension = widget.size.dimension;

    // Speed Dial з підменю
    if (widget.variant == AppFabVariant.speedDial &&
        widget.speedDialActions != null) {
      return _buildSpeedDial(effectiveDimension);
    }

    // Loading FAB
    if (widget.variant == AppFabVariant.loading || widget.isLoading) {
      return _buildLoadingFab(effectiveDimension);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceController,
        _appearController,
      ]),
      builder: (context, child) {
        final bounceScale = _wasPressed
            ? 1.0 +
                math.sin(_bounceController.value * math.pi) * 0.15
            : 1.0;
        final appearScale = _appearController.value;

        return Transform.scale(
          scale: bounceScale * appearScale,
          child: Opacity(
            opacity: _appearController.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: _handleLongPress,
        child: _buildWithLongPressLabel(effectiveDimension),
      ),
    );
  }

  /// Обгортає FAB з міткою, що з'являється при довгому натисканні.
  Widget _buildWithLongPressLabel(double dimension) {
    final fab = _buildFabContent(dimension);
    if (widget.longPressLabel == null && widget.onLongPress == null) return fab;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedOpacity(
          opacity: _showLongPressLabel ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.only(bottom: Spacing.xs),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(Radii.sm),
              boxShadow: AppShadows.level2,
            ),
            child: Text(
              widget.longPressLabel ?? 'Утримуй',
              style: AppTypography.labelSmall.copyWith(
                color: _effectiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        fab,
      ],
    );
  }

  /// FAB у стані завантаження.
  Widget _buildLoadingFab(double dimension) {
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: widget.isLoading ? null : _handleTap,
            backgroundColor: _effectiveColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.base),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: widget.size.iconSize,
                    height: widget.size.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                    ),
                  )
                : Icon(
                    widget.icon ?? Icons.check_rounded,
                    color: _textColor,
                    size: widget.size.iconSize,
                  ),
          ),
          // ── Badge Counter ──
          if (widget.badgeCount != null && widget.badgeCount! > 0) ...[
            _buildBadge(dimension),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedDial(double dimension) {
    final actions = widget.speedDialActions!;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        // Спливаючі дії
        ...List.generate(actions.length, (index) {
          final action = actions[actions.length - 1 - index];
          final delay = (index + 1) * 0.1;
          return AnimatedBuilder(
            animation: _speedDialController,
            builder: (context, child) {
              final t = CurvedAnimation(
                parent: _speedDialController,
                curve: Interval(delay.clamp(0.0, 0.8), 1.0),
              ).value;
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, -56 * (index + 1) * t),
                  child: Transform.scale(scale: t, child: child),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: action.color ?? _effectiveColor,
                    borderRadius: BorderRadius.circular(Radii.lg),
                    boxShadow: AppShadows.glow(action.color ?? _effectiveColor),
                  ),
                  child: Text(
                    action.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: _textColor,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                FloatingActionButton.small(
                  heroTag: 'speed_dial_$index',
                  onPressed: action.onTap,
                  backgroundColor: action.color ?? _effectiveColor,
                  elevation: 0,
                  child: Icon(action.icon, color: _textColor),
                ),
              ],
            ),
          );
        }),
        // Головна кнопка
        _buildFabContent(dimension),
      ],
    );
  }

  Widget _buildFabContent(double dimension) {
    // ── Notification FAB ──
    if (widget.variant == AppFabVariant.notification) {
      return _buildNotificationFab(dimension);
    }

    // ── Extended FAB (icon + label) ──
    if ((widget.isExtended || widget.variant == AppFabVariant.extended) &&
        widget.label != null) {
      return FloatingActionButton.extended(
        onPressed: _handleTap,
        backgroundColor: _effectiveColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.base),
        ),
        icon: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.base),
            boxShadow: AppShadows.fab,
          ),
          child: Icon(
            widget.icon ?? Icons.add,
            color: _textColor,
            size: widget.size.iconSize,
          ),
        ),
        label: Text(
          widget.label!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      );
    }

    // ── Mini FAB ──
    if (widget.variant == AppFabVariant.mini) {
      return SizedBox(
        width: dimension,
        height: dimension,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton.small(
              heroTag: 'mini_fab',
              onPressed: _handleTap,
              backgroundColor: _effectiveColor,
              elevation: 0,
              child: Icon(
                widget.icon ?? Icons.add,
                color: _textColor,
                size: widget.size.iconSize,
              ),
            ),
            if (widget.badgeCount != null && widget.badgeCount! > 0) ...[
              _buildBadge(dimension),
            ],
          ],
        ),
      );
    }

    // ── Standard FAB ──
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: _handleTap,
            backgroundColor: _effectiveColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.base),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.base),
                boxShadow: AppShadows.fab,
              ),
              child: Icon(
                widget.icon ?? Icons.add,
                color: _textColor,
                size: widget.size.iconSize,
              ),
            ),
          ),
          // ── Badge Counter ──
          if (widget.badgeCount != null && widget.badgeCount! > 0) ...[
            _buildBadge(dimension),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationFab(double dimension) {
    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: _handleTap,
            backgroundColor: _effectiveColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.base),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    widget.icon ?? Icons.notifications_rounded,
                    color: _textColor,
                    size: widget.size.iconSize,
                  ),
                ),
                // Індикатор непрочитаних
                if (widget.badgeCount != null && widget.badgeCount! > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColorsPS5.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: _effectiveColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Badge Counter ──
          if (widget.badgeCount != null && widget.badgeCount! > 0) ...[
            _buildBadge(dimension),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(double dimension) {
    final count = widget.badgeCount!;
    final isLarge = count > 99;
    final displayText = isLarge ? '99+' : '$count';

    return Positioned(
      top: -4,
      right: -4,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 6 : 5,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColorsPS5.error,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _bgColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorsPS5.error.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 18),
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ).animate().scale(
            begin: const Offset(0.0, 0.0),
            end: const Offset(1.0, 1.0),
            duration: AppDurations.small,
            curve: AppEasings.subtlePop,
          ),
    );
  }
}

// ─── FAB Constants ──────────────────────────────────────────────────────────

/// Константи для FAB-віджета: розміри, анімації, граничні значення.
///
/// Містить усі числові значення, які використовуються для налаштування
/// плаваючих кнопок дії в додатку Nexora.
class AppFabConstants {
  AppFabConstants._();

  /// Максимальна кількість бейджів для відображення тексту "99+".
  static const int maxBadgeCount = 99;

  /// Мінімальний розмір FAB у пікселях.
  static const double minDimension = 36.0;

  /// Максимальний розмір FAB у пікселях.
  static const double maxDimension = 96.0;

  /// Стандартна ширина тіні під FAB.
  static const double defaultElevation = 0.0;

  /// Відступ бейджу від краю FAB.
  static const double badgeOffset = -4.0;

  /// Мінімальна ширина бейджу.
  static const double badgeMinWidth = 18.0;

  /// Максимальна кількість speed dial-дій.
  static const int maxSpeedDialActions = 5;

  /// Тривалість анімації розгортання speed dial.
  static const Duration speedDialExpandDuration = Duration(milliseconds: 250);

  /// Тривалість анімації згортання speed dial.
  static const Duration speedDialCollapseDuration = Duration(milliseconds: 200);

  /// Міжрядковий інтервал між speed dial-екранами.
  static const double speedDialItemSpacing = 56.0;

  /// Затримка появи кожного speed dial-екрану (секунди).
  static const double speedDialStaggerDelay = 0.1;

  /// Максимальна кількість символів для label extended FAB.
  static const int maxExtendedLabelLength = 24;

  /// Розмір індикатора непрочитаних (notification dot).
  static const double notificationDotSize = 10.0;

  /// Товщина рамки навколо notification dot.
  static const double notificationDotBorderWidth = 2.0;

  /// Відступ notification dot від краю.
  static const double notificationDotInset = 4.0;

  /// Ширина stroke для кастомної рамки FAB.
  static const double customStrokeWidth = 1.5;

  /// Тривалість анімації long press label.
  static const Duration longPressLabelDuration = Duration(milliseconds: 200);

  /// Відступ bottom для standard-позиціонування.
  static const double standardBottomInset = 80.0;

  /// Відступ right для standard-позиціонування.
  static const double standardRightInset = 16.0;

  /// Відступ bottom для centered-notch позиціонування.
  static const double centeredNotchBottomInset = 24.0;

  /// Відступ top для top-right позиціонування.
  static const double topRightTopInset = 80.0;

  /// Тривалість bounce-анімації при натисканні.
  static const Duration bounceDuration = Duration(milliseconds: 150);

  /// Максимальний масштаб bounce-анімації (1.0 = без масштабування).
  static const double bounceMaxScale = 1.15;

  /// Діапазон скролу для показу/сховання FAB (пікселі вниз).
  static const double showScrollThreshold = 100.0;

  /// Діапазон скролу для показу/сховання FAB (пікселі вгору).
  static const double hideScrollThreshold = 50.0;
}

// ─── FAB Validation ─────────────────────────────────────────────────────────

/// Методи валідації для FAB-віджета.
///
/// Перевіряє коректність параметрів FAB перед відображенням.
class AppFabValidation {
  AppFabValidation._();

  /// Перевіряє, чи розмір FAB знаходиться в допустимих межах.
  ///
  /// [dimension] — розмір кнопки у пікселях.
  /// Повертає `true`, якщо розмір в межах [minDimension, maxDimension].
  static bool isValidDimension(double dimension) {
    return dimension >= AppFabConstants.minDimension &&
        dimension <= AppFabConstants.maxDimension;
  }

  /// Перевіряє, чи кількість бейджів коректна.
  ///
  /// [count] — кількість бейджів.
  /// Повертає `true`, якщо count > 0.
  static bool isValidBadgeCount(int count) {
    return count > 0;
  }

  /// Перевіряє, чи кількість speed dial-дій не перевищує ліміт.
  ///
  /// [actionCount] — кількість дій.
  /// Повертає `true`, якщо кількість дій в межах ліміту.
  static bool isValidSpeedDialCount(int actionCount) {
    return actionCount > 0 && actionCount <= AppFabConstants.maxSpeedDialActions;
  }

  /// Перевіряє, чи довжина label extended FAB в межах.
  ///
  /// [label] — текстова мітка.
  /// Повертає `true`, якщо label не пустий і не перевищує ліміт символів.
  static bool isValidExtendedLabel(String label) {
    return label.isNotEmpty && label.length <= AppFabConstants.maxExtendedLabelLength;
  }

  /// Перевіряє, чи варіант FAB підтримує передані параметри.
  ///
  /// Наприклад, speed dial вимагає [speedDialActions], а notification
  /// — [badgeCount].
  static bool isVariantCompatible({
    required AppFabVariant variant,
    List<SpeedDialAction>? speedDialActions,
    int? badgeCount,
    bool isExtended = false,
  }) {
    switch (variant) {
      case AppFabVariant.speedDial:
        return speedDialActions != null && speedDialActions.isNotEmpty;
      case AppFabVariant.notification:
        return badgeCount != null && badgeCount > 0;
      case AppFabVariant.extended:
        return isExtended;
      default:
        return true;
    }
  }

  /// Повертає відформатоване повідомлення про помилку валідації.
  ///
  /// [field] — назва поля, що не пройшло валідацію.
  /// [value] — некоректне значення.
  static String validationErrorMessage(String field, dynamic value) {
    return 'Некоректне значення $field: $value';
  }
}

// ─── FAB Theme Resolver ─────────────────────────────────────────────────────

/// Допоміжний клас для визначення кольорів FAB залежно від теми.
///
/// Центральний точка для всіх кольорових рішень FAB.
class AppFabThemeResolver {
  AppFabThemeResolver._();

  /// Повертає ефективний колір кнопки.
  ///
  /// Враховує кастомний колір, тему FAB та тему інтерфейсу.
  static Color resolveColor({
    Color? customColor,
    required AppFabTheme fabTheme,
    required AppFabSize size,
    required bool isLightTheme,
  }) {
    if (customColor != null) return customColor;
    return isLightTheme
        ? fabTheme.lightColor(size)
        : fabTheme.darkColor(size);
  }

  /// Повертає колір тексту на FAB.
  ///
  /// Зазвичай білий, але для деяких тем може бути темним.
  static Color resolveTextColor({
    required AppFabTheme fabTheme,
    Color? customColor,
  }) {
    // Для кастомних кольорів — автоматично визначає контраст
    if (customColor != null) {
      return _getContrastColor(customColor);
    }
    return Colors.white;
  }

  /// Повертає колір фону для long press label.
  static Color resolveLabelBgColor({
    required bool isLightTheme,
  }) {
    return isLightTheme ? AppColorsMonitor.background : AppColorsPS5.background;
  }

  /// Повертає колір тіні для FAB залежно від теми.
  static Color resolveShadowColor({
    required bool isLightTheme,
    required AppFabTheme fabTheme,
  }) {
    if (isLightTheme) return Colors.black.withOpacity(0.1);
    return Colors.black.withOpacity(0.3);
  }

  /// Визначає колір тексту з високим контрастом.
  ///
  /// Повертає чорний або білий залежно від яскравості фону.
  static Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Повертає кольори для disabled-стану FAB.
  static ({Color bg, Color text}) resolveDisabledColors({
    required bool isLightTheme,
  }) {
    if (isLightTheme) {
      return (
        bg: AppColorsMonitor.textHint.withOpacity(0.12),
        text: AppColorsMonitor.textHint,
      );
    }
    return (
      bg: AppColorsPS5.textHint.withOpacity(0.12),
      text: AppColorsPS5.textHint,
    );
  }
}

// ─── FAB Placement Helper ───────────────────────────────────────────────────

/// Допоміжні методи для розміщення FAB на екрані.
class AppFabPlacement {
  AppFabPlacement._();

  /// Стандартне позиціонування FAB над BottomNavigationBar.
  static const EdgeInsets standardMargin = EdgeInsets.only(
    right: 16,
    bottom: 80,
  );

  /// Центрування FAB над BottomNavigationBar з notch.
  static const EdgeInsets centeredNotchMargin = EdgeInsets.only(
    bottom: 24,
  );

  /// Позиціонування FAB у правому верхньому куті (як action button).
  static const EdgeInsets topRightMargin = EdgeInsets.only(
    right: 16,
    top: 80,
  );

  /// Позиціонування для speed dial FAB.
  static const EdgeInsets speedDialMargin = EdgeInsets.only(
    right: 16,
    bottom: 80,
  );

  /// Створити позиціонування з відступами.
  static Widget wrapWithPosition({
    required Widget child,
    EdgeInsets margin = standardMargin,
  }) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: margin,
        child: child,
      ),
    );
  }

  /// Створити позиціонування з анімованою появою.
  static Widget wrapWithAnimation({
    required Widget child,
    EdgeInsets margin = standardMargin,
    bool isVisible = true,
  }) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: margin,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: isVisible ? 1.0 : 0.5,
            duration: AppDurations.medium,
            curve: Curves.easeOutBack,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Створити FAB з визначенням видимості при скролі.
  static Widget wrapWithScrollVisibility({
    required Widget child,
    required ScrollController scrollController,
    EdgeInsets margin = standardMargin,
    double showThreshold = 100,
    double hideThreshold = 50,
  }) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: margin,
        child: AnimatedBuilder(
          animation: scrollController,
          builder: (context, _) {
            final offset = scrollController.offset;
            final visible = offset < showThreshold;
            return AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: AppDurations.medium,
              child: AnimatedScale(
                scale: visible ? 1.0 : 0.6,
                duration: AppDurations.medium,
                curve: Curves.easeOutBack,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Створити FAB з анімованим backdrop (напівпрозорий оверлей).
  ///
  /// Корисно для speed dial — backdrop з'являється при розгортанні
  /// і дозволяє закрити підменю натисканням поза кнопками.
  static Widget wrapWithBackdrop({
    required Widget child,
    required bool isOpen,
    required VoidCallback onClose,
    Color? backdropColor,
  }) {
    return Stack(
      children: [
        if (isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: backdropColor ?? Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        child,
      ],
    );
  }

  /// Створити горизонтальний ряд FAB-кнопок.
  ///
  /// Корисно для тулбарів з кількома дій.
  static Widget buildHorizontalRow({
    required List<Widget> fabs,
    double spacing = 12.0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < fabs.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              fabs[i],
            ],
          ],
        ),
      ),
    );
  }

  /// Обчислює оптимальний розмір FAB залежно від ширини екрана.
  ///
  /// На вузьких екранах (< 360px) повертає [AppFabSize.small],
  /// інакше [AppFabSize.medium].
  static AppFabSize adaptiveSize(double screenWidth) {
    if (screenWidth < 360) return AppFabSize.small;
    if (screenWidth < 600) return AppFabSize.medium;
    return AppFabSize.large;
  }
}

// ─── FAB Extensions ───────────────────────────────────────────────────────────

/// Розширення для зручного створення типових FAB-віджетів.
///
/// Надає фабричні методи для найпоширеніших сценаріїв використання.
extension AppFabExtensions on AppFab {
  /// Створює копію FAB з іншою темою інтерфейсу.
  ///
  /// Корисно для перемикання між світлою та темною темою.
  AppFab withLightTheme(bool isLight) {
    return AppFab(
      key: key,
      onPressed: onPressed,
      isLightTheme: isLight,
      size: size,
      icon: icon,
      label: label,
      isExtended: isExtended,
      fabColor: fabColor,
      badgeCount: badgeCount,
      tooltipText: tooltipText,
      enableHaptic: enableHaptic,
      showBounce: showBounce,
      isVisible: isVisible,
      notchOffset: notchOffset,
      variant: variant,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      speedDialActions: speedDialActions,
      isLoading: isLoading,
      fabTheme: fabTheme,
      longPressLabel: longPressLabel,
    );
  }

  /// Створює копію FAB з іншим розміром.
  AppFab withSize(AppFabSize newSize) {
    return AppFab(
      key: key,
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      size: newSize,
      icon: icon,
      label: label,
      isExtended: isExtended,
      fabColor: fabColor,
      badgeCount: badgeCount,
      tooltipText: tooltipText,
      enableHaptic: enableHaptic,
      showBounce: showBounce,
      isVisible: isVisible,
      notchOffset: notchOffset,
      variant: variant,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      speedDialActions: speedDialActions,
      isLoading: isLoading,
      fabTheme: fabTheme,
      longPressLabel: longPressLabel,
    );
  }

  /// Створює копію FAB у стані завантаження.
  AppFab withLoading(bool loading) {
    return AppFab(
      key: key,
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      size: size,
      icon: icon,
      label: label,
      isExtended: isExtended,
      fabColor: fabColor,
      badgeCount: badgeCount,
      tooltipText: tooltipText,
      enableHaptic: enableHaptic,
      showBounce: showBounce,
      isVisible: isVisible,
      notchOffset: notchOffset,
      variant: loading ? AppFabVariant.loading : variant,
      semanticLabel: semanticLabel,
      onLongPress: onLongPress,
      speedDialActions: speedDialActions,
      isLoading: loading,
      fabTheme: fabTheme,
      longPressLabel: longPressLabel,
    );
  }
}

// ─── FAB Preset Builders ──────────────────────────────────────────────────────

/// Зручні статичні методи для швидкого створення типових FAB-віджетів.
///
/// Дозволяє створювати FAB без явного вказування всіх параметрів.
class AppFabPresets {
  AppFabPresets._();

  /// Створює стандартний FAB з іконкою "додати" (+).
  ///
  /// [onPressed] — callback при натисканні.
  /// [isLightTheme] — тема інтерфейсу.
  static AppFab add({
    required VoidCallback onPressed,
    bool isLightTheme = false,
    AppFabTheme theme = AppFabTheme.primary,
    AppFabSize size = AppFabSize.medium,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      fabTheme: theme,
      size: size,
      icon: Icons.add,
    );
  }

  /// Створює FAB для створення цілі.
  ///
  /// Використовує іконку ціль і тему success.
  static AppFab createGoal({
    required VoidCallback onPressed,
    bool isLightTheme = false,
    AppFabSize size = AppFabSize.medium,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      fabTheme: AppFabTheme.success,
      size: size,
      icon: Icons.flag_rounded,
      label: 'Нова ціль',
      isExtended: true,
    );
  }

  /// Створює FAB для внеску коштів.
  ///
  /// Використовує іконку гаманця і тему accent.
  static AppFab deposit({
    required VoidCallback onPressed,
    bool isLightTheme = false,
    AppFabSize size = AppFabSize.medium,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      fabTheme: AppFabTheme.accent,
      size: size,
      icon: Icons.account_balance_wallet_rounded,
    );
  }

  /// Створює розширений FAB для головної дії.
  ///
  /// Використовує текстову мітку та великий розмір.
  static AppFab primaryAction({
    required VoidCallback onPressed,
    required String label,
    IconData icon = Icons.add,
    bool isLightTheme = false,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      label: label,
      icon: icon,
      isExtended: true,
      size: AppFabSize.medium,
      fabTheme: AppFabTheme.primary,
    );
  }

  /// Створює speed dial FAB з кількома діями.
  ///
  /// [actions] — список дій для підменю.
  /// [isLightTheme] — тема інтерфейсу.
  static AppFab speedDial({
    required List<SpeedDialAction> actions,
    required VoidCallback onPressed,
    bool isLightTheme = false,
    AppFabTheme theme = AppFabTheme.primary,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      variant: AppFabVariant.speedDial,
      speedDialActions: actions,
      fabTheme: theme,
      icon: Icons.add,
    );
  }

  /// Створює notification FAB з лічильником.
  ///
  /// [onPressed] — callback при натисканні.
  /// [count] — кількість непрочитаних сповіщень.
  /// [isLightTheme] — тема інтерфейсу.
  static AppFab notification({
    required VoidCallback onPressed,
    required int count,
    bool isLightTheme = false,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      variant: AppFabVariant.notification,
      badgeCount: count,
      icon: Icons.notifications_rounded,
      fabTheme: AppFabTheme.primary,
    );
  }

  /// Створює FAB у стані завантаження.
  ///
  /// Корисно для відображення під час асинхронних операцій.
  static AppFab loading({
    required VoidCallback onPressed,
    bool isLightTheme = false,
    AppFabTheme theme = AppFabTheme.primary,
    bool isLoading = true,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      variant: AppFabVariant.loading,
      isLoading: isLoading,
      fabTheme: theme,
      icon: Icons.check_rounded,
    );
  }

  /// Створює mini FAB для compact-інтерфейсів.
  ///
  /// Менший розмір, без тіні, для вбудовування у картки.
  static AppFab mini({
    required VoidCallback onPressed,
    IconData icon = Icons.add,
    bool isLightTheme = false,
    Color? color,
  }) {
    return AppFab(
      onPressed: onPressed,
      isLightTheme: isLightTheme,
      variant: AppFabVariant.mini,
      size: AppFabSize.small,
      icon: icon,
      fabColor: color,
    );
  }
}

// ─── FAB Size Extensions ───────────────────────────────────────────────────────

/// Розширення для [AppFabSize] з computed properties та допоміжними методами.
extension AppFabSizeExtensions on AppFabSize {
  /// Чи це найменший доступний розмір.
  bool get isSmallest => this == AppFabSize.xs;

  /// Чи це найбільший доступний розмір.
  bool get isLargest => this == AppFabSize.large;

  /// Індекс розміру (для серіалізації).
  int get index => AppFabSize.values.indexOf(this);

  /// Коефіціент масштабування іконки відносно medium.
  double get iconScaleFactor => iconSize / AppFabSize.medium.iconSize;

  /// Коефіцієнт масштабування кнопки відносно medium.
  double get dimensionScaleFactor => dimension / AppFabSize.medium.dimension;

  /// Площа кнопки у квадратних пікселях.
  double get area => dimension * dimension;

  /// Радиус кнопки (половина розміру).
  double get radius => dimension / 2;

  /// Чи розмір підходить для compact-інтерфейсів.
  bool get isCompact => this == AppFabSize.xs || this == AppFabSize.small;

  /// Наступний розмір за зростанням (null для найбільшого).
  AppFabSize? get nextLarger {
    if (isLargest) return null;
    return AppFabSize.values[index + 1];
  }

  /// Попередній розмір за спаданням (null для найменшого).
  AppFabSize? get nextSmaller {
    if (isSmallest) return null;
    return AppFabSize.values[index - 1];
  }

  /// Повертає розмір у вигляді рядка для debug.
  String get debugString => 'AppFabSize($label, ${dimension}px, icon ${iconSize}px)';
}

// ─── FAB Variant Extensions ────────────────────────────────────────────────────

/// Розширення для [AppFabVariant] з computed properties.
extension AppFabVariantExtensions on AppFabVariant {
  /// Чи цей варіант підтримує бейджі.
  bool get supportsBadge =>
      this == AppFabVariant.notification ||
      this == AppFabVariant.standard ||
      this == AppFabVariant.loading ||
      this == AppFabVariant.mini;

  /// Чи цей варіант підтримує підменю (speed dial).
  bool get hasSubmenu => this == AppFabVariant.speedDial;

  /// Чи цей варіант підтримує текстову мітку.
  bool get supportsLabel =>
      this == AppFabVariant.extended ||
      this == AppFabVariant.standard ||
      this == AppFabVariant.speedDial;

  /// Чи цей варіант має індикатор стану.
  bool get hasStateIndicator =>
      this == AppFabVariant.loading;

  /// Чи цей варіант має нотифікаційну іконку.
  bool get isNotificationBased =>
      this == AppFabVariant.notification;

  /// Чи цей варіант є компактним (без тіні, менший).
  bool get isCompact =>
      this == AppFabVariant.mini;

  /// Індекс варіанту (для серіалізації).
  int get index => AppFabVariant.values.indexOf(this);

  /// Опис можливостей варіанту для debug.
  String get capabilities {
    final parts = <String>[];
    if (supportsBadge) parts.add('badge');
    if (supportsLabel) parts.add('label');
    if (hasSubmenu) parts.add('submenu');
    if (hasStateIndicator) parts.add('state');
    if (isCompact) parts.add('compact');
    return parts.join(', ');
  }
}

// ─── FAB Theme Extensions ─────────────────────────────────────────────────────

/// Розширення для [AppFabTheme] з computed properties.
extension AppFabThemeExtensions on AppFabTheme {
  /// Чи ця тема є "небезпечною" (error, warning).
  bool get isDestructive =>
      this == AppFabTheme.error || this == AppFabTheme.warning;

  /// Чи ця тема є "позитивною" (success, accent).
  bool get isPositive =>
      this == AppFabTheme.success || this == AppFabTheme.accent;

  /// Чи ця тема є нейтральною (primary, secondary).
  bool get isNeutral =>
      this == AppFabTheme.primary || this == AppFabTheme.secondary;

  /// Індекс теми (для серіалізації).
  int get index => AppFabTheme.values.indexOf(this);

  /// Наступна тема за списком (циклічно).
  AppFabTheme get next => AppFabTheme.values[(index + 1) % AppFabTheme.values.length];

  /// Попередня тема за списком (циклічно).
  AppFabTheme get previous =>
      AppFabTheme.values[(index - 1 + AppFabTheme.values.length) % AppFabTheme.values.length];

  /// Опис теми для debug-логування.
  String get debugString => 'AppFabTheme($label)';
}

// ─── Speed Dial Action Extensions ────────────────────────────────────────────

/// Розширення для [SpeedDialAction] з додатковими методами.
extension SpeedDialActionExtensions on SpeedDialAction {
  /// Чи ця дія має кастомний стиль.
  bool get hasCustomColor => color != null;

  /// Чи ця дія має підказку.
  bool get hasTooltip => tooltip != null;

  /// Створює копію з оновленими параметрами.
  SpeedDialAction copyWith({
    IconData? icon,
    String? label,
    VoidCallback? onTap,
    Color? color,
    String? tooltip,
  }) {
    return SpeedDialAction(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      onTap: onTap ?? this.onTap,
      color: color ?? this.color,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  /// Опис дії для debug.
  String get debugDescription {
    return 'SpeedDialAction($label, color: $color, tooltip: $tooltip)';
  }

  /// Створює [SpeedDialAction] з нульовим callback (для prototyping).
  SpeedDialAction get asPrototype => copyWith(onTap: () {});
}

// ─── FAB Animation Helpers ──────────────────────────────────────────────────────

/// Допоміжний клас для анімацій FAB.
///
/// Надає заздалегідь налаштовані криві, тривалості
/// та tween-об'єкти для всіх анімацій FAB.
class AppFabAnimationHelpers {
  AppFabAnimationHelpers._();

  /// Крива для bounce-анімації.
  static const Curve bounceCurve = Curves.elasticOut;

  /// Крива для згортання speed dial.
  static const Curve speedDialCollapseCurve = Curves.easeInBack;

  /// Крива для розгортання speed dial.
  static const Curve speedDialExpandCurve = Curves.easeOutBack;

  /// Крива для появи FAB.
  static const Curve appearCurve = Curves.easeOutBack;

  /// Крива для зникнення FAB.
  static const Curve disappearCurve = Curves.easeInBack;

  /// Крива для badge-анімації.
  static const Curve badgeCurve = AppEasings.subtlePop;

  /// Крива для long press label.
  static const Curve longPressCurve = Curves.easeOutCubic;

  /// Створює bounce tween (0 → maxScale → 1).
  static Tween<double> bounceTween({
    double maxScale = AppFabConstants.bounceMaxScale,
  }) {
    return Tween<double>(begin: 1.0, end: maxScale);
  }

  /// Створює fade tween для появи/зникнення.
  static Tween<double> fadeTween() {
    return Tween<double>(begin: 0.0, end: 1.0);
  }

  /// Створює tween для badge scale-анімації.
  static Tween<double> badgeScaleTween() {
    return Tween<double>(begin: 0.0, end: 1.0);
  }

  /// Обчислює загальну тривалість анімації speed dial
  /// залежно від кількості дій.
  static Duration totalSpeedDialDuration(int actionCount) {
    final expand = AppFabConstants.speedDialExpandDuration;
    final stagger = Duration(
      milliseconds: (AppFabConstants.speedDialStaggerDelay * 1000 * actionCount).round(),
    );
    return expand + stagger;
  }
}

// ─── FAB Accessibility Helpers ─────────────────────────────────────────────────

/// Допоміжні методи для accessibility FAB.
///
/// Генерує семантичні мітки, описи та налаштування для TalkBack/VoiceOver.
class AppFabAccessibility {
  AppFabAccessibility._();

  /// Створює семантичну мітку для FAB.
  ///
  /// Якщо [customLabel] не надано, генерує на основі варіанту та теми.
  static String buildSemanticLabel({
    AppFabVariant variant,
    AppFabTheme? fabTheme,
    String? label,
    String? tooltipText,
    int? badgeCount,
    bool isLoading = false,
  }) {
    if (label != null) return label;

    final parts = <String>[];

    switch (variant) {
      case AppFabVariant.standard:
        parts.add('Кнопка дії');
        break;
      case AppFabVariant.mini:
        parts.add('Міні-кнопка');
        break;
      case AppFabVariant.extended:
        parts.add('Кнопка: ${label ?? "дія"}');
        break;
      case AppFabVariant.notification:
        parts.add('Сповіщення');
        if (badgeCount != null && badgeCount > 0) {
          parts.add('$badgeCount unread');
        }
        break;
      case AppFabVariant.speedDial:
        parts.add('Меню дій');
        break;
      case AppFabVariant.loading:
        parts.add('Завантаження…');
        break;
    }

    if (isLoading) {
      parts.add('завантаження');
    }

    return parts.join('. ');
  }

  /// Повертає опис для tooltip на основі стану FAB.
  static String buildTooltip({
    required String? tooltipText,
    required String? label,
    required AppFabVariant variant,
    int? badgeCount,
    bool isLoading = false,
  }) {
    if (tooltipText != null) return tooltipText;

    if (isLoading) return 'Обробка…';
    if (variant == AppFabVariant.notification && badgeCount != null) {
      return '$badgeCount непрочитаних';
    }
    if (label != null) return label;

    switch (variant) {
      case AppFabVariant.speedDial:
        return 'Відкрити меню';
      case AppFabVariant.extended:
        return label ?? 'Дія';
      case AppFabVariant.mini:
        return 'Дія';
      case AppFabVariant.loading:
        return 'Завантаження…';
      default:
        return 'Дія';
    }
  }

  /// Створює мапу Semantics для FAB-віджета.
  static Map<String, String> buildSemanticsMap({
    required String label,
    required bool isEnabled,
    required bool isLoading,
    int? badgeCount,
  }) {
    return {
      'button': label,
      'state': isLoading ? 'loading' : (isEnabled ? 'enabled' : 'disabled'),
      if (badgeCount != null && badgeCount > 0) 'badge': '$badgeCount unread',
    };
  }
}

// ─── FAB Computed Props ─────────────────────────────────────────────────────────

/// Допоміжні обчислювані властивості для FAB.
///
/// Надає зручні getters для визначення стану FAB
/// на основі комбінації параметрів.
class AppFabComputedProps {
  AppFabComputedProps._();

  /// Визначає, чи FAB в інтерактивному стані.
  static bool isInteractive({
    required AppFabVariant variant,
    required bool isLoading,
    required bool isVisible,
  }) {
    return isVisible && !isLoading;
  }

  /// Визначає, чи FAB показує будь-який бейдж.
  static bool showsBadge({
    required AppFabVariant variant,
    required int? badgeCount,
  }) {
    return badgeCount != null && badgeCount > 0 && variant.supportsBadge;
  }

  /// Визначає ефективний розмір з урахуванням variant.
  ///
  /// Mini варіант завжди використовує small розмір.
  static double effectiveDimension({
    required AppFabSize size,
    required AppFabVariant variant,
  }) {
    if (variant == AppFabVariant.mini && size.index > AppFabSize.small.index) {
      return AppFabSize.small.dimension;
    }
    return size.dimension;
  }

  /// Обчислює відступ знизу з урахуванням notchOffset.
  static double bottomInset({
    required double notchOffset,
    required AppFabVariant variant,
  }) {
    final base = variant == AppFabVariant.speedDial
        ? AppFabConstants.centeredNotchBottomInset
        : AppFabConstants.standardBottomInset;
    return base + notchOffset;
  }

  /// Визначає, чи FAB потребує backdrop (напівпрозорий оверлей).
  static bool requiresBackdrop({
    required AppFabVariant variant,
    required bool isSpeedDialOpen,
  }) {
    return variant == AppFabVariant.speedDial && isSpeedDialOpen;
  }

  /// Обчислює загальну висоту speed dial меню з усіма діями.
  static double speedDialHeight(int actionCount) {
    return actionCount * AppFabConstants.speedDialItemSpacing +
        AppFabConstants.speedDialItemSpacing; // for main FAB
  }

  /// Визначає кількість видимих бейджів для display.
  static String badgeDisplayText(int count) {
    if (count <= 0) return '';
    if (count > AppFabConstants.maxBadgeCount) return '${AppFabConstants.maxBadgeCount}+';
    return '$count';
  }
}

// ─── FAB Debug Helper ───────────────────────────────────────────────────────

/// Допоміжний клас для debug-логування FAB.
///
/// Генерує структуровані звіти про стан FAB
/// для використання під час розробки.
class AppFabDebugHelper {
  AppFabDebugHelper._();

  /// Генерує повний debug-звіт для FAB.
  static String generateReport({
    required AppFabVariant variant,
    required AppFabSize size,
    required AppFabTheme theme,
    required bool isLightTheme,
    int? badgeCount,
    String? label,
    bool? isLoading,
    bool? isVisible,
    int? speedDialCount,
    double? notchOffset,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('╔─ AppFab Debug Report ─');
    buffer.writeln('  variant: ${variant.label}');
    buffer.writeln('  size: ${size.label} (${size.dimension}px)');
    buffer.writeln('  theme: ${theme.label}');
    buffer.writeln('  themeMode: ${isLightTheme ? 'light' : 'dark'}');
    if (badgeCount != null) {
      buffer.writeln('  badgeCount: $badgeCount');
    }
    if (label != null) {
      buffer.writeln('  label: "$label"');
    }
    if (isLoading != null) {
      buffer.writeln('  isLoading: $isLoading');
    }
    if (isVisible != null) {
      buffer.writeln('  isVisible: $isVisible');
    }
    if (speedDialCount != null) {
      buffer.writeln('  speedDialActions: $speedDialCount');
    }
    if (notchOffset != null) {
      buffer.writeln('  notchOffset: ${notchOffset}px');
    }
    return buffer.toString();
  }

  /// Генерує компактний one-line звіт для FAB.
  static String compactReport({
    required AppFabVariant variant,
    required AppFabSize size,
    bool isLoading = false,
  }) {
    return 'FAB(${variant.name}, ${size.label}${isLoading ? ', loading' : ''})';
  }

  /// Генерує JSON-сумісний звіт для аналізу.
  static Map<String, dynamic> toJsonMap({
    required AppFabVariant variant,
    required AppFabSize size,
    required AppFabTheme theme,
    bool isLightTheme = false,
    int? badgeCount,
  }) {
    return {
      'variant': variant.name,
      'size': size.dimension,
      'iconSize': size.iconSize,
      'theme': theme.name,
      'themeMode': isLightTheme ? 'light' : 'dark',
      'badgeCount': badgeCount,
      'supportsBadge': variant.supportsBadge,
      'hasSubmenu': variant.hasSubmenu,
    };
  }
}

// ─── FAB Serialization Helper ──────────────────────────────────────────────────

/// Допоміжні методи для серіалізації/десеріалізації FAB-параметрів.
///
/// Використовується для збереження стану FAB у SharedPreferences
/// або передачі між екранами.
class AppFabSerialization {
  AppFabSerialization._();

  /// Ключі для SharedPreferences.
  static const String prefKeyVariant = 'fab_variant';
  static const String prefKeySize = 'fab_size';
  static const String prefKeyTheme = 'fab_theme';
  static const String prefKeyIsLight = 'fab_is_light';
  static const String prefKeyBadge = 'fab_badge';

  /// Серіалізує розмір FAB у рядок.
  static String sizeToString(AppFabSize size) => size.name;

  /// Десеріалізує розмір FAB з рядка.
  static AppFabSize? sizeFromString(String value) {
    try {
      return AppFabSize.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  /// Серіалізує варіант FAB у рядок.
  static String variantToString(AppFabVariant variant) => variant.name;

  /// Десеріалізує варіант FAB з рядка.
  static AppFabVariant? variantFromString(String value) {
    try {
      return AppFabVariant.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  /// Серіалізує тему FAB у рядок.
  static String themeToString(AppFabTheme theme) => theme.name;

  /// Десеріалізує тему FAB з рядка.
  static AppFabTheme? themeFromString(String value) {
    try {
      return AppFabTheme.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  /// Перевіряє, чи рядок є валідним іменем варіанту.
  static bool isValidVariantName(String value) {
    return variantFromString(value) != null;
  }

  /// Перевіряє, чи рядок є валідним іменем розміру.
  static bool isValidSizeName(String value) {
    return sizeFromString(value) != null;
  }

  /// Перевіряє, чи рядок є валідним іменем теми.
  static bool isValidThemeName(String value) {
    return themeFromString(value) != null;
  }

  /// Повертає список усіх доступних імен варіантів.
  static List<String> allVariantNames =>
      AppFabVariant.values.map((e) => e.name).toList();

  /// Повертає список усіх доступних імен розмірів.
  static List<String> allSizeNames =>
      AppFabSize.values.map((e) => e.name).toList();

  /// Повертає список усіх доступних імен тем.
  static List<String> allThemeNames =>
      AppFabTheme.values.map((e) => e.name).toList();

  /// Створює карту параметрів для збереження.
  static Map<String, String> toPrefsMap({
    required AppFabVariant variant,
    required AppFabSize size,
    required AppFabTheme theme,
    required bool isLightTheme,
    int? badgeCount,
  }) {
    return {
      prefKeyVariant: variantToString(variant),
      prefKeySize: sizeToString(size),
      prefKeyTheme: themeToString(theme),
      prefKeyIsLight: isLightTheme.toString(),
      if (badgeCount != null) prefKeyBadge: badgeCount.toString(),
    };
  }

  /// Відновлює параметри з карти SharedPreferences.
  static AppFabPrefsData fromPrefsMap(Map<String, dynamic> map) {
    return AppFabPrefsData(
      variant: variantFromString(map[prefKeyVariant] as String?),
      size: sizeFromString(map[prefKeySize] as String?),
      theme: themeFromString(map[prefKeyTheme] as String?),
      isLightTheme: map[prefKeyIsLight] as bool? ?? false,
      badgeCount: map[prefKeyBadge] as int?,
    );
  }
}

/// Дані FAB, десеріалізовані з SharedPreferences.
class AppFabPrefsData {
  const AppFabPrefsData({
    this.variant,
    this.size,
    this.theme,
    this.isLightTheme,
    this.badgeCount,
  });

  final AppFabVariant? variant;
  final AppFabSize? size;
  final AppFabTheme? theme;
  final bool isLightTheme;
  final int? badgeCount;

  /// Чи всі параметри були успішно десеріалізовані.
  bool get isFullyLoaded =>
      variant != null && size != null && theme != null;

  /// Повертає опис для debug.
  String get debugDescription {
    return 'AppFabPrefsData(variant: ${variant?.name}, '
        'size: ${size?.name}, theme: ${theme?.name}, '
        'light: $isLightTheme, badge: $badgeCount)';
  }

  /// Створює копію з оновленими параметрами.
  AppFabPrefsData copyWith({
    AppFabVariant? variant,
    AppFabSize? size,
    AppFabTheme? theme,
    bool? isLightTheme,
    int? badgeCount,
  }) {
    return AppFabPrefsData(
      variant: variant ?? this.variant,
      size: size ?? this.size,
      theme: theme ?? this.theme,
      isLightTheme: isLightTheme ?? this.isLightTheme,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}

// ─── FAB Gesture Helpers ──────────────────────────────────────────────────────

/// Допоміжні методи для роботи з жестами FAB.
///
/// Надає перевірки та конфігурацію для різних типів натискань.
class AppFabGestureHelper {
  AppFabGestureHelper._();

  /// Мінімальна тривалість натискання для визнання short tap (vs long press).
  static const Duration shortTapThreshold = Duration(milliseconds: 200);

  /// Мінімальна тривалість натискання для визнання long press.
  static const Duration longPressThreshold = Duration(milliseconds: 500);

  /// Коефіціент затримки debounce для повторних натискань.
  static const Duration tapDebounce = Duration(milliseconds: 300);

  /// Максимальна відстань для визнання drag-жесту (пікселі).
  static const double dragThreshold = 16.0;

  /// Чи тривалість вказує на long press.
  static bool isLongPress(Duration elapsed) {
    return elapsed >= longPressThreshold;
  }

  /// Чи тривалість вказує на short tap.
  static bool isShortTap(Duration elapsed) {
    return elapsed < shortTapThreshold;
  }

  /// Чи тривалість між short та long press (незрозмірний жест).
  static bool isAmbiguous(Duration elapsed) {
    return elapsed >= shortTapThreshold && elapsed < longPressThreshold;
  }

  /// Повертає тип жесту на основі тривалості.
  static String classifyGesture(Duration elapsed) {
    if (isShortTap(elapsed)) return 'shortTap';
    if (isLongPress(elapsed)) return 'longPress';
    return 'ambiguous';
  }

  /// Обчислює швидкість жесту (px/s).
  static double computeVelocity(double distance, Duration duration) {
    if (duration.inMilliseconds == 0) return 0.0;
    return distance / (duration.inMilliseconds / 1000);
  }

  /// Визначає, чи жест є "швидким свайпом" (для dismiss).
  static bool isQuickSwipe(double distance, Duration duration) {
    final velocity = computeVelocity(distance, duration);
    return velocity > 300 && distance > 50;
  }

  /// Обчислює delta між двома точками.
  static double computeDelta(Offset start, Offset end) {
    return (end - start).distance;
  }

  /// Напрям жесту (горизонтальний, вертикальний, невизначений).
  static String gestureDirection(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs() * 2) {
      return delta.dx > 0 ? 'right' : 'left';
    } else if (delta.dy.abs() > delta.dx.abs() * 2) {
      return delta.dy > 0 ? 'down' : 'up';
    }
    return 'unknown';
  }
}

// ─── FAB Responsive Builder ────────────────────────────────────────────────────

/// Створює адаптивний layout з FAB залежно від розміру екрана.
///
/// Автоматично обирає розмір, позиціонування та variant
/// на основі медіа-запитів.
class AppFabResponsiveBuilder {
  AppFabResponsiveBuilder._();

  /// Створює адаптивний FAB для переданого контексту.
  static AppFab build({
    required BuildContext context,
    required VoidCallback onPressed,
    AppFabTheme theme = AppFabTheme.primary,
    AppFabVariant variant = AppFabVariant.standard,
    IconData? icon,
    String? label,
    int? badgeCount,
    Color? color,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth >= 768;
    final isCompact = screenWidth < 360;

    final effectiveSize = isCompact
        ? AppFabSize.small
        : (isTablet ? AppFabSize.large : AppFabSize.medium);

    final effectiveVariant = isCompact && variant == AppFabVariant.extended
        ? AppFabVariant.standard
        : variant;

    return AppFab(
      onPressed: onPressed,
      size: effectiveSize,
      fabTheme: theme,
      variant: effectiveVariant,
      icon: icon,
      label: label,
      badgeCount: badgeCount,
      fabColor: color,
    );
  }

  /// Створює адаптивний speed dial FAB для планшетів.
  static AppFab buildSpeedDial({
    required BuildContext context,
    required List<SpeedDialAction> actions,
    required VoidCallback onPressed,
    AppFabTheme theme = AppFabTheme.primary,
    int maxActionsOnPhone = 3,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth >= 768;

    final effectiveActions = isTablet
        ? actions
        : actions.take(maxActionsOnPhone).toList();

    return AppFab(
      onPressed: onPressed,
      variant: AppFabVariant.speedDial,
      speedDialActions: effectiveActions,
      fabTheme: theme,
      size: isTablet ? AppFabSize.large : AppFabSize.medium,
    );
  }

  /// Створює адаптивний notification FAB для планшетів.
  static AppFab buildNotification({
    required BuildContext context,
    required VoidCallback onPressed,
    required int count,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 768;

    return AppFab(
      onPressed: onPressed,
      variant: AppFabVariant.notification,
      badgeCount: count,
      icon: Icons.notifications_rounded,
      size: isTablet ? AppFabSize.large : AppFabSize.medium,
    );
  }

  /// Обчислює оптимальні відступи залежно від розміру екрана.
  static EdgeInsets adaptiveMargin({
    required BuildContext context,
    EdgeInsets? baseMargin,
    bool hasBottomBar = true,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    if (baseMargin != null) return baseMargin;

    if (hasBottomBar) {
      return EdgeInsets.only(
        right: 16,
        bottom: 80 + bottomPadding,
      );
    }
    return const EdgeInsets.only(right: 16, bottom: 16);
  }
}

// ─── FAB Color Interpolation ────────────────────────────────────────────────────

/// Інструменти для інтерполяції кольорів FAB між станами.
///
/// Використовується для плавних переходів між темами
/// або анімацій зміни кольору.
class AppFabColorInterpolation {
  AppFabColorInterpolation._();

  /// Лінійно інтерполяє два кольори.
  static Color lerp(Color a, Color b, double t) {
    return Color.lerp(a, b, t.clamp(0.0, 1.0));
  }

  /// Інтерполює між двома темами FAB залежно від progress.
  static Color lerpThemes({
    required AppFabTheme from,
    required AppFabTheme to,
    required double progress,
    required AppFabSize size,
    required bool isLightTheme,
  }) {
    final fromColor = isLightTheme
        ? from.lightColor(size)
        : from.darkColor(size);
    final toColor = isLightTheme
        ? to.lightColor(size)
        : to.darkColor(size);
    return Color.lerp(fromColor, toColor, progress.clamp(0.0, 1.0));
  }

  /// Інтерполює між світлою та темною темою для однієї і тієї ж теми FAB.
  static Color lerpLightDark({
    required AppFabTheme theme,
    required AppFabSize size,
    required double progress,
  }) {
    final light = theme.lightColor(size);
    final dark = theme.darkColor(size);
    return Color.lerp(light, dark, progress.clamp(0.0, 1.0));
  }

  /// Створює градієнтний BoxShadow для FAB.
  static BoxShadow gradientShadow(Color color, double progress) {
    return BoxShadow(
      color: color.withOpacity(0.3 * progress),
      blurRadius: 8 + 4 * progress,
      offset: Offset(0, 2 + 2 * progress),
    );
  }

  /// Обчислює opacity для badge-тіні залежно від кількості.
  static double badgeShadowOpacity(int count) {
    if (count <= 0) return 0.0;
    if (count <= 10) return 0.2;
    if (count <= 50) return 0.3;
    return 0.4;
  }
}

// ─── FAB State Machine ────────────────────────────────────────────────────────

/// Простий станевий автомат для FAB.
///
/// Відстежує переходи між станами:
/// idle → pressed → bouncing → idle
/// idle → loading → idle
/// idle → speedDialOpen → speedDialClosed
enum FabState {
  /// FAB у спокійному стані.
  idle,

  /// FAB натиснутий.
  pressed,

  /// FAB в стані bounce-анімації.
  bouncing,

  /// FAB у стані завантаження.
  loading,

  /// Speed dial меню відкрите.
  speedDialOpen,

  /// Speed dial меню закрито.
  speedDialClosed,
}

/// Керуючий станами FAB для debounce/throttle логіки.
class FabStateMachine {
  FabStateMachine();

  FabState _state = FabState.idle;
  DateTime? _lastTapTime;
  DateTime? _lastLongPressTime;

  /// Поточний стан FAB.
  FabState get state => _state;

  /// Чи FAB зараз інтерактивний.
  bool get isInteractive => _state == FabState.idle;

  /// Чи FAB в анімації.
  bool get isAnimating =>
      _state == FabState.bouncing ||
      _state == FabState.speedDialOpen ||
      _state == FabState.speedDialClosed;

  /// Обробляє натискання на FAB.
  void onTap() {
    _lastTapTime = DateTime.now();
    _transition(FabState.pressed);
    _transition(FabState.bouncing);
    _transition(FabState.idle);
  }

  /// Обробляє початок завантаження.
  void startLoading() {
    _transition(FabState.loading);
  }

  /// Обробляє завершення завантаження.
  void finishLoading() {
    _transition(FabState.idle);
  }

  /// Обробляє відкриття speed dial.
  void openSpeedDial() {
    _transition(FabState.speedDialOpen);
  }

  /// Обробляє закриття speed dial.
  void closeSpeedDial() {
    _transition(FabState.speedDialClosed);
  }

  /// Задає стан явно (для тестування).
  void forceState(FabState state) {
    _state = state;
  }

  /// Виконує перехід між станами.
  void _transition(FabState newState) {
    _state = newState;
  }

  /// Обчислює час з останнього натискання.
  Duration? timeSinceLastTap() {
    if (_lastTapTime == null) return null;
    return DateTime.now().difference(_lastTapTime!);
  }

  /// Обчислює час з останнього довгого натискання.
  Duration? timeSinceLastLongPress() {
    if (_lastLongPressTime == null) return null;
    return DateTime.now().difference(_lastLongPressTime!);
  }

  /// Опис поточного стану для debug.
  String get debugState {
    return 'FabStateMachine(state: ${_state.name})';
  }

  /// Повертає історію переходів для debug.
  String debugHistory() {
    return 'FabStateMachine(current: ${_state.name})';
  }
}

// ─── FAB State Info (Computed Props) ─────────────────────────────────────────

/// Клас з обчислюваними властивостями для аналізу стану FAB.
///
/// Надає зручні computed-гетери для перевірки поточного стану
/// FAB-віджета, аналізу видимості, активності, та сполучуваності параметрів.
class AppFabStateInfo {
  AppFabStateInfo({
    required this.variant,
    required this.size,
    required this.fabTheme,
    required this.isVisible,
    required this.isLoading,
    required this.isExtended,
    required this.badgeCount,
    required this.hasSpeedDialActions,
    required this.hasCustomColor,
    required this.hasCustomLabel,
    required this.hasLongPress,
    required this.isLightTheme,
    this.speedDialActionCount = 0,
    this.customDimension,
    this.labelLength = 0,
  });

  /// Варіант відображення.
  final AppFabVariant variant;

  /// Розмір кнопки.
  final AppFabSize size;

  /// Кольорова тема.
  final AppFabTheme fabTheme;

  /// Чи кнопка видима.
  final bool isVisible;

  /// Чи кнопка в стані завантаження.
  final bool isLoading;

  /// Чи кнопка розгорнута.
  final bool isExtended;

  /// Кількість бейджів.
  final int? badgeCount;

  /// Чи є speed dial дії.
  final bool hasSpeedDialActions;

  /// Чи встановлено кастомний колір.
  final bool hasCustomColor;

  /// Чи встановлено кастомну мітку.
  final bool hasCustomLabel;

  /// Чи встановлено long press handler.
  final bool hasLongPress;

  /// Світла тема.
  final bool isLightTheme;

  /// Кількість speed dial дій.
  final int speedDialActionCount;

  /// Кастомний розмір (якщо перевизначено).
  final double? customDimension;

  /// Довжина мітки.
  final int labelLength;

  // ─── Computed: Видимість ──────────────────────────────────────────────

  /// Чи FAB активний (видимий і не завантажується).
  bool get isInteractive => isVisible && !isLoading;

  /// Чи FAB повністю прихований.
  bool get isHidden => !isVisible;

  /// Чи FAB заблокований (завантажується або прихований).
  bool get isDisabled => isLoading || !isVisible;

  /// Рівень активності FAB.
  ///
  /// Повертає від 0.0 (повністю неактивний) до 1.0 (повністю активний).
  double get activityLevel {
    if (isInteractive) return 1.0;
    if (isLoading && isVisible) return 0.5;
    return 0.0;
  }

  // ─── Computed: Контент ────────────────────────────────────────────────

  /// Чи FAB має бейдж.
  bool get hasBadge => badgeCount != null && badgeCount! > 0;

  /// Чи FAB має текстовий контент.
  bool get hasTextContent => hasCustomLabel || isExtended;

  /// Чи FAB має багатий контент (badge + text + long press).
  bool get isRich => hasBadge && hasTextContent && hasLongPress;

  /// Кількість елементів контенту на FAB.
  int get contentElementCount {
    var count = 1; // іконка завжди є
    if (hasBadge) count++;
    if (hasTextContent) count++;
    if (hasLongPress) count++;
    return count;
  }

  /// Чи текст мітки занадто довгий для extended FAB.
  bool get isLabelTooLong =>
      labelLength > AppFabConstants.maxExtendedLabelLength;

  /// Чи label порожній (для extended).
  bool get isLabelEmpty => labelLength == 0;

  // ─── Computed: Speed Dial ─────────────────────────────────────────────

  /// Чи speed dial конфігурований коректно.
  bool get isSpeedDialConfigured =>
      variant == AppFabVariant.speedDial &&
      hasSpeedDialActions &&
      AppFabValidation.isValidSpeedDialCount(speedDialActionCount);

  /// Чи speed dial перевищує ліміт дій.
  bool get isSpeedDialOverLimit =>
      speedDialActionCount > AppFabConstants.maxSpeedDialActions;

  /// Кількість видимих speed dial дій (обмежено лімітом).
  int get visibleSpeedDialCount =>
      speedDialActionCount.clamp(0, AppFabConstants.maxSpeedDialActions);

  // ─── Computed: Розміри ───────────────────────────────────────────────

  /// Ефективний розмір кнопки у пікселях.
  double get effectiveDimension =>
      customDimension ?? size.dimension;

  /// Чи розмір FAB в допустимих межах.
  bool get isDimensionValid =>
      AppFabValidation.isValidDimension(effectiveDimension);

  /// Фактор масштабу іконки відносно стандартного (24px).
  double get iconScaleFactor => size.iconSize / 24.0;

  /// Площа кнопки у квадратних пікселях.
  double get area => effectiveDimension * effectiveDimension;

  /// Відношення іконки до кнопки.
  double get iconToButtonRatio => size.iconSize / effectiveDimension;

  // ─── Computed: Тема ───────────────────────────────────────────────────

  /// Назва теми інтерфейсу (українською).
  String get themeDescription => isLightTheme ? 'Світла' : 'Темна';

  /// Повний опис стану FAB для debug.
  String get debugSummary {
    return 'AppFabStateInfo('
        'variant: ${variant.label}, '
        'size: ${size.label}, '
        'theme: ${fabTheme.label}, '
        'visible: $isVisible, '
        'loading: $isLoading, '
        'badge: $badgeCount, '
        'interactive: $isInteractive, '
        'uiTheme: $themeDescription)';
  }

  /// Повертає список попереджень про конфігурацію.
  List<String> get warnings {
    final warnings = <String>[];
    if (isLabelTooLong) {
      warnings.add('Мітка занадто довга (${labelLength} символів)');
    }
    if (isSpeedDialOverLimit) {
      warnings.add(
          'Кількість speed dial дій перевищує ліміт ($speedDialActionCount)');
    }
    if (!isDimensionValid) {
      warnings.add('Некоректний розмір: $effectiveDimension px');
    }
    if (variant == AppFabVariant.speedDial && !hasSpeedDialActions) {
      warnings.add('Speed Dial без дій');
    }
    if (variant == AppFabVariant.notification && !hasBadge) {
      warnings.add('Notification FAB без бейджу');
    }
    return warnings;
  }

  /// Чи конфігурація FAB коректна (без попереджень).
  bool get isValid => warnings.isEmpty;

  /// Рівень складності FAB (для аналізу).
  ///
  /// Від 0 (мінімальний standard) до 10 (повний speed dial з усім).
  int get complexityScore {
    var score = 0;
    if (hasBadge) score += 1;
    if (isExtended) score += 1;
    if (hasLongPress) score += 1;
    if (hasCustomColor) score += 1;
    if (isLoading) score += 1;
    if (hasSpeedDialActions) score += 3;
    if (variant == AppFabVariant.speedDial) score += 2;
    return score;
  }
}

// ─── FAB Animation Config Builder ────────────────────────────────────────────

/// Конфігурація анімацій для FAB.
///
/// Допомагає створювати та керувати анімаціями FAB:
/// bounce, appear/disappear, speed dial розгортання, badge появу.
class AppFabAnimationConfig {
  AppFabAnimationConfig({
    this.bounceDuration = AppFabConstants.bounceDuration,
    this.bounceMaxScale = AppFabConstants.bounceMaxScale,
    this.appearDuration = const Duration(milliseconds: 300),
    this.disappearDuration = const Duration(milliseconds: 200),
    this.speedDialExpandDuration = AppFabConstants.speedDialExpandDuration,
    this.speedDialCollapseDuration = AppFabConstants.speedDialCollapseDuration,
    this.speedDialStaggerDelay = AppFabConstants.speedDialStaggerDelay,
    this.longPressLabelDuration = AppFabConstants.longPressLabelDuration,
    this.badgeAppearDuration = const Duration(milliseconds: 150),
    this.badgeCurve = AppEasings.subtlePop,
  });

  /// Тривалість bounce-анімації.
  final Duration bounceDuration;

  /// Максимальний масштаб bounce.
  final double bounceMaxScale;

  /// Тривалість появи FAB.
  final Duration appearDuration;

  /// Тривалість зникнення FAB.
  final Duration disappearDuration;

  /// Тривалість розгортання speed dial.
  final Duration speedDialExpandDuration;

  /// Тривалість згортання speed dial.
  final Duration speedDialCollapseDuration;

  /// Затримка між появою speed dial елементів.
  final double speedDialStaggerDelay;

  /// Тривалість появи long press label.
  final Duration longPressLabelDuration;

  /// Тривалість появи badge.
  final Duration badgeAppearDuration;

  /// Крива анімації badge.
  final Curve badgeCurve;

  /// Створює конфігурацію з швидкими анімаціями (для тестування).
  factory AppFabAnimationConfig.fast() {
    return AppFabAnimationConfig(
      bounceDuration: const Duration(milliseconds: 80),
      appearDuration: const Duration(milliseconds: 100),
      disappearDuration: const Duration(milliseconds: 80),
      speedDialExpandDuration: const Duration(milliseconds: 120),
      speedDialCollapseDuration: const Duration(milliseconds: 80),
      speedDialStaggerDelay: 0.05,
      longPressLabelDuration: const Duration(milliseconds: 80),
      badgeAppearDuration: const Duration(milliseconds: 60),
    );
  }

  /// Створює конфігурацію без анімацій (для accessibility).
  factory AppFabAnimationConfig.none() {
    return AppFabAnimationConfig(
      bounceDuration: Duration.zero,
      appearDuration: Duration.zero,
      disappearDuration: Duration.zero,
      speedDialExpandDuration: Duration.zero,
      speedDialCollapseDuration: Duration.zero,
      speedDialStaggerDelay: 0.0,
      longPressLabelDuration: Duration.zero,
      badgeAppearDuration: Duration.zero,
    );
  }

  /// Створює конфігурацію з повільними анімаціями (для презентацій).
  factory AppFabAnimationConfig.slow() {
    return AppFabAnimationConfig(
      bounceDuration: const Duration(milliseconds: 400),
      appearDuration: const Duration(milliseconds: 600),
      disappearDuration: const Duration(milliseconds: 400),
      speedDialExpandDuration: const Duration(milliseconds: 600),
      speedDialCollapseDuration: const Duration(milliseconds: 400),
      speedDialStaggerDelay: 0.2,
      longPressLabelDuration: const Duration(milliseconds: 400),
      badgeAppearDuration: const Duration(milliseconds: 300),
    );
  }

  /// Створює копію з оновленими параметрами.
  AppFabAnimationConfig copyWith({
    Duration? bounceDuration,
    double? bounceMaxScale,
    Duration? appearDuration,
    Duration? disappearDuration,
    Duration? speedDialExpandDuration,
    Duration? speedDialCollapseDuration,
    double? speedDialStaggerDelay,
    Duration? longPressLabelDuration,
    Duration? badgeAppearDuration,
    Curve? badgeCurve,
  }) {
    return AppFabAnimationConfig(
      bounceDuration: bounceDuration ?? this.bounceDuration,
      bounceMaxScale: bounceMaxScale ?? this.bounceMaxScale,
      appearDuration: appearDuration ?? this.appearDuration,
      disappearDuration: disappearDuration ?? this.disappearDuration,
      speedDialExpandDuration:
          speedDialExpandDuration ?? this.speedDialExpandDuration,
      speedDialCollapseDuration:
          speedDialCollapseDuration ?? this.speedDialCollapseDuration,
      speedDialStaggerDelay:
          speedDialStaggerDelay ?? this.speedDialStaggerDelay,
      longPressLabelDuration:
          longPressLabelDuration ?? this.longPressLabelDuration,
      badgeAppearDuration: badgeAppearDuration ?? this.badgeAppearDuration,
      badgeCurve: badgeCurve ?? this.badgeCurve,
    );
  }

  /// Чи всі анімації вимкнені.
  bool get isDisabled =>
      bounceDuration == Duration.zero && appearDuration == Duration.zero;

  /// Загальна тривалість повного циклу speed dial (expand + collapse).
  Duration get fullSpeedDialCycle =>
      speedDialExpandDuration + speedDialCollapseDuration;

  /// Тривалість появи останнього speed dial елемента.
  ///
  /// Обчислюється з урахуванням затримки між елементами.
  Duration get lastSpeedDialItemDuration {
    final itemCount = AppFabConstants.maxSpeedDialActions;
    final delayMs =
        (speedDialStaggerDelay * itemCount * 1000).round();
    return speedDialExpandDuration +
        Duration(milliseconds: delayMs);
  }

  /// Опис конфігурації для debug.
  String get debugDescription {
    return 'AppFabAnimationConfig('
        'bounce: ${bounceDuration.inMilliseconds}ms, '
        'appear: ${appearDuration.inMilliseconds}ms, '
        'speedDial: ${speedDialExpandDuration.inMilliseconds}ms, '
        'disabled: $isDisabled)';
  }
}

// ─── FAB Accessibility Helper ────────────────────────────────────────────────

/// Допоміжні методи для доступності FAB-віджета.
///
/// Генерує семантичні мітки, описи та повідомлення для TalkBack/VoiceOver.
class AppFabAccessibility {
  AppFabAccessibility._();

  /// Генерує семантичну мітку для FAB.
  ///
  /// Враховує варіант, стан та наявність бейджу.
  static String semanticLabelFor({
    required AppFabVariant variant,
    String? customLabel,
    int? badgeCount,
    bool isLoading = false,
    String? tooltipText,
  }) {
    if (customLabel != null) return customLabel;

    final parts = <String>[];

    switch (variant) {
      case AppFabVariant.standard:
        parts.add('Кнопка дії');
        break;
      case AppFabVariant.mini:
        parts.add('Міні-кнопка');
        break;
      case AppFabVariant.extended:
        parts.add('Розширена кнопка');
        break;
      case AppFabVariant.notification:
        parts.add('Сповіщення');
        break;
      case AppFabVariant.speedDial:
        parts.add('Швидкий набір');
        break;
      case AppFabVariant.loading:
        parts.add('Кнопка завантаження');
        break;
    }

    if (isLoading) {
      parts.add('Завантаження...');
    }

    if (badgeCount != null && badgeCount > 0) {
      parts.add('$badgeCount unread');
    }

    return parts.join('. ');
  }

  /// Генерує опис для long press дії.
  static String longPressHint({
    required AppFabVariant variant,
    String? longPressLabel,
    String? tooltipText,
  }) {
    if (longPressLabel != null) {
      return 'Утримайте: $longPressLabel';
    }
    if (tooltipText != null) {
      return 'Утримайте для деталей';
    }
    return 'Утримуйте для додаткових дій';
  }

  /// Генерує HintValue для accessibility.
  static String hintForVariant(AppFabVariant variant) {
    switch (variant) {
      case AppFabVariant.standard:
        return 'Натисніть для дії';
      case AppFabVariant.mini:
        return 'Міні-дія';
      case AppFabVariant.extended:
        return 'Натисніть для дії';
      case AppFabVariant.notification:
        return 'Натисніть для сповіщень';
      case AppFabVariant.speedDial:
        return 'Натисніть для швидкого набору';
      case AppFabVariant.loading:
        return 'Зачекайте завершення';
    }
  }

  /// Перевіряє, чи конфігурація FAB відповідає вимогам доступності.
  ///
  /// Повертає список проблем, якщо є.
  static List<String> checkAccessibility({
    required AppFabVariant variant,
    String? semanticLabel,
    double? customDimension,
    bool hasLongPress = false,
    bool enableHaptic = true,
  }) {
    final issues = <String>[];

    if (semanticLabel == null || semanticLabel.isEmpty) {
      issues.add('Відсутня семантична мітка (semanticLabel)');
    }

    if (customDimension != null &&
        customDimension < AppFabConstants.minDimension) {
      issues.add(
          'Кнопка замала для зручного натискання (${customDimension}px)');
    }

    if (hasLongPress && !enableHaptic) {
      issues.add(
          'Long press без тактильного відгуку може бути непомітним');
    }

    if (variant == AppFabVariant.speedDial) {
      issues.add(
          'Speed Dial потребує додаткового управління фокусом');
    }

    return issues;
  }

  /// Генерує повний accessibility-опис для налаштування екранних читачів.
  static Map<String, String> accessibilityMap({
    required AppFabVariant variant,
    required AppFabSize size,
    String? label,
    int? badgeCount,
    bool isLoading = false,
  }) {
    return {
      'label': semanticLabelFor(
        variant: variant,
        customLabel: label,
        badgeCount: badgeCount,
        isLoading: isLoading,
      ),
      'hint': hintForVariant(variant),
      'size': '${size.dimension}px',
      'variant': variant.name,
    };
  }
}

// ─── FAB Keyboard Helper ─────────────────────────────────────────────────────

/// Допоміжні методи для клавіатурної навігації FAB.
///
/// Надає callbacks для клавіатурних скорочень,
/// фокусування та навігації між FAB-кнопками.
class AppFabKeyboardHelper {
  AppFabKeyboardHelper._();

  /// Обробляє натискання клавіші для FAB.
  ///
  /// Повертає `true`, якщо клавіша була оброблена.
  static bool handleKeyEvent(
    KeyEvent event, {
    required VoidCallback onActivate,
    VoidCallback? onSecondary,
    VoidCallback? onLongPress,
  }) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        onActivate();
        return true;
      case LogicalKeyboardKey.tab:
        // Дозволяє стандартну навігацію
        return false;
      case LogicalKeyboardKey.shift:
      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        if (onSecondary != null) {
          onSecondary();
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  /// Створює FocusNode для FAB з callbacks.
  static FocusNode createFocusNode({
    VoidCallback? onFocusGained,
    VoidCallback? onFocusLost,
  }) {
    return FocusNode(
      onKeyEvent: (node, event) {
        // Обробка клавіатурних подій
        return false;
      },
    );
  }

  /// Повертає набір клавіатурних скорочень для FAB.
  static Map<LogicalKeyboardKey, String> shortcuts() {
    return {
      LogicalKeyboardKey.enter: 'Активувати FAB',
      LogicalKeyboardKey.space: 'Активувати FAB',
      LogicalKeyboardKey.escape: 'Закрити speed dial',
      LogicalKeyboardKey.tab: 'Наступний елемент',
    };
  }

  /// Перевіряє, чи клавіша є модифікатором.
  static bool isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.shift ||
        key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.alt ||
        key == LogicalKeyboardKey.meta;
  }
}

// ─── FAB Badge Helper ────────────────────────────────────────────────────────

/// Допоміжні методи для роботи з бейджами FAB.
class AppFabBadgeHelper {
  AppFabBadgeHelper._();

  /// Форматує текст бейджу.
  ///
  /// Якщо [count] > 99, повертає "99+".
  /// Інакше повертає рядкове представлення.
  static String formatBadgeCount(int count) {
    if (count > AppFabConstants.maxBadgeCount) return '99+';
    return '$count';
  }

  /// Обчислює розмір бейджу залежно від кількості.
  ///
  /// Більші числа потребують ширшого бейджу.
  static double badgeWidth(int count) {
    if (count <= 9) return 18.0;
    if (count <= 99) return 22.0;
    return 30.0; // для "99+"
  }

  /// Обчислює offset бейджу від краю FAB.
  static Offset badgeOffset(double dimension) {
    return const Offset(
      AppFabConstants.badgeOffset,
      AppFabConstants.badgeOffset,
    );
  }

  /// Повертає колір фону бейджу.
  static Color badgeBackgroundColor({required bool isLightTheme}) {
    return AppColorsPS5.error;
  }

  /// Повертає колір тексту бейджу.
  static Color badgeTextColor() {
    return Colors.white;
  }

  /// Чи бейдж потребує анімації появи.
  static bool needsAppearAnimation(int? previousCount, int? currentCount) {
    if (previousCount == null && currentCount != null) return true;
    if (previousCount != null && currentCount != null && previousCount != currentCount) return true;
    return false;
  }

  /// Генерує опис бейджу для accessibility.
  static String badgeAccessibilityLabel(int count) {
    if (count > AppFabConstants.maxBadgeCount) {
      return 'Більше ніж ${AppFabConstants.maxBadgeCount} непрочитаних';
    }
    if (count == 1) return '1 непрочитане';
    if (count >= 2 && count <= 4) return '$count непрочитаних';
    return '$count непрочитаних';
  }
}

// ─── FAB Responsive Config ───────────────────────────────────────────────────

/// Конфігурація адаптивного FAB залежно від розміру екрана.
///
/// Автоматично підбирає розмір, відступи та варіант FAB
/// залежно від ширини екрана та типу пристрою.
class AppFabResponsiveConfig {
  AppFabResponsiveConfig({
    required this.screenWidth,
    required this.screenHeight,
    this.hasBottomNav = true,
    this.hasNotch = false,
    this.isTablet = false,
  });

  /// Ширина екрана.
  final double screenWidth;

  /// Висота екрана.
  final double screenHeight;

  /// Чи є BottomNavigationBar.
  final bool hasBottomNav;

  /// Чи є notch (виїмка).
  final bool hasNotch;

  /// Чи це планшет.
  final bool isTablet;

  /// Оптимальний розмір FAB для цього екрана.
  AppFabSize get optimalSize {
    if (isTablet) return AppFabSize.large;
    if (screenWidth < 360) return AppFabSize.small;
    if (screenWidth < 600) return AppFabSize.medium;
    return AppFabSize.large;
  }

  /// Оптимальний варіант FAB.
  AppFabVariant get optimalVariant {
    if (isTablet) return AppFabVariant.standard;
    if (screenWidth < 360) return AppFabVariant.mini;
    return AppFabVariant.standard;
  }

  /// Відступ знизу з урахуванням навігації та notch.
  double get bottomInset {
    double inset = hasBottomNav ? 80.0 : 24.0;
    if (hasNotch) inset += 16.0;
    return inset;
  }

  /// Відступ справа.
  double get rightInset {
    if (isTablet) return 24.0;
    return 16.0;
  }

  /// EdgeInsets для позиціонування FAB.
  EdgeInsets get fabMargin => EdgeInsets.only(
        right: rightInset,
        bottom: bottomInset,
      );

  /// Чи показувати extended FAB з текстом.
  bool get showExtended => screenWidth >= 400 && !isTablet;

  /// Максимальна ширина extended FAB.
  double get maxExtendedWidth {
    if (isTablet) return 280.0;
    if (screenWidth < 400) return 160.0;
    return 220.0;
  }

  /// Опис конфігурації для debug.
  String get debugDescription {
    return 'AppFabResponsiveConfig('
        'screen: ${screenWidth.toStringAsFixed(0)}x${screenHeight.toStringAsFixed(0)}, '
        'size: ${optimalSize.label}, '
        'variant: ${optimalVariant.label}, '
        'bottomInset: ${bottomInset.toStringAsFixed(0)}, '
        'tablet: $isTablet)';
  }
}

// ─── FAB Size Extensions ─────────────────────────────────────────────────────

/// Розширення для [AppFabSize] з додатковими computed properties.
extension AppFabSizeExtension on AppFabSize {
  /// Чи це мінімальний розмір FAB.
  bool get isMinimal => this == AppFabSize.xs || this == AppFabSize.small;

  /// Чи це стандартний розмір FAB.
  bool get isStandard => this == AppFabSize.medium;

  /// Чи це великий розмір FAB.
  bool get isLarge => this == AppFabSize.large;

  /// Коефіцієнт масштабування badge для цього розміру FAB.
  ///
  /// Більші FAB потребують пропорційно більшого badge.
  double get badgeScaleFactor {
    switch (this) {
      case AppFabSize.xs:
        return 0.8;
      case AppFabSize.small:
        return 0.9;
      case AppFabSize.medium:
        return 1.0;
      case AppFabSize.large:
        return 1.1;
    }
  }

  /// Оптимальний відступ badge від краю FAB.
  double get badgeTopOffset {
    switch (this) {
      case AppFabSize.xs:
        return -2.0;
      case AppFabSize.small:
        return -3.0;
      case AppFabSize.medium:
        return -4.0;
      case AppFabSize.large:
        return -5.0;
    }
  }

  /// Оптимальний правий відступ badge.
  double get badgeRightOffset {
    switch (this) {
      case AppFabSize.xs:
        return -2.0;
      case AppFabSize.small:
        return -3.0;
      case AppFabSize.medium:
        return -4.0;
      case AppFabSize.large:
        return -5.0;
    }
  }

  /// Розмір badge-тексту для цього розміру FAB.
  double get badgeFontSize {
    switch (this) {
      case AppFabSize.xs:
        return 8.0;
      case AppFabSize.small:
        return 9.0;
      case AppFabSize.medium:
        return 10.0;
      case AppFabSize.large:
        return 11.0;
    }
  }

  /// Ширина badge контейнера для одного символу.
  double get badgeSingleCharWidth {
    switch (this) {
      case AppFabSize.xs:
        return 14.0;
      case AppFabSize.small:
        return 16.0;
      case AppFabSize.medium:
        return 18.0;
      case AppFabSize.large:
        return 20.0;
    }
  }

  /// Відстань між speed dial-екранами для цього розміру.
  double get speedDialSpacing {
    switch (this) {
      case AppFabSize.xs:
        return 44.0;
      case AppFabSize.small:
        return 48.0;
      case AppFabSize.medium:
        return 56.0;
      case AppFabSize.large:
        return 64.0;
    }
  }

  /// Опис розміру для debug-логування.
  String get debugInfo =>
      'AppFabSize($name, dim: ${dimension.toStringAsFixed(0)}, icon: ${iconSize.toStringAsFixed(0)})';
}

// ─── FAB Variant Extensions ──────────────────────────────────────────────────

/// Розширення для [AppFabVariant] з додатковими computed properties.
extension AppFabVariantExtension on AppFabVariant {
  /// Чи цей варіант підтримує badge.
  bool get supportsBadge {
    switch (this) {
      case AppFabVariant.standard:
      case AppFabVariant.mini:
      case AppFabVariant.notification:
      case AppFabVariant.loading:
        return true;
      case AppFabVariant.extended:
      case AppFabVariant.speedDial:
        return false;
    }
  }

  /// Чи цей варіант підтримує текстову мітку.
  bool get supportsLabel {
    switch (this) {
      case AppFabVariant.standard:
      case AppFabVariant.mini:
      case AppFabVariant.extended:
        return true;
      case AppFabVariant.notification:
      case AppFabVariant.speedDial:
      case AppFabVariant.loading:
        return false;
    }
  }

  /// Чи цей варіант підтримує іконку.
  bool get supportsIcon => true;

  /// Чи цей варіант підтримує long press.
  bool get supportsLongPress {
    switch (this) {
      case AppFabVariant.standard:
      case AppFabVariant.mini:
      case AppFabVariant.extended:
        return true;
      case AppFabVariant.notification:
      case AppFabVariant.speedDial:
      case AppFabVariant.loading:
        return false;
    }
  }

  /// Чи цей варіант має підменю.
  bool get hasSubmenu => this == AppFabVariant.speedDial;

  /// Чи цей варіант показує стан завантаження.
  bool get isLoadingVariant => this == AppFabVariant.loading;

  /// Чи цей варіант призначений для сповіщень.
  bool get isNotificationVariant => this == AppFabVariant.notification;

  /// Повертає опис варіанту для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case AppFabVariant.standard:
        return 'Кнопка дії';
      case AppFabVariant.mini:
        return 'Міні-кнопка дії';
      case AppFabVariant.extended:
        return 'Розширена кнопка дії';
      case AppFabVariant.notification:
        return 'Кнопка сповіщень';
      case AppFabVariant.speedDial:
        return 'Швидкий набір дій';
      case AppFabVariant.loading:
        return 'Кнопка завантаження';
    }
  }
}

// ─── FAB Theme Extensions ────────────────────────────────────────────────────

/// Розширення для [AppFabTheme] з додатковими computed properties.
extension AppFabThemeExtension on AppFabTheme {
  /// Чи це "тепла" тема (жовті/помаранчеві відтінки).
  bool get isWarm {
    switch (this) {
      case AppFabTheme.accent:
      case AppFabTheme.success:
      case AppFabTheme.warning:
        return true;
      case AppFabTheme.primary:
      case AppFabTheme.secondary:
      case AppFabTheme.error:
        return false;
    }
  }

  /// Чи це "холодна" тема (сині/фіолетові відтінки).
  bool get isCool {
    switch (this) {
      case AppFabTheme.primary:
      case AppFabTheme.secondary:
        return true;
      case AppFabTheme.accent:
      case AppFabTheme.success:
      case AppFabTheme.warning:
      case AppFabTheme.error:
        return false;
    }
  }

  /// Чи ця тема використовується для критичних дій.
  bool get isCritical => this == AppFabTheme.error;

  /// Чи ця тема використовується для позитивних дій.
  bool get isPositive => this == AppFabTheme.success;

  /// Повертає колір тіні для FAB залежно від теми.
  Color shadowColor({required bool isDark}) {
    final baseColor = isDark ? darkColor(AppFabSize.medium) : lightColor(AppFabSize.medium);
    return baseColor.withOpacity(isDark ? 0.4 : 0.2);
  }

  /// Повертає колір glow-ефекту для FAB.
  Color glowColor({required bool isDark}) {
    final baseColor = isDark ? darkColor(AppFabSize.medium) : lightColor(AppFabSize.medium);
    return baseColor.withOpacity(isDark ? 0.3 : 0.15);
  }

  /// Повертає колір для ripple-ефекту при натисканні.
  Color rippleColor({required bool isDark}) {
    return Colors.white.withOpacity(0.2);
  }

  /// Повертає порядок сортування для теми.
  ///
  /// Корисно для відображення палітри в settings.
  int get sortIndex {
    switch (this) {
      case AppFabTheme.primary:
        return 0;
      case AppFabTheme.secondary:
        return 1;
      case AppFabTheme.accent:
        return 2;
      case AppFabTheme.success:
        return 3;
      case AppFabTheme.warning:
        return 4;
      case AppFabTheme.error:
        return 5;
    }
  }
}

// ─── Speed Dial Action Extensions ────────────────────────────────────────────

/// Розширення для [SpeedDialAction] з додатковими computed properties.
extension SpeedDialActionExtension on SpeedDialAction {
  /// Чи ця дія має кастомний колір.
  bool get hasCustomColor => color != null;

  /// Чи ця дія має підказку (tooltip).
  bool get hasTooltip => tooltip != null && tooltip!.isNotEmpty;

  /// Чи ця дія коректно налаштована (обов'язкові поля заповнені).
  bool get isValid => label.isNotEmpty;

  /// Довжина тексту мітки.
  int get labelLength => label.length;

  /// Чи мітка задовга для відображення (більше 20 символів).
  bool get isLabelTooLong => label.length > 20;

  /// Опис дії для accessibility.
  String get accessibilityLabel =>
      tooltip ?? 'Дія: $label';
}

// ─── FAB Icon Resolver ───────────────────────────────────────────────────────

/// Допоміжний клас для визначення іконки FAB.
///
/// Центральний точка для всіх рішень щодо іконок FAB.
class AppFabIconResolver {
  AppFabIconResolver._();

  /// Повертає ефективну іконку для FAB.
  ///
  /// Враховує кастомну іконку, варіант та стан.
  static IconData resolveIcon({
    IconData? customIcon,
    required AppFabVariant variant,
    bool isLoading = false,
  }) {
    if (isLoading) return Icons.hourglass_top_rounded;
    if (customIcon != null) return customIcon;

    switch (variant) {
      case AppFabVariant.standard:
        return Icons.add;
      case AppFabVariant.mini:
        return Icons.add;
      case AppFabVariant.extended:
        return Icons.add;
      case AppFabVariant.notification:
        return Icons.notifications_rounded;
      case AppFabVariant.speedDial:
        return Icons.add;
      case AppFabVariant.loading:
        return Icons.check_rounded;
    }
  }

  /// Повертає іконку для закритого стану speed dial.
  static IconData get speedDialClosedIcon => Icons.add;

  /// Повертає іконку для відкритого стану speed dial.
  static IconData get speedDialOpenIcon => Icons.close;

  /// Повертає іконку-замовчування для speed dial дій.
  static IconData defaultActionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.edit_rounded;
      case 1:
        return Icons.share_rounded;
      case 2:
        return Icons.delete_outline_rounded;
      case 3:
        return Icons.bookmark_outline_rounded;
      case 4:
        return Icons.more_horiz;
      default:
        return Icons.star_outline_rounded;
    }
  }

  /// Повертає розмір іконки для speed dial мітки.
  static double speedDialLabelIconSize(AppFabSize size) {
    switch (size) {
      case AppFabSize.xs:
        return 12.0;
      case AppFabSize.small:
        return 14.0;
      case AppFabSize.medium:
        return 16.0;
      case AppFabSize.large:
        return 18.0;
    }
  }
}

// ─── FAB Animation Builders ──────────────────────────────────────────────────

/// Будівники анімацій для FAB-віджета.
///
/// Надає готові анімаційні переходи для FAB.
class AppFabAnimationBuilders {
  AppFabAnimationBuilders._();

  /// Будує bounce-анімацію при натисканні.
  ///
  /// Повертає [Matrix4] трансформацію для поточного значення прогресу.
  static Matrix4 bounceTransform(double progress, double maxScale) {
    final scale = 1.0 + math.sin(progress * math.pi) * (maxScale - 1.0);
    return Matrix4.identity()..scale(scale);
  }

  /// Будує анімацію появи (scale + fade).
  ///
  /// [appearProgress] — значення від 0.0 (прихований) до 1.0 (видимий).
  static Matrix4 appearTransform(double appearProgress) {
    final scale = 0.5 + appearProgress * 0.5;
    return Matrix4.identity()..scale(scale);
  }

  /// Повертає оптимальну криву для bounce-анімації.
  static Curve bounceCurve() {
    return Curves.easeOutBack;
  }

  /// Повертає оптимальну криву для speed dial появи.
  static Curve speedDialCurve(int actionIndex, int totalActions) {
    final start = (actionIndex / totalActions).clamp(0.0, 0.8);
    final end = ((actionIndex + 1) / totalActions).clamp(0.2, 1.0);
    return Curves.easeOutCubic;
  }

  /// Повертає Interval для stagger-анімації speed dial.
  static Interval speedDialInterval(int actionIndex, int totalActions) {
    final delay = (actionIndex + 1) * AppFabConstants.speedDialStaggerDelay;
    return Interval(
      delay.clamp(0.0, 0.8),
      1.0,
      curve: Curves.easeOutCubic,
    );
  }

  /// Будує rotate-трансформацію для speed dial іконки.
  static Matrix4 speedDialIconRotation(bool isOpen) {
    final angle = isOpen ? (math.pi / 4) : 0.0;
    return Matrix4.identity()..rotateZ(angle);
  }
}

// ─── FAB Accessibility Helpers ───────────────────────────────────────────────

/// Допоміжні методи для accessibility FAB.
///
/// Надає текстові описи для екранних читачів.
class AppFabAccessibility {
  AppFabAccessibility._();

  /// Генерує семантичну мітку для FAB.
  static String semanticLabelFor({
    required AppFabVariant variant,
    String? customLabel,
    String? tooltipText,
    int? badgeCount,
    bool isLoading = false,
  }) {
    final parts = <String>[];

    if (customLabel != null) {
      parts.add(customLabel);
    } else {
      parts.add(variant.accessibilityDescription);
    }

    if (isLoading) {
      parts.add('(завантаження)');
    }

    if (badgeCount != null && badgeCount > 0) {
      if (badgeCount > AppFabConstants.maxBadgeCount) {
        parts.add('(${AppFabConstants.maxBadgeCount}+ сповіщень)');
      } else {
        parts.add('($badgeCount сповіщень)');
      }
    }

    return parts.join(' ');
  }

  /// Генерує опис long press дії.
  static String longPressHint({
    String? longPressLabel,
    String? tooltipText,
    VoidCallback? onLongPress,
  }) {
    if (onLongPress != null) return 'Утримайте для додаткової дії';
    if (tooltipText != null) return 'Утримайте: $tooltipText';
    if (longPressLabel != null) return 'Утримайте: $longPressLabel';
    return '';
  }

  /// Генерує опис speed dial дії.
  static String speedDialActionLabel(SpeedDialAction action) {
    return action.accessibilityLabel;
  }

  /// Генерує опис state для screen reader.
  static String stateDescription({
    required bool isVisible,
    required bool isLoading,
    required bool isSpeedDialOpen,
    int? badgeCount,
  }) {
    final parts = <String>[];
    if (!isVisible) parts.add('Приховано');
    if (isLoading) parts.add('Завантаження');
    if (isSpeedDialOpen) parts.add('Меню відкрито');
    if (badgeCount != null && badgeCount > 0) {
      parts.add('$badgeCount непрочитаних');
    }
    return parts.isEmpty ? '' : parts.join(', ');
  }
}

// ─── FAB Debug Helper ────────────────────────────────────────────────────────

/// Допоміжні методи для debug-логування FAB.
///
/// Надає форматовані рядки для аналізу стану FAB.
class AppFabDebugHelper {
  AppFabDebugHelper._();

  /// Генерує debug-рядок для всього стану FAB.
  static String buildDebugString({
    required AppFabVariant variant,
    required AppFabSize size,
    required AppFabTheme theme,
    required bool isVisible,
    required bool isLoading,
    int? badgeCount,
    String? label,
    String? tooltipText,
    bool isLightTheme = false,
  }) {
    final buffer = StringBuffer('AppFab(');
    buffer.writeln();
    buffer.writeln('  variant: ${variant.label}');
    buffer.writeln('  size: ${size.label} (${size.dimension}px)');
    buffer.writeln('  theme: ${theme.label}');
    buffer.writeln('  visible: $isVisible');
    buffer.writeln('  loading: $isLoading');
    buffer.writeln('  theme: ${isLightTheme ? "light" : "dark"}');
    if (badgeCount != null) buffer.writeln('  badge: $badgeCount');
    if (label != null) buffer.writeln('  label: "$label"');
    if (tooltipText != null) buffer.writeln('  tooltip: "$tooltipText"');
    buffer.write(')');
    return buffer.toString();
  }

  /// Генерує debug-рядок для speed dial стану.
  static String speedDialDebugString({
    required bool isOpen,
    required int actionCount,
    required Duration animationDuration,
  }) {
    return 'SpeedDial('
        'open: $isOpen, '
        'actions: $actionCount, '
        'animDuration: ${animationDuration.inMilliseconds}ms)';
  }

  /// Генерує debug-рядок для badge стану.
  static String badgeDebugString(int? count) {
    if (count == null) return 'Badge(none)';
    if (count > AppFabConstants.maxBadgeCount) {
      return 'Badge(${AppFabConstants.maxBadgeCount}+)';
    }
    return 'Badge($count)';
  }

  /// Генерує debug-рядок для кольорів FAB.
  static String colorsDebugString({
    required Color fabColor,
    required Color textColor,
    required Color bgColor,
  }) {
    return 'Colors('
        'fab: ${_colorToHex(fabColor)}, '
        'text: ${_colorToHex(textColor)}, '
        'bg: ${_colorToHex(bgColor)})';
  }

  /// Перетворює колір у hex-рядок.
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}

// ─── FAB Predicate Helpers ───────────────────────────────────────────────────

/// Предикати для перевірки стану FAB.
///
/// Надає методи для перевірки складних умов.
class AppFabPredicates {
  AppFabPredicates._();

  /// Чи FAB в interactable стані (не loading, visible).
  static bool isInteractable({
    required bool isVisible,
    required bool isLoading,
  }) {
    return isVisible && !isLoading;
  }

  /// Чи FAB в interactable стані для speed dial.
  static bool canOpenSpeedDial({
    required AppFabVariant variant,
    required bool isVisible,
    required bool isLoading,
    required List<SpeedDialAction>? actions,
  }) {
    return variant == AppFabVariant.speedDial &&
        isVisible &&
        !isLoading &&
        actions != null &&
        actions.isNotEmpty;
  }

  /// Чи badge повинен бути показаний.
  static bool shouldShowBadge(int? badgeCount) {
    return badgeCount != null && badgeCount > 0;
  }

  /// Чи badge має текст "99+".
  static bool isBadgeOverflow(int? badgeCount) {
    return badgeCount != null && badgeCount > AppFabConstants.maxBadgeCount;
  }

  /// Чи потрібно показати tooltip.
  static bool shouldShowTooltip({
    String? tooltipText,
    VoidCallback? onLongPress,
    String? longPressLabel,
  }) {
    return tooltipText != null && tooltipText.isNotEmpty && onLongPress == null;
  }

  /// Чи потрібно показати long press label.
  static bool shouldShowLongPressLabel({
    String? longPressLabel,
    VoidCallback? onLongPress,
  }) {
    return longPressLabel != null && longPressLabel.isNotEmpty || onLongPress != null;
  }

  /// Чи FAB compatable з extended режимом.
  static bool canBeExtended({
    required AppFabVariant variant,
    String? label,
  }) {
    return (variant == AppFabVariant.extended || variant == AppFabVariant.standard) &&
        label != null &&
        label.isNotEmpty;
  }
}
