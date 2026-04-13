import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [AppCoinBadge].
///
/// Контролює видимість debug-повідомлень та візуальних індикаторів.
class CoinBadgeDebugConfig {
  CoinBadgeDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати рамку навколо бейджа для налагодження.
  static bool showDebugBounds = false;

  /// Показувати значення прогрес-кільця як текст.
  static bool showProgressValue = false;

  /// Записує debug-повідомлення.
  ///
  /// [message] — текст повідомлення.
  /// [tag] — додатковий тег.
  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[CoinBadge:$tag] ' : '[CoinBadge] ';
    debugPrint('$prefix$message');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розміри бейджа монет (Coin Badge Size Variants)
// ═══════════════════════════════════════════════════════════════════════════

/// Розміри бейджа монет для різних контекстів використання.
///
/// Кожен розмір визначає піксельні значення для:
/// - загального розміру (dimension)
/// - масштабу іконки (iconScale)
/// - масштабу тексту (textScale)
/// - радіусу розмиття сяйва (glowBlur)
enum CoinBadgeSize {
  /// Мініатюрний бейдж для навігації (28px).
  ///
  /// Компактний — для BottomNavigationBar або AppBar.
  tiny,

  /// Компактний бейдж для списків (36px).
  ///
  /// Для рядків транзакцій, невеликих карток.
  small,

  /// Стандартний бейдж для панелі інструментів (44px).
  ///
  /// Оптимальний розмір для більшості контекстів.
  medium,

  /// Збільшений бейдж для карток (56px).
  ///
  /// Для виділених секцій, hero-карок.
  large,

  /// Герой-бейдж для екранів нагород (72px).
  ///
  /// Максимальний розмір — для святкувань, досягнень.
  hero;

  /// Загальний розмір бейджа в пікселях.
  double get value {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 28.0;
      case CoinBadgeSize.small:
        return 36.0;
      case CoinBadgeSize.medium:
        return 44.0;
      case CoinBadgeSize.large:
        return 56.0;
      case CoinBadgeSize.hero:
        return 72.0;
    }
  }

  /// Масштаб іконки монети відносно розміру бейджа.
  double get iconScale {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 0.32;
      case CoinBadgeSize.small:
        return 0.34;
      case CoinBadgeSize.medium:
        return 0.36;
      case CoinBadgeSize.large:
        return 0.38;
      case CoinBadgeSize.hero:
        return 0.40;
    }
  }

  /// Масштаб тексту (числа монет) відносно розміру бейджа.
  double get textScale {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 0.26;
      case CoinBadgeSize.small:
        return 0.28;
      case CoinBadgeSize.medium:
        return 0.28;
      case CoinBadgeSize.large:
        return 0.26;
      case CoinBadgeSize.hero:
        return 0.24;
    }
  }

  /// Радіус розмиття сяйва навколо монети.
  double get glowBlur {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 6.0;
      case CoinBadgeSize.small:
        return 8.0;
      case CoinBadgeSize.medium:
        return 10.0;
      case CoinBadgeSize.large:
        return 14.0;
      case CoinBadgeSize.hero:
        return 20.0;
    }
  }

  /// Ширина обводки прогрес-кільця.
  double get ringStrokeWidth {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 1.5;
      case CoinBadgeSize.small:
        return 2.0;
      case CoinBadgeSize.medium:
        return 2.5;
      case CoinBadgeSize.large:
        return 3.0;
      case CoinBadgeSize.hero:
        return 3.5;
    }
  }

  /// Розмір тексту мітки під бейджем.
  double get labelFontSize {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 8.0;
      case CoinBadgeSize.small:
        return 9.0;
      case CoinBadgeSize.medium:
        return 10.0;
      case CoinBadgeSize.large:
        return 11.0;
      case CoinBadgeSize.hero:
        return 12.0;
    }
  }

  /// Коротка українська назва розміру.
  String get label {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 'Крихітний';
      case CoinBadgeSize.small:
        return 'Малий';
      case CoinBadgeSize.medium:
        return 'Середній';
      case CoinBadgeSize.large:
        return 'Великий';
      case CoinBadgeSize.hero:
        return 'Герой';
    }
  }

  /// Опис розміру для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 'Крихітний бейдж монет для навігації';
      case CoinBadgeSize.small:
        return 'Малий бейдж монет для списків';
      case CoinBadgeSize.medium:
        return 'Середній бейдж монет стандартного розміру';
      case CoinBadgeSize.large:
        return 'Великий бейдж монет для карток';
      case CoinBadgeSize.hero:
        return 'Герой-бейдж монет для нагород';
    }
  }

  /// Чи цей розмір підходить для відображення тексту.
  bool get canShowText => this != CoinBadgeSize.tiny;

  /// Чи цей розмір підходить для прогрес-кільця.
  bool get canShowRing => index >= CoinBadgeSize.small.index;
}

// ═══════════════════════════════════════════════════════════════════════════
// Coin Badge Animation Config
// ═══════════════════════════════════════════════════════════════════════════

