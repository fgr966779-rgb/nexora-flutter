import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Перелік товщин лінійки прогресу (Progress Bar Height Enum)
// ═══════════════════════════════════════════════════════════════════════════

/// Товщина лінійки прогресу в пікселях.
///
/// Визначає висоту шкали залежно від контексту використання.
enum ProgressBarHeight {
  /// Ультратонка (2px) — для мінімалістичних індикаторів у compact-режимі.
  ///
  /// Мінімальна видимість, для subtle-вказівників.
  hairline(2.0),

  /// Тонка (4px) — для компактних відображень у списках.
  ///
  /// Мінімальна видимість, але все ще чітка.
  thin(4.0),

  /// Стандартна (8px) — для карток та списків.
  ///
  /// Оптимальний баланс між видимістю та компактністю.
  normal(8.0),

  /// Середньо-товста (12px) — для виділених секцій.
  ///
  /// Добре підходить для секцій з підзаголовком.
  medium(12.0),

  /// Товста (14px) — для виділених індикаторів.
  ///
  /// Для головних шкал прогресу цілей.
  thick(14.0),

  /// Надтовста (20px) — для hero-відображень.
  ///
  /// Для екранів деталей цілей з великим прогресом.
  extraThick(20.0),

  /// Масивна (28px) — для великих екранів прогресу.
  ///
  /// Для повноекранних індикаторів навантаження.
  massive(28.0);

  const ProgressBarHeight(this.value);

  /// Висота лінійки прогресу в пікселях.
  final double value;

  /// Розмір шрифту для тексту всередині шкали.
  double get innerFontSize {
    switch (this) {
      case ProgressBarHeight.hairline:
      case ProgressBarHeight.thin:
      case ProgressBarHeight.normal:
      case ProgressBarHeight.medium:
        return 0; // Занадто мала для тексту
      case ProgressBarHeight.thick:
        return 10.0;
      case ProgressBarHeight.extraThick:
        return 12.0;
      case ProgressBarHeight.massive:
        return 14.0;
    }
  }

  /// Чи підтримує мітку всередині.
  bool get supportsInnerLabel => value >= 14.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// Маркер етапу (Milestone Marker)
// ═══════════════════════════════════════════════════════════════════════════

/// Опис маркера етапу на шкалі прогресу.
///
/// Кожен маркер містить позицію, мітку та стан завершення.
class ProgressMilestone {
  const ProgressMilestone({
    required this.position,
    this.label,
    this.isCompleted = false,
    this.icon,
  });

  /// Позиція маркера від 0.0 до 1.0.
  final double position;

  /// Текстова мітка маркера (наприклад, «25%» або «Крок 1»).
  final String? label;

  /// Чи етап вже завершено.
  final bool isCompleted;

  /// Кастомна іконка маркера.
  final IconData? icon;
}

// ═══════════════════════════════════════════════════════════════════════════
// Сегмент прогресу (Progress Segment)
// ═══════════════════════════════════════════════════════════════════════════

/// Опис кольорового сегмента для багатокольорової шкали прогресу.
///
/// Дозволяє створювати прогрес-бари з різними кольорами для різних
/// етапів або категорій.
class ProgressSegment {
  const ProgressSegment({
    required this.from,
    required this.to,
    required this.color,
    this.label,
  });

  /// Початок сегмента від 0.0 до 1.0.
  final double from;

  /// Кінець сегмента від 0.0 до 1.0.
  final double to;

  /// Колір сегмента.
  final Color color;

  /// Опціональна мітка сегмента.
  final String? label;
}

/// Лінійна шкала прогресу з градієнтом, shimmer та багатьма варіантами.
///
/// Підтримує різні товщини, кастомні кольори, градієнт, неонове свічення
/// при наближенні до завершення, пульс-анімацію, shimmer, маркери кроків,
/// етапи (milestones), багатокольорові сегменти, неозначений прогрес
/// та вторинний прогрес для викликів.
///
/// Приклад використання:
/// ```dart
/// AppProgressBar(
///   progress: 0.75,
///   height: ProgressBarHeight.thick,
///   showLabel: true,
///   showShimmer: true,
/// )
/// ```
class AppProgressBar extends StatefulWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = ProgressBarHeight.normal,
    this.showLabel = false,
    this.showLabelInside = false,
    this.isLightTheme = false,
    this.isPulsing = false,
    this.showShimmer = false,
    this.showGlowNearComplete = true,
    this.glowThreshold = 0.85,
    this.trackColor,
    this.fillColor,
    this.gradientStart,
    this.gradientEnd,
    this.multiGradientColors,
    this.secondaryProgress,
    this.stepMarkers,
    this.milestones,
    this.segments,
    this.isIndeterminate = false,
    this.indeterminateSpeed = 1.0,
    this.centerIcon,
    this.roundedCap = true,
    this.animationDuration,
    this.labelPrefix,
    this.labelSuffix,
    this.showMilestoneLabels = false,
  });

  /// Значення прогресу від 0.0 до 1.0.
  ///
  /// Автоматично обмежується до діапазону 0.0–1.0.
  /// Ігнорується, якщо [isIndeterminate] = true.
  final double progress;

  /// Товщина шкали прогресу.
  final ProgressBarHeight height;

  /// Показувати відсоток під шкалою.
  final bool showLabel;

  /// Показувати відсоток всередині шкали (тільки для thick та вище).
  final bool showLabelInside;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Пульс-анімація шкали (для привернення уваги).
  final bool isPulsing;

  /// Shimmer-ефект на заповненій частині.
  final bool showShimmer;

  /// Неонове свічення при наближенні до 100%.
  final bool showGlowNearComplete;

  /// Поріг для увімкнення свічення (default 0.85).
  ///
  /// Коли прогрес перевищує це значення — з'являється glow.
  final double glowThreshold;

  /// Кастомний колір фонової доріжки.
  final Color? trackColor;

  /// Кастомний однотонний колір заповнення (без градієнта).
  final Color? fillColor;

  /// Кастомний початковий колір градієнта (ліворуч).
  final Color? gradientStart;

  /// Кастомний кінцевий колір градієнта (праворуч).
  final Color? gradientEnd;

  /// Багатокольоровий градієнт (список кольорів).
  ///
  /// Якщо вказано — перевизначає [gradientStart] та [gradientEnd].
  final List<Color>? multiGradientColors;

  /// Вторинний прогрес (для відображення бонусного/виклик прогресу).
  ///
  /// Відображається як напівпрозорий шар під основним заповненням.
  final double? secondaryProgress;

  /// Кількість маркерів кроків на шкалі.
  ///
  /// Наприклад, 5 маркерів для 4-етапного прогресу.
  final int? stepMarkers;

  /// Список етапів (milestones) на шкалі прогресу.
  ///
  /// Кожен етап має позицію, мітку та стан завершення.
  final List<ProgressMilestone>? milestones;

  /// Список кольорових сегментів для багатокольорової шкали.
  ///
  /// Дозволяє показувати різні кольори для різних частин прогресу.
  final List<ProgressSegment>? segments;

  /// Неозначений режим прогресу (анімована смужка завантаження).
  ///
  /// Коли true — [progress] ігнорується.
  final bool isIndeterminate;

  /// Швидкість анімації неозначеного прогресу (1.0 = стандартна).
  final double indeterminateSpeed;

  /// Іконка по центру шкали (для thick та вище).
  final IconData? centerIcon;

  /// Заокруглені кінці шкали (BorderRadius.circular).
  final bool roundedCap;

  /// Кастомна тривалість анімації заповнення.
  ///
  /// Якщо не вказано — використовується [AppDurations.slow].
  final Duration? animationDuration;

  /// Префікс для мітки прогресу (наприклад, "Зібрано: ").
  final String? labelPrefix;

  /// Суфікс для мітки прогресу (наприклад, "%").
  final String? labelSuffix;

  /// Показувати мітки етапів (milestones) під шкалою.
  final bool showMilestoneLabels;

  @override
  State<AppProgressBar> createState() => _AppProgressBarState();
}

