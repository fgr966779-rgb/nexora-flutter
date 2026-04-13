import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_enums.dart';
import '../constants/app_durations.dart';

// ─── Particle Shapes ────────────────────────────────────────────────────────

/// Форми частинок у фоні.
enum ParticleShape {
  /// Звичайне коло.
  circle,

  /// Зірка з п'ятьма променями.
  star,

  /// Ромб.
  diamond,

  /// Серце.
  heart,

  /// Трикутник.
  triangle,

  /// Шестикутник.
  hexagon,

  /// Хрестик.
  cross,

  /// П'ятикутник.
  pentagon,

  /// Стрілка (вгору).
  arrow,

  /// Півмісяць.
  crescent,

  /// Блискавка.
  lightning;

  /// Малює форму на canvas.
  void draw(Canvas canvas, Offset center, double size, Paint paint) {
    switch (this) {
      case ParticleShape.circle:
        canvas.drawCircle(center, size, paint);
        break;
      case ParticleShape.star:
        _drawStar(canvas, center, size, paint);
        break;
      case ParticleShape.diamond:
        _drawDiamond(canvas, center, size, paint);
        break;
      case ParticleShape.heart:
        _drawHeart(canvas, center, size, paint);
        break;
      case ParticleShape.triangle:
        _drawTriangle(canvas, center, size, paint);
        break;
      case ParticleShape.hexagon:
        _drawHexagon(canvas, center, size, paint);
        break;
      case ParticleShape.cross:
        _drawCross(canvas, center, size, paint);
        break;
      case ParticleShape.pentagon:
        _drawPentagon(canvas, center, size, paint);
        break;
      case ParticleShape.arrow:
        _drawArrow(canvas, center, size, paint);
        break;
      case ParticleShape.crescent:
        _drawCrescent(canvas, center, size, paint);
        break;
      case ParticleShape.lightning:
        _drawLightning(canvas, center, size, paint);
        break;
    }
  }

  /// Українська назва форми.
  String get label {
    switch (this) {
      case ParticleShape.circle: return 'Круг';
      case ParticleShape.star: return 'Зірка';
      case ParticleShape.diamond: return 'Ромб';
      case ParticleShape.heart: return 'Серце';
      case ParticleShape.triangle: return 'Трикутник';
      case ParticleShape.hexagon: return 'Шестикутник';
      case ParticleShape.cross: return 'Хрестик';
      case ParticleShape.pentagon: return 'П\'ятикутник';
      case ParticleShape.arrow: return 'Стрілка';
      case ParticleShape.crescent: return 'Півмісяць';
      case ParticleShape.lightning: return 'Блискавка';
    }
  }

  /// Чи має форма гострі кути (для визначення складності рендерингу).
  bool get hasSharpEdges {
    switch (this) {
      case ParticleShape.circle:
      case ParticleShape.heart:
      case ParticleShape.crescent:
        return false;
      case ParticleShape.star:
      case ParticleShape.diamond:
      case ParticleShape.triangle:
      case ParticleShape.hexagon:
      case ParticleShape.cross:
      case ParticleShape.pentagon:
      case ParticleShape.arrow:
      case ParticleShape.lightning:
        return true;
    }
  }

  /// Кількість вершин форми (0 для криволінійних).
  int get vertexCount {
    switch (this) {
      case ParticleShape.circle: return 0;
      case ParticleShape.star: return 10;
      case ParticleShape.diamond: return 4;
      case ParticleShape.heart: return 0;
      case ParticleShape.triangle: return 3;
      case ParticleShape.hexagon: return 6;
      case ParticleShape.cross: return 12;
      case ParticleShape.pentagon: return 5;
      case ParticleShape.arrow: return 7;
      case ParticleShape.crescent: return 0;
      case ParticleShape.lightning: return 6;
    }
  }

  /// Повертає випадкову форму (виключаючи коло).
  static ParticleShape randomDecorative(math.Random rng) {
    final decorative = ParticleShape.values
        .where((s) => s != ParticleShape.circle)
        .toList();
    return decorative[rng.nextInt(decorative.length)];
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.6, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.6, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final s = size * 0.8;
    path.moveTo(center.dx, center.dy + s * 0.4);
    path.bezierCurveTo(
      center.dx - s, center.dy - s * 0.4,
      center.dx - s * 0.5, center.dy - s,
      center.dx, center.dy - s * 0.5,
    );
    path.bezierCurveTo(
      center.dx + s * 0.5, center.dy - s,
      center.dx + s, center.dy - s * 0.4,
      center.dx, center.dy + s * 0.4,
    );
    canvas.drawPath(path, paint);
  }

