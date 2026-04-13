import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [AppXpBadge].
class XpBadgeDebugConfig {
  XpBadgeDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати рамку навколо бейджа.
  static bool showDebugBounds = false;

  /// Показувати значення прогресу як текст.
  static bool showProgressValue = false;

  /// Записує debug-повідомлення.
  ///
  /// [message] — текст повідомлення.
  /// [tag] — додатковий тег.
  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[XpBadge:$tag] ' : '[XpBadge] ';
    debugPrint('$prefix$message');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розмір XP-бейджа (XP Badge Size Enum)
// ═══════════════════════════════════════════════════════════════════════════

/// Розмір XP-бейджа для різних контекстів використання.
///
/// Кожен розмір визначає піксельні значення для:
/// - загального розміру (dimension)
/// - розміру іконки зірки (iconSize)
/// - розміру шрифту тексту (fontSize)
/// - товщини кільця прогресу (ringStrokeWidth)
enum AppXpBadgeSize {
  /// Малий (32px) — для списків та compact-інтерфейсів.
  ///
  /// Компактний — для рядків транзакцій, малих карток.
  small(32.0, 10.0, 11.0, 2.0),

  /// Середній (40px) — стандартний для верхньої панелі.
  ///
  /// Оптимальний розмір для більшості контекстів.
  medium(40.0, 14.0, 13.0, 2.5),

  /// Великий (56px) — для виділених секцій.
  ///
  /// Для великих карток, hero-секцій.
  large(56.0, 18.0, 16.0, 3.0);

  const AppXpBadgeSize(
    this.dimension,
    this.iconSize,
    this.fontSize,
    this.ringStrokeWidth,
  );

  /// Розмір бейджа у пікселях.
  final double dimension;

  /// Розмір іконки зірки в пікселях.
  final double iconSize;

  /// Розмір шрифту тексту в пікселях.
  final double fontSize;

  /// Товщина кільця прогресу в пікселях.
  final double ringStrokeWidth;

  /// Розмір тексту мітки під бейджем.
  double get labelFontSize {
    switch (this) {
      case AppXpBadgeSize.small:
        return 8.0;
      case AppXpBadgeSize.medium:
        return 10.0;
      case AppXpBadgeSize.large:
        return 11.0;
    }
  }

  /// Радіус розмиття сяйва для milestone.
  double get milestoneGlowBlur {
    switch (this) {
      case AppXpBadgeSize.small:
        return 6.0;
      case AppXpBadgeSize.medium:
        return 10.0;
      case AppXpBadgeSize.large:
        return 16.0;
    }
  }

  /// Коротка українська назва.
  String get label {
    switch (this) {
      case AppXpBadgeSize.small:
        return 'Малий';
      case AppXpBadgeSize.medium:
        return 'Середній';
      case AppXpBadgeSize.large:
        return 'Великий';
    }
  }

  /// Опис для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case AppXpBadgeSize.small:
        return 'Малий XP-бейдж для списків';
      case AppXpBadgeSize.medium:
        return 'Середній XP-бейдж стандартного розміру';
      case AppXpBadgeSize.large:
        return 'Великий XP-бейдж для виділених секцій';
    }
  }

  /// Чи підходить для відображення тексту.
  bool get canShowText => this != AppXpBadgeSize.small;
}

// ═══════════════════════════════════════════════════════════════════════════
// XP Badge Animation Config
// ═══════════════════════════════════════════════════════════════════════════

/// Конфігурація анімацій для [AppXpBadge].
class XpBadgeAnimationConfig {
  /// Створює конфігурацію анімацій.
  ///
  /// [countUpDuration] — тривалість count-up анімації.
  /// [countUpMinStep] — мінімальний інтервал між кроками (мс).
  /// [countUpMaxStep] — максимальний інтервал між кроками (мс).
  /// [pulseDuration] — тривалість пульсації.
  /// [pulseScale] — максимальний масштаб при пульсації.
  /// [glowPulseDuration] — тривалість пульсації сяйва.
  /// [glowMin] — мінімальна непрозорість сяйва milestone.
  /// [glowMax] — максимальна непрозорість сяйва milestone.
  const XpBadgeAnimationConfig({
    this.countUpDuration = AppDurations.countUp,
    this.countUpMinStep = 8,
    this.countUpMaxStep = 50,
    this.pulseDuration = AppDurations.pulse,
    this.pulseScale = 1.08,
    this.glowPulseDuration = AppDurations.glow,
    this.glowMin = 0.3,
    this.glowMax = 0.6,
  });

  /// Тривалість count-up анімації.
  final Duration countUpDuration;

  /// Мінімальний інтервал між кроками count-up (мс).
  final int countUpMinStep;

  /// Максимальний інтервал між кроками count-up (мс).
  final int countUpMaxStep;

  /// Тривалість пульсації.
  final Duration pulseDuration;

  /// Максимальний масштаб при пульсації.
  final double pulseScale;

  /// Тривалість пульсації сяйва milestone.
  final Duration glowPulseDuration;

  /// Мінімальна непрозорість сяйва.
  final double glowMin;