/// Конфігурація анімацій для [AppCoinBadge].
class CoinBadgeAnimationConfig {
  /// Створює конфігурацію анімацій.
  ///
  /// [bounceDuration] — тривалість анімації відскоку.
  /// [bounceScaleUp] — максимальний масштаб при відскоку вгору.
  /// [bounceScaleDown] — мінімальний масштаб при відскоку вниз.
  /// [spinDuration] — тривалість обертання монети.
  /// [glowDuration] — тривалість пульсації сяйва.
  /// [glowMin] — мінімальна непрозорість сяйва.
  /// [glowMax] — максимальна непрозорість сяйва.
  const CoinBadgeAnimationConfig({
    this.bounceDuration = AppDurations.bounce,
    this.bounceScaleUp = 1.3,
    this.bounceScaleDown = 0.9,
    this.spinDuration = const Duration(seconds: 2),
    this.glowDuration = AppDurations.glow,
    this.glowMin = 0.3,
    this.glowMax = 0.7,
  });

  /// Тривалість анімації відскоку.
  final Duration bounceDuration;

  /// Максимальний масштаб при відскоку.
  final double bounceScaleUp;

  /// Мінімальний масштаб при відскоку.
  final double bounceScaleDown;

  /// Тривалість обертання монети.
  final Duration spinDuration;

  /// Тривалість пульсації сяйва.
  final Duration glowDuration;

  /// Мінімальна непрозорість сяйва.
  final double glowMin;

  /// Максимальна непрозорість сяйва.
  final double glowMax;

  /// Стандартна конфігурація.
  static const CoinBadgeAnimationConfig standard = CoinBadgeAnimationConfig();

  /// Швидка конфігурація (менші тривалості).
  static const CoinBadgeAnimationConfig fast = CoinBadgeAnimationConfig(
    bounceDuration: Duration(milliseconds: 200),
    spinDuration: Duration(milliseconds: 800),
    glowDuration: Duration(milliseconds: 400),
  );