  void _drawTriangle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.87, center.dy + size * 0.5)
      ..lineTo(center.dx - size * 0.87, center.dy + size * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 6;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCross(Canvas canvas, Offset center, double size, Paint paint) {
    final arm = size * 0.9;
    final thick = size * 0.3;
    final path = Path()
      ..moveTo(center.dx - thick, center.dy - arm)
      ..lineTo(center.dx + thick, center.dy - arm)
      ..lineTo(center.dx + thick, center.dy - thick)
      ..lineTo(center.dx + arm, center.dy - thick)
      ..lineTo(center.dx + arm, center.dy + thick)
      ..lineTo(center.dx + thick, center.dy + thick)
      ..lineTo(center.dx + thick, center.dy + arm)
      ..lineTo(center.dx - thick, center.dy + arm)
      ..lineTo(center.dx - thick, center.dy + thick)
      ..lineTo(center.dx - arm, center.dy + thick)
      ..lineTo(center.dx - arm, center.dy - thick)
      ..lineTo(center.dx - thick, center.dy - thick)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawPentagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, Offset center, double size, Paint paint) {
    final s = size;
    final path = Path()
      ..moveTo(center.dx, center.dy - s)
      ..lineTo(center.dx + s * 0.7, center.dy + s * 0.1)
      ..lineTo(center.dx + s * 0.3, center.dy + s * 0.1)
      ..lineTo(center.dx + s * 0.3, center.dy + s)
      ..lineTo(center.dx - s * 0.3, center.dy + s)
      ..lineTo(center.dx - s * 0.3, center.dy + s * 0.1)
      ..lineTo(center.dx - s * 0.7, center.dy + s * 0.1)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCrescent(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: size),
      -math.pi / 2,
      math.pi * 1.5,
    );
    path.addArc(
      Rect.fromCircle(
        center: Offset(center.dx + size * 0.35, center.dy - size * 0.15),
        radius: size * 0.8,
      ),
      math.pi * 0.65,
      -math.pi * 1.6,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLightning(Canvas canvas, Offset center, double size, Paint paint) {
    final s = size;
    final path = Path()
      ..moveTo(center.dx + s * 0.1, center.dy - s)
      ..lineTo(center.dx - s * 0.4, center.dy + s * 0.05)
      ..lineTo(center.dx + s * 0.05, center.dy + s * 0.05)
      ..lineTo(center.dx - s * 0.15, center.dy + s)
      ..lineTo(center.dx + s * 0.5, center.dy - s * 0.15)
      ..lineTo(center.dx + s * 0.0, center.dy - s * 0.15)
      ..close();
    canvas.drawPath(path, paint);
  }
}

// ─── Particle Rendering Constants ────────────────────────────────────────────

/// Константи для рендерингу частинок.
///
/// Визначає межі, пороги та значення за замовчуванням для частинок.
class ParticleRenderConstants {
  ParticleRenderConstants._();

  /// Мінімальна кількість частинок для layered-режиму.
  static const int minLayeredParticles = 6;

  /// Максимальна кількість частинок (обмеження продуктивності).
  static const int maxParticleCount = 300;

  /// Мінімальний розмір частинки (пікселі).
  static const double minParticleSize = 0.5;

  /// Максимальний розмір частинки (пікселі).
  static const double maxParticleSize = 12.0;

  /// Радіус розсіювання при дотику (пікселі).
  static const double touchScatterRadius = 80.0;

  /// Максимальна сила розсіювання.
  static const double maxScatterForce = 30.0;

  /// Час життя точки дотику (мілісекунди).
  static const int touchPointLifetimeMs = 800;

  /// Тривалість базового циклу анімації (секунди).
  static const int animationCycleSeconds = 10;

  /// Мінімальний прогрес для зміни кількості частинок.
  static const double progressParticleThreshold = 0.05;

  /// Базова кількість частинок на кожні 10% прогресу.
  static const double particlesPerProgressDecade = 2.0;

  /// Мінімальна швидкість частинки (множник).
  static const double minSpeedMultiplier = 0.1;

  /// Максимальна швидкість частинки (множник).
  static const double maxSpeedMultiplier = 3.0;

  /// Кількість шарів у layered-системі.
  static const int layerCount = 3;

  /// Множник зменшення розміру для кожного шару.
  static const double layerSizeDecay = 0.2;

  /// Множник зменшення швидкості для кожного шару.
  static const double layerSpeedDecay = 0.3;

  /// Множник зменшення непрозорості для кожного шару.
  static const double layerOpacityDecay = 0.15;

  /// Поріг для переходу на святковий режим.
  static const double celebrationProgressThreshold = 0.95;

  /// Максимальна кількість частинок для низької продуктивності.
  static const int lowPerformanceMaxParticles = 30;

  /// Максимальна кількість точок сліду на частинку.
  static const int trailMaxPointsPerParticle = 8;

  /// Базовий радіус розмиття для glow-ефекту.
  static const double glowBlurRadius = 8.0;

  /// Частота пульсації частинок (цикли за одну анімацію).
  static const double pulseFrequency = 1.0;

  /// Цільова частота кадрів для анімації.
  static const int animationFpsTarget = 60;

  /// Тривалість fade-переходу (мілісекунди).
  static const int fadeTransitionDurationMs = 300;

  /// Ширина лінії силуету за замовчуванням.
  static const double silhouetteDefaultStrokeWidth = 1.5;

  /// Фактор масштабу форми частинки за замовчуванням.
  static const double shapeScaleFactor = 1.0;

  /// Мінімальна відстань між частинками для уникнення накладання.
  static const double minParticleSpacing = 5.0;

  /// Максимальна кількість активних точок дотику.
  static const int maxSimultaneousTouchPoints = 10;

  /// Множник зменшення glow при активних слідах.
  static const double trailGlowReduction = 0.5;

  /// Валідує непрозорість.
  ///
  /// Повертає значення, обмежене між 0.0 та 1.0.
  static double validateOpacity(double opacity) {
    return opacity.clamp(0.0, 1.0);
  }

  /// Валідує кількість шарів.
  ///
  /// Повертає значення, обмежене між 1 та [layerCount].
  static int validateLayers(int layers) {
    return layers.clamp(1, layerCount);
  }

  /// Валідує довжину сліду.
  ///
  /// Повертає значення, обмежене між 1 та [trailMaxPointsPerParticle].
  static int validateTrailLength(int length) {
    return length.clamp(1, trailMaxPointsPerParticle);
  }

  /// Обчислює оптимальну кількість частинок залежно від розміру екрану.
  ///
  /// [screenArea] — площа екрану в пікселях².
  /// [baseDensity] — бажана густина частинок на 1000×1000 пікселів.
  static int computeCountForScreenArea({
    required double screenArea,
    double baseDensity = 20.0,
  }) {
    final normalizedArea = screenArea / 1000000.0;
    final raw = (normalizedArea * baseDensity).round();
    return validateParticleCount(raw);
  }

  /// Оцінює загальну складність рендерингу (0.0–1.0).
  ///
  /// Враховує кількість частинок, сліди, шари та glow.
  static double computeRenderComplexity({
    required int particleCount,
    required bool enableTrails,
    required int layers,
    required double glowIntensity,
  }) {
    final countFactor = (particleCount / maxParticleCount).clamp(0.0, 1.0);
    final trailFactor = enableTrails ? 0.3 : 0.0;
    final layerFactor = (layers - 1) * 0.15;
    final glowFactor = glowIntensity * 0.2;
    return (countFactor + trailFactor + layerFactor + glowFactor)
        .clamp(0.0, 1.0);
  }

  /// Валідує кількість частинок.
  ///
  /// Повертає значення, обмежене між [minLayeredParticles] та
  /// [maxParticleCount].
  static int validateParticleCount(int count) {
    return count.clamp(minLayeredParticles, maxParticleCount);
  }

  /// Валідує розмір частинки.
  ///
  /// Повертає значення, обмежене між [minParticleSize] та
  /// [maxParticleSize].
  static double validateParticleSize(double size) {
    return size.clamp(minParticleSize, maxParticleSize);
  }

  /// Валідує швидкість частинки.
  ///
  /// Повертає значення, обмежене між [minSpeedMultiplier] та
  /// [maxSpeedMultiplier].
  static double validateSpeed(double speed) {
    return speed.clamp(minSpeedMultiplier, maxSpeedMultiplier);
  }

  /// Обчислює кількість частинок залежно від прогресу та пресету.
  ///
  /// [baseCount] — базова кількість з пресету.
  /// [progress] — поточний прогрес (0.0–1.0).
  /// [isCelebration] — чи увімкнено режим святкування.
  static int computeParticleCount({
    required int baseCount,
    required double progress,
    bool isCelebration = false,
  }) {
    final progressBonus =
        (progress * particlesPerProgressDecade * 10).round();
    final total = isCelebration
        ? baseCount * 2
        : baseCount + progressBonus;
    return validateParticleCount(total);
  }
}

// ─── Particle Configuration ──────────────────────────────────────────────────

/// Налаштування для генерації частинок.
///
/// Містить всі параметри для кастомного створення системи частинок
/// поза межами пресетів.
class ParticleConfig {
  const ParticleConfig({
    this.particleCount = 20,
    this.speedMultiplier = 0.5,
    this.maxSize = 3.0,
    this.glowIntensity = 0.12,
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
    this.minRadius = 0.15,
    this.maxRadius = 0.65,
    this.enableTrails = false,
    this.trailChance = 0.4,
    this.minTrailLength = 3,
    this.maxTrailLength = 6,
    this.layers = 1,
    this.shape,
  });

  /// Кількість частинок.
  final int particleCount;

  /// Множник швидкості (0.1–3.0).
  final double speedMultiplier;

  /// Максимальний розмір частинки.
  final double maxSize;

  /// Інтенсивність glow-ефекту.
  final double glowIntensity;

  /// Мінімальна непрозорість (0.0–1.0).
  final double minOpacity;

  /// Максимальна непрозорість (0.0–1.0).
  final double maxOpacity;

  /// Мінімальний орбітальний радіус (відносно центру).
  final double minRadius;

  /// Максимальний орбітальний радіус (відносно центру).
  final double maxRadius;

  /// Увімкнути сліди частинок.
  final bool enableTrails;

  /// Ймовірність сліду (0.0–1.0).
  final double trailChance;

  /// Мінімальна довжина сліду.
  final int minTrailLength;

  /// Максимальна довжина сліду.
  final int maxTrailLength;

  /// Кількість шарів (1–3).
  final int layers;

  /// Форма частинок (null = випадкова).
  final ParticleShape? shape;

  /// Створює конфігурацію з пресету.
  factory ParticleConfig.fromPreset(ParticleBehaviorPreset preset) {
    return ParticleConfig(
      particleCount: preset.particleCount,
      speedMultiplier: preset.speedMultiplier,
      maxSize: preset.maxSize,
      glowIntensity: preset.glowIntensity,
    );
  }

  /// Створює конфігурацію для святкування з подвійною кількістю.
  factory ParticleConfig.celebration({
    ParticleBehaviorPreset base = ParticleBehaviorPreset.festive,
  }) {
    return ParticleConfig.fromPreset(base).copyWith(
      particleCount: base.particleCount * 2,
      enableTrails: true,
      layers: 3,
    );
  }

  /// Створює мінімалістичну конфігурацію.
  factory ParticleConfig.minimal() {
    return const ParticleConfig(
      particleCount: 5,
      speedMultiplier: 0.2,
      maxSize: 1.5,
      glowIntensity: 0.05,
    );
  }

  /// Створює конфігурацію для компактних екранів.
  factory ParticleConfig.compact() {
    return const ParticleConfig(
      particleCount: 10,
      speedMultiplier: 0.3,
      maxSize: 2.0,
      glowIntensity: 0.08,
      minOpacity: 0.2,
      maxOpacity: 0.6,
    );
  }

  /// Повертає копію з заміненими полями.
  ParticleConfig copyWith({
    int? particleCount,
    double? speedMultiplier,
    double? maxSize,
    double? glowIntensity,
    double? minOpacity,
    double? maxOpacity,
    double? minRadius,
    double? maxRadius,
    bool? enableTrails,
    double? trailChance,
    int? minTrailLength,
    int? maxTrailLength,
    int? layers,
    ParticleShape? shape,
  }) {
    return ParticleConfig(
      particleCount: particleCount ?? this.particleCount,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      maxSize: maxSize ?? this.maxSize,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      minOpacity: minOpacity ?? this.minOpacity,
      maxOpacity: maxOpacity ?? this.maxOpacity,
      minRadius: minRadius ?? this.minRadius,
      maxRadius: maxRadius ?? this.maxRadius,
      enableTrails: enableTrails ?? this.enableTrails,
      trailChance: trailChance ?? this.trailChance,
      minTrailLength: minTrailLength ?? this.minTrailLength,
      maxTrailLength: maxTrailLength ?? this.maxTrailLength,
      layers: layers ?? this.layers,
      shape: shape ?? this.shape,
    );
  }

  /// Валідує конфігурацію та повертає виправлену копію.
  ///
  /// Перевіряє всі числові параметри на допустимі діапазони.
  ParticleConfig validated() {
    return copyWith(
      particleCount:
          ParticleRenderConstants.validateParticleCount(particleCount),
      speedMultiplier:
          ParticleRenderConstants.validateSpeed(speedMultiplier),
      maxSize: ParticleRenderConstants.validateParticleSize(maxSize),
      minOpacity: minOpacity.clamp(0.0, 1.0),
      maxOpacity: maxOpacity.clamp(0.0, 1.0),
      minRadius: minRadius.clamp(0.05, 0.5),
      maxRadius: maxRadius.clamp(0.3, 0.8),
      layers: layers.clamp(1, ParticleRenderConstants.layerCount),
      trailChance: trailChance.clamp(0.0, 1.0),
    );
  }

  /// Чи є конфігурація валідною без необхідності виправлення.
  bool get isValid {
    return particleCount >= ParticleRenderConstants.minLayeredParticles &&
        particleCount <= ParticleRenderConstants.maxParticleCount &&
        speedMultiplier >= ParticleRenderConstants.minSpeedMultiplier &&
        speedMultiplier <= ParticleRenderConstants.maxSpeedMultiplier &&
        maxSize >= ParticleRenderConstants.minParticleSize &&
        maxSize <= ParticleRenderConstants.maxParticleSize &&
        minOpacity >= 0.0 &&
        maxOpacity <= 1.0 &&
        minOpacity <= maxOpacity &&
        layers >= 1 &&
        layers <= ParticleRenderConstants.layerCount;
  }

  /// Обчислена ефективна кількість частинок із урахуванням прогресу.
  ///
  /// [progress] — поточний прогрес (0.0–1.0).
  int effectiveCount(double progress) {
    return ParticleRenderConstants.computeParticleCount(
      baseCount: particleCount,
      progress: progress,
    );
  }

  /// Обчислений множник розміру для заданого шару.
  ///
  /// [layerIndex] — індекс шару (0 = передній, 2 = задній).
  double layerSizeMultiplier(int layerIndex) {
    return 1.0 - layerIndex * ParticleRenderConstants.layerSizeDecay;
  }

  /// Обчислений множник швидкості для заданого шару.
  double layerSpeedMultiplier(int layerIndex) {
    return 1.0 - layerIndex * ParticleRenderConstants.layerSpeedDecay;
  }

  /// Обчислений множник непрозорості для заданого шару.
  double layerOpacityMultiplier(int layerIndex) {
    return 1.0 - layerIndex * ParticleRenderConstants.layerOpacityDecay;
  }

  /// Текстовий опис конфігурації (для дебаггінгу).
  @override
  String toString() {
    return 'ParticleConfig('
        'count: $particleCount, '
        'speed: ${speedMultiplier.toStringAsFixed(2)}, '
        'maxSize: ${maxSize.toStringAsFixed(1)}, '
        'glow: ${glowIntensity.toStringAsFixed(2)}, '
        'trails: $enableTrails, '
        'layers: $layers, '
        'shape: ${shape?.name ?? "mixed"})';
  }

  // ── Рівність та хеш ────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticleConfig &&
        other.particleCount == particleCount &&
        other.speedMultiplier == speedMultiplier &&
        other.maxSize == maxSize &&
        other.glowIntensity == glowIntensity &&
        other.minOpacity == minOpacity &&
        other.maxOpacity == maxOpacity &&
        other.minRadius == minRadius &&
        other.maxRadius == maxRadius &&
        other.enableTrails == enableTrails &&
        other.trailChance == trailChance &&
        other.minTrailLength == minTrailLength &&
        other.maxTrailLength == maxTrailLength &&
        other.layers == layers &&
        other.shape == shape;
  }

  @override
  int get hashCode => Object.hash(
        particleCount,
        speedMultiplier,
        maxSize,
        glowIntensity,
        minOpacity,
        maxOpacity,
        minRadius,
        maxRadius,
        enableTrails,
        trailChance,
        minTrailLength,
        maxTrailLength,
        layers,
        shape,
      );

  // ── Валідаційні повідомлення ───────────────────────────────────────────

  /// Список повідомлень про проблеми валідації.
  ///
  /// Повертає порожній список, якщо конфігурація валідна.
  List<String> get validationErrors {
    final errors = <String>[];
    if (particleCount < ParticleRenderConstants.minLayeredParticles) {
      errors.add(
        'particleCount ($particleCount) < min ('
            '${ParticleRenderConstants.minLayeredParticles})',
      );
    }
    if (particleCount > ParticleRenderConstants.maxParticleCount) {
      errors.add(
        'particleCount ($particleCount) > max ('
            '${ParticleRenderConstants.maxParticleCount})',
      );
    }
    if (speedMultiplier < ParticleRenderConstants.minSpeedMultiplier) {
      errors.add('speedMultiplier too low');
    }
    if (speedMultiplier > ParticleRenderConstants.maxSpeedMultiplier) {
      errors.add('speedMultiplier too high');
    }
    if (maxSize < ParticleRenderConstants.minParticleSize) {
      errors.add('maxSize too small');
    }
    if (maxSize > ParticleRenderConstants.maxParticleSize) {
      errors.add('maxSize too large');
    }
    if (minOpacity < 0.0 || minOpacity > 1.0) {
      errors.add('minOpacity out of range');
    }
    if (maxOpacity < 0.0 || maxOpacity > 1.0) {
      errors.add('maxOpacity out of range');
    }
    if (minOpacity > maxOpacity) {
      errors.add('minOpacity > maxOpacity');
    }
    if (layers < 1 || layers > ParticleRenderConstants.layerCount) {
      errors.add('layers out of range');
    }
    if (trailChance < 0.0 || trailChance > 1.0) {
      errors.add('trailChance out of range');
    }
    if (minTrailLength > maxTrailLength) {
      errors.add('minTrailLength > maxTrailLength');
    }
    return errors;
  }

  // ── Обчислювані властивості ────────────────────────────────────────────

  /// Оцінка ваги рендерингу (0.0–1.0).
  ///
  /// Враховує кількість частинок, сліди, шари та glow.
  double get estimatedRenderWeight {
    return ParticleRenderConstants.computeRenderComplexity(
      particleCount: particleCount,
      enableTrails: enableTrails,
      layers: layers,
      glowIntensity: glowIntensity,
    );
  }

  /// Загальна кількість точок сліду для всіх частинок.
  ///
  /// Обчислюється як: кількість × ймовірність × середня довжина.
  int get totalTrailPoints {
    final avgLength = (minTrailLength + maxTrailLength) / 2;
    return (particleCount * trailChance * avgLength).round();
  }

  /// Чи є конфігурація високопродуктивною.
  ///
  /// Вважається високопродуктивною без слідів, 1 шар,
  /// та кількість частинок у межах низької продуктивності.
  bool get isHighPerformance {
    return !enableTrails &&
        layers <= 1 &&
        particleCount <=
            ParticleRenderConstants.lowPerformanceMaxParticles;
  }

  /// Чи потребує конфігурація адаптивного зменшення частинок.
  bool get needsAdaptiveReduction => estimatedRenderWeight > 0.7;

  /// Середній розмір частинки (для оцінки візуальної щільності).
  double get averageParticleSize => maxSize * 0.6;

  // ── Додаткові фабрики ─────────────────────────────────────────────────

  /// Створює адаптивну конфігурацію залежно від ширини екрану.
  ///
  /// Для вузьких екранів (< 400) повертає compact,
  /// для широких (> 800) — стандартну з більшою кількістю.
  factory ParticleConfig.responsive(double screenWidth) {
    if (screenWidth < 400) {
      return ParticleConfig.compact();
    } else if (screenWidth > 800) {
      return const ParticleConfig(
        particleCount: 30,
        speedMultiplier: 0.4,
        maxSize: 3.5,
        glowIntensity: 0.1,
        enableTrails: true,
        trailChance: 0.3,
      );
    }
    return const ParticleConfig();
  }

  /// Створює конфігурацію для режиму доступності (менше руху).
  factory ParticleConfig.accessible() {
    return const ParticleConfig(
      particleCount: 8,
      speedMultiplier: 0.15,
      maxSize: 2.0,
      glowIntensity: 0.05,
      enableTrails: false,
      layers: 1,
    );
  }

  /// Створює конфігурацію з енергозбереженням.
  factory ParticleConfig.powerSaving() {
    return const ParticleConfig(
      particleCount: ParticleRenderConstants.minLayeredParticles,
      speedMultiplier: ParticleRenderConstants.minSpeedMultiplier,
      maxSize: 1.0,
      glowIntensity: 0.0,
      enableTrails: false,
      layers: 1,
    );
  }
}