  /// Максимальна непрозорість сяйва.
  final double glowMax;

  /// Стандартна конфігурація.
  static const XpBadgeAnimationConfig standard = XpBadgeAnimationConfig();

  /// Швидка конфігурація.
  static const XpBadgeAnimationConfig fast = XpBadgeAnimationConfig(
    countUpDuration: Duration(milliseconds: 400),
    pulseDuration: Duration(milliseconds: 300),
  );

  /// Без анімацій.
  static const XpBadgeAnimationConfig none = XpBadgeAnimationConfig(
    countUpDuration: Duration(milliseconds: 0),
    pulseDuration: Duration(milliseconds: 0),
    glowPulseDuration: Duration(milliseconds: 0),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// XP-бейдж віджет (XP Badge Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Круглий бейдж XP з іконкою зірки, анімованим числом та кільцем прогресу.
///
/// Використовується для відображення кількості досвіду користувача.
/// Підтримує розміри, count-up анімацію, свічення на етапах рівня,
/// кастомні кольори, мітку «XP» або номер рівня та кільце прогресу.
///
/// Приклад використання:
/// ```dart
/// AppXpBadge(
///   xp: 2500,
///   size: AppXpBadgeSize.medium,
///   showLabel: true,
///   levelProgress: 0.75,
///   levelNumber: 5,
/// )
/// ```
class AppXpBadge extends StatefulWidget {
  const AppXpBadge({
    super.key,
    required this.xp,
    this.isLightTheme = false,
    this.size = AppXpBadgeSize.medium,
    this.showGlow = true,
    this.showLabel = false,
    this.labelText = 'XP',
    this.animatedCount = false,
    this.levelProgress,
    this.levelNumber,
    this.customXpColor,
    this.onTap,
    this.showPulse = false,
    this.animationConfig = const XpBadgeAnimationConfig.standard,
    this.semanticLabel,
    this.enableTapFeedback = true,
    this.showMilestoneGlow = true,
    this.customBgColor,
  });

  /// Створює компактний бейдж для рядків транзакцій.
  AppXpBadge.compact({
    super.key,
    required this.xp,
    this.isLightTheme = false,
    this.customXpColor,
    this.onTap,
  })  : size = AppXpBadgeSize.small,
        showGlow = false,
        showLabel = false,
        labelText = 'XP',
        animatedCount = false,
        levelProgress = null,
        levelNumber = null,
        showPulse = false,
        animationConfig = const XpBadgeAnimationConfig.none,
        semanticLabel = null,
        enableTapFeedback = true,
        showMilestoneGlow = false,
        customBgColor = null;

  /// Створює великий бейдж для hero-секцій.
  AppXpBadge.hero({
    super.key,
    required this.xp,
    this.isLightTheme = false,
    this.showGlow = true,
    this.showLabel = true,
    this.labelText = 'XP',
    this.animatedCount = true,
    this.levelProgress,
    this.levelNumber,
    this.customXpColor,
    this.onTap,
    this.semanticLabel,
    this.customBgColor,
  })  : size = AppXpBadgeSize.large,
        showPulse = false,
        animationConfig = const XpBadgeAnimationConfig.standard,
        enableTapFeedback = true,
        showMilestoneGlow = true;

  /// Кількість досвіду (XP).
  final int xp;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Розмір бейджа.
  final AppXpBadgeSize size;

  /// Показувати неонове свічення навколо бейджа.
  final bool showGlow;

  /// Показувати текстову мітку під бейджем.
  final bool showLabel;

  /// Текст мітки (за замовчуванням «XP»).
  final String labelText;

  /// Анімувати число (count-up ефект від 0 до [xp]).
  final bool animatedCount;

  /// Прогрес поточного рівня (0.0-1.0) для кільця.
  final double? levelProgress;

  /// Номер поточного рівня (відображається в центрі замість XP).
  final int? levelNumber;

  /// Кастомний колір XP (замість стандартного фіолетового).
  final Color? customXpColor;

  /// Зворотний виклик при натисканні на бейдж.
  final VoidCallback? onTap;

  /// Пульс-анімація бейджа (для привернення уваги при отриманні XP).
  final bool showPulse;

  /// Конфігурація анімацій.
  final XpBadgeAnimationConfig animationConfig;

  /// Семантична мітка для екранних читачів.
  final String? semanticLabel;

  /// Увімкнути тактильний відгук при натисканні.
  final bool enableTapFeedback;

  /// Показувати підсилене свічення при milestone.
  final bool showMilestoneGlow;

  /// Кастомний колір фону.
  final Color? customBgColor;

  @override
  State<AppXpBadge> createState() => _AppXpBadgeState();
}

class _AppXpBadgeState extends State<AppXpBadge> {
  /// Поточне відображуване число XP (для count-up анімації).
  int _displayedXp = 0;

  /// Чи зараз виконується count-up анімація.
  bool _isAnimating = false;

  /// Контролер пульсації milestone-сяйва.
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // ═══════════════════════════════════════════════════════════════════════
  // Гетери кольорів (Color Getters)
  // ═══════════════════════════════════════════════════════════════════════

  /// Колір фону бейджа.
  Color get _bgColor =>
      widget.customBgColor ??
      (widget.isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card);

  /// Колір XP (фіолетовий або кастомний).
  Color get _xpColor =>
      widget.customXpColor ?? AppColorsPS5.xp;

  /// Колір тексту числа XP.
  Color get _textColor =>
      widget.isLightTheme
          ? AppColorsMonitor.textPrimary
          : AppColorsPS5.textPrimary;

  /// Колір тексту мітки під бейджем.
  Color get _labelColor =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  /// Колір кільця прогресу.
  Color get _ringColor =>
      widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;

  /// Колір доріжки кільця прогресу.
  Color get _trackColor =>
      widget.isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;

  // ═══════════════════════════════════════════════════════════════════════
  // Логіка міленів (Milestone Logic)
  // ═══════════════════════════════════════════════════════════════════════

  /// Чи поточне значення XP є етапом рівня.
  bool get _isMilestone =>
      widget.showMilestoneGlow && _isLevelMilestone(widget.xp);

  /// Перевіряє, чи значення XP є "круглим" етапом рівня.
  ///
  /// Круглі етапи: 100, 250, 500, 1000, 2000...
  bool _isLevelMilestone(int xp) {
    if (xp < 50) return false;
    return xp % 500 == 0 || xp % 1000 == 0 || xp % 2500 == 0;
  }

  /// Повертає опис milestone для tooltip.
  String get _milestoneDescription {
    if (!_isMilestone) return '';
    if (widget.xp % 5000 == 0) return '🏆 Великі досягнення!';
    if (widget.xp % 2500 == 0) return '⭐ Значний етап!';
    if (widget.xp % 1000 == 0) return '✨ Рівеньний етап!';
    return '🎯 Етап!';

    // ignore: dead_code
    return '';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Життєвий цикл (Lifecycle)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    XpBadgeDebugConfig.log('initState', tag: 'lifecycle');

    // ── Контролер пульсації milestone ──
    _glowController = AnimationController(
      vsync: this,
      duration: widget.animationConfig.glowPulseDuration,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: widget.animationConfig.glowMin,
      end: widget.animationConfig.glowMax,
    ).animate(
      CurvedAnimation(parent: _glowController, curve: AppEasings.neonGlow),
    );

    _displayedXp = widget.animatedCount ? 0 : widget.xp;
    if (widget.animatedCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateCount();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AppXpBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.xp != oldWidget.xp) {
      XpBadgeDebugConfig.log(
        'XP changed: ${oldWidget.xp} → ${widget.xp}',
        tag: 'update',
      );
      if (widget.animatedCount) {
        _animateCount(from: _displayedXp, to: widget.xp);
      } else {
        setState(() => _displayedXp = widget.xp);
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    XpBadgeDebugConfig.log('dispose', tag: 'lifecycle');
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Validation (Перевірка)
  // ═══════════════════════════════════════════════════════════════════════

  /// Перевіряє коректність параметрів бейджа.
  void _validateParams() {
    assert(
      widget.xp >= 0,
      'XP must be non-negative, got ${widget.xp}',
    );
    assert(
      widget.levelNumber == null || widget.levelNumber! > 0,
      'Level number must be positive',
    );
    assert(
      widget.levelProgress == null ||
          (widget.levelProgress! >= 0.0 && widget.levelProgress! <= 1.0),
      'Level progress must be between 0.0 and 1.0',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Анімація підрахунку (Count-Up Animation)
  // ═══════════════════════════════════════════════════════════════════════

  /// Запускає count-up анімацію числа XP.
  ///
  /// [from] — початкове значення (за замовчуванням 0).
  /// [to] — кінцеве значення (за замовчуванням widget.xp).
  void _animateCount({int? from, int? to}) {
    final start = from ?? 0;
    final end = to ?? widget.xp;
    final range = (end - start).abs();

    if (range == 0) {
      setState(() => _displayedXp = end);
      return;
    }

    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    final durationMs = widget.animationConfig.countUpDuration.inMilliseconds;
    final stepMs = (durationMs / range)
        .clamp(
          widget.animationConfig.countUpMinStep.toDouble(),
          widget.animationConfig.countUpMaxStep.toDouble(),
        )
        .toInt();
    final isIncreasing = end > start;
    var current = start;

    XpBadgeDebugConfig.log(
      'Count-up: $start → $end (step: ${stepMs}ms)',
      tag: 'animation',
    );

    void step() {
      if (!mounted) {
        _isAnimating = false;
        return;
      }

      if ((isIncreasing && current >= end) ||
          (!isIncreasing && current <= end)) {
        setState(() {
          _displayedXp = end;
          _isAnimating = false;
        });
        XpBadgeDebugConfig.log('Count-up complete: $end', tag: 'animation');
        return;
      }

      current += isIncreasing ? 1 : -1;
      setState(() => _displayedXp = current);
      Future.delayed(Duration(milliseconds: stepMs), step);
    }

    step();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Обробники жестів (Gesture Handlers)
  // ═══════════════════════════════════════════════════════════════════════

  /// Обробляє натискання на бейдж.
  void _handleTap() {
    if (widget.enableTapFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
    XpBadgeDebugConfig.log('Tap', tag: 'gesture');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    _validateParams();

    final hasLevelRing =
        widget.levelProgress != null && widget.levelNumber != null;

    Widget badge = GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Контейнер бейджа ──
          AnimatedContainer(
            duration: AppDurations.medium,
            width: hasLevelRing
                ? widget.size.dimension + 8
                : widget.size.dimension,
            height: hasLevelRing
                ? widget.size.dimension + 8
                : widget.size.dimension,
            decoration: _buildDecoration(),
            child: hasLevelRing
                ? _buildLevelRingContent()
                : _buildSimpleContent(),
          ),
          // ── Мітка під бейджем ──
          if (widget.showLabel && widget.size.canShowText) ...[
            const SizedBox(height: 4),
            Text(
              widget.labelText,
              style: AppTypography.labelSmall.copyWith(
                color: _labelColor,
                fontSize: widget.size.labelFontSize,
              ),
            ),
          ],
          // ── Debug: Milestone Description ──
          if (_isMilestone && XpBadgeDebugConfig.showProgressValue) ...[
            const SizedBox(height: 2),
            Text(
              _milestoneDescription,
              style: const TextStyle(fontSize: 8, color: Colors.amber),
            ),
          ],
        ],
      ),
    );

    // ── Pulse Animation ──
    if (widget.showPulse) {
      badge = badge
          .animate(target: widget.showPulse ? 1 : 0)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: Offset(widget.animationConfig.pulseScale, widget.animationConfig.pulseScale),
            duration: widget.animationConfig.pulseDuration,
            curve: Curves.easeInOut,
          );
    }

    // ── Fade In ──
    badge = badge.animate().fadeIn(
      duration: AppDurations.fast,
      curve: AppEasings.decelerate,
    );

    // ── Semantics ──
    return Semantics(
      label: widget.semanticLabel ?? tooltipMessage,
      button: widget.onTap != null,
      value: 'XP: ${_formatXp(widget.xp)}',
      child: badge,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Декорація (Decoration)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує BoxDecoration для бейджа.
  ///
  /// Обирає стиль залежно від наявності кільця рівня та milestone.
  BoxDecoration _buildDecoration() {
    final hasLevelRing =
        widget.levelProgress != null && widget.levelNumber != null;

    if (hasLevelRing) {
      return BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      );
    }

    return BoxDecoration(
      color: _bgColor,
      shape: BoxShape.circle,
      boxShadow: [
        if (widget.showGlow)
          BoxShadow(
            color: _xpColor.withOpacity(
              _isMilestone ? _glowAnimation.value : 0.3,
            ),
            blurRadius: _isMilestone
                ? widget.size.milestoneGlowBlur
                : 8,
            spreadRadius: _isMilestone ? 2 : 1,
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  /// Простий контент (Simple Content - без кільця рівня)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує вміст бейджа без кільця рівня.
  Widget _buildSimpleContent() {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        shape: BoxShape.circle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            color: _xpColor,
            size: widget.size.iconSize,
          ),
          Flexible(
            child: Text(
              _formatXp(_displayedXp),
              style: AppTypography.monoCaption.copyWith(
                color: _textColor,
                fontSize: widget.size.fontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  /// Контент з кільцем рівня (Level Ring Content)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує вміст бейджа з кільцем прогресу рівня.
  Widget _buildLevelRingContent() {
    return SizedBox(
      width: widget.size.dimension + 8,
      height: widget.size.dimension + 8,
      child: CustomPaint(
        painter: _XpBadgeRingPainter(
          progress: (widget.levelProgress ?? 0).clamp(0.0, 1.0),
          strokeWidth: widget.size.ringStrokeWidth,
          ringColor: _ringColor,
          trackColor: _trackColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.levelNumber}',
                style: AppTypography.monoMedium.copyWith(
                  color: _textColor,
                  fontSize: widget.size.fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _formatXp(_displayedXp),
                style: AppTypography.monoCaption.copyWith(
                  color: _xpColor,
                  fontSize: widget.size.fontSize - 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  /// Форматування XP (XP Formatting)
  // ═══════════════════════════════════════════════════════════════════════

  /// Форматує число XP для компактного відображення.
  ///
  /// - 2500 → "2.5K"
  /// - 2500000 → "2.5M"
  String _formatXp(int value) {
    if (value < 0) return '-${_formatPositiveXp(value.abs())}';
    return _formatPositiveXp(value);
  }

  /// Форматує додатне число XP.
  String _formatPositiveXp(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════
  /// Tooltip інформація (Tooltip Info)
  // ═══════════════════════════════════════════════════════════════════════

  /// Повна інформація про XP для tooltip.
  ///
  /// Використовується в Semantics або Tooltip.
  String get tooltipMessage {
    final milestoneNote = _isMilestone ? ' (${_milestoneDescription})' : '';
    if (widget.levelNumber != null && widget.levelProgress != null) {
      final percent = ((widget.levelProgress ?? 0) * 100).toInt();
      return 'XP: ${_formatXp(widget.xp)} • Рівень ${widget.levelNumber} ($percent%)$milestoneNote';
    }
    return 'Досвід: ${_formatXp(widget.xp)}$milestoneNote';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Малювальник кільця XP-бейджа (XP Badge Ring Painter)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник кільцевого прогресу рівня навколо XP-бейджа.
///
/// Малює фонову доріжку та кольорову дугу прогресу.
class _XpBadgeRingPainter extends CustomPainter {
  /// Створює малювальник кільця.
  ///
  /// [progress] — значення прогресу (0.0 - 1.0).
  /// [strokeWidth] — товщина ліній кільця.
  /// [ringColor] — колір дуги прогресу.
  /// [trackColor] — колір фонової доріжки.
  _XpBadgeRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.ringColor,
    required this.trackColor,
  });

  /// Значення прогресу (0.0 - 1.0).
  final double progress;

  /// Товщина ліній кільця.
  final double strokeWidth;

  /// Колір дуги прогресу.
  final Color ringColor;

  /// Колір фонової доріжки.
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final pi = 3.14159265359;

    // ── Доріжка кільця ──
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // ── Дуга прогресу ──
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // ── Точка-індикатор на кінці прогресу ──
      if (progress < 1.0 && progress > 0.02) {
        final dotAngle = -pi / 2 + sweepAngle;
        final dotX = center.dx + radius * math.cos(dotAngle);
        final dotY = center.dy + radius * math.sin(dotAngle);
        final dotPaint = Paint()
          ..color = ringColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(dotX, dotY),
          strokeWidth * 0.7,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _XpBadgeRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Допоміжні методи XP-бейджа (XP Badge Helpers)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з XP бейджами.
class AppXpBadgeHelpers {
  AppXpBadgeHelpers._();

  /// Форматування XP для відображення.
  ///
  /// - 2500 → "2.5K"
  /// - 2500000 → "2.5M"
  static String formatXp(int value) {
    if (value < 0) return '-${_fmtAbs(value.abs())}';
    return _fmtAbs(value);
  }

  static String _fmtAbs(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  /// Розрахунок XP, необхідного для заданого рівня.
  ///
  /// Формула: level * 500 + level² * 100
  static int xpForLevel(int level) {
    return (level * 500) + (level * level * 100);
  }

  /// Повертає прогрес у межах поточного рівня (0.0-1.0).
  ///
  /// [totalXp] — загальна кількість XP користувача.
  /// [currentLevel] — поточний рівень користувача.
  static double levelProgress(int totalXp, int currentLevel) {
    final currentLevelXp = xpForLevel(currentLevel);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    final xpInLevel = totalXp - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;
    if (xpNeeded <= 0) return 1.0;
    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Повертає номер рівня за загальною кількістю XP.
  ///
  /// Використовує пошук для визначення поточного рівня.
  static int levelFromXp(int totalXp) {
    if (totalXp < 0) return 0;
    var level = 0;
    // Обмежуємо пошук для запобігання нескінченному циклу
    final maxLevel = 1000;
    while (level < maxLevel && xpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// Повертає відсоток XP до наступного рівня.
  ///
  /// [totalXp] — загальна кількість XP.
  /// [currentLevel] — поточний рівень.
  static double percentToNextLevel(int totalXp, int currentLevel) {
    return levelProgress(totalXp, currentLevel) * 100;
  }

  /// Повертає XP, необхідний для переходу на наступний рівень.
  ///
  /// [totalXp] — загальна кількість XP.
  /// [currentLevel] — поточний рівень.
  static int xpToNextLevel(int totalXp, int currentLevel) {
    final nextLevelXp = xpForLevel(currentLevel + 1);
    final currentLevelXp = xpForLevel(currentLevel);
    return (nextLevelXp - totalXp).clamp(0, nextLevelXp - currentLevelXp);
  }

  /// Повертає кількість XP зароблену на поточному рівні.
  ///
  /// [totalXp] — загальна кількість XP.
  /// [currentLevel] — поточний рівень.
  static int xpInCurrentLevel(int totalXp, int currentLevel) {
    final currentLevelXp = xpForLevel(currentLevel);
    return (totalXp - currentLevelXp).clamp(0, totalXp);
  }

  /// Повертає XP, необхідний для завершення поточного рівня.
  ///
  /// [currentLevel] — поточний рівень.
  static int xpForNextLevel(int currentLevel) {
    return xpForLevel(currentLevel + 1) - xpForLevel(currentLevel);
  }

  /// Повідомлення про отримання XP.
  static String xpGainedMessage(int amount) {
    return '+${formatXp(amount)} XP отримано!';
  }

  /// Повідомлення про втрату XP (при штрафі).
  static String xpLostMessage(int amount) {
    return '-${formatXp(amount)} XP втрачено';
  }

  /// Повідомлення про підвищення рівня.
  static String levelUpMessage(int newLevel) {
    return '🎉 Рівень $newLevel досягнуто!';
  }

  /// Повідомлення про прогрес у рівні.
  ///
  /// [percent] — відсоток прогресу (0-100).
  static String levelProgressMessage(int percent) {
    return 'Прогрес рівня: $percent%';
  }

  /// Повертає опис для accessibility.
  static String accessibilityLabel(int xp, {int? level}) {
    if (level != null) {
      return 'Досвід: ${formatXp(xp)}, рівень $level';
    }
    return 'Досвід: ${formatXp(xp)}';
  }

  /// Обчислює рекомендований розмір бейджа.
  ///
  /// Залежить від кількості XP та наявності кільця рівня.
  static AppXpBadgeSize recommendSize(int xp, {bool hasLevelRing = false}) {
    if (hasLevelRing) return AppXpBadgeSize.large;
    if (xp >= 10000) return AppXpBadgeSize.large;
    if (xp >= 1000) return AppXpBadgeSize.medium;
    return AppXpBadgeSize.small;
  }

  /// Перевіряє, чи XP є milestone (круглим етапом).
  ///
  /// Milestone: 100, 250, 500, 1000, 2500, 5000...
  static bool isMilestone(int xp) {
    if (xp < 50) return false;
    return xp % 500 == 0 || xp % 1000 == 0 || xp % 2500 == 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions (Утиліти-розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [int] з форматуванням XP.
extension XpFormatExtension on int {
  /// Форматує число як XP.
  ///
  /// 2500.formatAsXp() → "2.5K"
  String formatAsXp() => AppXpBadgeHelpers.formatXp(this);

  /// Визначає рівень для цього XP.
  int get level => AppXpBadgeHelpers.levelFromXp(this);

  /// Чи це milestone.
  bool get isXpMilestone => AppXpBadgeHelpers.isMilestone(this);
}

/// Розширення для [AppXpBadgeSize].
extension AppXpBadgeSizeExtension on AppXpBadgeSize {
  /// Наступний розмір.
  AppXpBadgeSize get next {
    if (index >= AppXpBadgeSize.values.length - 1) return this;
    return AppXpBadgeSize.values[index + 1];
  }

  /// Попередній розмір.
  AppXpBadgeSize get previous {
    if (index <= 0) return this;
    return AppXpBadgeSize.values[index - 1];
  }

  /// Чи це найбільший доступний розмір.
  bool get isMax => this == AppXpBadgeSize.large;

  /// Чи це найменший доступний розмір.
  bool get isMin => this == AppXpBadgeSize.small;

  /// Площа бейджа в пікселях².
  double get area => math.pi * (dimension / 2) * (dimension / 2);

  /// Діаметр кільця з кільцем рівня (з урахуванням +8px відступу).
  double get ringDiameter => dimension + 8;

  /// Коефіцієнт масштабування тіні відносно розміру.
  double get shadowScaleFactor {
    switch (this) {
      case AppXpBadgeSize.small:
        return 0.6;
      case AppXpBadgeSize.medium:
        return 0.8;
      case AppXpBadgeSize.large:
        return 1.0;
    }
  }

  /// Мінімальна висота контейнера з міткою під бейджем.
  double get minTotalHeight {
    switch (this) {
      case AppXpBadgeSize.small:
        return dimension;
      case AppXpBadgeSize.medium:
        return dimension + 14.0;
      case AppXpBadgeSize.large:
        return dimension + 15.0;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// XP Badge Theme Data (Тема для XP-бейджа)
// ═══════════════════════════════════════════════════════════════════════════

/// Незмінні дані теми для кастомізації [AppXpBadge].
///
/// Дозволяє визначити палітру кольорів та інтенсивності
/// для XP-бейджа і повторно використовувати їх.
///
/// Приклад:
/// ```dart
/// final theme = XpBadgeThemeData(
///   xpColor: Colors.blueAccent,
///   bgColor: Colors.grey[900]!,
///   glowIntensity: 0.8,
/// );
/// AppXpBadge(xp: 2500, themeData: theme);
/// ```
class XpBadgeThemeData {
  /// Створює дані теми для XP-бейджа.
  ///
  /// [xpColor] — колір XP (зірка, кільце, текст XP).
  /// [bgColor] — колір фону.
  /// [textColor] — колір тексту числа.
  /// [labelColor] — колір тексту мітки.
  /// [ringColor] — колір кільця прогресу.
  /// [trackColor] — колір доріжки кільця.
  /// [glowIntensity] — інтенсивність milestone-сяйва (0.0–1.0).
  const XpBadgeThemeData({
    this.xpColor,
    this.bgColor,
    this.textColor,
    this.labelColor,
    this.ringColor,
    this.trackColor,
    this.glowIntensity = 0.5,
  });

  /// Колір XP.
  final Color? xpColor;

  /// Колір фону.
  final Color? bgColor;

  /// Колір тексту.
  final Color? textColor;

  /// Колір мітки.
  final Color? labelColor;

  /// Колір кільця прогресу.
  final Color? ringColor;

  /// Колір доріжки кільця.
  final Color? trackColor;

  /// Інтенсивність сяйва.
  final double glowIntensity;

  /// Стандартна темна тема.
  static const XpBadgeThemeData dark = XpBadgeThemeData(
    glowIntensity: 0.6,
  );

  /// Стандартна світла тема.
  static const XpBadgeThemeData light = XpBadgeThemeData(
    glowIntensity: 0.3,
  );

  /// Преміум тема з підвищеним сяйвом.
  static const XpBadgeThemeData premium = XpBadgeThemeData(
    glowIntensity: 0.9,
  );

  /// Об'єднує цю тему з [other], заповнюючи null-значення.
  XpBadgeThemeData merge(XpBadgeThemeData? other) {
    if (other == null) return this;
    return XpBadgeThemeData(
      xpColor: other.xpColor ?? xpColor,
      bgColor: other.bgColor ?? bgColor,
      textColor: other.textColor ?? textColor,
      labelColor: other.labelColor ?? labelColor,
      ringColor: other.ringColor ?? ringColor,
      trackColor: other.trackColor ?? trackColor,
      glowIntensity: other.glowIntensity,
    );
  }

  /// Повертає копію з перезаписаними полями.
  XpBadgeThemeData copyWith({
    Color? xpColor,
    Color? bgColor,
    Color? textColor,
    Color? labelColor,
    Color? ringColor,
    Color? trackColor,
    double? glowIntensity,
  }) {
    return XpBadgeThemeData(
      xpColor: xpColor ?? this.xpColor,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      labelColor: labelColor ?? this.labelColor,
      ringColor: ringColor ?? this.ringColor,
      trackColor: trackColor ?? this.trackColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XpBadgeThemeData &&
        other.xpColor == xpColor &&
        other.bgColor == bgColor &&
        other.textColor == textColor &&
        other.labelColor == labelColor &&
        other.ringColor == ringColor &&
        other.trackColor == trackColor &&
        other.glowIntensity == glowIntensity;
  }

  @override
  int get hashCode => Object.hash(
        xpColor,
        bgColor,
        textColor,
        labelColor,
        ringColor,
        trackColor,
        glowIntensity,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// XP Badge Milestone Decorator (Декоратор milestone)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник декоративних елементів навколо milestone XP-бейджа.
///
/// Малює кілька обертових променів, що створюють ефект «зірки»
/// навколо бейджа при досягненні milestone.
class _XpMilestoneDecorator extends CustomPainter {
  /// Створює декоратор milestone.
  ///
  /// [rayCount] — кількість променів.
  /// [glowOpacity] — непрозорість променів.
  /// [color] — колір променів.
  const _XpMilestoneDecorator({
    required this.rayCount,
    required this.glowOpacity,
    required this.color,
  });

  /// Кількість променів.
  final int rayCount;

  /// Непрозорість променів.
  final double glowOpacity;

  /// Колір променів.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 + 6;

    final rayPaint = Paint()
      ..color = color.withOpacity(glowOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi * i) / rayCount;
      final innerR = maxRadius * 0.7;
      final outerR = maxRadius;

      final x1 = center.dx + math.cos(angle) * innerR;
      final y1 = center.dy + math.sin(angle) * innerR;
      final x2 = center.dx + math.cos(angle) * outerR;
      final y2 = center.dy + math.sin(angle) * outerR;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rayPaint);
    }

    // Малюємо зовнішнє кільце
    final ringPaint = Paint()
      ..color = color.withOpacity(glowOpacity * 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _XpMilestoneDecorator oldDelegate) {
    return oldDelegate.glowOpacity != glowOpacity ||
        oldDelegate.color != color ||
        oldDelegate.rayCount != rayCount;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// XP Badge Presets (Передвизначені конфігурації)
// ═══════════════════════════════════════════════════════════════════════════

/// Зручні фабричні методи для створення XP-бейджів.
///
/// Кожен пресет оптимізує параметри для типового сценарію:
/// навігація, профіль, досягнення, список завдань тощо.
///
/// Приклад:
/// ```dart
/// // Бейдж для профілю
/// XpBadgePresets.profile(xp: 5000, level: 5, levelProgress: 0.75);
/// ```
class XpBadgePresets {
  XpBadgePresets._();

  /// Бейдж для панелі інструментів (AppBar).
  ///
  /// Стандартний розмір, без мітки, без кільця.
  static AppXpBadge appBar({
    required int xp,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppXpBadge(
      key: key,
      xp: xp,
      size: AppXpBadgeSize.medium,
      showGlow: false,
      onTap: onTap,
    );
  }

  /// Бейдж для рядка списку завдань.
  ///
  /// Компактний, без анімацій.
  static AppXpBadge taskRow({
    required int xp,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppXpBadge.compact(
      key: key,
      xp: xp,
      onTap: onTap,
    );
  }

  /// Бейдж для екрана профілю з рівнем.
  ///
  /// Великий, з кільцем прогресу рівня.
  static AppXpBadge profile({
    required int xp,
    required int level,
    required double levelProgress,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppXpBadge(
      key: key,
      xp: xp,
      size: AppXpBadgeSize.large,
      showGlow: true,
      showLabel: true,
      levelNumber: level,
      levelProgress: levelProgress.clamp(0.0, 1.0),
      onTap: onTap,
    );
  }

  /// Бейдж-герой для екрана досягнень.
  ///
  /// Великий, з count-up анімацією та milestone-сяйвом.
  static AppXpBadge achievement({
    required int xp,
    Key? key,
    int? level,
    VoidCallback? onTap,
  }) {
    return AppXpBadge.hero(
      key: key,
      xp: xp,
      levelNumber: level,
      onTap: onTap,
    );
  }

  /// Бейдж для екрана daily-завдань.
  ///
  /// Середній, з пульсацією для привернення уваги.
  static AppXpBadge dailyQuest({
    required int xp,
    Key? key,
    VoidCallback? onTap,
  }) {
    return AppXpBadge(
      key: key,
      xp: xp,
      size: AppXpBadgeSize.medium,
      showGlow: true,
      showPulse: true,
      onTap: onTap,
    );
  }

  /// Бейдж для екрану level-up святкування.
  ///
  /// З count-up анімацією та підсвічуванням.
  static AppXpBadge levelUp({
    required int xp,
    required int newLevel,
    Key? key,
  }) {
    return AppXpBadge(
      key: key,
      xp: xp,
      size: AppXpBadgeSize.large,
      showGlow: true,
      showLabel: true,
      labelText: 'Рівень $newLevel',
      animatedCount: true,
      showPulse: true,
      showMilestoneGlow: true,
    );
  }

  /// Бейдж для статистичного звіту.
  ///
  /// Без сяйва, без анімацій — чітке відображення.
  static AppXpBadge stats({
    required int xp,
    Key? key,
    int? level,
    double? levelProgress,
  }) {
    return AppXpBadge(
      key: key,
      xp: xp,
      size: AppXpBadgeSize.medium,
      showGlow: false,
      showLabel: true,
      levelNumber: level,
      levelProgress: levelProgress,
      animatedCount: false,
      showMilestoneGlow: false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// XP Badge Validation & Computed Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширені методи перевірки та обчислення для XP.
extension XpBadgeValidationExt on AppXpBadgeHelpers {
  /// Перевіряє коректність значення XP.
  ///
  /// Повертає [true], якщо [xp] >= 0.
  static bool isValidXp(int xp) => xp >= 0;

  /// Перевіряє коректність номера рівня.
  ///
  /// Повертає [true], якщо [level] є null або > 0.
  static bool isValidLevel(int? level) => level == null || level > 0;

  /// Перевіряє коректність прогресу рівня.
  ///
  /// Повертає [true], якщо [progress] є null або в межах 0.0–1.0.
  static bool isValidLevelProgress(double? progress) =>
      progress == null || (progress >= 0.0 && progress <= 1.0);

  /// Обчислює «ранг» користувача за XP.
  ///
  /// Ранги: 'Новачок', 'Учень', 'Володар', 'Майстер', 'Легенда'.
  static String xpRank(int totalXp) {
    final level = levelFromXp(totalXp);
    if (level >= 50) return 'Легенда';
    if (level >= 30) return 'Майстер';
    if (level >= 15) return 'Володар';
    if (level >= 5) return 'Учень';
    return 'Новачок';
  }

  /// Обчислює кількість XP, отриманих за останній рівень.
  ///
  /// [totalXp] — загальна кількість XP.
  /// [currentLevel] — поточний рівень.
  static int lastLevelXpGain(int totalXp, int currentLevel) {
    final prevLevelXp = xpForLevel(currentLevel);
    return (totalXp - prevLevelXp).clamp(0, totalXp);
  }

  /// Обчислює загальну кількість XP для списку рівнів.
  ///
  /// Корисно для відображення прогресу по кількох рівнях.
  ///
  /// [levels] — список рівнів для підсумку.
  static int totalXpForLevels(List<int> levels) {
    return levels.fold<int>(0, (sum, level) => sum + xpForLevel(level));
  }

  /// Повертає опис тренувального етапу для XP.
  ///
  /// - 0–500 → «Початок шляху»
  /// - 500–2000 → «Перші кроки»
  /// - 2000–5000 → «Середовище»
  /// - 5000–15000 → «Просунутий»
  /// - 15000+ → «Експерт»
  static String xpStage(int xp) {
    if (xp < 500) return 'Початок шляху';
    if (xp < 2000) return 'Перші кроки';
    if (xp < 5000) return 'Середовище';
    if (xp < 15000) return 'Просунутий';
    return 'Експерт';
  }

  /// Обчислює XP на годину на основі загального XP та днів.
  ///
  /// [totalXp] — загальна кількість XP.
  /// [activeDays] — кількість днів активності.
  /// [avgDailyHours] — середньо годин на день (за замовчуванням 1.0).
  static double xpPerHour(int totalXp, int activeDays, {double avgDailyHours = 1.0}) {
    if (activeDays <= 0 || avgDailyHours <= 0) return 0.0;
    return totalXp / (activeDays * avgDailyHours);
  }
}

