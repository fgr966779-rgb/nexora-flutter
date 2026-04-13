import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Тип скелетного заповнювача (Skeleton Type)
// ═══════════════════════════════════════════════════════════════════════════

/// Тип скелетного заповнювача для різних UI-патернів.
///
/// Кожен тип має власні значення за замовчуванням для розміру
/// та форми скелетного елемента.
enum SkeletonType {
  /// Горизонтальна лінія — для тексту, заголовків, описів.
  line,

  /// Коло — для аватарів, іконок, фотографій.
  circle,

  /// Картка з кількома лініями — для карток цілей, товарів.
  card,

  /// Аватар з текстовими лініями поруч — для списків користувачів.
  avatar,

  /// Список елементів — для повного списку транзакцій.
  list,

  /// Графік — стовпчики або лінійний графік.
  chart,

  /// Статистика — велике число з малим текстом під ним.
  stats,

  /// Кнопка — прямокутна скелетна кнопка.
  button,

  /// Чіп — компактний скелетний чіп.
  chip,

  /// Зображення — скелетне фото або іконка.
  image,

  /// Профіль — аватар з ім'ям, електронною поштою та бейджем.
  profile,

  /// Хедер — широкий рядок заголовка з підзаголовком.
  header,

  /// Таблиця — сітка з комірками для табличних даних.
  table,

  /// Чат-бульбашка — для повідомлень у чаті.
  chatBubble,

  /// Стрічка новин — горизонтальна картка з текстом та зображенням.
  feedItem,
}

// ═══════════════════════════════════════════════════════════════════════════
// Ефекти скелетного заповнювача (Skeleton Effect)
// ═══════════════════════════════════════════════════════════════════════════

/// Тип візуального ефекту скелетного заповнювача.
///
/// Визначає, як анімується підсвітка під час завантаження.
enum SkeletonEffect {
  /// Стандартний рухомий градієнт зліва направо.
  shimmer,

  /// Пульсуючий ефект — плавне згасання та appearing.
  pulse,

  /// Хвильовий ефект — послідовне appearing елементів.
  wave,

  /// Градієнтна хвиля — поєднання градієнта та хвилі.
  gradientWave,

  /// Статичний — без анімації, лише колір фону.
  none,
}

// ═══════════════════════════════════════════════════════════════════════════
// Основний віджет (Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Shimmer-заповнювач для стану завантаження.
///
/// Рендерить контейнер з сірим фоном та градієнтною анімацією
/// рухомої підсвітки (shimmer effect).
///
/// Підтримує:
/// - Різні типи [SkeletonType] з автоматичними налаштуваннями
/// - Готові пресети: card, transaction, stats, chart, button
/// - Кастомні кольори shimmer для адаптації до теми
/// - Регулювання швидкості анімації
/// - Адаптація кольорів до PS5 / Monitor теми
/// - Різні ефекти анімації (shimmer, pulse, wave)
/// - Респонсивне масштабування розмірів
/// - Кастомні темні кольори для різних палітр
///
/// Приклад використання:
/// ```dart
/// // Проста лінія
/// Skeleton(type: SkeletonType.line, width: 200),
///
/// // Картка пресет
/// SkeletonCard(),
///
/// // Список транзакцій
/// SkeletonList(itemCount: 5),
///
/// // Профіль пресет
/// SkeletonProfile(),
///
/// // Кастомний ефект пульсу
/// AppSkeleton(type: SkeletonType.circle, effect: SkeletonEffect.pulse),
/// ```
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.type = SkeletonType.line,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.isLightTheme = false,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.speedMultiplier = 1.0,
    this.direction = SkeletonDirection.ltr,
    this.effect = SkeletonEffect.shimmer,
    this.delayMultiplier = 0.0,
    this.responsiveScale = 1.0,
  });

  /// Тип скелетного елемента.
  final SkeletonType type;

  /// Ширина (null = автоматична залежно від типу).
  final double? width;

  /// Висота в пікселях.
  final double height;

  /// Кастомний радіус кутів (null = автоматичний залежно від типу).
  final double? borderRadius;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Кастомний базовий колір shimmer (темний фон смуги).
  final Color? shimmerBaseColor;

  /// Кастомний колір підсвітки shimmer (світла смуга).
  final Color? shimmerHighlightColor;

  /// Множник швидкості анімації (1.0 = стандартна, 2.0 = двічі швидше).
  final double speedMultiplier;

  /// Напрямок руху shimmer підсвітки.
  final SkeletonDirection direction;

  /// Тип візуального ефекту анімації.
  final SkeletonEffect effect;

  /// Затримка появи для хвильового ефекту (0.0–1.0).
  final double delayMultiplier;

  /// Множник масштабування для адаптивних розмірів.
  final double responsiveScale;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

/// Напрямок руху shimmer підсвітки.
enum SkeletonDirection {
  /// Зліва направо — стандартний напрямок.
  ltr,

  /// Справа наліво — зворотний напрямок.
  rtl,

  /// Зверху вниз — вертикальний напрямок.
  ttb,