// ─── Behavior Presets ───────────────────────────────────────────────────────

/// Попередньо налаштовані режими поведінки частинок.
enum ParticleBehaviorPreset {
  /// Спокійний — повільні, маленькі, легкі частинки.
  calm,

  /// Енергійний — швидкі, яскраві, з великим діапазоном.
  energetic,

  /// Сяючий — з великим glow-ефектом, м'які.
  glowing,

  /// Святковий — різні форми, швидкі, яскраві.
  festive,

  /// Мінімальний — найменша кількість, найменші частинки.
  minimal,

  /// Плаваючий — частинки повільно піднімаються вгору як бульбашки.
  floating,

  /// Космічний — глибокі просторові частинки з великою глибиною.
  cosmic,

  /// Сніжний — м'які білі частинки, що повільно падають.
  snow;

  /// Кількість частинок.
  int get particleCount {
    switch (this) {
      case ParticleBehaviorPreset.calm: return 15;
      case ParticleBehaviorPreset.energetic: return 50;
      case ParticleBehaviorPreset.glowing: return 30;
      case ParticleBehaviorPreset.festive: return 100;
      case ParticleBehaviorPreset.minimal: return 8;
      case ParticleBehaviorPreset.floating: return 25;
      case ParticleBehaviorPreset.cosmic: return 60;
      case ParticleBehaviorPreset.snow: return 40;
    }
  }

  /// Базова швидкість руху (множник).
  double get speedMultiplier {
    switch (this) {
      case ParticleBehaviorPreset.calm: return 0.3;
      case ParticleBehaviorPreset.energetic: return 1.5;
      case ParticleBehaviorPreset.glowing: return 0.5;
      case ParticleBehaviorPreset.festive: return 1.0;
      case ParticleBehaviorPreset.minimal: return 0.2;
      case ParticleBehaviorPreset.floating: return 0.25;
      case ParticleBehaviorPreset.cosmic: return 0.8;
      case ParticleBehaviorPreset.snow: return 0.15;
    }
  }

  /// Максимальний розмір частинки.
  double get maxSize {
    switch (this) {
      case ParticleBehaviorPreset.calm: return 2.0;
      case ParticleBehaviorPreset.energetic: return 4.0;
      case ParticleBehaviorPreset.glowing: return 5.0;
      case ParticleBehaviorPreset.festive: return 4.0;
      case ParticleBehaviorPreset.minimal: return 1.5;
      case ParticleBehaviorPreset.floating: return 3.5;
      case ParticleBehaviorPreset.cosmic: return 3.0;
      case ParticleBehaviorPreset.snow: return 4.5;
    }
  }

  /// Інтенсивність glow-ефекту.
  double get glowIntensity {
    switch (this) {
      case ParticleBehaviorPreset.calm: return 0.08;
      case ParticleBehaviorPreset.energetic: return 0.12;
      case ParticleBehaviorPreset.glowing: return 0.2;
      case ParticleBehaviorPreset.festive: return 0.15;
      case ParticleBehaviorPreset.minimal: return 0.05;
      case ParticleBehaviorPreset.floating: return 0.1;
      case ParticleBehaviorPreset.cosmic: return 0.18;
      case ParticleBehaviorPreset.snow: return 0.06;
    }
  }

  /// Українська назва пресету.
  String get label {
    switch (this) {
      case ParticleBehaviorPreset.calm: return 'Спокійний';
      case ParticleBehaviorPreset.energetic: return 'Енергійний';
      case ParticleBehaviorPreset.glowing: return 'Сяючий';
      case ParticleBehaviorPreset.festive: return 'Святковий';
      case ParticleBehaviorPreset.minimal: return 'Мінімальний';
      case ParticleBehaviorPreset.floating: return 'Плаваючий';
      case ParticleBehaviorPreset.cosmic: return 'Космічний';
      case ParticleBehaviorPreset.snow: return 'Сніжний';
    }
  }

  /// Чи є пресет призначеним для святкування.
  bool get isCelebrationPreset {
    switch (this) {
      case ParticleBehaviorPreset.festive:
      case ParticleBehaviorPreset.cosmic:
        return true;
      case ParticleBehaviorPreset.calm:
      case ParticleBehaviorPreset.energetic:
      case ParticleBehaviorPreset.glowing:
      case ParticleBehaviorPreset.minimal:
      case ParticleBehaviorPreset.floating:
      case ParticleBehaviorPreset.snow:
        return false;
    }
  }