class _AppProgressBarState extends State<AppProgressBar>
    with SingleTickerProviderStateMixin {
  /// Контролер для неозначеного прогресу.
  late AnimationController _indeterminateController;

  // ═══════════════════════════════════════════════════════════════════════
  // Гетери кольорів (Color Getters)
  // ═══════════════════════════════════════════════════════════════════════

  /// Колір фонової доріжки (не заповнена частина).
  Color get _trackColor =>
      widget.trackColor ??
      (widget.isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border);

  /// Початковий колір градієнта заповнення (ліворуч).
  Color get _gradientStartColor =>
      widget.gradientStart ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientStart
          : AppColorsPS5.gradientStart);

  /// Кінцевий колір градієнта заповнення (праворуч).
  Color get _gradientEndColor =>
      widget.gradientEnd ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientEnd
          : AppColorsPS5.gradientEnd);

  /// Кольори градієнта заповнення (багатокольоровий або стандартний).
  List<Color> get _gradientColors =>
      widget.multiGradientColors ??
      [_gradientStartColor, _gradientEndColor];

  /// Колір вторинного прогресу (напівпрозорий).
  Color get _secondaryColor =>
      widget.isLightTheme
          ? AppColorsMonitor.accentLight
          : AppColorsPS5.accentLight;

  /// Колір мітки прогресу під шкалою.
  Color get _labelColor =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  /// Чи потрібно показувати свічення.
  bool get _shouldGlow =>
      widget.showGlowNearComplete &&
      !widget.isIndeterminate &&
      widget.progress >= widget.glowThreshold;

  /// Тривалість анімації заповнення.
  Duration get _animationDuration =>
      widget.animationDuration ?? AppDurations.slow;

  // ═══════════════════════════════════════════════════════════════════════
  // Життєвий цикл (Lifecycle)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _indeterminateController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (1500 ~/ widget.indeterminateSpeed).clamp(500, 5000),
      ),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AppProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.indeterminateSpeed != widget.indeterminateSpeed) {
      _indeterminateController.duration = Duration(
        milliseconds: (1500 ~/ widget.indeterminateSpeed).clamp(500, 5000),
      );
    }
  }

  @override
  void dispose() {
    _indeterminateController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final clampedSecondary = widget.secondaryProgress?.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Контейнер зі свіченням ──
        AnimatedContainer(
          duration: _animationDuration,
          decoration: _shouldGlow
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.xs),
                  boxShadow: [
                    BoxShadow(
                      color: _gradientStartColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.roundedCap ? Radii.progress : Radii.xs,
            ),
            child: SizedBox(
              height: widget.height.value,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // ── Фонова доріжка ──
                      _buildTrack(constraints),
                      // ── Сегменти ──
                      if (widget.segments != null &&
                          widget.segments!.isNotEmpty) ...[
                        _buildSegments(constraints, clampedProgress),
                      ],
                      // ── Маркери кроків ──
                      if (widget.stepMarkers != null) ...[
                        _buildStepMarkers(constraints),
                      ],
                      // ── Етапи (milestones) ──
                      if (widget.milestones != null &&
                          widget.milestones!.isNotEmpty) ...[
                        _buildMilestones(constraints),
                      ],
                      // ── Вторинний прогрес ──
                      if (clampedSecondary != null &&
                          !widget.isIndeterminate) ...[
                        _buildSecondaryProgress(constraints, clampedSecondary),
                      ],
                      // ── Основне заповнення ──
                      widget.isIndeterminate
                          ? _buildIndeterminateFill(constraints)
                          : _buildMainFill(constraints, clampedProgress),
                      // ── Іконка по центру ──
                      if (widget.centerIcon != null &&
                          widget.height.supportsInnerLabel &&
                          (clampedProgress > 0.15 || widget.isIndeterminate)) ...[
                        _buildCenterIcon(constraints),
                      ],
                      // ── Мітка всередині ──
                      if (widget.showLabelInside &&
                          widget.height.supportsInnerLabel &&
                          clampedProgress > 0.15) ...[
                        _buildInsideLabel(constraints, clampedProgress),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        // ── Мітки етапів під шкалою ──
        if (widget.showMilestoneLabels &&
            widget.milestones != null &&
            widget.milestones!.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildMilestoneLabels(),
        ],
        // ── Мітка під шкалою ──
        if (widget.showLabel && !widget.showLabelInside) ...[
          const SizedBox(height: 6),
          _buildOutsideLabel(clampedProgress, clampedSecondary),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Фонова доріжка (Track)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує фонову доріжку (не заповнену частину шкали).
  Widget _buildTrack(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _trackColor,
        borderRadius: BorderRadius.circular(
          widget.roundedCap ? Radii.progress : Radii.xs,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Кольорові сегменти (Colored Segments)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує кольорові сегменти на шкалі прогресу.
  ///
  /// Кожен сегмент має свій колір та межі.
  Widget _buildSegments(BoxConstraints constraints, double clampedProgress) {
    return Positioned.fill(
      child: Row(
        children: widget.segments!.map((segment) {
          final segmentWidth =
              ((segment.to - segment.from) * constraints.maxWidth)
                  .clamp(0.0, constraints.maxWidth);
          final isVisible = clampedProgress >= segment.from;
          final segmentProgress =
              ((clampedProgress - segment.from) / (segment.to - segment.from))
                  .clamp(0.0, 1.0);

          if (!isVisible) return const SizedBox.shrink();

          return SizedBox(
            width: segmentWidth * segmentProgress,
            child: Container(
              decoration: BoxDecoration(
                color: segment.color,
                borderRadius: BorderRadius.circular(
                  widget.roundedCap ? Radii.progress : Radii.xs,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Маркери кроків (Step Markers)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує маркери кроків на шкалі прогресу.
  ///
  /// Кожен маркер — вертикальна лінія на відповідній позиції.
  Widget _buildStepMarkers(BoxConstraints constraints) {
    final steps = widget.stepMarkers!;
    return Positioned.fill(
      child: Row(
        children: List.generate(steps - 1, (index) {
          final fraction = (index + 1) / steps;
          return Expanded(
            child: Align(
              alignment: Alignment(fraction * 2 - 1, 0),
              child: Container(
                width: 2,
                height: widget.height.value * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Етапи (Milestones)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує маркери етапів на шкалі прогресу.
  ///
  /// Завершені етапи показуються зеленим, невиконані — сірим.
  Widget _buildMilestones(BoxConstraints constraints) {
    return Positioned.fill(
      child: Stack(
        children: widget.milestones!.map((milestone) {
          final xPos = milestone.position * constraints.maxWidth;
          final color = milestone.isCompleted
              ? Colors.greenAccent
              : Colors.white.withOpacity(0.3);
          final size = widget.height.value * 0.5;

          return Positioned(
            left: xPos - size / 2,
            top: (widget.height.value - size) / 2,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: milestone.icon != null
                  ? Icon(
                      milestone.icon,
                      color: Colors.white,
                      size: size * 0.5,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Будує мітки етапів під шкалою.
  Widget _buildMilestoneLabels() {
    return Row(
      children: widget.milestones!.map((milestone) {
        return Expanded(
          child: Align(
            alignment: Alignment(milestone.position * 2 - 1, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                milestone.label ?? '',
                style: AppTypography.caption.copyWith(
                  color: milestone.isCompleted
                      ? _gradientStartColor
                      : _labelColor.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Вторинний прогрес (Secondary Progress)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує шар вторинного прогресу.
  ///
  /// Напівпрозорий шар під основним заповненням.
  Widget _buildSecondaryProgress(
    BoxConstraints constraints,
    double secondaryProgress,
  ) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        width: constraints.maxWidth * secondaryProgress,
        decoration: BoxDecoration(
          color: _secondaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(
            widget.roundedCap ? Radii.progress : Radii.xs,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Неозначений прогрес (Indeterminate Progress)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує анімовану неозначену смужку завантаження.
  ///
  /// Смужка рухається зліва направо і повторюється.
  Widget _buildIndeterminateFill(BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _indeterminateController,
      builder: (context, _) {
        final value = _indeterminateController.value;
        // Дві хвилі, що рухаються одна за одною
        final firstStart = (value * 2 - 0.5) * constraints.maxWidth;
        final secondStart = (value * 2 - 1.0) * constraints.maxWidth;
        const waveWidth = 0.3; // 30% ширини

        return Stack(
          children: [
            _buildIndeterminateWave(
              constraints: constraints,
              start: firstStart,
              waveWidth: waveWidth,
            ),
            _buildIndeterminateWave(
              constraints: constraints,
              start: secondStart,
              waveWidth: waveWidth,
            ),
          ],
        );
      },
    );
  }

  /// Будує одну хвилю неозначеного прогресу.
  Widget _buildIndeterminateWave({
    required BoxConstraints constraints,
    required double start,
    required double waveWidth,
  }) {
    final wavePx = constraints.maxWidth * waveWidth;
    return Positioned(
      left: start,
      top: 0,
      bottom: 0,
      child: Container(
        width: wavePx,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _gradientColors.first.withOpacity(0),
              _gradientColors.first,
              _gradientColors.last,
              _gradientColors.last.withOpacity(0),
            ],
          ),
          borderRadius: BorderRadius.circular(
            widget.roundedCap ? Radii.progress : Radii.xs,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Основне заповнення (Main Fill)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує основне заповнення шкали прогресу.
  ///
  /// Включає градієнт, shimmer та пульс-анімацію.
  Widget _buildMainFill(BoxConstraints constraints, double clampedProgress) {
    Widget fill = AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      width: constraints.maxWidth * clampedProgress,
      decoration: BoxDecoration(
        gradient: widget.fillColor != null
            ? null
            : LinearGradient(
                colors: _gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(
          widget.roundedCap ? Radii.progress : Radii.xs,
        ),
      ),
    );

    // ── Shimmer ефект ──
    if (widget.showShimmer) {
      fill = fill
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: AppDurations.skeleton,
            color: Colors.white.withOpacity(0.3),
          );
    }

    // ── Пульс-анімація ──
    if (widget.isPulsing) {
      fill = fill.animate(target: 1).scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.01, 1.1),
            duration: AppDurations.pulse,
            curve: Curves.easeInOut,
          );
    }

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: fill,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Іконка по центру (Center Icon)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує іконку по центру шкали прогресу.
  Widget _buildCenterIcon(BoxConstraints constraints) {
    final iconSize = widget.height.innerFontSize * 1.2;
    return Positioned(
      left: constraints.maxWidth / 2 - iconSize / 2,
      top: 0,
      bottom: 0,
      child: Center(
        child: Icon(
          widget.centerIcon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Мітки (Labels)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує мітку відсотка всередині шкали.
  Widget _buildInsideLabel(
    BoxConstraints constraints,
    double clampedProgress,
  ) {
    final percent = (clampedProgress * 100).toInt();
    final prefix = widget.labelPrefix ?? '';
    final suffix = widget.labelSuffix ?? '%';

    return Positioned(
      left: constraints.maxWidth * clampedProgress - 30,
      top: 0,
      bottom: 0,
      child: Center(
        child: Text(
          '$prefix$percent$suffix',
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: widget.height.innerFontSize,
          ),
        ),
      ),
    );
  }

  /// Будує мітку відсотка під шкалою.
  Widget _buildOutsideLabel(
    double clampedProgress,
    double? clampedSecondary,
  ) {
    final percent = (clampedProgress * 100).toInt();
    final prefix = widget.labelPrefix ?? '';
    final suffix = widget.labelSuffix ?? '%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$prefix$percent$suffix',
          style: AppTypography.labelSmall.copyWith(color: _labelColor),
        ),
        if (widget.secondaryProgress != null) ...[
          Text(
            'Бонус: ${(clampedSecondary!.clamp(0.0, 1.0) * 100).toInt()}%',
            style: AppTypography.labelSmall.copyWith(
              color: _secondaryColor,
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Семантичні мітки (Semantic Labels)
  // ═══════════════════════════════════════════════════════════════════════

  /// Текст для екранних читачів — опис поточного прогресу.
  ///
  /// [progress] — значення прогресу від 0.0 до 1.0.
  static String accessibilityLabel(double progress) {
    final percent = (progress * 100).toInt();
    return 'Прогрес: $percent відсотків';
  }

  /// Повідомлення про завершення прогресу.
  static String get completedMessage => 'Прогрес завершено на 100%';

  /// Повідомлення про початок прогресу.
  static String get startedMessage => 'Прогрес тільки почато';

  /// Повідомлення про завантаження (неозначений прогрес).
  static String get loadingMessage => 'Завантаження, зачекайте...';

  /// Повертає опис прогресу з контекстом цілі.
  ///
  /// [progress] — значення прогресу від 0.0 до 1.0.
  /// [goalName] — назва цілі заощаджень.
  static String contextualLabel(double progress, String goalName) {
    final percent = (progress * 100).toInt();
    return '$goalName: $percent% виконано';
  }

  /// Повертає опис прогресу з кількістю етапів.
  ///
  /// [completedSteps] — кількість завершених етапів.
  /// [totalSteps] — загальна кількість етапів.
  static String stepsLabel(int completedSteps, int totalSteps) {
    return 'Етап $completedSteps з $totalSteps';
  }

  /// Повертає опис залишку часу (орієнтовно).
  ///
  /// [remainingPercent] — залишок у відсотках (100 - progress%).
  static String remainingLabel(double remainingPercent) {
    final percent = remainingPercent.toInt();
    return 'Залишилось: $percent%';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Константи лінійки прогресу (Progress Bar Constants)
// ═══════════════════════════════════════════════════════════════════════════

/// Статичні константи для лінійки прогресу.
///
/// Центральне місце для всіх магічних чисел, меж та значень за замовчуванням.
class ProgressBarConstants {
  ProgressBarConstants._();

  /// Мінімально допустимий прогрес.
  static const double minProgress = 0.0;

  /// Максимально допустимий прогрес.
  static const double maxProgress = 1.0;

  /// Стандартний поріг свічення.
  static const double defaultGlowThreshold = 0.85;

  /// Мінімально допустимий поріг свічення.
  static const double minGlowThreshold = 0.5;

  /// Максимально допустимий поріг свічення.
  static const double maxGlowThreshold = 0.99;

  /// Стандартна тривалість анімації заповнення.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 500);

  /// Мінімальна тривалість анімації.
  static const Duration minAnimationDuration = Duration(milliseconds: 100);

  /// Максимальна тривалість анімації.
  static const Duration maxAnimationDuration = Duration(milliseconds: 3000);

  /// Стандартна швидкість неозначеного прогресу.
  static const double defaultIndeterminateSpeed = 1.0;

  /// Мінімальна швидкість неозначеного прогресу.
  static const double minIndeterminateSpeed = 0.2;

  /// Максимальна швидкість неозначеного прогресу.
  static const double maxIndeterminateSpeed = 5.0;

  /// Стандартна ширина хвилі неозначеного прогресу (частка ширини).
  static const double indeterminateWaveWidth = 0.3;

  /// Мінімальний прогрес для відображення мітки всередині шкали.
  static const double minProgressForInnerLabel = 0.15;

  /// Стандартна висота маркера кроку (частка висоти шкали).
  static const double stepMarkerHeightRatio = 0.6;

  /// Стандартна ширина маркера кроку в пікселях.
  static const double stepMarkerWidth = 2.0;

  /// Мінімальна кількість маркерів кроків.
  static const int minStepMarkers = 2;

  /// Максимальна кількість маркерів кроків.
  static const int maxStepMarkers = 20;

  /// Стандартний розмір іконки етапу (частка висоти шкали).
  static const double milestoneSizeRatio = 0.5;

  /// Максимальна кількість сегментів.
  static const int maxSegments = 10;

  /// Стандартна ширина shimmer-ефекту.
  static const double shimmerWidth = 0.5;

  /// Стандартна тривалість shimmer-анімації.
  static const Duration shimmerDuration = Duration(milliseconds: 1200);

  /// Мінімальна висота шкали для тексту всередині.
  static const double minHeightForInnerText = 14.0;

  /// Максимальна кількість етапів (milestones).
  static const int maxMilestones = 20;

  /// Стандартний відступ під шкалою для мітки.
  static const double labelSpacing = 6.0;

  /// Стандартна горизонтальна висота пульс-анімації.
  static const double pulseScaleY = 1.1;

  /// Стандартна горизонтальна ширина пульс-анімації.
  static const double pulseScaleX = 1.01;
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідація лінійки прогресу (Progress Bar Validation)
// ═══════════════════════════════════════════════════════════════════════════

/// Методи валідації для лінійки прогресу.
///
/// Перевіряє коректність параметрів перед відображенням.
class ProgressBarValidation {
  ProgressBarValidation._();

  /// Перевіряє, чи прогрес знаходиться в допустимих межах.
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  static bool isValidProgress(double progress) {
    return !progress.isNaN && !progress.isInfinite &&
        progress >= ProgressBarConstants.minProgress &&
        progress <= ProgressBarConstants.maxProgress;
  }

  /// Перевіряє, чи висота шкали підтримує текст всередині.
  ///
  /// [height] — висота шкали в пікселях.
  static bool supportsInnerLabel(double height) {
    return height >= ProgressBarConstants.minHeightForInnerText;
  }

  /// Перевіряє, чи кількість маркерів кроків в допустимих межах.
  ///
  /// [count] — кількість маркерів.
  static bool isValidStepMarkerCount(int count) {
    return count >= ProgressBarConstants.minStepMarkers &&
        count <= ProgressBarConstants.maxStepMarkers;
  }

  /// Перевіряє, чи кількість етапів в допустимих межах.
  ///
  /// [count] — кількість етапів.
  static bool isValidMilestoneCount(int count) {
    return count > 0 && count <= ProgressBarConstants.maxMilestones;
  }

  /// Перевіряє, чи кількість сегментів в допустимих межах.
  ///
  /// [count] — кількість сегментів.
  static bool isValidSegmentCount(int count) {
    return count > 0 && count <= ProgressBarConstants.maxSegments;
  }

  /// Перевіряє, чи швидкість неозначеного прогресу в допустимих межах.
  ///
  /// [speed] — швидкість (1.0 = стандартна).
  static bool isValidIndeterminateSpeed(double speed) {
    return speed >= ProgressBarConstants.minIndeterminateSpeed &&
        speed <= ProgressBarConstants.maxIndeterminateSpeed;
  }

  /// Перевіряє, чи поріг свічення в допустимих межах.
  ///
  /// [threshold] — поріг свічення (0.5–0.99).
  static bool isValidGlowThreshold(double threshold) {
    return threshold >= ProgressBarConstants.minGlowThreshold &&
        threshold <= ProgressBarConstants.maxGlowThreshold;
  }

  /// Повертає виправлений прогрес (обмежений 0.0–1.0).
  ///
  /// Обробляє NaN та Infinity.
  static double clampProgress(double progress) {
    if (progress.isNaN || progress.isInfinite) return 0.0;
    return progress.clamp(
      ProgressBarConstants.minProgress,
      ProgressBarConstants.maxProgress,
    );
  }

  /// Повертає список усіх помилок валідації.
  ///
  /// Перевіряє всі параметри та повертає список рядків з помилками.
  static List<String> validateAll({
    double? progress,
    double? glowThreshold,
    int? stepMarkers,
    int? milestones,
    int? segments,
    double? indeterminateSpeed,
  }) {
    final errors = <String>[];
    if (progress != null && !isValidProgress(progress)) {
      errors.add('Прогрес має бути в межах 0.0–1.0');
    }
    if (glowThreshold != null && !isValidGlowThreshold(glowThreshold)) {
      errors.add('Поріг свічення має бути в межах 0.5–0.99');
    }
    if (stepMarkers != null && !isValidStepMarkerCount(stepMarkers)) {
      errors.add('Кількість маркерів має бути від '
          '${ProgressBarConstants.minStepMarkers} до '
          '${ProgressBarConstants.maxStepMarkers}');
    }
    if (milestones != null && !isValidMilestoneCount(milestones)) {
      errors.add('Кількість етапів має бути від 1 до '
          '${ProgressBarConstants.maxMilestones}');
    }
    if (segments != null && !isValidSegmentCount(segments)) {
      errors.add('Кількість сегментів має бути від 1 до '
          '${ProgressBarConstants.maxSegments}');
    }
    if (indeterminateSpeed != null &&
        !isValidIndeterminateSpeed(indeterminateSpeed)) {
      errors.add('Швидкість має бути від '
          '${ProgressBarConstants.minIndeterminateSpeed} до '
          '${ProgressBarConstants.maxIndeterminateSpeed}');
    }
    return errors;
  }

  /// Перевіряє сегменти на валідність та відповідність межам.
  ///
  /// [segments] — список сегментів для перевірки.
  static List<String> validateSegments(List<ProgressSegment> segments) {
    final errors = <String>[];
    if (segments.isEmpty) {
      errors.add('Список сегментів не може бути порожнім');
      return errors;
    }
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.from < 0.0 || seg.from > 1.0) {
        errors.add('Сегмент $i: початок (${seg.from}) поза межами 0.0–1.0');
      }
      if (seg.to < 0.0 || seg.to > 1.0) {
        errors.add('Сегмент $i: кінець (${seg.to}) поза межами 0.0–1.0');
      }
      if (seg.from >= seg.to) {
        errors.add('Сегмент $i: початок (${seg.from}) має бути менше кінця (${seg.to})');
      }
      if (seg.from.isNaN || seg.to.isNaN) {
        errors.add('Сегмент $i: значення не може бути NaN');
      }
    }
    return errors;
  }

  /// Перевіряє етапи (milestones) на валідність.
  ///
  /// [milestones] — список етапів для перевірки.
  static List<String> validateMilestones(
    List<ProgressMilestone> milestones,
  ) {
    final errors = <String>[];
    for (var i = 0; i < milestones.length; i++) {
      final m = milestones[i];
      if (m.position < 0.0 || m.position > 1.0) {
        errors.add('Етап $i: позиція (${m.position}) поза межами 0.0–1.0');
      }
      if (m.position.isNaN) {
        errors.add('Етап $i: позиція не може бути NaN');
      }
    }
    return errors;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Progress Bar Helper)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для лінійки прогресу.
///
/// Надає методи форматування, обчислення та утиліти.
class ProgressBarHelper {
  ProgressBarHelper._();

  /// Форматує прогрес як текст з префіксом та суфіксом.
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  /// [prefix] — текст перед числом (наприклад, «Зібрано: »).
  /// [suffix] — текст після числа (наприклад, «%»).
  static String formatProgressLabel({
    required double progress,
    String prefix = '',
    String suffix = '%',
  }) {
    final percent = (progress.clamp(0.0, 1.0) * 100).toInt();
    return '$prefix$percent$suffix';
  }

  /// Форматує прогрес як детальний текст з десятковими.
  ///
  /// [progress] — значення прогресу (0.0–1.0).
  /// [decimalPlaces] — кількість знаків після коми.
  static String formatDetailed({
    required double progress,
    int decimalPlaces = 1,
    String prefix = '',
    String suffix = '%',
  }) {
    final value = (progress.clamp(0.0, 1.0) * 100)
        .toStringAsFixed(decimalPlaces);
    return '$prefix$value$suffix';
  }

  /// Обчислює ширину заповнення в пікселях.
  ///
  /// [progress] — прогрес (0.0–1.0).
  /// [totalWidth] — загальна ширина контейнера.
  static double fillWidth(double progress, double totalWidth) {
    return totalWidth * progress.clamp(0.0, 1.0);
  }

  /// Обчислює інтенсивність свічення залежно від прогресу.
  ///
  /// [progress] — поточний прогрес.
  /// [threshold] — поріг активації свічення.
  static double glowIntensity(double progress, double threshold) {
    if (progress < threshold) return 0.0;
    return ((progress - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);
  }

  /// Обчислює позицію маркера кроку по горизонталі.
  ///
  /// [fraction] — частка позиції (0.0–1.0).
  /// [totalWidth] — загальна ширина контейнера.
  static double stepMarkerPosition(double fraction, double totalWidth) {
    return fraction * totalWidth;
  }

  /// Обчислює оптимальну висоту шкали для контексту.
  ///
  /// [context] — контекст використання (card, list, hero, dialog).
  static ProgressBarHeight heightForContext(String context) {
    switch (context.toLowerCase()) {
      case 'card':
        return ProgressBarHeight.normal;
      case 'list':
        return ProgressBarHeight.thin;
      case 'hero':
        return ProgressBarHeight.extraThick;
      case 'dialog':
        return ProgressBarHeight.thick;
      case 'badge':
        return ProgressBarHeight.hairline;
      default:
        return ProgressBarHeight.normal;
    }
  }

  /// Обчислює кількість активних кроків.
  ///
  /// [progress] — поточний прогрес.
  /// [totalSteps] — загальна кількість кроків.
  static int activeSteps(double progress, int totalSteps) {
    return (progress.clamp(0.0, 1.0) * totalSteps).round();
  }

  /// Повертає текстовий опис рівня прогресу.
  ///
  /// Використовується для логування та діагностики.
  static String progressLevelDescription(double progress) {
    final percent = (progress * 100).round();
    if (percent == 0) return 'Порожньо (0%)';
    if (percent < 25) return 'Початок ($percent%)';
    if (percent < 50) return 'Перша половина ($percent%)';
    if (percent < 75) return 'Друга половина ($percent%)';
    if (percent < 100) return 'Майже завершено ($percent%)';
    return 'Завершено (100%)';
  }

  /// Обчислює різницю між двома значеннями прогресу.
  ///
  /// Повертає позитивне число якщо прогрес зріс, негативне якщо впав.
  static double progressDifference(double current, double previous) {
    return current.clamp(0.0, 1.0) - previous.clamp(0.0, 1.0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Будуєчий градієнтів для лінійки (Progress Bar Gradient Builder)
// ═══════════════════════════════════════════════════════════════════════════

/// Будуєчий градієнтів для лінійки прогресу.
///
/// Надає готові конфігурації градієнтів та методи для кастомних градієнтів.
class ProgressBarGradientBuilder {
  ProgressBarGradientBuilder._();

  /// Створює стандартний градієнт для шкали прогресу.
  ///
  /// [startColor] — початковий колір (ліворуч).
  /// [endColor] — кінцевий колір (праворуч).
  static LinearGradient createGradient({
    required Color startColor,
    required Color endColor,
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// Створює градієнт з трьома кольорами.
  ///
  /// [startColor] — початковий колір.
  /// [midColor] — середній колір.
  /// [endColor] — кінцевий колір.
  static LinearGradient createTriGradient({
    required Color startColor,
    required Color midColor,
    required Color endColor,
  }) {
    return LinearGradient(
      colors: [startColor, midColor, endColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Створює градієнт з багатьма кольорами.
  ///
  /// [colors] — список кольорів градієнта.
  static LinearGradient createMultiGradient(List<Color> colors) {
    if (colors.length < 2) {
      throw ArgumentError('Потрібно мінімум 2 кольори для градієнта');
    }
    return LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// Створює градієнт для неозначеного прогресу.
  ///
  /// Градієнт з прозорими краями для хвилеподібного ефекту.
  static LinearGradient createIndeterminateGradient(Color baseColor) {
    return LinearGradient(
      colors: [
        baseColor.withOpacity(0),
        baseColor,
        baseColor,
        baseColor.withOpacity(0),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Повертає кольори XP-градієнта (золотий → помаранчевий).
  static List<Color> get xpColors => [
        const Color(0xFFFFD600),
        const Color(0xFFFF9100),
      ];

  /// Повертає кольори градієнта цілі (синій → бірюзовий).
  static List<Color> get goalColors => [
        const Color(0xFF2979FF),
        const Color(0xFF00E5FF),
      ];

  /// Повертає кольори градієнта серії (помаранчевий → червоний).
  static List<Color> get streakColors => [
        const Color(0xFFFF9100),
        const Color(0xFFFF1744),
      ];

  /// Повертає кольори градієнта успіху (зелений → смарагдовий).
  static List<Color> get successColors => [
        const Color(0xFF00E676),
        const Color(0xFF00C853),
      ];

  /// Повертає кольори градієнта небезпеки (жовтий → червоний).
  static List<Color> get dangerColors => [
        const Color(0xFFFFEA00),
        const Color(0xFFFF5252),
      ];

  /// Створює градієнт, який змінюється залежно від прогресу.
  ///
  /// Червоний → Жовтий → Зелений.
  static Color colorForProgress(double progress) {
    final p = progress.clamp(0.0, 1.0);
    if (p < 0.5) {
      return Color.lerp(
        const Color(0xFFFF5252),
        const Color(0xFFFFEA00),
        p * 2,
      )!;
    }
    return Color.lerp(
      const Color(0xFFFFEA00),
      const Color(0xFF00E676),
      (p - 0.5) * 2,
    )!;
  }

  /// Створює градієнт з неоновим ефектом.
  ///
  /// Використовує напівпрозорий колір на початку.
  static LinearGradient createNeonGradient(Color neonColor) {
    return LinearGradient(
      colors: [
        neonColor.withOpacity(0.6),
        neonColor,
        neonColor.withOpacity(0.8),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Вирішувач теми для лінійки (Progress Bar Theme Resolver)
// ═══════════════════════════════════════════════════════════════════════════

/// Вирішувач тем кольорів для лінійки прогресу.
///
/// Центральна точка для визначення кольорів залежно від теми та стану.
class ProgressBarThemeResolver {
  ProgressBarThemeResolver._();

  /// Повертає колір фонової доріжки.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  /// [customColor] — кастомний колір (якщо є).
  static Color resolveTrackColor({
    required bool isLightTheme,
    Color? customColor,
  }) {
    return customColor ??
        (isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border);
  }

  /// Повертає кольори градієнта заповнення.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  /// [customColors] — кастомні кольори (якщо є).
  /// [customStart] — кастомний початковий колір.
  /// [customEnd] — кастомний кінцевий колір.
  static List<Color> resolveGradientColors({
    required bool isLightTheme,
    List<Color>? customColors,
    Color? customStart,
    Color? customEnd,
  }) {
    if (customColors != null) return customColors;
    final start = customStart ??
        (isLightTheme
            ? AppColorsMonitor.gradientStart
            : AppColorsPS5.gradientStart);
    final end = customEnd ??
        (isLightTheme
            ? AppColorsMonitor.gradientEnd
            : AppColorsPS5.gradientEnd);
    return [start, end];
  }

  /// Повертає колір вторинного прогресу.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  static Color resolveSecondaryColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.accentLight : AppColorsPS5.accentLight;
  }

  /// Повертає колір мітки прогресу.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  static Color resolveLabelColor({required bool isLightTheme}) {
    return isLightTheme
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;
  }

  /// Повертає колір мітки етапу.
  ///
  /// [isLightTheme] — тема інтерфейсу.
  /// [isCompleted] — чи етап завершено.
  static Color resolveMilestoneLabelColor({
    required bool isLightTheme,
    required bool isCompleted,
    Color? accentColor,
  }) {
    if (isCompleted) {
      return accentColor ??
          (isLightTheme
              ? AppColorsMonitor.gradientStart
              : AppColorsPS5.gradientStart);
    }
    return (isLightTheme
            ? AppColorsMonitor.textSecondary
            : AppColorsPS5.textSecondary)
        .withOpacity(0.5);
  }

  /// Повертає колір активного маркера етапу.
  static Color resolveMilestoneColor({
    required bool isCompleted,
  }) {
    return isCompleted ? Colors.greenAccent : Colors.white.withOpacity(0.3);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжний для свічення (Progress Bar Glow Helper)
// ═══════════════════════════════════════════════════════════════════════════

/// Обчислення параметрів свічення для лінійки прогресу.
///
/// Визначає коли та як відображати неонове свічення.
class ProgressBarGlowHelper {
  ProgressBarGlowHelper._();

  /// Чи потрібно показувати свічення.
  ///
  /// [showGlowEnabled] — чи увімкнено свічення в налаштуваннях.
  /// [isIndeterminate] — чи це неозначений прогрес.
  /// [progress] — поточний прогрес.
  /// [threshold] — поріг активації.
  static bool shouldShowGlow({
    required bool showGlowEnabled,
    required bool isIndeterminate,
    required double progress,
    required double threshold,
  }) {
    return showGlowEnabled && !isIndeterminate && progress >= threshold;
  }

  /// Обчислює інтенсивність свічення.
  ///
  /// [progress] — поточний прогрес.
  /// [threshold] — поріг активації.
  static double computeIntensity(double progress, double threshold) {
    if (progress < threshold) return 0.0;
    return ((progress - threshold) / (1.0 - threshold)).clamp(0.0, 1.0);
  }

  /// Створює BoxShadow для свічення.
  ///
  /// [color] — колір свічення.
  /// [intensity] — інтенсивність (0.0–1.0).
  /// [baseBlur] — базовий радіус розмиття.
  /// [baseSpread] — базовий spread.
  static BoxShadow createBoxShadow({
    required Color color,
    required double intensity,
    double baseBlur = 12.0,
    double baseSpread = 2.0,
  }) {
    return BoxShadow(
      color: color.withOpacity(0.4 * intensity),
      blurRadius: baseBlur * intensity,
      spreadRadius: baseSpread * intensity,
    );
  }

  /// Створює BoxDecoration для контейнера зі свіченням.
  ///
  /// [color] — колір свічення.
  /// [intensity] — інтенсивність (0.0–1.0).
  /// [borderRadius] — радіус заокруглення.
  static BoxDecoration createGlowDecoration({
    required Color color,
    required double intensity,
    required BorderRadius borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4 * intensity),
          blurRadius: 12.0 * intensity,
          spreadRadius: 2.0 * intensity,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Шиммер-маляр (Progress Bar Shimmer Painter)
// ═══════════════════════════════════════════════════════════════════════════

/// CustomPainter для малювання shimmer-ефекту на шкалі прогресу.
///
/// Малює рухомий відблиск, що проходить по заповненій частині шкали.
class ProgressBarShimmerPainter extends CustomPainter {
  ProgressBarShimmerPainter({
    required this.progress,
    required this.height,
    this.shimmerColor,
    this.shimmerWidth = 0.5,
    this.direction = TextDirection.ltr,
  });

  /// Поточний прогрес (визначає ширину заповнення).
  final double progress;

  /// Висота шкали.
  final double height;

  /// Колір shimmer-ефекту.
  final Color? shimmerColor;

  /// Ширина shimmer-ефекту (частка ширини заповнення).
  final double shimmerWidth;

  /// Напрямок руху.
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    if (fillWidth <= 0) return;

    final baseColor = shimmerColor ?? Colors.white.withOpacity(0.3);
    final gradient = LinearGradient(
      colors: [
        baseColor.withOpacity(0),
        baseColor,
        baseColor.withOpacity(0),
      ],
      begin: direction == TextDirection.ltr
          ? Alignment.centerLeft
          : Alignment.centerRight,
      end: direction == TextDirection.ltr
          ? Alignment.centerRight
          : Alignment.centerLeft,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, fillWidth, height))
      ..blendMode = BlendMode.srcOver;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, fillWidth, height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressBarShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.height != height ||
        oldDelegate.shimmerColor != shimmerColor;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Маляр сегментів (Progress Bar Segment Painter)
// ═══════════════════════════════════════════════════════════════════════════

/// CustomPainter для малювання кольорових сегментів шкали прогресу.
///
/// Малює прямокутні сегменти з різними кольорами та опціональними
/// поділами між ними.
class ProgressBarSegmentPainter extends CustomPainter {
  ProgressBarSegmentPainter({
    required this.segments,
    required this.progress,
    required this.height,
    this.gapWidth = 1.0,
    this.gapColor,
    this.roundedCap = true,
  });

  /// Список сегментів.
  final List<ProgressSegment> segments;

  /// Поточний прогрес.
  final double progress;

  /// Висота шкали.
  final double height;

  /// Ширина поділки між сегментами.
  final double gapWidth;

  /// Колір поділок.
  final Color? gapColor;

  /// Заокруглені кінці.
  final bool roundedCap;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final gap = gapColor ?? Colors.black.withOpacity(0.3);
    final cornerRadius = roundedCap ? height / 2 : 0.0;

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final segStart = seg.from.clamp(0.0, 1.0);
      final segEnd = seg.to.clamp(0.0, 1.0);

      // Пропускаємо сегменти, які ще не досягнуті прогресом
      if (segStart >= clampedProgress) continue;

      // Обмежуємо видиму частину сегмента прогресом
      final visibleEnd = segEnd.clamp(segStart, clampedProgress);

      final x = segStart * size.width;
      final segWidth = (visibleEnd - segStart) * size.width;

      if (segWidth <= 0) continue;

      final paint = Paint()..color = seg.color;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, 0, segWidth, height),
        topLeft: (i == 0 && roundedCap) ? Radius.circular(cornerRadius) : Radius.zero,
        bottomLeft: (i == 0 && roundedCap) ? Radius.circular(cornerRadius) : Radius.zero,
        topRight: (visibleEnd >= clampedProgress && roundedCap)
            ? Radius.circular(cornerRadius)
            : Radius.zero,
        bottomRight: (visibleEnd >= clampedProgress && roundedCap)
            ? Radius.circular(cornerRadius)
            : Radius.zero,
      );

      canvas.drawRRect(rect, paint);

      // Малюємо поділку між сегментами
      if (i > 0 && gapWidth > 0) {
        final gapPaint = Paint()..color = gap;
        canvas.drawRect(
          Rect.fromLTWH(x - gapWidth / 2, 0, gapWidth, height),
          gapPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ProgressBarSegmentPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.segments != segments ||
        oldDelegate.height != height ||
        oldDelegate.gapWidth != gapWidth;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Маляр міток (Progress Bar Tick Painter)
// ═══════════════════════════════════════════════════════════════════════════

/// CustomPainter для малювання міток-поділоків на шкалі прогресу.
///
/// Малює вертикальні лінії на рівних відстанях по шкалі.
class ProgressBarTickPainter extends CustomPainter {
  ProgressBarTickPainter({
    required this.tickCount,
    required this.height,
    this.tickHeightRatio = 0.6,
    this.tickWidth = 2.0,
    this.tickColor,
    this.progress = 1.0,
    this.activeTickColor,
    this.roundedCaps = true,
  });

  /// Кількість міток.
  final int tickCount;

  /// Висота шкали.
  final double height;

  /// Висота кожної мітки (частка від висоти шкали).
  final double tickHeightRatio;

  /// Ширина кожної мітки.
  final double tickWidth;

  /// Колір неактивної мітки.
  final Color? tickColor;

  /// Поточний прогрес (визначає які мітки активні).
  final double progress;

  /// Колір активної мітки.
  final Color? activeTickColor;

  /// Заокруглені кінці міток.
  final bool roundedCaps;

  @override
  void paint(Canvas canvas, Size size) {
    final inactiveColor = tickColor ?? Colors.white.withOpacity(0.15);
    final activeColor = activeTickColor ?? Colors.white.withOpacity(0.6);
    final tickHeight = height * tickHeightRatio;

    final paint = Paint()
      ..strokeWidth = tickWidth
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt;

    for (var i = 0; i < tickCount - 1; i++) {
      final fraction = (i + 1) / tickCount;
      final x = fraction * size.width;
      final isActive = fraction <= progress.clamp(0.0, 1.0);

      paint.color = isActive ? activeColor : inactiveColor;

      final yStart = (height - tickHeight) / 2;
      canvas.drawLine(
        Offset(x, yStart),
        Offset(x, yStart + tickHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProgressBarTickPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tickCount != tickCount ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.activeTickColor != activeTickColor;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжний для доступності (Progress Bar Accessibility Helper)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для доступності лінійки прогресу.
///
/// Надає семантичні мітки, описи та значення для екранних читачів.
class ProgressBarAccessibilityHelper {
  ProgressBarAccessibilityHelper._();

  /// Форматує повну семантичну мітку для лінійки прогресу.
  ///
  /// [progress] — поточний прогрес.
  /// [context] — контекст (наприклад, «PS5», «XP»).
  /// [secondaryProgress] — вторинний прогрес.
  static String fullSemanticLabel({
    required double progress,
    String? context,
    double? secondaryProgress,
  }) {
    final percent = (progress.clamp(0.0, 1.0) * 100).toInt();
    final prefix = context != null ? '$context: ' : '';
    final base = '$prefix$percent% виконано';
    if (secondaryProgress != null) {
      final secPercent = (secondaryProgress.clamp(0.0, 1.0) * 100).toInt();
      return '$base, бонус: $secPercent%';
    }
    return base;
  }

  /// Повертає опис стану прогресу для TalkBack/VoiceOver.
  static String announceState(double progress) {
    final percent = (progress * 100).round();
    if (percent == 0) return 'Прогрес не розпочато';
    if (percent < 25) return 'Прогрес $percent відсотків, початковий етап';
    if (percent < 50) return 'Прогрес $percent відсотків, менше половини';
    if (percent < 75) return 'Прогрес $percent відсотків, більше половини';
    if (percent < 100) return 'Прогрес $percent відсотків, майже завершено';
    return 'Прогрес завершено на 100 відсотків';
  }

  /// Форматує повідомлення про зміну прогресу для екранних читачів.
  static String announceChange({
    required double oldProgress,
    required double newProgress,
    String? context,
  }) {
    final oldPercent = (oldProgress.clamp(0.0, 1.0) * 100).round();
    final newPercent = (newProgress.clamp(0.0, 1.0) * 100).round();
    final diff = newPercent - oldPercent;
    final sign = diff >= 0 ? '+' : '';
    final prefix = context != null ? '$context: ' : '';
    return '${prefix}Прогрес змінено на $sign$diff%, тепер $newPercent%';
  }

  /// Повертає тривалість оцінного залишку для доступності.
  ///
  /// [progress] — поточний прогрес.
  /// [totalMinutes] — загальна тривалість у хвилинах.
  static String announceTimeRemaining(double progress, int totalMinutes) {
    if (progress >= 1.0) return 'Завершено';
    final remaining = ((1.0 - progress) * totalMinutes).round();
    if (remaining < 1) return 'Менше хвилини залишилось';
    if (remaining < 60) return '$remaining хвилин залишилось';
    final hours = remaining ~/ 60;
    final mins = remaining % 60;
    return '$hours годин $mins хвилин залишилось';
  }

  /// Повертає опис режиму прогресу.
  static String modeDescription({
    required bool isIndeterminate,
    required bool showShimmer,
    required bool isPulsing,
  }) {
    if (isIndeterminate) return 'Режим завантаження, тривалість невідома';
    final features = <String>[];
    if (showShimmer) features.add('з ефектом блиску');
    if (isPulsing) features.add('з пульс-анімацією');
    if (features.isEmpty) return 'Звичайний режим прогресу';
    return 'Звичайний режим прогресу, ${features.join(', ')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Обчислювані властивості (Computed Props Extension)
// ═══════════════════════════════════════════════════════════════════════════

/// Додаткові обчислювані властивості для AppProgressBar.
///
/// Розширює можливості шкали прогресу зручними гетерами.
extension ProgressBarComputedProps on AppProgressBar {
  /// Чи прогрес завершено (100%).
  bool get isComplete => progress >= 1.0;

  /// Чи прогрес порожній (0%).
  bool get isEmpty => progress <= 0.0;

  /// Чи прогрес близький до завершення (≥85%).
  bool get isNearComplete =>
      progress >= glowThreshold && progress < 1.0;

  /// Чи прогрес в останній чверті (75–99%).
  bool get isInLastQuarter => progress >= 0.75 && progress < 1.0;

  /// Чи прогрес в першій половині (0–49%).
  bool get isInFirstHalf => progress >= 0.0 && progress < 0.5;

  /// Чи шкала підтримує мітку всередині.
  bool get canShowInnerLabel =>
      height.supportsInnerLabel && !isIndeterminate;

  /// Прогрес у відсотках (ціле число).
  int get percentValue => (progress.clamp(0.0, 1.0) * 100).round();

  /// Прогрес у відсотках (дробове число).
  double get percentDetailed => progress.clamp(0.0, 1.0) * 100.0;

  /// Залишок до 100% (у одиницях прогресу).
  double get remaining => 1.0 - progress.clamp(0.0, 1.0);

  /// Залишок до 100% у відсотках.
  int get remainingPercent =>
      ((1.0 - progress.clamp(0.0, 1.0)) * 100).round();

  /// Чи є активні сегменти.
  bool get hasActiveSegments =>
      segments != null && segments!.isNotEmpty;

  /// Чи є маркери кроків.
  bool get hasStepMarkers => stepMarkers != null && stepMarkers! > 1;

  /// Чи є етапи (milestones).
  bool get hasMilestones =>
      milestones != null && milestones!.isNotEmpty;

  /// Чи є вторинний прогрес.
  bool get hasSecondaryProgress =>
      secondaryProgress != null && secondaryProgress! > 0;

  /// Кількість видимих етапів (досягнутих прогресом).
  int get visibleMilestoneCount {
    if (milestones == null) return 0;
    return milestones!.where((m) => m.position <= progress).length;
  }

  /// Кількість завершених етапів.
  int get completedMilestoneCount {
    if (milestones == null) return 0;
    return milestones!.where((m) => m.isCompleted).length;
  }

  /// Ширина fill в пікселях (потрібно constraint).
  double fillWidthFor(double totalWidth) {
    return totalWidth * progress.clamp(0.0, 1.0);
  }

  /// Чи шкала має валідні параметри.
  bool get isValid {
    if (progress.isNaN || progress < 0.0 || progress > 1.0) return false;
    if (secondaryProgress != null &&
        (secondaryProgress!.isNaN ||
            secondaryProgress! < 0.0 ||
            secondaryProgress! > 1.0)) {
      return false;
    }
    return true;
  }
}