  /// Знизу вгору — зворотний вертикальний напрямок.
  btt,
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  /// Контролер анімації shimmer.
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant AppSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedMultiplier != widget.speedMultiplier ||
        oldWidget.effect != widget.effect) {
      _initController();
    }
  }

  /// Ініціалізує або переініціалізує контролер анімації.
  void _initController() {
    final baseDuration = widget.effect == SkeletonEffect.pulse
        ? const Duration(milliseconds: 1200)
        : widget.effect == SkeletonEffect.wave
            ? const Duration(milliseconds: 1500)
            : AppDurations.skeleton;

    final duration = widget.speedMultiplier > 0
        ? Duration(
            milliseconds: (baseDuration.inMilliseconds /
                    widget.speedMultiplier)
                .round(),
          )
        : baseDuration;

    if (_controller.isAnimating) {
      _controller.dispose();
    }
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Кольори (Colors)
  // ═══════════════════════════════════════════════════════════════════════

  /// Базовий колір shimmer (темний фон).
  Color get _baseColor =>
      widget.shimmerBaseColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.shimmerBase
          : AppColorsPS5.shimmerBase);

  /// Колір підсвітки shimmer (світла смуга).
  Color get _highlightColor =>
      widget.shimmerHighlightColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.shimmerHighlight
          : AppColorsPS5.shimmerHighlight);

  /// Колір для пульсуючого ефекту (напівпрозорий акцент).
  Color get _pulseColor =>
      (widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent)
          .withOpacity(0.08);

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? _defaultRadius;
    final scaledWidth = widget.width != null
        ? widget.width! * widget.responsiveScale
        : _defaultWidth != null
            ? _defaultWidth! * widget.responsiveScale
            : null;
    final scaledHeight = widget.height * widget.responsiveScale;

    // Статичний ефект без анімації
    if (widget.effect == SkeletonEffect.none) {
      return _buildStatic(effectiveRadius, scaledWidth, scaledHeight);
    }

    // Пульсуючий ефект
    if (widget.effect == SkeletonEffect.pulse) {
      return _buildPulse(effectiveRadius, scaledWidth, scaledHeight);
    }

    // Хвильовий ефект
    if (widget.effect == SkeletonEffect.wave) {
      return _buildWave(effectiveRadius, scaledWidth, scaledHeight);
    }

    // Градієнтна хвиля
    if (widget.effect == SkeletonEffect.gradientWave) {
      return _buildGradientWave(effectiveRadius, scaledWidth, scaledHeight);
    }

    // Стандартний shimmer
    return _buildShimmer(effectiveRadius, scaledWidth, scaledHeight);
  }

  /// Будує статичний скелетний елемент без анімації.
  Widget _buildStatic(
      double effectiveRadius, double? effectiveWidth, double effectiveHeight) {
    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
    );
  }

  /// Будує скелетний елемент з пульсуючим ефектом.
  Widget _buildPulse(
      double effectiveRadius, double? effectiveWidth, double effectiveHeight) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final opacity = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(value * 2 * math.pi));
        return Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: _baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(effectiveRadius),
          ),
        );
      },
    );
  }

  /// Будує скелетний елемент з хвильовим ефектом.
  Widget _buildWave(
      double effectiveRadius, double? effectiveWidth, double effectiveHeight) {
    final delay = widget.delayMultiplier * 0.5;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = ((1 - delay) - (1 - delay) * _controller.value);
        final opacity = (0.3 + 0.7 * value).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: effectiveWidth,
            height: effectiveHeight,
            decoration: BoxDecoration(
              color: _baseColor,
              borderRadius: BorderRadius.circular(effectiveRadius),
            ),
          ),
        );
      },
    );
  }

  /// Будує скелетний елемент з градієнтною хвилею.
  Widget _buildGradientWave(
      double effectiveRadius, double? effectiveWidth, double effectiveHeight) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * value, -1 + 2 * value),
              end: Alignment(1 - 2 * value, 1 - 2 * value),
              colors: [
                _baseColor,
                _highlightColor.withOpacity(0.6),
                _baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  /// Будує стандартний shimmer-ефект.
  Widget _buildShimmer(
      double effectiveRadius, double? effectiveWidth, double effectiveHeight) {
    // Обчислення напрямку руху shimmer
    final isVertical = widget.direction == SkeletonDirection.ttb ||
        widget.direction == SkeletonDirection.btt;
    final value = widget.direction == SkeletonDirection.rtl ||
            widget.direction == SkeletonDirection.btt
        ? 1.0 - 2.0 * _controller.value
        : -1.0 + 2.0 * _controller.value;
    final valueOffset = widget.direction == SkeletonDirection.rtl ||
            widget.direction == SkeletonDirection.btt
        ? -0.6
        : 0.6;

    final begin = isVertical
        ? Alignment(0.0, value + valueOffset)
        : Alignment(value + valueOffset, 0.0);
    final end = isVertical
        ? Alignment(0.0, value - valueOffset)
        : Alignment(value - valueOffset, 0.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                _baseColor,
                _highlightColor,
                _baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  /// Радіус кутів за замовчуванням залежно від типу.
  double get _defaultRadius {
    switch (widget.type) {
      case SkeletonType.circle:
      case SkeletonType.avatar:
      case SkeletonType.image:
      case SkeletonType.profile:
        return 100; // Повне заокруглення = коло
      case SkeletonType.card:
      case SkeletonType.chart:
      case SkeletonType.stats:
      case SkeletonType.button:
      case SkeletonType.table:
      case SkeletonType.feedItem:
        return Radii.md;
      case SkeletonType.chip:
      case SkeletonType.chatBubble:
        return Radii.circular;
      case SkeletonType.header:
        return Radii.lg;
      default:
        return Radii.sm;
    }
  }

  /// Ширина за замовчуванням залежно від типу.
  double? get _defaultWidth {
    switch (widget.type) {
      case SkeletonType.circle:
      case SkeletonType.avatar:
      case SkeletonType.image:
        return widget.height; // Квадратна форма
      case SkeletonType.card:
      case SkeletonType.chart:
      case SkeletonType.stats:
      case SkeletonType.button:
      case SkeletonType.table:
      case SkeletonType.feedItem:
        return double.infinity; // На всю ширину
      default:
        return null; // Використовує widget.width
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Пресети скелетних компонентів (Preset Skeletons)
// ═══════════════════════════════════════════════════════════════════════════

/// Скелетон картки з іконкою та текстовими лініями.
///
/// Імітує вигляд картки цілі під час завантаження.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.isLightTheme = false,
    this.width = 200,
    this.height = 120,
    this.showIcon = true,
    this.showFooter = true,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Ширина картки.
  final double width;

  /// Висота картки.
  final double height;

  /// Показувати скелетну іконку.
  final bool showIcon;

  /// Показувати нижній рядок картки.
  final bool showFooter;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Рядок заголовка з іконкою ──
          if (showIcon) ...[
            Row(
              children: [
                AppSkeleton(
                  type: SkeletonType.circle,
                  height: 32,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppSkeleton(
                    type: SkeletonType.line,
                    width: double.infinity,
                    height: 12,
                    isLightTheme: isLightTheme,
                    effect: effect,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // ── Заголовок ──
          AppSkeleton(
            type: SkeletonType.line,
            width: width * 0.6,
            height: 14,
            isLightTheme: isLightTheme,
            effect: effect,
          ),
          const SizedBox(height: 12),
          // ── Велике число ──
          AppSkeleton(
            type: SkeletonType.line,
            width: width * 0.8,
            height: 24,
            isLightTheme: isLightTheme,
            effect: effect,
          ),
          const SizedBox(height: 8),
          // ── Прогрес-бар ──
          AppSkeleton(
            type: SkeletonType.line,
            width: double.infinity,
            height: 6,
            borderRadius: 3,
            isLightTheme: isLightTheme,
            effect: effect,
          ),
          const SizedBox(height: 8),
          // ── Нижній рядок ──
          if (showFooter)
            AppSkeleton(
              type: SkeletonType.line,
              width: width * 0.4,
              height: 10,
              isLightTheme: isLightTheme,
              effect: effect,
            ),
        ],
      ),
    );
  }
}

/// Скелетон транзакції — аватар, дві лінії тексту, сума.
///
/// Імітує вигляд рядка транзакції під час завантаження.
class SkeletonTransaction extends StatelessWidget {
  const SkeletonTransaction({
    super.key,
    this.isLightTheme = false,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // ── Іконка (кругла) ──
          AppSkeleton(
            type: SkeletonType.circle,
            height: 40,
            isLightTheme: isLightTheme,
            effect: effect,
          ),
          const SizedBox(width: 12),
          // ── Текстові лінії ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  type: SkeletonType.line,
                  width: double.infinity,
                  height: 14,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
                const SizedBox(height: 6),
                AppSkeleton(
                  type: SkeletonType.line,
                  width: 100,
                  height: 10,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Сума ──
          AppSkeleton(
            type: SkeletonType.line,
            width: 70,
            height: 14,
            isLightTheme: isLightTheme,
            effect: effect,
          ),
        ],
      ),
    );
  }
}

/// Скелетон статистики — велике число + малий текст.
///
/// Імітує вигляд блоку статистики під час завантаження.
class SkeletonStats extends StatelessWidget {
  const SkeletonStats({
    super.key,
    this.isLightTheme = false,
    this.itemCount = 3,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Кількість елементів статистики.
  final int itemCount;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Заголовок ──
        AppSkeleton(
          type: SkeletonType.line,
          width: 120,
          height: 16,
          isLightTheme: isLightTheme,
          effect: effect,
        ),
        const SizedBox(height: 16),
        // ── Елементи статистики ──
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: List.generate(itemCount, (index) {
            return SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(
                    type: SkeletonType.line,
                    width: 80,
                    height: 28,
                    isLightTheme: isLightTheme,
                    effect: effect,
                    delayMultiplier: index * 0.2,
                  ),
                  const SizedBox(height: 6),
                  AppSkeleton(
                    type: SkeletonType.line,
                    width: 60,
                    height: 10,
                    isLightTheme: isLightTheme,
                    effect: effect,
                    delayMultiplier: index * 0.2,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Скелетон графіка — кілька стовпчиків.
///
/// Імітує вигляд вертикального графіка під час завантаження.
class SkeletonChart extends StatelessWidget {
  const SkeletonChart({
    super.key,
    this.isLightTheme = false,
    this.barCount = 7,
    this.height = 120,
    this.effect = SkeletonEffect.shimmer,
    this.showLabels = true,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Кількість стовпчиків.
  final int barCount;

  /// Висота графіка.
  final double height;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  /// Показувати мітки під стовпчиками.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(barCount, (index) {
              final barHeight = 20.0 + random.nextDouble() * (height - 40);
              return AppSkeleton(
                type: SkeletonType.line,
                width: 24,
                height: barHeight,
                borderRadius: 6,
                isLightTheme: isLightTheme,
                effect: effect,
                delayMultiplier: index * 0.1,
              );
            }),
          ),
        ),
        // ── Мітки днів під графіком ──
        if (showLabels) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(barCount, (index) {
              return AppSkeleton(
                type: SkeletonType.line,
                width: 20,
                height: 8,
                borderRadius: 4,
                isLightTheme: isLightTheme,
                effect: effect,
                delayMultiplier: index * 0.1,
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Скелетон кнопки — прямокутна форма.
///
/// Імітує вигляд кнопки під час завантаження.
class SkeletonButton extends StatelessWidget {
  const SkeletonButton({
    super.key,
    this.isLightTheme = false,
    this.width = 200,
    this.height = 48,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Ширина кнопки.
  final double width;

  /// Висота кнопки.
  final double height;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      type: SkeletonType.button,
      width: width,
      height: height,
      isLightTheme: isLightTheme,
      effect: effect,
    );
  }
}

/// Скелетон профілю — аватар, ім'я, пошта, бейдж.
///
/// Імітує вигляд блоку профілю користувача під час завантаження.
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({
    super.key,
    this.isLightTheme = false,
    this.effect = SkeletonEffect.shimmer,
    this.showEmail = true,
    this.showLevelBadge = true,
    this.showStats = true,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  /// Показувати рядок електронної пошти.
  final bool showEmail;

  /// Показувати бейдж рівня.
  final bool showLevelBadge;

  /// Показувати рядок статистики.
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Аватар ──
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              AppSkeleton(
                type: SkeletonType.circle,
                height: 80,
                isLightTheme: isLightTheme,
                effect: effect,
              ),
              // ── Бейдж рівня ──
              if (showLevelBadge)
                AppSkeleton(
                  type: SkeletonType.line,
                  width: 40,
                  height: 18,
                  borderRadius: 9,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Ім'я ──
          AppSkeleton(
            type: SkeletonType.line,
            width: 140,
            height: 18,
            isLightTheme: isLightTheme,
            effect: effect,
          ),
          const SizedBox(height: 6),
          // ── Електронна пошта ──
          if (showEmail)
            AppSkeleton(
              type: SkeletonType.line,
              width: 180,
              height: 12,
              isLightTheme: isLightTheme,
              effect: effect,
            ),
          const SizedBox(height: 12),
          // ── Рядок статистики ──
          if (showStats)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSkeleton(
                  type: SkeletonType.line,
                  width: 60,
                  height: 10,
                  isLightTheme: isLightTheme,
                  effect: effect,
                  delayMultiplier: 0.1,
                ),
                const SizedBox(width: 16),
                AppSkeleton(
                  type: SkeletonType.line,
                  width: 60,
                  height: 10,
                  isLightTheme: isLightTheme,
                  effect: effect,
                  delayMultiplier: 0.2,
                ),
                const SizedBox(width: 16),
                AppSkeleton(
                  type: SkeletonType.line,
                  width: 60,
                  height: 10,
                  isLightTheme: isLightTheme,
                  effect: effect,
                  delayMultiplier: 0.3,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Скелетон таблиці — сітка з комірками.
///
/// Імітує вигляд таблиці з даними під час завантаження.
class SkeletonTable extends StatelessWidget {
  const SkeletonTable({
    super.key,
    this.isLightTheme = false,
    this.rowCount = 4,
    this.columnCount = 3,
    this.rowHeight = 40,
    this.headerHeight = 32,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Кількість рядків (без заголовка).
  final int rowCount;

  /// Кількість стовпців.
  final int columnCount;

  /// Висота рядка.
  final double rowHeight;

  /// Висота рядка заголовка.
  final double headerHeight;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Заголовок таблиці ──
        Row(
          children: List.generate(columnCount, (col) {
            return Expanded(
              child: AppSkeleton(
                type: SkeletonType.line,
                height: 12,
                isLightTheme: isLightTheme,
                effect: effect,
                delayMultiplier: col * 0.1,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // ── Рядки даних ──
        ...List.generate(rowCount, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: List.generate(columnCount, (col) {
                final widths = [0.6, 0.8, 0.4];
                return Expanded(
                  child: AppSkeleton(
                    type: SkeletonType.line,
                    height: 12,
                    isLightTheme: isLightTheme,
                    effect: effect,
                    delayMultiplier: (row + col) * 0.08,
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

/// Скелетон чат-бульбашки — для повідомлень.
///
/// Імітує вигляд повідомлення у чаті під час завантаження.
class SkeletonChatBubble extends StatelessWidget {
  const SkeletonChatBubble({
    super.key,
    this.isLightTheme = false,
    this.isOwnMessage = false,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Чи це повідомлення поточного користувача.
  final bool isOwnMessage;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(Radii.base),
              topRight: const Radius.circular(Radii.base),
              bottomLeft: Radius.circular(isOwnMessage ? Radii.base : Radii.sm),
              bottomRight: Radius.circular(isOwnMessage ? Radii.sm : Radii.base),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                type: SkeletonType.line,
                width: double.infinity,
                height: 12,
                isLightTheme: isLightTheme,
                effect: effect,
              ),
              const SizedBox(height: 6),
              AppSkeleton(
                type: SkeletonType.line,
                width: 120,
                height: 12,
                isLightTheme: isLightTheme,
                effect: effect,
              ),
              const SizedBox(height: 4),
              AppSkeleton(
                type: SkeletonType.line,
                width: 60,
                height: 8,
                isLightTheme: isLightTheme,
                effect: effect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Скелетон стрічки новин — горизонтальна картка.
///
/// Імітує вигляд елемента стрічки під час завантаження.
class SkeletonFeedItem extends StatelessWidget {
  const SkeletonFeedItem({
    super.key,
    this.isLightTheme = false,
    this.effect = SkeletonEffect.shimmer,
    this.showImage = true,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  /// Показувати скелетне зображення.
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage) ...[
            AppSkeleton(
              type: SkeletonType.image,
              height: 64,
              isLightTheme: isLightTheme,
              effect: effect,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  type: SkeletonType.line,
                  width: double.infinity,
                  height: 14,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
                const SizedBox(height: 8),
                AppSkeleton(
                  type: SkeletonType.line,
                  width: double.infinity,
                  height: 10,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
                const SizedBox(height: 6),
                AppSkeleton(
                  type: SkeletonType.line,
                  width: 80,
                  height: 8,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Список скелетних елементів (Skeleton List)
// ═══════════════════════════════════════════════════════════════════════════

/// Список скелетних елементів.
///
/// Генерує [itemCount] скелетних елементів з опціональним кастомним білдером.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.itemCount,
    this.isLightTheme = false,
    this.itemBuilder,
    this.effect = SkeletonEffect.shimmer,
  });

  /// Кількість елементів у списку.
  final int itemCount;

  /// Світла тема.
  final bool isLightTheme;

  /// Кастомний білдер для кожного елемента.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        if (itemBuilder != null) {
          return itemBuilder!(context, index);
        }
        return SkeletonTransaction(
          isLightTheme: isLightTheme,
          effect: effect,
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Helper Methods)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для створення тематизованих скелетних компонентів.
class SkeletonHelpers {
  SkeletonHelpers._();

  /// Повертає базовий колір shimmer для вказаної теми.
  static Color baseColorForTheme(bool isLightTheme) {
    return isLightTheme ? AppColorsMonitor.shimmerBase : AppColorsPS5.shimmerBase;
  }

  /// Повертає колір підсвітки shimmer для вказаної теми.
  static Color highlightColorForTheme(bool isLightTheme) {
    return isLightTheme
        ? AppColorsMonitor.shimmerHighlight
        : AppColorsPS5.shimmerHighlight;
  }

  /// Повертає колір фону картки для вказаної теми.
  static Color cardColorForTheme(bool isLightTheme) {
    return isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card;
  }

  /// Повертає адаптивний множник масштабу залежно від ширини екрана.
  ///
  /// [screenWidth] — ширина екрана в пікселях.
  /// [baseWidth] — базова ширина (за замовчуванням 375).
  static double responsiveScale(double screenWidth, {double baseWidth = 375}) {
    return (screenWidth / baseWidth).clamp(0.85, 1.3);
  }

  /// Створює повний екранний скелетний оверлей.
  ///
  /// Зручний для показу під час початкового завантаження екрану.
  static Widget fullScreenOverlay({
    required bool isLightTheme,
    SkeletonEffect effect = SkeletonEffect.shimmer,
  }) {
    return Container(
      color: isLightTheme
          ? AppColorsMonitor.background
          : AppColorsPS5.background,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Перевіряє чи кількість елементів списку є валідною.
  ///
  /// [itemCount] — кількість елементів для відображення.
  ///
  /// Повертає `true` якщо [itemCount] у межах 1–100.
  static bool isValidItemCount(int itemCount) {
    return itemCount > 0 && itemCount <= 100;
  }

  /// Обмежує кількість елементів до безпечного діапазону.
  ///
  /// [itemCount] — бажана кількість.
  /// [maxCount] — максимальна кількість (за замовчуванням 20).
  ///
  /// Повертає значення в діапазоні 1–[maxCount].
  static int clampItemCount(int itemCount, {int maxCount = 20}) {
    return itemCount.clamp(1, maxCount);
  }

  /// Повертає відсоткову ширину лінії відносно контейнера.
  ///
  /// [percentage] — відсоток від 0.0 до 1.0.
  /// [containerWidth] — ширина контейнера.
  static double lineWidthFromPercentage(double percentage, double containerWidth) {
    return (percentage.clamp(0.0, 1.0) * containerWidth).toDouble();
  }

  /// Обчислює затримку для хвильового ефекту.
  ///
  /// [index] — індекс елемента в списку.
  /// [totalItems] — загальна кількість елементів.
  ///
  /// Повертає значення від 0.0 до 1.0 для [delayMultiplier].
  static double waveDelay(int index, int totalItems) {
    if (totalItems <= 1) return 0.0;
    return (index / totalItems).clamp(0.0, 1.0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація скелетних компонентів (Skeleton Configuration)
// ═══════════════════════════════════════════════════════════════════════════

/// Клас конфігурації для скелетних компонентів.
///
/// Об'єднує всі налаштування скелетних віджетів в один об'єкт
/// для зручного управління та повторного використання.
///
/// Приклад створення:
/// ```dart
/// final config = SkeletonConfig(
///   isLightTheme: true,
///   effect: SkeletonEffect.pulse,
///   speedMultiplier: 1.5,
/// );
/// ```
class SkeletonConfig {
  /// Створює конфігурацію з усіма параметрами.
  const SkeletonConfig({
    this.isLightTheme = false,
    this.effect = SkeletonEffect.shimmer,
    this.speedMultiplier = 1.0,
    this.direction = SkeletonDirection.ltr,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.responsiveScale = 1.0,
  });

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  /// Множник швидкості анімації.
  final double speedMultiplier;

  /// Напрямок руху shimmer.
  final SkeletonDirection direction;

  /// Кастомний базовий колір.
  final Color? shimmerBaseColor;

  /// Кастомний колір підсвітки.
  final Color? shimmerHighlightColor;

  /// Множник масштабування.
  final double responsiveScale;

  /// Створює копію конфігурації з перевизначенням.
  SkeletonConfig copyWith({
    bool? isLightTheme,
    SkeletonEffect? effect,
    double? speedMultiplier,
    SkeletonDirection? direction,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    double? responsiveScale,
  }) {
    return SkeletonConfig(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      effect: effect ?? this.effect,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      direction: direction ?? this.direction,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor:
          shimmerHighlightColor ?? this.shimmerHighlightColor,
      responsiveScale: responsiveScale ?? this.responsiveScale,
    );
  }

  /// Базовий колір shimmer для вказаної теми.
  Color get baseColor => shimmerBaseColor ??
      (isLightTheme
          ? AppColorsMonitor.shimmerBase
          : AppColorsPS5.shimmerBase);

  /// Колір підсвітки shimmer для вказаної теми.
  Color get highlightColor => shimmerHighlightColor ??
      (isLightTheme
          ? AppColorsMonitor.shimmerHighlight
          : AppColorsPS5.shimmerHighlight);

  /// Колір фону картки для вказаної теми.
  Color get cardColor =>
      isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkeletonConfig &&
          runtimeType == other.runtimeType &&
          isLightTheme == other.isLightTheme &&
          effect == other.effect &&
          speedMultiplier == other.speedMultiplier &&
          direction == other.direction;

  @override
  int get hashCode =>
      Object.hash(isLightTheme, effect, speedMultiplier, direction);
}

// ═══════════════════════════════════════════════════════════════════════════
// Предвизначені конфігурації (Preset Configurations)
// ═══════════════════════════════════════════════════════════════════════════

/// Передвизначені конфігурації для скелетних компонентів.
///
/// Дозволяє швидко обрати потрібний стиль без створення об'єкта.
class SkeletonConfigs {
  SkeletonConfigs._();

  /// Стандартна конфігурація для темної теми PS5.
  static const SkeletonConfig ps5 = SkeletonConfig(
    isLightTheme: false,
    effect: SkeletonEffect.shimmer,
    speedMultiplier: 1.0,
    direction: SkeletonDirection.ltr,
  );

  /// Стандартна конфігурація для світлої теми Monitor.
  static const SkeletonConfig monitor = SkeletonConfig(
    isLightTheme: true,
    effect: SkeletonEffect.shimmer,
    speedMultiplier: 1.0,
    direction: SkeletonDirection.ltr,
  );

  /// Швидка пульсуюча конфігурація (для швидкого завантаження).
  static const SkeletonConfig fastPulse = SkeletonConfig(
    isLightTheme: false,
    effect: SkeletonEffect.pulse,
    speedMultiplier: 2.0,
  );

  /// Повільна хвильова конфігурація (для великих списків).
  static const SkeletonConfig slowWave = SkeletonConfig(
    isLightTheme: false,
    effect: SkeletonEffect.wave,
    speedMultiplier: 0.5,
  );

  /// Статична конфігурація без анімації (для режиму економії заряду).
  static const SkeletonConfig static = SkeletonConfig(
    isLightTheme: false,
    effect: SkeletonEffect.none,
  );

  /// Градієнтна хвиля (для привабливого завантаження).
  static const SkeletonConfig gradient = SkeletonConfig(
    isLightTheme: false,
    effect: SkeletonEffect.gradientWave,
    speedMultiplier: 1.0,
  );

  /// Створює конфігурацію з вертикальним напрямком.
  static SkeletonConfig vertical({
    bool isLightTheme = false,
    SkeletonEffect effect = SkeletonEffect.shimmer,
  }) {
    return SkeletonConfig(
      isLightTheme: isLightTheme,
      effect: effect,
      direction: SkeletonDirection.ttb,
    );
  }

  /// Створює конфігурацію з реверсивним напрямком.
  static SkeletonConfig reversed({
    bool isLightTheme = false,
    SkeletonEffect effect = SkeletonEffect.shimmer,
  }) {
    return SkeletonConfig(
      isLightTheme: isLightTheme,
      effect: effect,
      direction: SkeletonDirection.rtl,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення типів (Type Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [SkeletonType] з додатковими властивостями.
extension SkeletonTypeExtension on SkeletonType {
  /// Чи тип має круглу форму за замовчуванням.
  bool get isCircular => [
    SkeletonType.circle,
    SkeletonType.avatar,
    SkeletonType.image,
    SkeletonType.profile,
  ].contains(this);

  /// Чи тип має квадратну ширину за замовчуванням.
  bool get isSquare => [
    SkeletonType.circle,
    SkeletonType.avatar,
    SkeletonType.image,
  ].contains(this);

  /// Чи тип займає всю ширину контейнера.
  bool get isFullWidth => [
    SkeletonType.card,
    SkeletonType.chart,
    SkeletonType.stats,
    SkeletonType.button,
    SkeletonType.table,
    SkeletonType.feedItem,
    SkeletonType.list,
  ].contains(this);

  /// Радіус кутів за замовчуванням для цього типу.
  double defaultRadius() {
    switch (this) {
      case SkeletonType.circle:
      case SkeletonType.avatar:
      case SkeletonType.image:
      case SkeletonType.profile:
        return 100.0;
      case SkeletonType.card:
      case SkeletonType.chart:
      case SkeletonType.stats:
      case SkeletonType.button:
      case SkeletonType.table:
      case SkeletonType.feedItem:
        return Radii.md;
      case SkeletonType.chip:
      case SkeletonType.chatBubble:
        return Radii.circular;
      case SkeletonType.header:
        return Radii.lg;
      default:
        return Radii.sm;
    }
  }

  /// Типова висота в пікселях для цього типу.
  double defaultHeight() {
    switch (this) {
      case SkeletonType.line:
        return 16.0;
      case SkeletonType.circle:
        return 40.0;
      case SkeletonType.avatar:
        return 48.0;
      case SkeletonType.button:
        return 48.0;
      case SkeletonType.chip:
        return 32.0;
      case SkeletonType.image:
        return 64.0;
      case SkeletonType.header:
        return 24.0;
      default:
        return 16.0;
    }
  }

  /// Кількість скелетних ліній для цього типу (для пресетів).
  int defaultLineCount() {
    switch (this) {
      case SkeletonType.card:
        return 4;
      case SkeletonType.transaction:
        return 3;
      case SkeletonType.profile:
        return 3;
      case SkeletonType.feedItem:
        return 3;
      case SkeletonType.chatBubble:
        return 3;
      case SkeletonType.avatar:
        return 2;
      default:
        return 1;
    }
  }

  /// Українська назва типу для дебагу та логування.
  String get localizedName {
    switch (this) {
      case SkeletonType.line:
        return 'Лінія';
      case SkeletonType.circle:
        return 'Коло';
      case SkeletonType.card:
        return 'Картка';
      case SkeletonType.avatar:
        return 'Аватар';
      case SkeletonType.list:
        return 'Список';
      case SkeletonType.chart:
        return 'Графік';
      case SkeletonType.stats:
        return 'Статистика';
      case SkeletonType.button:
        return 'Кнопка';
      case SkeletonType.chip:
        return 'Чіп';
      case SkeletonType.image:
        return 'Зображення';
      case SkeletonType.profile:
        return 'Профіль';
      case SkeletonType.header:
        return 'Заголовок';
      case SkeletonType.table:
        return 'Таблиця';
      case SkeletonType.chatBubble:
        return 'Чат-бульбашка';
      case SkeletonType.feedItem:
        return 'Стрічка';
    }
  }
}

/// Розширення для [SkeletonEffect] з додатковими властивостями.
extension SkeletonEffectExtension on SkeletonEffect {
  /// Чи ефект включає анімацію.
  bool get isAnimated => this != SkeletonEffect.none;

  /// Чи ефект використовує градієнт.
  bool get isGradient =>
      this == SkeletonEffect.shimmer || this == SkeletonEffect.gradientWave;

  /// Чи ефект використовує затримку для хвильового ефекту.
  bool get usesDelay =>
      this == SkeletonEffect.wave || this == SkeletonEffect.gradientWave;

  /// Базова тривалість ефекту в мілісекундах.
  int baseDurationMs() {
    switch (this) {
      case SkeletonEffect.pulse:
        return 1200;
      case SkeletonEffect.wave:
        return 1500;
      case SkeletonEffect.shimmer:
        return AppDurations.skeleton.inMilliseconds;
      case SkeletonEffect.gradientWave:
        return AppDurations.skeleton.inMilliseconds;
      case SkeletonEffect.none:
        return 0;
    }
  }

  /// Українська назва ефекту для дебагу та логування.
  String get localizedName {
    switch (this) {
      case SkeletonEffect.shimmer:
        return 'Мерехтіння';
      case SkeletonEffect.pulse:
        return 'Пульс';
      case SkeletonEffect.wave:
        return 'Хвиля';
      case SkeletonEffect.gradientWave:
        return 'Градієнтна хвиля';
      case SkeletonEffect.none:
        return 'Без ефекту';
    }
  }
}

/// Розширення для [SkeletonDirection] з додатковими властивостями.
extension SkeletonDirectionExtension on SkeletonDirection {
  /// Чи напрямок вертикальний.
  bool get isVertical =>
      this == SkeletonDirection.ttb || this == SkeletonDirection.btt;

  /// Чи напрямок зворотний.
  bool get isReversed =>
      this == SkeletonDirection.rtl || this == SkeletonDirection.btt;

  /// Обернений напрямок.
  SkeletonDirection get reversed {
    switch (this) {
      case SkeletonDirection.ltr:
        return SkeletonDirection.rtl;
      case SkeletonDirection.rtl:
        return SkeletonDirection.ltr;
      case SkeletonDirection.ttb:
        return SkeletonDirection.btt;
      case SkeletonDirection.btt:
        return SkeletonDirection.ttb;
    }
  }

  /// Українська назва напрямку для дебагу.
  String get localizedName {
    switch (this) {
      case SkeletonDirection.ltr:
        return 'Зліва направо';
      case SkeletonDirection.rtl:
        return 'Справа наліво';
      case SkeletonDirection.ttb:
        return 'Зверху вниз';
      case SkeletonDirection.btt:
        return 'Знизу вгору';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідація (Validation)
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатори для параметрів скелетних компонентів.
///
/// Забезпечують безпечні значення для всіх конфігураційних параметрів.
class SkeletonValidators {
  SkeletonValidators._();

  /// Мінімальна допустима висота скелетного елемента.
  static const double minHeight = 1.0;

  /// Максимальна допустима висота скелетного елемента.
  static const double maxHeight = 500.0;

  /// Мінімальний допустимий множник швидкості.
  static const double minSpeedMultiplier = 0.1;

  /// Максимальний допустимий множник швидкості.
  static const double maxSpeedMultiplier = 5.0;

  /// Мінімальний допустимий множник масштабування.
  static const double minResponsiveScale = 0.5;

  /// Максимальний допустимий множник масштабування.
  static const double maxResponsiveScale = 2.0;

  /// Мінімальна кількість елементів у списку.
  static const int minItemCount = 1;

  /// Максимальна кількість елементів у списку.
  static const int maxItemCount = 50;

  /// Валідує висоту скелетного елемента.
  ///
  /// Повертає висоту в безпечному діапазоні [minHeight, maxHeight].
  static double validateHeight(double height) {
    return height.clamp(minHeight, maxHeight);
  }

  /// Валідує множник швидкості.
  ///
  /// Повертає множник в безпечному діапазоні.
  static double validateSpeedMultiplier(double multiplier) {
    return multiplier.clamp(minSpeedMultiplier, maxSpeedMultiplier);
  }

  /// Валідує множник масштабування.
  ///
  /// Повертає множник в безпечному діапазоні.
  static double validateResponsiveScale(double scale) {
    return scale.clamp(minResponsiveScale, maxResponsiveScale);
  }

  /// Валідує кількість елементів.
  ///
  /// Повертає кількість в безпечному діапазоні.
  static int validateItemCount(int count) {
    return count.clamp(minItemCount, maxItemCount);
  }

  /// Валідує затримку хвильового ефекту.
  ///
  /// Повертає затримку в діапазоні 0.0–1.0.
  static double validateDelayMultiplier(double delay) {
    return delay.clamp(0.0, 1.0);
  }

  /// Валідує кількість стовпчиків графіка.
  ///
  /// Повертає кількість в діапазоні 2–14.
  static int validateBarCount(int count) {
    return count.clamp(2, 14);
  }

  /// Валідує кількість рядків таблиці.
  ///
  /// Повертає кількість в діапазоні 1–20.
  static int validateRowCount(int count) {
    return count.clamp(1, 20);
  }

  /// Валідує кількість стовпців таблиці.
  ///
  /// Повертає кількість в діапазоні 1–8.
  static int validateColumnCount(int count) {
    return count.clamp(1, 8);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Тема-білдер (Theme Builder)
// ═══════════════════════════════════════════════════════════════════════════

/// Білдер теми для скелетних компонентів.
///
/// Дозволяє створювати кастомні палітри shimmer-кольорів
/// для різних тем додатку або брендування.
///
/// Приклад використання:
/// ```dart
/// final theme = SkeletonThemeBuilder()
///   .withBaseColor(const Color(0xFF1A1A2E))
///   .withHighlightColor(const Color(0xFF16213E))
///   .build();
/// ```
class SkeletonThemeBuilder {
  /// Створює білдер з дефолтними значеннями для темної теми.
  SkeletonThemeBuilder({
    Color? baseColor,
    Color? highlightColor,
    this.opacity = 1.0,
    this.cornerRadius = Radii.sm,
  })  : _baseColor = baseColor,
        _highlightColor = highlightColor;

  /// Кастомний базовий колір shimmer.
  final Color? _baseColor;

  /// Кастомний колір підсвітки shimmer.
  final Color? _highlightColor;

  /// Загальна прозорість скелетних елементів.
  final double opacity;

  /// Загальний радіус кутів для скелетних елементів.
  final double cornerRadius;

  /// Поточний базовий колір (або null).
  Color? get baseColor => _baseColor;

  /// Поточний колір підсвітки (або null).
  Color? get highlightColor => _highlightColor;

  /// Встановлює базовий колір shimmer.
  SkeletonThemeBuilder withBaseColor(Color color) {
    return SkeletonThemeBuilder(
      baseColor: color,
      highlightColor: _highlightColor,
      opacity: opacity,
      cornerRadius: cornerRadius,
    );
  }

  /// Встановлює колір підсвітки shimmer.
  SkeletonThemeBuilder withHighlightColor(Color color) {
    return SkeletonThemeBuilder(
      baseColor: _baseColor,
      highlightColor: color,
      opacity: opacity,
      cornerRadius: cornerRadius,
    );
  }

  /// Встановлює загальну прозорість.
  SkeletonThemeBuilder withOpacity(double value) {
    return SkeletonThemeBuilder(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      opacity: value.clamp(0.1, 1.0),
      cornerRadius: cornerRadius,
    );
  }

  /// Встановлює загальний радіус кутів.
  SkeletonThemeBuilder withCornerRadius(double radius) {
    return SkeletonThemeBuilder(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      opacity: opacity,
      cornerRadius: radius,
    );
  }

  /// Створює конфігурацію з поточними налаштуваннями.
  ///
  /// Використовує PS5/Monitor кольори як fallback.
  SkeletonConfig build({bool isLightTheme = false}) {
    return SkeletonConfig(
      isLightTheme: isLightTheme,
      shimmerBaseColor:
          _baseColor?.withOpacity(opacity),
      shimmerHighlightColor:
          _highlightColor?.withOpacity(opacity),
    );
  }

  /// Створює конфігурацію для світлої теми.
  SkeletonConfig buildLight() => build(isLightTheme: true);

  /// Створює конфігурацію для темної теми.
  SkeletonConfig buildDark() => build(isLightTheme: false);

  /// Створює конфігурацію з градієнтним хвильовим ефектом.
  SkeletonConfig buildGradient({bool isLightTheme = false}) {
    return SkeletonConfig(
      isLightTheme: isLightTheme,
      effect: SkeletonEffect.gradientWave,
      shimmerBaseColor:
          _baseColor?.withOpacity(opacity),
      shimmerHighlightColor:
          _highlightColor?.withOpacity(opacity),
    );
  }

  /// Створює конфігурацію з пульсуючим ефектом.
  SkeletonConfig buildPulse({bool isLightTheme = false}) {
    return SkeletonConfig(
      isLightTheme: isLightTheme,
      effect: SkeletonEffect.pulse,
      shimmerBaseColor:
          _baseColor?.withOpacity(opacity),
      shimmerHighlightColor:
          _highlightColor?.withOpacity(opacity),
    );
  }

  @override
  String toString() =>
      'SkeletonThemeBuilder(baseColor: $_baseColor, '
      'highlightColor: $_highlightColor, '
      'opacity: $opacity, '
      'cornerRadius: $cornerRadius)';
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація скелетного заповнювача (Skeleton Configuration)
// ═══════════════════════════════════════════════════════════════════════════

/// Незмінна конфігурація для скелетних віджетів.
///
/// Об'єднує всі параметри скелетного заповнювача в один об'єкт.
/// Використовується для стандартизації вигляду скелетонів у всьому додатку.
///
/// Приклад:
/// ```dart
/// final config = SkeletonConfig(
///   isLightTheme: true,
///   effect: SkeletonEffect.pulse,
///   speedMultiplier: 0.8,
/// );
/// ```
class SkeletonConfig {
  const SkeletonConfig({
    this.isLightTheme = false,
    this.effect = SkeletonEffect.shimmer,
    this.speedMultiplier = 1.0,
    this.direction = SkeletonDirection.ltr,
    this.responsiveScale = 1.0,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.defaultBorderRadius,
    this.defaultHeight = 16.0,
    this.animationDelay = 0.0,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  /// Множник швидкості анімації.
  final double speedMultiplier;

  /// Напрямок руху shimmer.
  final SkeletonDirection direction;

  /// Множник масштабування.
  final double responsiveScale;

  /// Кастомний базовий колір.
  final Color? shimmerBaseColor;

  /// Кастомний колір підсвітки.
  final Color? shimmerHighlightColor;

  /// Радіус кутів за замовчуванням.
  final double? defaultBorderRadius;

  /// Висота за замовчуванням.
  final double defaultHeight;

  /// Затримка анімації.
  final double animationDelay;

  /// Створює копію з перевизначенням.
  SkeletonConfig copyWith({
    bool? isLightTheme,
    SkeletonEffect? effect,
    double? speedMultiplier,
    SkeletonDirection? direction,
    double? responsiveScale,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    double? defaultBorderRadius,
    double? defaultHeight,
    double? animationDelay,
  }) {
    return SkeletonConfig(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      effect: effect ?? this.effect,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      direction: direction ?? this.direction,
      responsiveScale: responsiveScale ?? this.responsiveScale,
      shimmerBaseColor: shimmerBaseColor ?? this.shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor ?? this.shimmerHighlightColor,
      defaultBorderRadius: defaultBorderRadius ?? this.defaultBorderRadius,
      defaultHeight: defaultHeight ?? this.defaultHeight,
      animationDelay: animationDelay ?? this.animationDelay,
    );
  }

  /// Створює AppSkeleton з цією конфігурацією.
  AppSkeleton build({
    SkeletonType type = SkeletonType.line,
    double? width,
    double? height,
    double? borderRadius,
    double? delayMultiplier,
  }) {
    return AppSkeleton(
      type: type,
      width: width,
      height: height ?? defaultHeight,
      borderRadius: borderRadius ?? defaultBorderRadius,
      isLightTheme: isLightTheme,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      speedMultiplier: speedMultiplier,
      direction: direction,
      effect: effect,
      delayMultiplier: delayMultiplier ?? animationDelay,
      responsiveScale: responsiveScale,
    );
  }

  /// Створює лінію скелетного заповнювача.
  AppSkeleton line({double? width, double height = 16.0}) {
    return build(type: SkeletonType.line, width: width, height: height);
  }

  /// Створює круглий скелетний заповнювач.
  AppSkeleton circle({double size = 40.0}) {
    return build(type: SkeletonType.circle, height: size);
  }

  /// Створює скелетну кнопку.
  AppSkeleton button({double width = 200.0, double height = 48.0}) {
    return build(type: SkeletonType.button, width: width, height: height);
  }

  /// Створює скелетний чіп.
  AppSkeleton chip({double width = 80.0, double height = 28.0}) {
    return build(type: SkeletonType.chip, width: width, height: height);
  }

  /// Створює скелетне зображення.
  AppSkeleton image({double size = 64.0}) {
    return build(type: SkeletonType.image, height: size);
  }

  /// Створює скелетний аватар.
  AppSkeleton avatar({double size = 44.0}) {
    return build(type: SkeletonType.avatar, height: size);
  }

  /// Створює скелетний хедер.
  AppSkeleton header({double? width, double height = 24.0}) {
    return build(type: SkeletonType.header, width: width, height: height);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkeletonConfig &&
          isLightTheme == other.isLightTheme &&
          effect == other.effect &&
          speedMultiplier == other.speedMultiplier;

  @override
  int get hashCode => Object.hash(isLightTheme, effect, speedMultiplier);

  @override
  String toString() =>
      'SkeletonConfig(isLight: $isLightTheme, effect: $effect, '
      'speed: $speedMultiplier, scale: $responsiveScale)';
}

// ═══════════════════════════════════════════════════════════════════════════
// Предвизначені конфігурації (Preset Configurations)
// ═══════════════════════════════════════════════════════════════════════════

/// Предвизначені конфігурації для стандартних випадків.
class SkeletonPresets {
  SkeletonPresets._();

  /// Стандартна конфігурація для темної теми.
  static const SkeletonConfig dark = SkeletonConfig(
    isLightTheme: false,
    effect: SkeletonEffect.shimmer,
    speedMultiplier: 1.0,
  );

  /// Стандартна конфігурація для світлої теми.
  static const SkeletonConfig light = SkeletonConfig(
    isLightTheme: true,
    effect: SkeletonEffect.shimmer,
    speedMultiplier: 1.0,
  );

  /// Повільна пульсуюча конфігурація.
  static const SkeletonConfig slowPulse = SkeletonConfig(
    effect: SkeletonEffect.pulse,
    speedMultiplier: 0.6,
  );

  /// Швидка хвильова конфігурація.
  static const SkeletonConfig fastWave = SkeletonConfig(
    effect: SkeletonEffect.wave,
    speedMultiplier: 1.8,
  );

  /// Градієнтна конфігурація.
  static const SkeletonConfig gradient = SkeletonConfig(
    effect: SkeletonEffect.gradientWave,
    speedMultiplier: 1.2,
  );

  /// Статична конфігурація без анімації.
  static const SkeletonConfig noAnimation = SkeletonConfig(
    effect: SkeletonEffect.none,
  );

  /// Конфігурація для таблиць.
  static const SkeletonConfig table = SkeletonConfig(
    effect: SkeletonEffect.shimmer,
    speedMultiplier: 0.9,
    defaultHeight: 12.0,
  );

  /// Конфігурація для карток.
  static const SkeletonConfig card = SkeletonConfig(
    effect: SkeletonEffect.shimmer,
    speedMultiplier: 1.0,
    defaultHeight: 14.0,
  );

  /// Конфігурація для списків.
  static const SkeletonConfig list = SkeletonConfig(
    effect: SkeletonEffect.wave,
    speedMultiplier: 1.0,
    defaultHeight: 56.0,
  );

  /// Повертає конфігурацію залежно від теми.
  static SkeletonConfig forTheme(bool isLightTheme) {
    return isLightTheme ? light : dark;
  }

  /// Повертає конфігурацію залежно від ефекту.
  static SkeletonConfig forEffect(SkeletonEffect effect) {
    return switch (effect) {
      SkeletonEffect.shimmer => dark,
      SkeletonEffect.pulse => slowPulse,
      SkeletonEffect.wave => fastWave,
      SkeletonEffect.gradientWave => gradient,
      SkeletonEffect.none => noAnimation,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Helper Utilities)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні утиліти для роботи зі скелетними заповнювачами.
class SkeletonHelpers {
  SkeletonHelpers._();

  /// Повертає рекомендовану висоту для типу скелетного елемента.
  static double recommendedHeight(SkeletonType type) {
    switch (type) {
      case SkeletonType.line:
        return 16.0;
      case SkeletonType.circle:
      case SkeletonType.avatar:
        return 40.0;
      case SkeletonType.card:
        return 120.0;
      case SkeletonType.chart:
        return 120.0;
      case SkeletonType.stats:
        return 48.0;
      case SkeletonType.button:
        return 48.0;
      case SkeletonType.chip:
        return 28.0;
      case SkeletonType.image:
        return 64.0;
      case SkeletonType.profile:
        return 80.0;
      case SkeletonType.header:
        return 24.0;
      case SkeletonType.table:
        return 40.0;
      case SkeletonType.chatBubble:
        return 60.0;
      case SkeletonType.feedItem:
        return 80.0;
      case SkeletonType.list:
        return 56.0;
    }
  }

  /// Повертає рекомендований радіус для типу скелетного елемента.
  static double recommendedRadius(SkeletonType type) {
    switch (type) {
      case SkeletonType.circle:
      case SkeletonType.avatar:
      case SkeletonType.image:
      case SkeletonType.profile:
        return 100;
      case SkeletonType.card:
      case SkeletonType.chart:
      case SkeletonType.stats:
      case SkeletonType.button:
      case SkeletonType.table:
      case SkeletonType.feedItem:
        return Radii.md;
      case SkeletonType.chip:
      case SkeletonType.chatBubble:
        return Radii.circular;
      case SkeletonType.header:
        return Radii.lg;
      default:
        return Radii.sm;
    }
  }

  /// Обчислює кількість скелетних ліній для текстового блоку.
  static int calculateLineCount({
    required double lineHeight,
    required double totalHeight,
  }) {
    if (lineHeight <= 0) return 0;
    return (totalHeight / lineHeight).ceil().clamp(1, 20);
  }

  /// Генерує список затримок для хвильового ефекту.
  static List<double> generateWaveDelays({
    required int count,
    double baseDelay = 0.0,
    double step = 0.1,
  }) {
    return List.generate(
      count,
      (index) => (baseDelay + index * step).clamp(0.0, 1.0),
    );
  }

  /// Обчислює оптимальну ширину скелетної лінії у відсотках.
  static double lineWidthPercent({
    required int lineIndex,
    required int totalLines,
  }) {
    if (totalLines <= 0) return 1.0;
    if (lineIndex >= totalLines - 1) {
      return 0.3 + (0.2 / totalLines);
    }
    return 0.8 + (0.2 * (totalLines - 1 - lineIndex) / totalLines);
  }

  /// Перевіряє чи параметри скелетного елемента валідні.
  static String? validate({
    double? width,
    required double height,
    double? speedMultiplier,
    double? responsiveScale,
  }) {
    if (height <= 0) return 'Висота повинна бути > 0 (отримано: $height)';
    if (width != null && width <= 0) {
      return 'Ширина повинна бути > 0 (отримано: $width)';
    }
    if (speedMultiplier != null && speedMultiplier <= 0) {
      return 'Множник швидкості повинен бути > 0';
    }
    if (responsiveScale != null && responsiveScale <= 0) {
      return 'Множник масштабу повинен бути > 0';
    }
    return null;
  }

  /// Повертає тривалість анімації в мілісекундах.
  static int effectDurationMs(SkeletonEffect effect, {double speed = 1.0}) {
    final baseMs = switch (effect) {
      SkeletonEffect.shimmer => 1500,
      SkeletonEffect.pulse => 1200,
      SkeletonEffect.wave => 1500,
      SkeletonEffect.gradientWave => 1800,
      SkeletonEffect.none => 0,
    };
    if (speed <= 0) return baseMs;
    return (baseMs / speed).round().clamp(200, 10000);
  }

  /// Обчислює кількість елементів, що поміщаються на екрані.
  static int itemsOnScreen({
    required double availableHeight,
    required double itemHeight,
    double spacing = 8.0,
  }) {
    if (itemHeight <= 0) return 0;
    final effectiveItemHeight = itemHeight + spacing;
    return (availableHeight / effectiveItemHeight).floor().clamp(1, 50);
  }

  /// Створює BoxConstraints для скелетного елемента.
  static BoxConstraints constraints({
    double? width,
    required double height,
    double? maxWidth,
  }) {
    return BoxConstraints(
      minWidth: width ?? 0,
      maxWidth: width ?? maxWidth ?? double.infinity,
      minHeight: height,
      maxHeight: height,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Скелетний список (Skeleton List Builder)
// ═══════════════════════════════════════════════════════════════════════════

/// Скелетний список елементів для завантаження списків.
///
/// Генерує вказану кількість скелетних елементів з хвильовим ефектом.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.isLightTheme = false,
    this.effect = SkeletonEffect.shimmer,
    this.itemHeight = 56.0,
    this.showAvatar = true,
    this.config,
  });

  /// Кількість елементів у списку.
  final int itemCount;

  /// Світла тема.
  final bool isLightTheme;

  /// Тип ефекту анімації.
  final SkeletonEffect effect;

  /// Висота одного елемента.
  final double itemHeight;

  /// Показувати аватар.
  final bool showAvatar;

  /// Конфігурація.
  final SkeletonConfig? config;

  @override
  Widget build(BuildContext context) {
    final cfg = config ??
        SkeletonPresets.forTheme(isLightTheme).copyWith(effect: effect);

    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (showAvatar) ...[
                cfg.circle(size: 40),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cfg.line(width: double.infinity),
                    const SizedBox(height: 6),
                    cfg.line(width: 100 + index * 10.0, height: 10),
                  ],
                ),
              ),
              cfg.line(width: 60, height: 14),
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Скелетний хедер (Skeleton Header)
// ═══════════════════════════════════════════════════════════════════════════

/// Скелетний хедер з підзаголовком та кнопками дій.
class SkeletonHeader extends StatelessWidget {
  const SkeletonHeader({
    super.key,
    this.isLightTheme = false,
    this.showSubtitle = true,
    this.showActions = false,
    this.width,
    this.effect = SkeletonEffect.shimmer,
  });

  final bool isLightTheme;
  final bool showSubtitle;
  final bool showActions;
  final double? width;
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  type: SkeletonType.header,
                  width: w * 0.5,
                  height: 24,
                  isLightTheme: isLightTheme,
                  effect: effect,
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 6),
                  AppSkeleton(
                    type: SkeletonType.line,
                    width: w * 0.7,
                    height: 12,
                    isLightTheme: isLightTheme,
                    effect: effect,
                  ),
                ],
              ],
            ),
          ),
          if (showActions) ...[
            AppSkeleton(
              type: SkeletonType.circle, height: 36,
              isLightTheme: isLightTheme, effect: effect,
            ),
            const SizedBox(width: 8),
            AppSkeleton(
              type: SkeletonType.circle, height: 36,
              isLightTheme: isLightTheme, effect: effect,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Скелетний аватар (Skeleton Avatar)
// ═══════════════════════════════════════════════════════════════════════════

/// Скелетний аватар з текстовими лініями поруч.
class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({
    super.key,
    this.isLightTheme = false,
    this.avatarSize = 44.0,
    this.showSubtitle = true,
    this.showTrailing = false,
    this.effect = SkeletonEffect.shimmer,
  });

  final bool isLightTheme;
  final double avatarSize;
  final bool showSubtitle;
  final bool showTrailing;
  final SkeletonEffect effect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AppSkeleton(
            type: SkeletonType.avatar, height: avatarSize,
            isLightTheme: isLightTheme, effect: effect,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  type: SkeletonType.line, width: double.infinity,
                  height: 14, isLightTheme: isLightTheme, effect: effect,
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 4),
                  AppSkeleton(
                    type: SkeletonType.line, width: 120,
                    height: 10, isLightTheme: isLightTheme, effect: effect,
                  ),
                ],
              ],
            ),
          ),
          if (showTrailing)
            AppSkeleton(
              type: SkeletonType.chip, width: 60, height: 24,
              isLightTheme: isLightTheme, effect: effect,
            ),
        ],
      ),
    );
  }
}