  /// Оцінка продуктивності пресету (0 = легкий, 1 = важкий).
  double get performanceWeight {
    switch (this) {
      case ParticleBehaviorPreset.minimal: return 0.05;
      case ParticleBehaviorPreset.calm: return 0.15;
      case ParticleBehaviorPreset.snow: return 0.2;
      case ParticleBehaviorPreset.floating: return 0.25;
      case ParticleBehaviorPreset.glowing: return 0.4;
      case ParticleBehaviorPreset.energetic: return 0.6;
      case ParticleBehaviorPreset.cosmic: return 0.75;
      case ParticleBehaviorPreset.festive: return 0.9;
    }
  }
}

// ─── Color Schemes ──────────────────────────────────────────────────────────

/// Кольорові схеми для частинок залежно від типу цілі.
class ParticleColorScheme {
  const ParticleColorScheme({
    required this.colors,
    required this.glowColor,
  });

  final List<Color> colors;
  final Color glowColor;

  static const ps5 = ParticleColorScheme(
    colors: [
      Color(0xFF006FCD),
      Color(0xFF00C6FF),
      Color(0xFF4D9AE8),
      Color(0xFF004A8A),
      Color(0xFF80D8FF),
    ],
    glowColor: Color(0x33006FCD),
  );

  static const monitor = ParticleColorScheme(
    colors: [
      Color(0xFF006FCD),
      Color(0xFF4D9AE8),
      Color(0xFF00C6FF),
      Color(0xFFB3E5FC),
      Color(0xFFE1F5FE),
    ],
    glowColor: Color(0x1A006FCD),
  );

  static const gold = ParticleColorScheme(
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFB300),
      Color(0xFFFFA000),
      Color(0xFFFF8F00),
      Color(0xFFFFE082),
    ],
    glowColor: Color(0x33FFD700),
  );

  static const neon = ParticleColorScheme(
    colors: [
      Color(0xFFFF0080),
      Color(0xFF00FF88),
      Color(0xFF00C6FF),
      Color(0xFFFF6EC7),
      Color(0xFF7B61FF),
    ],
    glowColor: Color(0x33FF0080),
  );

  /// Полярне сяйво — зелені, блакитні, фіолетові тони.
  static const aurora = ParticleColorScheme(
    colors: [
      Color(0xFF00FF88),
      Color(0xFF00C6FF),
      Color(0xFF7B61FF),
      Color(0xFF00E5FF),
      Color(0xFF76FF03),
    ],
    glowColor: Color(0x3300FF88),
  );

  /// Захід сонця — теплі помаранчеві та рожеві тони.
  static const sunset = ParticleColorScheme(
    colors: [
      Color(0xFFFF6F00),
      Color(0xFFFF8F00),
      Color(0xFFFF5722),
      Color(0xFFE91E63),
      Color(0xFFFFAB40),
    ],
    glowColor: Color(0x33FF6F00),
  );

  /// Океан — глибокі сині та бірюзові тони.
  static const ocean = ParticleColorScheme(
    colors: [
      Color(0xFF006064),
      Color(0xFF00838F),
      Color(0xFF00ACC1),
      Color(0xFF26C6DA),
      Color(0xFF80DEEA),
    ],
    glowColor: Color(0x33006064),
  );

  /// Ліс — природні зелені та жовто-зелені тони.
  static const forest = ParticleColorScheme(
    colors: [
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
      Color(0xFF43A047),
      Color(0xFF66BB6A),
      Color(0xFFA5D6A7),
    ],
    glowColor: Color(0x331B5E20),
  );

  /// Лавовий — вогняні червоні та помаранчеві тони.
  static const lava = ParticleColorScheme(
    colors: [
      Color(0xFFBF360C),
      Color(0xFFD84315),
      Color(0xFFFF5722),
      Color(0xFFFF6E40),
      Color(0xFFFF9E80),
    ],
    glowColor: Color(0x33BF360C),
  );

  /// Обирає схему за типом цілі та темою.
  ///
  /// Повертає відповідну кольорову схему залежно від [goalType]
  /// та [isLightTheme].
  static ParticleColorScheme forGoal({
    required GoalType goalType,
    required bool isLightTheme,
  }) {
    if (isLightTheme) return monitor;
    switch (goalType) {
      case GoalType.ps5:
        return ps5;
      case GoalType.monitor:
        return monitor;
    }
  }

  /// Обирає випадковий колір зі схеми.
  ///
  /// [rng] — генератор випадкових чисел.
  Color randomColor(math.Random rng) {
    return colors[rng.nextInt(colors.length)];
  }

  /// Інтерполює колір зі схеми на основі значення [t] (0.0–1.0).
  ///
  /// Корисно для градієнтних ефектів між кольорами схеми.
  Color lerp(double t) {
    final clampedT = t.clamp(0.0, 1.0);
    if (colors.isEmpty) return const Color(0x00000000);
    if (colors.length == 1) return colors.first;

    final scaledT = clampedT * (colors.length - 1);
    final index = scaledT.floor().clamp(0, colors.length - 2);
    final fraction = scaledT - index;

    return Color.lerp(colors[index], colors[index + 1], fraction)!;
  }

  /// Кількість кольорів у схемі.
  int get colorCount => colors.length;

  /// Перевіряє, чи схема містить достатньо кольорів для святкування.
  bool get isSuitableForCelebration => colors.length >= 4;

  // ── Нові схеми ──────────────────────────────────────────────────────────

  /// Сакура — рожеві та білі тони.
  static const cherryBlossom = ParticleColorScheme(
    colors: [
      Color(0xFFFFB7C5),
      Color(0xFFFF69B4),
      Color(0xFFFFC0CB),
      Color(0xFFFFD1DC),
      Color(0xFFFFFFFF),
    ],
    glowColor: Color(0x33FFB7C5),
  );

  /// Північне сяйво — глибокі сині та фіолетові тони.
  static const midnight = ParticleColorScheme(
    colors: [
      Color(0xFF1A237E),
      Color(0xFF283593),
      Color(0xFF3949AB),
      Color(0xFF5C6BC0),
      Color(0xFF7986CB),
    ],
    glowColor: Color(0x331A237E),
  );

  /// Мороз — крижані білі та блакитні тони.
  static const frost = ParticleColorScheme(
    colors: [
      Color(0xFFE0F7FA),
      Color(0xFFB2EBF2),
      Color(0xFF80DEEA),
      Color(0xFF4DD0E1),
      Color(0xFFFFFFFF),
    ],
    glowColor: Color(0x33B2EBF2),
  );

  // ── Обчислювані властивості ────────────────────────────────────────────

  /// Домінуючий колір схеми (перший колір).
  Color get dominantColor =>
      colors.isNotEmpty ? colors.first : const Color(0x00000000);

  /// Середня яскравість кольорів схеми (0.0–1.0).
  ///
  /// Обчислюється на основі sRGB яскравості.
  double get averageBrightness {
    if (colors.isEmpty) return 0.0;
    var total = 0.0;
    for (final c in colors) {
      total += (c.red * 0.299 + c.green * 0.587 + c.blue * 0.114) / 255.0;
    }
    return total / colors.length;
  }

  /// Чи є схема теплою (помаранчеві, червоні, рожеві тони).
  bool get isWarm {
    if (colors.isEmpty) return false;
    final warmCount = colors.where((c) {
      final hue = _hueFromColor(c);
      return (hue >= 0.0 && hue < 60.0) || hue >= 300.0;
    }).length;
    return warmCount > colors.length / 2;
  }

  /// Чи є схема холодною (сині, зелені, фіолетові тони).
  bool get isCool {
    if (colors.isEmpty) return false;
    final coolCount = colors.where((c) {
      final hue = _hueFromColor(c);
      return hue >= 120.0 && hue < 300.0;
    }).length;
    return coolCount > colors.length / 2;
  }

  /// Перевіряє, чи колір міститься у схемі (з урахуванням толерансу).
  ///
  /// [target] — цільовий колір.
  /// [tolerance] — допустима різниця по кожному каналу (0–255).
  bool containsColor(Color target, {int tolerance = 10}) {
    return colors.any((c) =>
        (c.red - target.red).abs() <= tolerance &&
        (c.green - target.green).abs() <= tolerance &&
        (c.blue - target.blue).abs() <= tolerance);
  }

  /// Створює затемнену версію схеми.
  ///
  /// [factor] — множник затемнення (0.0–1.0, 0 = чорний, 1 = без змін).
  ParticleColorScheme dim(double factor) {
    return ParticleColorScheme(
      colors: colors
          .map((c) => Color.fromARGB(
                c.alpha,
                (c.red * factor).round().clamp(0, 255),
                (c.green * factor).round().clamp(0, 255),
                (c.blue * factor).round().clamp(0, 255),
              ))
          .toList(),
      glowColor: Color.fromARGB(
        glowColor.alpha,
        (glowColor.red * factor).round().clamp(0, 255),
        (glowColor.green * factor).round().clamp(0, 255),
        (glowColor.blue * factor).round().clamp(0, 255),
      ),
    );
  }

  /// Створює освітлену версію схеми.
  ///
  /// [factor] — множник освітлення (0.0–1.0, 0 = без змін, 1 = білий).
  ParticleColorScheme lighten(double factor) {
    return ParticleColorScheme(
      colors: colors
          .map((c) => Color.fromARGB(
                c.alpha,
                (c.red + (255 - c.red) * factor).round().clamp(0, 255),
                (c.green + (255 - c.green) * factor).round().clamp(0, 255),
                (c.blue + (255 - c.blue) * factor).round().clamp(0, 255),
              ))
          .toList(),
      glowColor: Color.fromARGB(
        glowColor.alpha,
        (glowColor.red + (255 - glowColor.red) * factor)
            .round()
            .clamp(0, 255),
        (glowColor.green + (255 - glowColor.green) * factor)
            .round()
            .clamp(0, 255),
        (glowColor.blue + (255 - glowColor.blue) * factor)
            .round()
            .clamp(0, 255),
      ),
    );
  }

  /// Обчислює відтінок (hue) кольору у градусах (0–360).
  static double _hueFromColor(Color c) {
    final r = c.red / 255.0;
    final g = c.green / 255.0;
    final b = c.blue / 255.0;
    final max = [r, g, b].reduce(math.max);
    final min = [r, g, b].reduce(math.min);
    final delta = max - min;
    if (delta == 0) return 0.0;

    double hue;
    if (max == r) {
      hue = 60 * (((g - b) / delta) % 6);
    } else if (max == g) {
      hue = 60 * ((b - r) / delta + 2);
    } else {
      hue = 60 * ((r - g) / delta + 4);
    }
    return hue < 0 ? hue + 360 : hue;
  }
}