  /// Повільна конфігурація (більші тривалості).
  static const CoinBadgeAnimationConfig slow = CoinBadgeAnimationConfig(
    bounceDuration: Duration(milliseconds: 700),
    spinDuration: Duration(seconds: 4),
    glowDuration: Duration(seconds: 3),
    bounceScaleUp: 1.4,
    bounceScaleDown: 0.85,
    glowMin: 0.2,
    glowMax: 0.8,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Віджет бейджа монет (Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Круглий бейдж монет з іконкою монети та анімованим підрахунком.
///
/// Підтримує:
/// - 5 розмірів [CoinBadgeSize] (tiny, small, medium, large, hero)
/// - Анімацію відскоку при отриманні монет
/// - Лічильник сповіщень (червона точка)
/// - Ефект пульсації сяйва
/// - Обертання монети (spinning)
/// - Прогрес-кільце навколо бейджа
/// - Напис "Монети" під бейджем
///
/// Приклад використання:
/// ```dart
/// AppCoinBadge(
///   coins: 1500,
///   size: CoinBadgeSize.medium,
///   showLabel: true,
///   showRingProgress: true,
///   ringProgress: 0.75,
/// )
/// ```
class AppCoinBadge extends StatefulWidget {
  const AppCoinBadge({
    super.key,
    required this.coins,
    this.previousCoins,
    this.isLightTheme = false,
    this.size = CoinBadgeSize.medium,
    this.showGlow = true,
    this.badgeCount,
    this.showLabel = false,
    this.showRingProgress = false,
    this.ringProgress,
    this.spinning = false,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.animationConfig = const CoinBadgeAnimationConfig.standard,
    this.customCoinColor,
    this.customBgColor,
    this.enableTapBounce = true,
    this.showTooltip = false,
  });

  /// Створює компактний бейдж для списків.
  ///
  /// Зручний конструктор для рядків транзакцій.
  AppCoinBadge.compact({
    super.key,
    required this.coins,
    this.previousCoins,
    this.isLightTheme = false,
    this.onTap,
    this.badgeCount,
    this.semanticLabel,
    this.customCoinColor,
  })  : size = CoinBadgeSize.small,
        showGlow = false,
        showLabel = false,
        showRingProgress = false,
        ringProgress = null,
        spinning = false,
        onLongPress = null,
        animationConfig = const CoinBadgeAnimationConfig.standard,
        customBgColor = null,
        enableTapBounce = true,
        showTooltip = false;

  /// Створює великий бейдж для hero-секцій.
  AppCoinBadge.hero({
    super.key,
    required this.coins,
    this.previousCoins,
    this.isLightTheme = false,
    this.showGlow = true,
    this.badgeCount,
    this.showLabel = true,
    this.showRingProgress = true,
    this.ringProgress,
    this.onTap,
    this.semanticLabel,
    this.customCoinColor,
    this.customBgColor,
  })  : size = CoinBadgeSize.hero,
        spinning = false,
        onLongPress = null,
        animationConfig = const CoinBadgeAnimationConfig.slow,
        enableTapBounce = true,
        showTooltip = false;

  /// Поточна кількість монет.
  final int coins;

  /// Попередня кількість монет для анімації відскоку.
  final int? previousCoins;

  /// Використовувати світлу тему (Monitor).
  final bool isLightTheme;

  /// Розмір бейджа.
  final CoinBadgeSize size;

  /// Показувати ефект світіння навколо монети.
  final bool showGlow;

  /// Кількість сповіщень (червона точка-лічильник).
  final int? badgeCount;

  /// Показувати напис "Монети" під бейджем.
  final bool showLabel;

  /// Показувати кільцевий прогрес навколо бейджа.
  final bool showRingProgress;

  /// Значення прогресу для кільця (0.0 - 1.0).
  final double? ringProgress;

  /// Анімація обертання монети (наприклад, при отриманні).
  final bool spinning;

  /// Зворотний виклик при натисканні на бейдж.
  final VoidCallback? onTap;

  /// Зворотний виклик при довгому натисканні.
  final VoidCallback? onLongPress;

  /// Семантична назва для екранних читачів.
  final String? semanticLabel;

  /// Конфігурація анімацій.
  final CoinBadgeAnimationConfig animationConfig;

  /// Кастомний колір монети (замість стандартного золотого).
  final Color? customCoinColor;

  /// Кастомний колір фону бейджа.
  final Color? customBgColor;

  /// Увімкнути анімацію відскоку при натисканні.
  final bool enableTapBounce;

  /// Показувати tooltip при натисканні.
  final bool showTooltip;

  @override
  State<AppCoinBadge> createState() => _AppCoinBadgeState();
}

class _AppCoinBadgeState extends State<AppCoinBadge>
    with SingleTickerProviderStateMixin {
  /// Контролер анімації відскоку при отриманні монет.
  late AnimationController _bounceController;

  /// Анімація відскоку (scale tween).
  late Animation<double> _bounceAnimation;

  /// Контролер анімації обертання монети.
  late AnimationController _spinController;

  /// Анімація обертання (кут).
  late Animation<double> _spinAnimation;

  /// Контролер пульсації сяйва.
  late AnimationController _glowController;

  /// Анімація пульсації (непрозорість сяйва).
  late Animation<double> _glowAnimation;

  /// Контролер анімації при натисканні.
  late AnimationController _tapController;

  /// Анімація натискання.
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    CoinBadgeDebugConfig.log('initState', tag: 'lifecycle');
    _initAnimations();

    // Запустити анімації при першому завантаженні
    if (widget.previousCoins != null &&
        widget.coins > widget.previousCoins!) {
      CoinBadgeDebugConfig.log(
        'Initial bounce: ${widget.previousCoins} → ${widget.coins}',
        tag: 'animation',
      );
      _bounceController.forward(from: 0);
    }

    if (widget.spinning) {
      _spinController.repeat();
    }
  }

  /// Ініціалізує всі анімаційні контролери.
  void _initAnimations() {
    // ── Контролер відскоку ──
    _bounceController = AnimationController(
      vsync: this,
      duration: widget.animationConfig.bounceDuration,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: widget.animationConfig.bounceScaleUp,
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: widget.animationConfig.bounceScaleUp,
          end: widget.animationConfig.bounceScaleDown,
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: widget.animationConfig.bounceScaleDown,
          end: 1.0,
        ),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: AppEasings.gentleBounce,
    ));

    // ── Контролер обертання ──
    _spinController = AnimationController(
      vsync: this,
      duration: widget.animationConfig.spinDuration,
    );
    _spinAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );

    // ── Контролер пульсації сяйва ──
    _glowController = AnimationController(
      vsync: this,
      duration: widget.animationConfig.glowDuration,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: widget.animationConfig.glowMin,
      end: widget.animationConfig.glowMax,
    ).animate(
      CurvedAnimation(parent: _glowController, curve: AppEasings.neonGlow),
    );

    // ── Контролер натискання ──
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AppCoinBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Анімація відскоку при збільшенні монет
    if (widget.coins > oldWidget.coins) {
      CoinBadgeDebugConfig.log(
        'Coins increased: ${oldWidget.coins} → ${widget.coins}',
        tag: 'update',
      );
      _bounceController.forward(from: 0);
    }

    // Анімація при зменшенні монет
    if (widget.coins < oldWidget.coins) {
      CoinBadgeDebugConfig.log(
        'Coins decreased: ${oldWidget.coins} → ${widget.coins}',
        tag: 'update',
      );
    }

    // Керування обертанням
    if (widget.spinning && !oldWidget.spinning) {
      _spinController.repeat();
    } else if (!widget.spinning && oldWidget.spinning) {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _spinController.dispose();
    _glowController.dispose();
    _tapController.dispose();
    CoinBadgeDebugConfig.log('dispose', tag: 'lifecycle');
    super.dispose();
  }

  // ─── Validation ───────────────────────────────────────────────────────