// ─── Orbital Particle ───────────────────────────────────────────────────────

/// Орбітальна частинка з формою та слідом.
class _OrbitalParticle {
  _OrbitalParticle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.color,
    this.shape = ParticleShape.circle,
    this.hasTrail = false,
    this.trailLength = 3,
    this.trailPositions = const [],
    this.layerIndex = 0,
  });

  final double angle;
  final double radius;
  final double speed;
  final double size;
  final double opacity;
  final Color color;
  final ParticleShape shape;
  final bool hasTrail;
  final int trailLength;
  final List<Offset> trailPositions;
  final int layerIndex;

  _OrbitalParticle copyWith({
    List<Offset>? trailPositions,
  }) {
    return _OrbitalParticle(
      angle: angle,
      radius: radius,
      size: size,
      opacity: opacity,
      color: color,
      speed: speed,
      shape: shape,
      hasTrail: hasTrail,
      trailLength: trailLength,
      trailPositions: trailPositions ?? this.trailPositions,
      layerIndex: layerIndex,
    );
  }
}

// ─── Touch Interaction ──────────────────────────────────────────────────────

/// Дані про точку дотику для розсіювання частинок.
class _TouchPoint {
  _TouchPoint({
    required this.position,
    required this.time,
    required this.force,
  });

  final Offset position;
  final DateTime time;
  final double force;

  bool get isExpired =>
      DateTime.now().difference(time).inMilliseconds > 800;
}

// ─── Widget ─────────────────────────────────────────────────────────────────

/// Анімований частинковий фон з силуетом пристрою.
///
/// Підтримує:
/// - Форми частинок: circle, star, diamond, heart, triangle, hexagon
/// - Кольорові схеми per theme (PS5 / Monitor / Gold / Neon)
/// - Залежність щільності частинок від прогресу (специфікація 4.2)
/// - Швидкість анімації залежно від настрою
/// - Дотик: частинки розсіюються при натисканні
/// - Ефект сліду за частинками
/// - Режим святкування (100+ частинок)
/// - Попередньо налаштовані режими поведінки
/// - Багаторівнева система частинок
class ParticleSilhouette extends StatefulWidget {
  const ParticleSilhouette({
    super.key,
    required this.goalType,
    required this.progress,
    this.isLightTheme = false,
    this.size,
    this.moodIntensity = 0.5,
    this.particleShape = ParticleShape.circle,
    this.celebrationMode = false,
    this.enableTrails = false,
    this.enableTouchInteraction = true,
    this.behaviorPreset = ParticleBehaviorPreset.calm,
    this.colorScheme,
    this.enableLayeredSystem = false,
  });

  /// Тип цілі (визначає силует).
  final GoalType goalType;

  /// Прогрес (0.0 - 1.0).
  final double progress;

  /// Світла тема.
  final bool isLightTheme;

  /// Розмір виджета.
  final Size? size;

  /// Інтенсивність настрою (0.0 - 1.0) для швидкості анімації.
  final double moodIntensity;

  /// Форма частинок.
  final ParticleShape particleShape;

  /// Режим святкування — 100+ частинок.
  final bool celebrationMode;

  /// Увімкнути ефект сліду за частинками.
  final bool enableTrails;

  /// Увімкнути взаємодію з дотиком (розсіювання).
  final bool enableTouchInteraction;

  /// Попередній налаштований режим поведінки.
  final ParticleBehaviorPreset behaviorPreset;

  /// Кастомна кольорова схема (якщо не вказано — тема за goalType).
  final ParticleColorScheme? colorScheme;

  /// Увімкнути багаторівневу систему частинок (фон + передній план).
  final bool enableLayeredSystem;

  @override
  State<ParticleSilhouette> createState() => _ParticleSilhouetteState();
}

class _ParticleSilhouetteState extends State<ParticleSilhouette>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_OrbitalParticle> _particles;
  final List<_TouchPoint> _touchPoints = [];
  static final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = _generateParticles();
  }

  /// Генерує частинки з урахуванням прогресу, настрою та пресету.
  List<_OrbitalParticle> _generateParticles() {
    final preset = widget.behaviorPreset;
    final baseCount = widget.celebrationMode
        ? preset.particleCount * 2
        : (preset.particleCount + widget.progress * 20).round();
    final count = baseCount.round();

    final colorScheme = widget.colorScheme ??
        (widget.isLightTheme
            ? ParticleColorScheme.monitor
            : ParticleColorScheme.ps5);

    return List.generate(count, (i) {
      final useShape = widget.celebrationMode
          ? ParticleShape.values[_random.nextInt(ParticleShape.values.length)]
          : widget.particleShape;

      final layerIndex = widget.enableLayeredSystem
          ? _random.nextInt(3)
          : 0;

      final layerSpeedMult = 1.0 - (layerIndex * 0.3);

      return _OrbitalParticle(
        angle: _random.nextDouble() * 2 * math.pi,
        radius: 0.25 + _random.nextDouble() * 0.3,
        speed: (0.002 + _random.nextDouble() * 0.004) *
            (_random.nextBool() ? 1 : -1) *
            (0.5 + widget.moodIntensity) *
            preset.speedMultiplier *
            layerSpeedMult,
        size: (1.0 + _random.nextDouble() * preset.maxSize) *
            (1.0 - layerIndex * 0.2),
        opacity: (0.3 + _random.nextDouble() * 0.7) *
            (1.0 - layerIndex * 0.15),
        color: colorScheme.colors[_random.nextInt(colorScheme.colors.length)],
        shape: useShape,
        hasTrail: widget.enableTrails && _random.nextDouble() > 0.6,
        trailLength: widget.enableTrails ? 3 + _random.nextInt(4) : 0,
        layerIndex: layerIndex,
      );
    });
  }

  @override
  void didUpdateWidget(covariant ParticleSilhouette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.celebrationMode != widget.celebrationMode ||
        oldWidget.moodIntensity != widget.moodIntensity ||
        oldWidget.particleShape != widget.particleShape ||
        oldWidget.behaviorPreset != widget.behaviorPreset ||
        oldWidget.colorScheme != widget.colorScheme ||
        oldWidget.enableLayeredSystem != widget.enableLayeredSystem) {
      _particles = _generateParticles();
    }
  }

  /// Обробка дотику — додавання точки розсіювання.
  void _handleTap(TapDownDetails details) {
    if (!widget.enableTouchInteraction) return;
    setState(() {
      _touchPoints.add(_TouchPoint(
        position: details.localPosition,
        time: DateTime.now(),
        force: 1.0,
      ));
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.enableTouchInteraction) return;
    setState(() {
      _touchPoints.add(_TouchPoint(
        position: details.localPosition,
        time: DateTime.now(),
        force: 0.5,
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final silhouetteColor = widget.isLightTheme
        ? AppColorsMonitor.textHint.withOpacity(0.15)
        : AppColorsPS5.textHint.withOpacity(0.12);

    // Очищаємо застарілі точки дотику
    _touchPoints.removeWhere((t) => t.isExpired);

    return GestureDetector(
      onTapDown: _handleTap,
      onPanUpdate: _handlePanUpdate,
      child: SizedBox(
        width: widget.size?.width ?? double.infinity,
        height: widget.size?.height ?? 200,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticleSilhouettePainter(
                particles: _particles,
                time: _controller.value,
                silhouetteColor: silhouetteColor,
                goalType: widget.goalType,
                progress: widget.progress,
                touchPoints: _touchPoints,
                glowIntensity: widget.behaviorPreset.glowIntensity,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _ParticleSilhouettePainter extends CustomPainter {
  _ParticleSilhouettePainter({
    required this.particles,
    required this.time,
    required this.silhouetteColor,
    required this.goalType,
    required this.progress,
    required this.touchPoints,
    this.glowIntensity = 0.12,
  });

  final List<_OrbitalParticle> particles;
  final double time;
  final Color silhouetteColor;
  final GoalType goalType;
  final double progress;
  final List<_TouchPoint> touchPoints;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Малюємо силует
    _drawSilhouette(canvas, center, size);

    // Малюємо орбітальні частинки
    for (final p in particles) {
      final currentAngle = p.angle + p.speed * time * 1000;
      var wobbleRadius =
          p.radius + math.sin(time * 2 * math.pi + p.angle) * 0.02;
      final clampedRadius = wobbleRadius.clamp(0.15, 0.65);

      var px = center.dx + math.cos(currentAngle) * size.width * clampedRadius;
      var py =
          center.dy + math.sin(currentAngle) * size.height * clampedRadius * 0.7;

      // Взаємодія з дотиком — розсіювання
      for (final touch in touchPoints) {
        final dx = px - touch.position.dx;
        final dy = py - touch.position.dy;
        final dist = math.sqrt(dx * dx + dy * dy);
        final scatterRadius = 80.0 * touch.force;
        if (dist < scatterRadius && dist > 0) {
          final force = (1 - dist / scatterRadius) * 30 * touch.force;
          px += (dx / dist) * force;
          py += (dy / dist) * force;
        }
      }

      // Слід частинки
      if (p.hasTrail && p.trailPositions.isNotEmpty) {
        for (var i = 0; i < p.trailPositions.length; i++) {
          final trailOpacity =
              p.opacity * 0.2 * (i / p.trailPositions.length);
          final trailSize = p.size * 0.5 * (i / p.trailPositions.length);
          final trailPaint = Paint()
            ..color = p.color.withOpacity(trailOpacity);
          canvas.drawCircle(
            p.trailPositions[i],
            trailSize,
            trailPaint,
          );
        }
      }

      // Основна частинка
      final particlePaint = Paint()
        ..color = p.color.withOpacity(p.opacity * 0.6);
      p.shape.draw(canvas, Offset(px, py), p.size, particlePaint);

      // Ефект світіння
      final glowPaint = Paint()
        ..color = p.color.withOpacity(p.opacity * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(px, py), p.size * 3, glowPaint);
    }
  }

  void _drawSilhouette(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..color = silhouetteColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final scale = size.width * 0.0018;

    if (goalType == GoalType.ps5) {
      _drawPs5Shape(canvas, center, scale, paint);
    } else {
      _drawMonitorShape(canvas, center, scale, paint);
    }
  }

  void _drawPs5Shape(Canvas canvas, Offset center, double scale, Paint paint) {
    final bodyWidth = 160.0 * scale;
    final bodyHeight = 40.0 * scale;
    final bodyRect = Rect.fromCenter(
      center: center,
      width: bodyWidth,
      height: bodyHeight,
    );

    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(8 * scale)));

    final leftWingPath = Path()
      ..moveTo(center.dx - bodyWidth / 2, center.dy - bodyHeight / 2 + 5 * scale)
      ..lineTo(center.dx - bodyWidth / 2 - 25 * scale, center.dy - bodyHeight / 2 - 10 * scale)
      ..lineTo(center.dx - bodyWidth / 2 - 25 * scale, center.dy + bodyHeight / 2 + 10 * scale)
      ..lineTo(center.dx - bodyWidth / 2, center.dy + bodyHeight / 2 - 5 * scale)
      ..close();

    final rightWingPath = Path()
      ..moveTo(center.dx + bodyWidth / 2, center.dy - bodyHeight / 2 + 5 * scale)
      ..lineTo(center.dx + bodyWidth / 2 + 25 * scale, center.dy - bodyHeight / 2 - 10 * scale)
      ..lineTo(center.dx + bodyWidth / 2 + 25 * scale, center.dy + bodyHeight / 2 + 10 * scale)
      ..lineTo(center.dx + bodyWidth / 2, center.dy + bodyHeight / 2 - 5 * scale)
      ..close();

    final lightPaint = Paint()
      ..color = AppColorsPS5.accentLight.withOpacity(0.2 + progress * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(leftWingPath, paint);
    canvas.drawPath(rightWingPath, paint);

    canvas.drawLine(
      Offset(center.dx - bodyWidth / 2 - 20 * scale, center.dy),
      Offset(center.dx + bodyWidth / 2 + 20 * scale, center.dy),
      lightPaint,
    );
  }

  void _drawMonitorShape(Canvas canvas, Offset center, double scale, Paint paint) {
    final screenWidth = 130.0 * scale;
    final screenHeight = 85.0 * scale;
    final screenRect = Rect.fromCenter(
      center: center - Offset(0, 10 * scale),
      width: screenWidth,
      height: screenHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, Radius.circular(6 * scale)),
      paint,
    );

    final neckTop = center.dy + screenHeight / 2 - 10 * scale;
    final neckBottom = neckTop + 25 * scale;
    canvas.drawLine(
      Offset(center.dx, neckTop),
      Offset(center.dx, neckBottom),
      paint,
    );

    final baseWidth = 60.0 * scale;
    final basePath = Path()
      ..moveTo(center.dx - baseWidth / 2, neckBottom)
      ..lineTo(center.dx + baseWidth / 2, neckBottom)
      ..lineTo(center.dx + baseWidth / 2 - 5 * scale, neckBottom + 8 * scale)
      ..lineTo(center.dx - baseWidth / 2 + 5 * scale, neckBottom + 8 * scale)
      ..close();
    canvas.drawPath(basePath, paint);

    final glowPaint = Paint()
      ..color = AppColorsMonitor.accent.withOpacity(0.1 + progress * 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        screenRect.inflate(-4 * scale),
        Radius.circular(4 * scale),
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticleSilhouettePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.progress != progress ||
        oldDelegate.goalType != goalType ||
        oldDelegate.touchPoints != touchPoints;
  }
}

// ─── Particle Physics Helpers ──────────────────────────────────────────────────

/// Допоміжні методи для фізики частинок.
///
/// Надає математичні функції для обчислення траєкторій, швидкостей,
/// прискорень та взаємодій між частинками.
class ParticlePhysics {
  ParticlePhysics._();

  /// Обчислює кут між двома точками.
  ///
  /// Повертає кут у радіанах від [start] до [end].
  static double angleBetween(Offset start, Offset end) {
    return math.atan2(end.dy - start.dy, end.dx - start.dx);
  }

  /// Обчислює відстань між двома точками.
  ///
  /// Повертає евклідову відстань у пікселях.
  static double distanceBetween(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Обчислює силу відштовхування від точки дотику.
  ///
  /// [particlePos] — поточна позиція частинки.
  /// [touchPos] — позиція дотику.
  /// [touchForce] — сила дотику (0.0–1.0).
  /// [scatterRadius] — радіус зони розсіювання.
  /// [maxForce] — максимальна сила відштовхування.
  ///
  /// Повертає [Offset] з вектором сили, що треба додати до позиції.
  static Offset computeScatterForce({
    required Offset particlePos,
    required Offset touchPos,
    double touchForce = 1.0,
    double scatterRadius = ParticleRenderConstants.touchScatterRadius,
    double maxForce = ParticleRenderConstants.maxScatterForce,
  }) {
    final dx = particlePos.dx - touchPos.dx;
    final dy = particlePos.dy - touchPos.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    if (dist >= scatterRadius || dist <= 0) return Offset.zero;

    final normalizedDx = dx / dist;
    final normalizedDy = dy / dist;
    final forceMagnitude = (1 - dist / scatterRadius) * maxForce * touchForce;

    return Offset(
      normalizedDx * forceMagnitude,
      normalizedDy * forceMagnitude,
    );
  }

  /// Обчислює позицію частинки на орбіті.
  ///
  /// [center] — центр орбіти.
  /// [angle] — поточний кут у радіанах.
  /// [radiusX] — радіус по осі X.
  /// [radiusY] — радіус по осі Y (для еліптичних орбіт).
  /// [wobble] — амплітуда коливання (небольшое відхилення).
  /// [wobbleOffset] — фазовий зсув для хвилі.
  static Offset computeOrbitalPosition({
    required Offset center,
    required double angle,
    required double radiusX,
    required double radiusY,
    double wobble = 0.0,
    double wobbleOffset = 0.0,
  }) {
    final effectiveRadiusX = radiusX + wobble * math.sin(angle * 2 + wobbleOffset);
    final effectiveRadiusY = radiusY + wobble * math.cos(angle * 2 + wobbleOffset);

    return Offset(
      center.dx + math.cos(angle) * effectiveRadiusX,
      center.dy + math.sin(angle) * effectiveRadiusY,
    );
  }

  /// Обчислює градієнтну непрозорість частинки залежно від відстані до центру.
  ///
  /// Частинки далі від центру — менш непрозорі.
  /// [normalizedRadius] — нормалізований радіус (0.0–1.0).
  /// [baseOpacity] — базова непрозорість у центрі.
  /// [minOpacity] — мінімальна непрозорість на краю.
  static double computeRadialOpacity({
    required double normalizedRadius,
    required double baseOpacity,
    double minOpacity = 0.1,
  }) {
    return baseOpacity - (baseOpacity - minOpacity) * normalizedRadius;
  }

  /// Обчислює пульсацію розміру частинки.
  ///
  /// [baseSize] — базовий розмір.
  /// [time] — поточний час анімації (0.0–1.0).
  /// [pulseAmount] — амплітуда пульсації (доля від базового розміру).
  /// [pulseSpeed] — швидкість пульсації.
  static double computePulseSize({
    required double baseSize,
    required double time,
    double pulseAmount = 0.15,
    double pulseSpeed = 1.0,
  }) {
    final pulse = math.sin(time * math.pi * 2 * pulseSpeed);
    return baseSize * (1.0 + pulse * pulseAmount);
  }

  /// Застосовує гравітаційне тяжіння між частинкою та точкою дотику.
  ///
  /// Частинки, що знаходяться далеко — слабо притягуються.
  /// Частинки поруч — сильно притягуються.
  static Offset computeAttraction({
    required Offset particlePos,
    required Offset attractorPos,
    double strength = 5.0,
    double falloff = 0.01,
  }) {
    final dx = attractorPos.dx - particlePos.dx;
    final dy = attractorPos.dy - particlePos.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    if (dist <= 0) return Offset.zero;

    // Обернено-квадратичне затухання
    final force = strength / (1.0 + dist * falloff * dist);
    final normalizedDx = dx / dist;
    final normalizedDy = dy / dist;

    return Offset(
      normalizedDx * force,
      normalizedDy * force,
    );
  }

  /// Обчислює швидкість обертання для заданого пресету та настрою.
  ///
  /// [baseSpeed] — базова швидкість пресету.
  /// [moodIntensity] — інтенсивність настрою (0.0–1.0).
  /// [direction] — напрямок обертання (+1 або -1).
  /// [layerMultiplier] — множник шару (для layered-системи).
  static double computeRotationSpeed({
    required double baseSpeed,
    required double moodIntensity,
    double direction = 1.0,
    double layerMultiplier = 1.0,
  }) {
    final moodFactor = 0.5 + moodIntensity;
    return baseSpeed * direction * moodFactor * layerMultiplier;
  }
}

// ─── Particle Trail Builder ────────────────────────────────────────────────────

/// Будуєчий для слідів частинок з фіксованою довжиною черги.
///
/// Керує позиціями попередніх місць частинки та надає
/// зручний API для додавання нових точок та отримання списку сліду.
class ParticleTrailBuilder {
  ParticleTrailBuilder({
    this.maxLength = 6,
    this.decayFactor = 0.3,
  });

  /// Максимальна кількість точок у сліді.
  final int maxLength;

  /// Фактор зменшення непрозорості для найдавніших точок.
  final double decayFactor;

  final List<Offset> _positions = [];

  /// Список поточних позицій у сліді.
  List<Offset> get positions => List.unmodifiable(_positions);

  /// Чи слід пустий.
  bool get isEmpty => _positions.isEmpty;

  /// Кількість точок у сліді.
  int get length => _positions.length;

  /// Додає нову позицію до сліду.
  ///
  /// Якщо кількість позицій перевищує [maxLength],
  /// найстаріша позиція видаляється.
  void addPosition(Offset position) {
    _positions.insert(0, position);
    if (_positions.length > maxLength) {
      _positions.removeRange(maxLength, _positions.length);
    }
  }

  /// Обчислює непрозорість для і-тої точки сліду.
  ///
  /// [index] — індекс точки (0 = найновіша).
  /// [baseOpacity] — базова непрозорість.
  double opacityForIndex(int index, double baseOpacity) {
    if (index >= _positions.length) return 0.0;
    return baseOpacity * (1.0 - decayFactor * index);
  }

  /// Обчислює розмір для і-тої точки сліду.
  ///
  /// [index] — індекс точки (0 = найновіша).
  /// [baseSize] — базовий розмір.
  double sizeForIndex(int index, double baseSize) {
    if (index >= _positions.length) return 0.0;
    return baseSize * (1.0 - decayFactor * 0.5 * index);
  }

  /// Очищає всі позиції сліду.
  void clear() {
    _positions.clear();
  }

  /// Копіює слід з іншого будівельника.
  void copyFrom(ParticleTrailBuilder other) {
    _positions.clear();
    _positions.addAll(other._positions);
  }
}

// ─── Particle Shape Complexity Scorer ──────────────────────────────────────────

/// Оцінює складність форми частинки для оптимізації рендерингу.
///
/// Допомагає визначити, чи потрібно спрощувати форми
/// на слабких пристроях.
class ParticleShapeComplexity {
  ParticleShapeComplexity._();

  /// Повертає бал складності форми (0 = найпростіша, 10 = найскладніша).
  static int score(ParticleShape shape) {
    switch (shape) {
      case ParticleShape.circle:
        return 1;
      case ParticleShape.diamond:
        return 3;
      case ParticleShape.triangle:
        return 3;
      case ParticleShape.hexagon:
        return 4;
      case ParticleShape.pentagon:
        return 4;
      case ParticleShape.star:
        return 6;
      case ParticleShape.cross:
        return 7;
      case ParticleShape.arrow:
        return 7;
      case ParticleShape.heart:
        return 8;
      case ParticleShape.crescent:
        return 8;
      case ParticleShape.lightning:
        return 9;
    }
  }

  /// Повертає середню складність для списку форм.
  ///
  /// Якщо список пустий, повертає 0.
  static double averageScore(List<ParticleShape> shapes) {
    if (shapes.isEmpty) return 0;
    final total = shapes.map(score).reduce((a, b) => a + b);
    return total / shapes.length;
  }

  /// Повертає максимальну складність для списку форм.
  static int maxScore(List<ParticleShape> shapes) {
    if (shapes.isEmpty) return 0;
    return shapes.map(score).reduce(math.max);
  }

  /// Рекомендація щодо кількості частинок залежно від складності форм.
  ///
  /// Для складних форм рекомендується менше частинок.
  static int recommendedCount({
    required ParticleShape shape,
    int baseCount = 50,
    double performanceFactor = 1.0,
  }) {
    final complexity = score(shape).toDouble();
    final reduction = complexity / 10.0; // 0.0 — 1.0
    return (baseCount * (1.0 - reduction * 0.5) * performanceFactor)
        .round()
        .clamp(ParticleRenderConstants.minLayeredParticles,
            ParticleRenderConstants.maxParticleCount);
  }

  /// Чи слід використовувати прості форми на основі складності.
  ///
  /// Якщо середня складність перевищує поріг — рекомендується circle.
  static bool shouldSimplifyShapes(
    List<ParticleShape> shapes, {
    double threshold = 6.0,
  }) {
    return averageScore(shapes) > threshold;
  }
}

// ─── Particle Debug Helpers ─────────────────────────────────────────────────────

/// Допоміжні методи для дебаггінгу системи частинок.
///
/// Надає методи для логування, профілювання та діагностики.
class ParticleDebugHelpers {
  ParticleDebugHelpers._();

  /// Форматує статистику системи частинок для логування.
  ///
  /// Повертає рядок з кількістю частинок, шарів, формами тощо.
  static String formatStats({
    required int particleCount,
    required ParticleBehaviorPreset preset,
    required bool enableTrails,
    required bool enableLayeredSystem,
    required bool enableTouchInteraction,
    required double progress,
    bool isCelebration = false,
    ParticleShape? shape,
  }) {
    final parts = <String>[
      'ParticleSystem(',
      'count: $particleCount,',
      'preset: ${preset.label},',
      'progress: ${(progress * 100).toInt()}%,',
      if (enableTrails) 'trails: on,',
      if (enableLayeredSystem) 'layers: on,',
      if (enableTouchInteraction) 'touch: on,',
      if (isCelebration) 'celebration: on,',
      if (shape != null) 'shape: ${shape.label},',
      ')';
    return parts.join(' ');
  }

  /// Форматує детальну інформацію про частинку для дебаггінгу.
  static String formatParticleInfo({
    required int index,
    required double angle,
    required double radius,
    required double speed,
    required double size,
    required double opacity,
    required ParticleShape shape,
    required int layerIndex,
    required bool hasTrail,
  }) {
    return 'Particle[$index]: '
        'angle=${angle.toStringAsFixed(2)}, '
        'radius=${radius.toStringAsFixed(3)}, '
        'speed=${speed.toStringAsFixed(4)}, '
        'size=${size.toStringAsFixed(1)}, '
        'opacity=${opacity.toStringAsFixed(2)}, '
        'shape=${shape.name}, '
        'layer=$layerIndex, '
        'trail=$hasTrail';
  }

  /// Обчислює оцінку продуктивності системи частинок.
  ///
  /// Повертає рядок з оцінкою: low / medium / high / critical.
  static String performanceRating(int particleCount) {
    if (particleCount <= 20) return 'low';
    if (particleCount <= 60) return 'medium';
    if (particleCount <= 150) return 'high';
    return 'critical';
  }

  /// Оцінює вплив режиму святкування на продуктивність.
  ///
  /// Повертає попередження, якщо комбінація параметрів може
  /// викликати проблеми з продуктивністю.
  static String? checkPerformanceImpact({
    required int particleCount,
    required bool enableTrails,
    required bool enableLayeredSystem,
    required bool enableTouchInteraction,
  }) {
    final warnings = <String>[];

    if (particleCount > 200) {
      warnings.add('Більше 200 частинок — можливе падіння FPS');
    }
    if (enableTrails && particleCount > 100) {
      warnings.add('Сліди з понад 100 частинками — висока витрата пам\'яті');
    }
    if (enableLayeredSystem && particleCount > 150) {
      warnings.add('Багаторівнева система з >150 частинками');
    }
    if (enableTouchInteraction && particleCount > 80) {
      warnings.add('Взаємодія з дотиком вимагає обчислень для >80 частинок');
    }

    if (warnings.isEmpty) return null;
    return warnings.join('; ');
  }
}

// ─── Particle Motion Interpolator ──────────────────────────────────────────────

/// Інтерполятор руху частинок для плавних переходів між станами.
///
/// Дозволяє плавно змінювати параметри частинок при зміні пресету,
/// прогресу або інших характеристик.
class ParticleMotionInterpolator {
  ParticleMotionInterpolator._();

  /// Інтерполює кут обертання між двома значеннями.
  ///
  /// Використовує лінійну інтерполяцію з урахуванням напрямку обертання.
  static double lerpAngle(
    double from,
    double to,
    double t,
  ) {
    // Нормалізуємо кути до діапазону 0..2π
    final normalizedFrom = from % (2 * math.pi);
    final normalizedTo = to % (2 * math.pi);
    return normalizedFrom + (normalizedTo - normalizedFrom) * t;
  }

  /// Інтерполює розмір частинки з пружинним ефектом.
  ///
  /// [from] — початковий розмір.
  /// [to] — цільовий розмір.
  /// [t] — прогрес інтерполяції (0.0–1.0).
  /// [overshoot] — амплітуда перегину (для пружинного ефекту).
  static double lerpSizeWithSpring(
    double from,
    double to,
    double t, {
    double overshoot = 0.1,
  }) {
    // Простий пружинний ефект за допомогою sin
    final springT = t + math.sin(t * math.pi) * overshoot * (1 - t);
    return from + (to - from) * springT.clamp(0.0, 1.2);
  }

  /// Інтерполює непрозорість з fade-in / fade-out.
  ///
  /// Частинки плавно з'являються і зникають при зміні конфігурації.
  static double lerpOpacity(double from, double to, double t) {
    if (to > from) {
      // Fade-in: уповільнення на початку
      return from + (to - from) * _easeOutQuad(t);
    } else {
      // Fade-out: уповільнення наприкінці
      return from + (to - from) * _easeInQuad(t);
    }
  }

  /// Інтерполює швидкість з затуханням.
  ///
  /// Застосовується при зміні швидкості між пресетами.
  static double lerpSpeed(double from, double to, double t) {
    return from + (to - from) * _easeInOutCubic(t);
  }

  /// Ease-out quadratic.
  static double _easeOutQuad(double t) {
    return 1 - (1 - t) * (1 - t);
  }

  /// Ease-in quadratic.
  static double _easeInQuad(double t) {
    return t * t;
  }

  /// Ease-in-out cubic.
  static double _easeInOutCubic(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    }
    return 1 - math.pow(-2 * t + 2, 3) / 2;
  }
}

// ─── Particle Performance Budget ─────────────────────────────────────────────

/// Менеджер бюджету продуктивності для системи частинок.
///
/// Допомагає визначати оптимальні параметри залежно від
/// можливостей пристрою та обмежень продуктивності.
class ParticlePerformanceBudget {
  ParticlePerformanceBudget({
    this.maxParticles = ParticleRenderConstants.maxParticleCount,
    this.maxTrailParticles = 50,
    this.maxLayers = ParticleRenderConstants.layerCount,
    this.targetFps = ParticleRenderConstants.animationFpsTarget,
    this.enableGlow = true,
    this.enableTrails = true,
    this.enableTouchInteraction = true,
    this.enableShapeVariation = true,
  });

  /// Максимальна кількість частинок.
  final int maxParticles;

  /// Максимальна кількість частинок зі слідами.
  final int maxTrailParticles;

  /// Максимальна кількість шарів.
  final int maxLayers;

  /// Цільова частота кадрів.
  final int targetFps;

  /// Увімкнути glow-ефект.
  final bool enableGlow;

  /// Увімкнути сліди частинок.
  final bool enableTrails;

  /// Увімкнути взаємодію з дотиком.
  final bool enableTouchInteraction;

  /// Увімкнути варіацію форм.
  final bool enableShapeVariation;

  /// Створює бюджет для високопродуктивних пристроїв.
  factory ParticlePerformanceBudget.high() {
    return ParticlePerformanceBudget(
      maxParticles: ParticleRenderConstants.maxParticleCount,
      maxTrailParticles: 100,
      maxLayers: ParticleRenderConstants.layerCount,
      targetFps: 60,
      enableGlow: true,
      enableTrails: true,
      enableTouchInteraction: true,
      enableShapeVariation: true,
    );
  }

  /// Створює бюджет для середніх пристроїв.
  factory ParticlePerformanceBudget.medium() {
    return ParticlePerformanceBudget(
      maxParticles: 80,
      maxTrailParticles: 30,
      maxLayers: 2,
      targetFps: 60,
      enableGlow: true,
      enableTrails: true,
      enableTouchInteraction: true,
      enableShapeVariation: true,
    );
  }

  /// Створює бюджет для низькопродуктивних пристроїв.
  factory ParticlePerformanceBudget.low() {
    return ParticlePerformanceBudget(
      maxParticles: ParticleRenderConstants.lowPerformanceMaxParticles,
      maxTrailParticles: 10,
      maxLayers: 1,
      targetFps: 30,
      enableGlow: false,
      enableTrails: false,
      enableTouchInteraction: true,
      enableShapeVariation: false,
    );
  }

  /// Створює адаптивний бюджет залежно від кількості частинок.
  factory ParticlePerformanceBudget.adaptive(int particleCount) {
    if (particleCount <= 30) return ParticlePerformanceBudget.high();
    if (particleCount <= 100) return ParticlePerformanceBudget.medium();
    return ParticlePerformanceBudget.low();
  }

  /// Застосовує бюджет до конфігурації, обмежуючи параметри.
  ParticleConfig applyTo(ParticleConfig config) {
    return config.copyWith(
      particleCount: config.particleCount.clamp(
        ParticleRenderConstants.minLayeredParticles,
        maxParticles,
      ),
      layers: config.layers.clamp(1, maxLayers),
      enableTrails: config.enableTrails && enableTrails,
      glowIntensity: enableGlow ? config.glowIntensity : 0.0,
    );
  }

  /// Перевіряє, чи конфігурація відповідає бюджету.
  bool isWithinBudget(ParticleConfig config) {
    return config.particleCount <= maxParticles &&
        config.layers <= maxLayers &&
        (config.enableTrails
            ? config.particleCount <= maxTrailParticles
            : true) &&
        (enableGlow || config.glowIntensity == 0.0);
  }

  /// Оцінює використання бюджету у відсотках (0.0–1.0).
  double budgetUsage(ParticleConfig config) {
    final particleUsage = config.particleCount / maxParticles;
    final layerUsage =
        config.layers / ParticleRenderConstants.layerCount;
    final trailUsage = config.enableTrails ? 1.0 : 0.0;
    final glowUsage = config.glowIntensity > 0 ? 1.0 : 0.0;

    return (particleUsage * 0.4 +
            layerUsage * 0.2 +
            trailUsage * 0.2 +
            glowUsage * 0.2)
        .clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'ParticlePerformanceBudget('
        'maxParticles: $maxParticles, '
        'maxLayers: $maxLayers, '
        'targetFps: $targetFps, '
        'glow: $enableGlow, '
        'trails: $enableTrails, '
        'touch: $enableTouchInteraction)';
  }
}

// ─── Particle Glow Ring Painter ──────────────────────────────────────────────

/// CustomPainter для декоративного кільця світіння навколо силуету.
///
/// Малює пульсуюче кільце glow, що підсвічує силует пристрою,
/// додаючи глибину та атмосферу до частинкового фону.
class _ParticleGlowRingPainter extends CustomPainter {
  _ParticleGlowRingPainter({
    required this.progress,
    required this.ringColor,
    required this.isLightTheme,
    this.pulseSpeed = 1.0,
    this.baseRadius = 0.35,
    this.ringWidth = 2.0,
    this.glowRadius = 15.0,
  });

  /// Поточний прогрес (0.0–1.0).
  final double progress;

  /// Колір кільця.
  final Color ringColor;

  /// Світла тема.
  final bool isLightTheme;

  /// Швидкість пульсації.
  final double pulseSpeed;

  /// Базовий радіус кільця (відносно центру).
  final double baseRadius;

  /// Ширина лінії кільця.
  final double ringWidth;

  /// Радіус розмиття glow-ефекту.
  final double glowRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final time = progress * math.pi * 2 * pulseSpeed;

    // Пульсуючий радіус
    final pulseAmount = math.sin(time) * 0.02;
    final radiusX = size.width * (baseRadius + pulseAmount);
    final radiusY = size.height * (baseRadius + pulseAmount) * 0.7;

    // Прогрес-залежна непрозорість
    final baseAlpha = isLightTheme ? 0.08 : 0.12;
    final progressAlpha = progress * 0.15;
    final totalAlpha = baseAlpha + progressAlpha;

    // Малюємо glow-ефект (зовнішнє розмиття)
    final glowPaint = Paint()
      ..color = ringColor.withOpacity(totalAlpha * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowRadius
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      glowPaint,
    );

    // Малюємо основне кільце
    final ringPaint = Paint()
      ..color = ringColor.withOpacity(totalAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      ringPaint,
    );

    // Малюємо внутрішнє кільце з меншою непрозорістю
    final innerRadiusX = radiusX * 0.85;
    final innerRadiusY = radiusY * 0.85;
    final innerRingPaint = Paint()
      ..color = ringColor.withOpacity(totalAlpha * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth * 0.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: innerRadiusX * 2,
        height: innerRadiusY * 2,
      ),
      innerRingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticleGlowRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.isLightTheme != isLightTheme;
  }
}

// ─── Top-Level Helper Functions ───────────────────────────────────────────────

/// Створює конфігурацію за замовчуванням з урахуванням параметрів.
///
/// Обирає оптимальний пресет та адаптує параметри
/// залежно від прогресу та теми.
ParticleConfig createDefaultParticleConfig({
  required double progress,
  required bool isLightTheme,
  required bool isCelebration,
  double screenWidth = 400,
}) {
  if (isCelebration) {
    return ParticleConfig.celebration();
  }

  final base = ParticleConfig.responsive(screenWidth);
  final effectiveCount = ParticleRenderConstants.computeParticleCount(
    baseCount: base.particleCount,
    progress: progress,
  );

  return base.copyWith(
    particleCount: effectiveCount,
    glowIntensity:
        isLightTheme ? base.glowIntensity * 0.7 : base.glowIntensity,
  );
}

/// Визначає оптимальну кольорову схему залежно від параметрів.
///
/// Повертає кольорову схему на основі пресету, теми
/// та стану святкування.
ParticleColorScheme resolveColorScheme({
  required ParticleBehaviorPreset preset,
  required bool isLightTheme,
  ParticleColorScheme? override,
}) {
  if (override != null) return override;

  if (isLightTheme) {
    return ParticleColorScheme.monitor;
  }

  switch (preset) {
    case ParticleBehaviorPreset.cosmic:
      return ParticleColorScheme.midnight;
    case ParticleBehaviorPreset.snow:
      return ParticleColorScheme.frost;
    case ParticleBehaviorPreset.festive:
      return ParticleColorScheme.neon;
    case ParticleBehaviorPreset.glowing:
      return ParticleColorScheme.aurora;
    case ParticleBehaviorPreset.calm:
    case ParticleBehaviorPreset.energetic:
    case ParticleBehaviorPreset.minimal:
    case ParticleBehaviorPreset.floating:
      return ParticleColorScheme.ps5;
  }
}

/// Обчислює оптимальну тривалість анімаційного циклу.
///
/// Повертає [Duration] залежно від пресету та настрою.
/// Швидші пресети — коротший цикл.
Duration computeOptimalAnimationDuration({
  required ParticleBehaviorPreset preset,
  double moodIntensity = 0.5,
}) {
  final baseSeconds = ParticleRenderConstants.animationCycleSeconds;
  final speedFactor = preset.speedMultiplier;
  final moodFactor = 0.5 + moodIntensity;
  final adjustedSeconds =
      (baseSeconds / (speedFactor * moodFactor)).clamp(5, 30);
  return Duration(seconds: adjustedSeconds.round());
}

/// Створює список форм, придатних для заданого рівня продуктивності.
///
/// Для низької продуктивності повертає лише прості форми.
/// Для високої — всі форми включно зі складними.
List<ParticleShape> shapesForPerformanceLevel({
  required double performanceLevel,
}) {
  if (performanceLevel < 0.3) {
    return [ParticleShape.circle, ParticleShape.diamond];
  } else if (performanceLevel < 0.6) {
    return [
      ParticleShape.circle,
      ParticleShape.diamond,
      ParticleShape.triangle,
      ParticleShape.hexagon,
      ParticleShape.pentagon,
    ];
  }
  return ParticleShape.values.toList();
}

/// Обчислює адаптивну кількість шарів залежно від кількості частинок.
///
/// Більше частинок — менше шарів (для продуктивності).
int computeAdaptiveLayerCount({
  required int particleCount,
  int maxLayers = ParticleRenderConstants.layerCount,
}) {
  if (particleCount <= 20) return maxLayers;
  if (particleCount <= 60) return (maxLayers * 0.66).ceil();
  return 1;
}