  /// Перевіряє коректність параметрів бейджа.
  void _validateParams() {
    assert(
      widget.coins >= 0,
      'Coin count must be non-negative, got ${widget.coins}',
    );
    assert(
      widget.badgeCount == null || widget.badgeCount! >= 0,
      'Badge count must be non-negative',
    );
    assert(
      widget.ringProgress == null ||
          (widget.ringProgress! >= 0.0 && widget.ringProgress! <= 1.0),
      'Ring progress must be between 0.0 and 1.0',
    );
    assert(
      widget.previousCoins == null || widget.previousCoins! >= 0,
      'Previous coins must be non-negative',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Форматування (Formatting)
  // ═══════════════════════════════════════════════════════════════════════

  /// Форматує число монет для компактного відображення.
  ///
  /// - 1500 → "1.5K"
  /// - 1500000 → "1.5M"
  String _formatCoins(int value) {
    if (value < 0) {
      return '-${_formatPositiveCoins(value.abs())}';
    }
    return _formatPositiveCoins(value);
  }

  /// Форматує позитивне число монет.
  ///
  /// [value] — додатне число монет.
  String _formatPositiveCoins(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  /// Обчислює різницю монет для повідомлення.
  String _computeDiffMessage() {
    if (widget.previousCoins == null) return '';
    final diff = widget.coins - widget.previousCoins!;
    if (diff == 0) return '';
    final sign = diff > 0 ? '+' : '';
    return '$sign${_formatCoins(diff)}';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Гетери кольорів (Color Getters)
  // ═══════════════════════════════════════════════════════════════════════

  /// Колір фону бейджа.
  Color get _bgColor =>
      widget.customBgColor ??
      (widget.isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card);

  /// Колір монети (золотий або кастомний).
  Color get _coinColor =>
      widget.customCoinColor ?? AppColorsPS5.coin;

  /// Колір тексту числа монет.
  Color get _textColor => widget.isLightTheme
      ? AppColorsMonitor.textPrimary
      : AppColorsPS5.textPrimary;

  /// Колір тексту мітки "Монети".
  Color get _labelColor => widget.isLightTheme
      ? AppColorsMonitor.textSecondary
      : AppColorsPS5.textSecondary;

  /// Колір доріжки прогрес-кільця.
  Color get _ringTrackColor => widget.isLightTheme
      ? AppColorsMonitor.border
      : AppColorsPS5.border;

  /// Колір заповнення прогрес-кільця.
  Color get _ringProgressColor => _coinColor;

  /// Колір індикатора сповіщень.
  Color get _notificationColor => AppColorsPS5.error;

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    _validateParams();
    final size = widget.size.value;

    Widget badge = Semantics(
      label: widget.semanticLabel ??
          'Монети: ${_formatCoins(widget.coins)}',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Бейдж з прогрес-кільцем ──
            _buildBadgeWithRing(size),
            // ── Напис "Монети" ──
            if (widget.showLabel && widget.size.canShowText) ...[
              const SizedBox(height: 4),
              Text(
                'Монети',
                style: AppTypography.labelSmall.copyWith(
                  color: _labelColor,
                  fontSize: widget.size.labelFontSize,
                ),
              ),
            ],
            // ── Debug: Progress Value ──
            if (CoinBadgeDebugConfig.showProgressValue &&
                widget.showRingProgress) ...[
              const SizedBox(height: 2),
              Text(
                '${((widget.ringProgress ?? 0) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 8, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );

    // Tooltip
    if (widget.showTooltip) {
      final diffMsg = _computeDiffMessage();
      final tooltipMsg = diffMsg.isNotEmpty
          ? '${_formatCoins(widget.coins)} монет ($diffMsg)'
          : '${_formatCoins(widget.coins)} монет';
      badge = Tooltip(message: tooltipMsg, child: badge);
    }

    return badge;
  }

  /// Обробляє натискання на бейдж.
  void _handleTap() {
    if (!widget.enableTapBounce) {
      widget.onTap?.call();
      return;
    }

    _tapController.forward(from: 0).then((_) {
      if (mounted) _tapController.reverse();
    });
    widget.onTap?.call();
    CoinBadgeDebugConfig.log('Tap detected', tag: 'gesture');
  }

  /// Будує бейдж з опціональним прогрес-кільцем.
  ///
  /// [size] — розмір бейджа в пікселях.
  Widget _buildBadgeWithRing(double size) {
    final badge = _buildBadge(size);

    if (widget.showRingProgress && widget.size.canShowRing) {
      return AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: SizedBox(
              width: size + 6,
              height: size + 6,
              child: CustomPaint(
                painter: _RingProgressPainter(
                  progress: (widget.ringProgress ?? 0.0).clamp(0.0, 1.0),
                  trackColor: _ringTrackColor,
                  progressColor: _ringProgressColor,
                  strokeWidth: widget.size.ringStrokeWidth,
                ),
                child: Center(child: child),
              ),
            ),
          );
        },
        child: badge,
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _tapAnimation]),
      builder: (context, child) {
        final bounceScale = _bounceAnimation.value;
        final tapScale = _tapAnimation.value;
        final combinedScale = bounceScale * tapScale;
        return Transform.scale(
          scale: combinedScale,
          child: child,
        );
      },
      child: badge,
    );
  }

  /// Будує основний бейдж монети з іконкою та числом.
  ///
  /// [size] — розмір бейджа в пікселях.
  Widget _buildBadge(double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_spinAnimation, _glowAnimation]),
      builder: (context, child) {
        final glowOpacity = widget.showGlow ? _glowAnimation.value : 0.3;
        final rotation = widget.spinning ? _spinAnimation.value : 0.0;

        return Container(
          width: size,
          height: size,
          decoration: _buildBadgeDecoration(glowOpacity, size),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Основний контент ──
              Transform.rotate(
                angle: rotation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: _coinColor,
                      size: size * widget.size.iconScale,
                    ),
                    Flexible(
                      child: Text(
                        _formatCoins(widget.coins),
                        style: AppTypography.monoCaption.copyWith(
                          color: _textColor,
                          fontSize: size * widget.size.textScale,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Бейдж сповіщень ──
              if (widget.badgeCount != null && widget.badgeCount! > 0)
                _buildNotificationBadge(size),
              // ── Debug Bounds ──
              if (CoinBadgeDebugConfig.showDebugBounds)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Будує декорацію бейджа (фон, тіні).
  ///
  /// [glowOpacity] — непрозорість сяйва.
  /// [size] — розмір бейджа.
  BoxDecoration _buildBadgeDecoration(double glowOpacity, double size) {
    return BoxDecoration(
      color: _bgColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: _coinColor.withOpacity(glowOpacity),
          blurRadius: widget.size.glowBlur,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Будує бейдж сповіщень (червона точка-лічильник).
  ///
  /// [size] — розмір основного бейджа.
  Widget _buildNotificationBadge(double size) {
    final badgeText = widget.badgeCount! > 99
        ? '99+'
        : '${widget.badgeCount}';
    final badgeSize = badgeText.length > 2 ? 22.0 : 16.0;
    final fontSize = badgeText.length > 2 ? 7.0 : 8.0;

    return Positioned(
      top: -2,
      right: -2,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          color: _notificationColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: _bgColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _notificationColor.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            badgeText,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Малювальник кільцевого прогресу (Ring Progress Painter)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник кільцевого прогресу навколо бейджа монет.
///
/// Малює фонову доріжку та дугу прогресу.
class _RingProgressPainter extends CustomPainter {
  /// Створює малювальник кільцевого прогресу.
  ///
  /// [progress] — значення прогресу (0.0 - 1.0).
  /// [trackColor] — колір фонової доріжки.
  /// [progressColor] — колір дуги прогресу.
  /// [strokeWidth] — товщина ліній кільця.
  _RingProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  /// Значення прогресу (0.0 - 1.0).
  final double progress;

  /// Колір фонової доріжки.
  final Color trackColor;

  /// Колір дуги прогресу.
  final Color progressColor;

  /// Товщина ліній кільця.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // ── Фонова доріжка ──
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // ── Дуга прогресу ──
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // ── Точка-індикатор на кінці прогресу ──
      if (progress < 1.0 && progress > 0.01) {
        final dotAngle = -math.pi / 2 + sweepAngle;
        final dotX = center.dx + radius * math.cos(dotAngle);
        final dotY = center.dy + radius * math.sin(dotAngle);
        final dotPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(dotX, dotY),
          strokeWidth * 0.6,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Helper Methods)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з бейджем монет.
class AppCoinBadgeHelpers {
  AppCoinBadgeHelpers._();

  /// Форматує кількість монет для відображення.
  ///
  /// - 1500 → "1.5K"
  /// - 1500000 → "1.5M"
  /// - 42 → "42"
  static String formatCoins(int value) {
    if (value < 0) return '-${_formatAbs(value.abs())}';
    return _formatAbs(value);
  }

  static String _formatAbs(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  /// Повертає повідомлення про отримання монет.
  static String gainedMessage(int amount) {
    return '+${formatCoins(amount)} монет отримано!';
  }

  /// Повертає повідомлення про витрачені монети.
  static String spentMessage(int amount) {
    return '-${formatCoins(amount)} монет витрачено';
  }

  /// Повертає опис для accessibility.
  static String accessibilityLabel(int coins) {
    return 'Баланс монет: ${formatCoins(coins)}';
  }

  /// Визначає, чи потрібно показувати скорочений формат.
  ///
  /// Повертає true, якщо значення >= 1000.
  static bool shouldAbbreviate(int value) {
    return value >= 1000;
  }

  /// Обчислює відсоток прогресу накопичення.
  ///
  /// [current] — поточна кількість монет.
  /// [target] — цільова кількість монет.
  static double savingsProgress(int current, int target) {
    if (target <= 0) return 1.0;
    return (current / target).clamp(0.0, 1.0);
  }

  /// Обчислює скільки монет залишилось до цілі.
  ///
  /// [current] — поточна кількість монет.
  /// [target] — цільова кількість монет.
  static int coinsRemaining(int current, int target) {
    return (target - current).clamp(0, target);
  }

  /// Повертає іконку залежно від суми монет.
  ///
  /// Малі суми — звичайна монета, великі — золота корона.
  static IconData coinIcon(int coins) {
    if (coins >= 100000) return Icons.emoji_events;
    if (coins >= 10000) return Icons.stars_rounded;
    if (coins >= 1000) return Icons.monetization_on_rounded;
    return Icons.monetization_on_outlined;
  }

  /// Обчислює розмір бейджа залежно від кількості монет.
  ///
  /// Більша кількість — більший бейдж.
  static CoinBadgeSize recommendSize(int coins) {
    if (coins >= 10000) return CoinBadgeSize.hero;
    if (coins >= 1000) return CoinBadgeSize.large;
    if (coins >= 100) return CoinBadgeSize.medium;
    return CoinBadgeSize.small;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions (Утиліти-розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [int] з форматуванням монет.
extension CoinFormatExtension on int {
  /// Форматує число як кількість монет.
  ///
  /// 1500.formatAsCoins() → "1.5K"
  String formatAsCoins() => AppCoinBadgeHelpers.formatCoins(this);

  /// Повертає іконку відповідну кількості монет.
  IconData get coinIcon => AppCoinBadgeHelpers.coinIcon(this);
}

/// Розширення для [CoinBadgeSize] з додатковими методами.
extension CoinBadgeSizeExtension on CoinBadgeSize {
  /// Наступний розмір (hero → hero).
  CoinBadgeSize get next {
    if (index >= CoinBadgeSize.values.length - 1) return this;
    return CoinBadgeSize.values[index + 1];
  }

  /// Попередній розмір (tiny → tiny).
  CoinBadgeSize get previous {
    if (index <= 0) return this;
    return CoinBadgeSize.values[index - 1];
  }

  /// Чи цей розмір є найбільшим.
  bool get isMax => this == CoinBadgeSize.hero;

  /// Чи цей розмір є найменшим.
  bool get isMin => this == CoinBadgeSize.tiny;

  /// Площа бейджа в пікселях² (для hit-testing).
  double get area => math.pi * (value / 2) * (value / 2);

  /// Діаметр кільця прогресу (з урахуванням ширини лінії).
  double get ringDiameter => value + 6;

  /// Коефіцієнт масштабування badgeCount-точки відносно розміру.
  double get notificationScaleFactor {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 0.6;
      case CoinBadgeSize.small:
        return 0.7;
      case CoinBadgeSize.medium:
        return 0.8;
      case CoinBadgeSize.large:
        return 0.9;
      case CoinBadgeSize.hero:
        return 1.0;
    }
  }

  /// Мінімальна ширина контейнера для бейджа з міткою.
  double get minContainerWidth {
    switch (this) {
      case CoinBadgeSize.tiny:
        return 28.0;
      case CoinBadgeSize.small:
        return 36.0;
      case CoinBadgeSize.medium:
        return 50.0;
      case CoinBadgeSize.large:
        return 62.0;
      case CoinBadgeSize.hero:
        return 80.0;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Coin Badge Theme Data (Тема для бейджа монет)
// ═══════════════════════════════════════════════════════════════════════════

/// Незмінні дані теми для кастомізації [AppCoinBadge].
///
/// Дозволяє визначити палітру кольорів та стилі для бейджа монет
/// та повторно використовувати їх у різних місцях додатку.
///
/// Приклад:
/// ```dart
/// final theme = CoinBadgeThemeData(
///   coinColor: Colors.amber,
///   bgColor: Colors.grey[900]!,
///   textColor: Colors.white,
/// );
/// AppCoinBadge(coins: 500, themeData: theme);
/// ```
class CoinBadgeThemeData {
  /// Створює дані теми для бейджа монет.
  ///
  /// [coinColor] — колір монети (іконка + прогрес-кільце).
  /// [bgColor] — колір фону бейджа.
  /// [textColor] — колір тексту числа монет.
  /// [labelColor] — колір тексту мітки «Монети».
  /// [glowIntensity] — інтенсивність сяйва (0.0–1.0).
  /// [ringTrackColor] — колір доріжки прогрес-кільця.
  /// [notificationColor] — колір червоного індикатора.
  const CoinBadgeThemeData({
    this.coinColor,
    this.bgColor,
    this.textColor,
    this.labelColor,
    this.glowIntensity = 0.5,
    this.ringTrackColor,
    this.notificationColor,
  });

  /// Колір монети.
  final Color? coinColor;

  /// Колір фону.
  final Color? bgColor;

  /// Колір тексту.
  final Color? textColor;

  /// Колір мітки.
  final Color? labelColor;

  /// Інтенсивність сяйва.
  final double glowIntensity;

  /// Колір доріжки кільця.
  final Color? ringTrackColor;

  /// Колір сповіщень.
  final Color? notificationColor;

  /// Стандартна темна тема (PS5-стиль).
  static const CoinBadgeThemeData dark = CoinBadgeThemeData(
    glowIntensity: 0.7,
  );

  /// Стандартна світла тема (Monitor-стиль).
  static const CoinBadgeThemeData light = CoinBadgeThemeData(
    glowIntensity: 0.3,
  );

  /// Золота преміум тема з підвищеним сяйвом.
  static const CoinBadgeThemeData premium = CoinBadgeThemeData(
    glowIntensity: 0.9,
  );

  /// Об'єднує цю тему з [other], заповнюючи null-значення з [other].
  CoinBadgeThemeData merge(CoinBadgeThemeData? other) {
    if (other == null) return this;
    return CoinBadgeThemeData(
      coinColor: other.coinColor ?? coinColor,
      bgColor: other.bgColor ?? bgColor,
      textColor: other.textColor ?? textColor,
      labelColor: other.labelColor ?? labelColor,
      glowIntensity: other.glowIntensity,
      ringTrackColor: other.ringTrackColor ?? ringTrackColor,
      notificationColor: other.notificationColor ?? notificationColor,
    );
  }

  /// Повертає копію з перезаписаними полями.
  CoinBadgeThemeData copyWith({
    Color? coinColor,
    Color? bgColor,
    Color? textColor,
    Color? labelColor,
    double? glowIntensity,
    Color? ringTrackColor,
    Color? notificationColor,
  }) {
    return CoinBadgeThemeData(
      coinColor: coinColor ?? this.coinColor,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      labelColor: labelColor ?? this.labelColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      ringTrackColor: ringTrackColor ?? this.ringTrackColor,
      notificationColor: notificationColor ?? this.notificationColor,
    );
  }

  /// Оператор рівності для порівняння тем.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinBadgeThemeData &&
        other.coinColor == coinColor &&
        other.bgColor == bgColor &&
        other.textColor == textColor &&
        other.labelColor == labelColor &&
        other.glowIntensity == glowIntensity &&
        other.ringTrackColor == ringTrackColor &&
        other.notificationColor == notificationColor;
  }

  @override
  int get hashCode => Object.hash(
        coinColor,
        bgColor,
        textColor,
        labelColor,
        glowIntensity,
        ringTrackColor,
        notificationColor,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Coin Shine Painter (Малювальник відблиску монети)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник ефекту відблиску на монеті.
///
/// Малює білий градієнтний відблиск під кутом,
/// що створює ефект об'ємної блискучої монети.
///
/// Використовується в [_AppCoinBadgeState._buildShineOverlay].
class _CoinShinePainter extends CustomPainter {
  /// Створює малювальник відблиску.
  ///
  /// [shineProgress] — прогрес руху відблиску (0.0–1.0).
  /// [coinColor] — колір монети для відтінку відблиску.
  const _CoinShinePainter({
    required this.shineProgress,
    required this.coinColor,
  });

  /// Поточна позиція відблиску (0.0 = ліва, 1.0 = права).
  final double shineProgress;

  /// Колір монети.
  final Color coinColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Обчислення позиції відблиску
    final shineX = radius + (radius * 2 * (shineProgress - 0.5));
    final shineY = center.dy - radius * 0.3;

    // Кутовий градієнт від центру до позиції відблиску
    final gradient = RadialGradient(
      center: Offset(shineX, shineY),
      radius: radius * 0.6,
      colors: [
        Colors.white.withOpacity(0.35),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: Offset(shineX, shineY),
        radius: radius * 0.6,
      ))
      ..blendMode = BlendMode.overlay;

    canvas.save();
    // Обрізаємо до круглої форми
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoinShinePainter oldDelegate) {
    return oldDelegate.shineProgress != shineProgress ||
        oldDelegate.coinColor != coinColor;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Coin Badge Presets (Передвизначені конфігурації)
// ═══════════════════════════════════════════════════════════════════════════

/// Зручні фабричні методи для створення передвизначених конфігурацій
/// бейджа монет для типових сценаріїв використання.
///
/// Кожен пресет визначає оптимальний набір параметрів:
/// розмір, анімації, відображення мітки, прогрес-кільце тощо.
///
/// Приклад:
/// ```dart
/// // Бейдж для панелі навігації
/// CoinBadgePresets.navigation(coins: 1500);
///
/// // Бейдж для екрана магазину
/// CoinBadgePresets.shopHero(coins: 50000);
/// ```
class CoinBadgePresets {
  CoinBadgePresets._();

  /// Бейдж для панелі навігації (BottomNavigationBar).
  ///
  /// Компактний, без мітки, з можливістю сповіщень.
  static AppCoinBadge navigation({
    required int coins,
    Key? key,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return AppCoinBadge(
      key: key,
      coins: coins,
      size: CoinBadgeSize.small,
      showGlow: false,
      badgeCount: badgeCount,
      onTap: onTap,
    );
  }

  /// Бейдж для рядка списку транзакцій.
  ///
  /// Компактний, з міткою витрати/отримання.
  static AppCoinBadge transactionRow({
    required int coins,
    Key? key,
    int? previousCoins,
    bool showDiff = true,
  }) {
    return AppCoinBadge(
      key: key,
      coins: coins,
      previousCoins: showDiff ? previousCoins : null,
      size: CoinBadgeSize.small,
      showGlow: false,
      showTooltip: showDiff,
    );
  }

  /// Бейдж для карточки товару в магазині.
  ///
  /// Середній, з прогрес-кільцем накопичення.
  static AppCoinBadge shopCard({
    required int coins,
    required double savingsProgress,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppCoinBadge(
      key: key,
      coins: coins,
      size: CoinBadgeSize.medium,
      showGlow: true,
      showRingProgress: true,
      ringProgress: savingsProgress.clamp(0.0, 1.0),
      onTap: onTap,
    );
  }

  /// Бейдж-герой для екрану досягнень.
  ///
  /// Максимальний розмір, з міткою, повільна анімація.
  static AppCoinBadge achievement({
    required int coins,
    Key? key,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return AppCoinBadge.hero(
      key: key,
      coins: coins,
      badgeCount: badgeCount,
      onTap: onTap,
    );
  }

  /// Бейдж для екрана профілю користувача.
  ///
  /// Великий розмір, з міткою «Монети».
  static AppCoinBadge profile({
    required int coins,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppCoinBadge(
      key: key,
      coins: coins,
      size: CoinBadgeSize.large,
      showGlow: true,
      showLabel: true,
      onTap: onTap,
    );
  }

  /// Бейдж для сповіщення про отримання монет.
  ///
  /// З анімацією обертання та відскоку.
  static AppCoinBadge rewardNotification({
    required int coins,
    required int previousCoins,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppCoinBadge(
      key: key,
      coins: coins,
      previousCoins: previousCoins,
      size: CoinBadgeSize.medium,
      showGlow: true,
      spinning: true,
      onTap: onTap,
    );
  }

  /// Бейдж для екрану щоденної нагороди.
  ///
  /// Середній, з прогрес-кільцем щоденного накопичення.
  static AppCoinBadge dailyReward({
    required int coins,
    required double dailyProgress,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppCoinBadge(
      key: key,
      coins: coins,
      size: CoinBadgeSize.medium,
      showGlow: true,
      showRingProgress: true,
      ringProgress: dailyProgress.clamp(0.0, 1.0),
      showLabel: true,
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Additional Helpers — Validation & Computed Properties
// ═══════════════════════════════════════════════════════════════════════════

/// Розширені методи перевірки для [AppCoinBadgeHelpers].
extension CoinBadgeValidationExt on AppCoinBadgeHelpers {
  /// Перевіряє, чи кількість монет є коректною.
  ///
  /// Повертає [true], якщо [coins] >= 0.
  static bool isValidCoinCount(int coins) => coins >= 0;

  /// Перевіряє, чи прогрес-кільце має допустиме значення.
  ///
  /// Повертає [true], якщо [progress] в межах 0.0–1.0.
  static bool isValidProgress(double progress) =>
      progress >= 0.0 && progress <= 1.0;

  /// Перевіряє, чи badgeCount допустиме.
  ///
  /// Повертає [true], якщо [count] є null або >= 0.
  static bool isValidBadgeCount(int? count) =>
      count == null || count >= 0;

  /// Обчислює «тип» суми монет для вибору стилю.
  ///
  /// Повертає рядок-ідентифікатор: 'none', 'small', 'medium', 'large', 'huge'.
  static String coinTier(int coins) {
    if (coins == 0) return 'none';
    if (coins < 100) return 'small';
    if (coins < 1000) return 'medium';
    if (coins < 10000) return 'large';
    return 'huge';
  }

  /// Обчислює локалізовану назву для кількості монет.
  ///
  /// - 0 → «Немає монет»
  /// - 1 → «1 монета»
  /// - 2–4 → «N монети»
  /// - 5+ → «N монет»
  static String localizedCoinName(int coins) {
    if (coins == 0) return 'Немає монет';
    if (coins == 1) return '1 монета';
    final lastTwoDigits = coins % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return '$coins монет';
    }
    final lastDigit = coins % 10;
    if (lastDigit >= 2 && lastDigit <= 4) {
      return '$coins монети';
    }
    return '$coins монет';
  }

  /// Обчислює estimated час накопичення цільової суми.
  ///
  /// [current] — поточний баланс.
  /// [target] — цільова сума.
  /// [dailyRate] — середня кількість монет за день.
  static int estimatedDaysToTarget(int current, int target, int dailyRate) {
    if (dailyRate <= 0) return -1;
    final remaining = (target - current).clamp(0, target);
    return (remaining / dailyRate).ceil();
  }
}
