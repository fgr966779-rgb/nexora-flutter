import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../constants/app_colors.dart';
import '../constants/app_durations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [AppConfetti].
class ConfettiDebugConfig {
  ConfettiDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати рамку навколо області конфетті.
  static bool showBounds = false;

  /// Показувати траєкторії частинок.
  static bool showTrajectories = false;

  /// Записує debug-повідомлення.
  ///
  /// [message] — текст повідомлення.
  /// [tag] — додатковий тег.
  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[Confetti:$tag] ' : '[Confetti] ';
    debugPrint('$prefix$message');
  }

  /// Записує інформацію про частинки.
  static void logParticleInfo(List<_ConfettiParticle> particles) {
    if (!enableLogging) return;
    log('Particle count: ${particles.length}', tag: 'info');
    for (var i = 0; i < particles.length && i < 5; i++) {
      final p = particles[i];
      log('  #$i: shape=${p.shape}, size=${p.size.toStringAsFixed(1)}, '
          'vx=${p.vx.toStringAsFixed(1)}, vy=${p.vy.toStringAsFixed(1)}',
          tag: 'particle');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Форми конфетті (Confetti Shapes)
// ═══════════════════════════════════════════════════════════════════════════

/// Форми частинок конфетті.
///
/// Кожна форма має власний метод малювання на Canvas.
enum ConfettiShape {
  /// Прямокутник (стрічка) — класичне конфетті.
  rectangle,

  /// Коло — кругле конфетті.
  circle,

  /// Зірка — п'ятикутна зірка.
  star,

  /// Стрічка — довгий тонкий прямокутник.
  ribbon,

  /// Серце — для романтичних святкувань.
  heart,

  /// Ромб — діамантна форма.
  diamond,

  /// Трикутник — гострокутний.
  triangle;

  /// Малює форму на canvas.
  ///
  /// [canvas] — холст для малювання.
  /// [center] — центр фігури.
  /// [size] — розмір фігури.
  /// [paint] — об'єкт Paint з кольором та стилем.
  void draw(Canvas canvas, Offset center, double size, Paint paint) {
    switch (this) {
      case ConfettiShape.rectangle:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: size, height: size * 0.6),
          paint,
        );
        break;
      case ConfettiShape.circle:
        canvas.drawCircle(center, size / 2, paint);
        break;
      case ConfettiShape.star:
        _drawStar(canvas, center, size, paint);
        break;
      case ConfettiShape.ribbon:
        canvas.drawRect(
          Rect.fromCenter(
              center: center, width: size * 1.5, height: size * 0.25),
          paint,
        );
        break;
      case ConfettiShape.heart:
        _drawHeart(canvas, center, size, paint);
        break;
      case ConfettiShape.diamond:
        _drawDiamond(canvas, center, size, paint);
        break;
      case ConfettiShape.triangle:
        _drawTriangle(canvas, center, size, paint);
        break;
    }
  }

  /// Малює п'ятикутну зірку.
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size / 2 : size / 5;
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

  /// Малює серце.
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final s = size / 2;
    final x = center.dx;
    final y = center.dy;
    path.moveTo(x, y + s * 0.3);
    path.cubicTo(x, y - s * 0.4, x - s, y - s * 0.4, x - s, y + s * 0.1);
    path.cubicTo(x - s, y + s * 0.6, x, y + s, x, y + s);
    path.cubicTo(x, y + s, x + s, y + s * 0.6, x + s, y + s * 0.1);
    path.cubicTo(x + s, y - s * 0.4, x, y - s * 0.4, x, y + s * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Малює ромб (діамант).
  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final s = size / 2;
    path.moveTo(center.dx, center.dy - s);
    path.lineTo(center.dx + s * 0.6, center.dy);
    path.lineTo(center.dx, center.dy + s);
    path.lineTo(center.dx - s * 0.6, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Малює трикутник.
  void _drawTriangle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final s = size / 2;
    path.moveTo(center.dx, center.dy - s);
    path.lineTo(center.dx + s * 0.87, center.dy + s * 0.5);
    path.lineTo(center.dx - s * 0.87, center.dy + s * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Українська назва форми.
  String get label {
    switch (this) {
      case ConfettiShape.rectangle:
        return 'Прямокутник';
      case ConfettiShape.circle:
        return 'Коло';
      case ConfettiShape.star:
        return 'Зірка';
      case ConfettiShape.ribbon:
        return 'Стрічка';
      case ConfettiShape.heart:
        return 'Серце';
      case ConfettiShape.diamond:
        return 'Ромб';
      case ConfettiShape.triangle:
        return 'Трикутник';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Напрямок вибуху (Direction)
// ═══════════════════════════════════════════════════════════════════════════

/// Напрямок вибуху конфетті.
///
/// Визначає початкову швидкість частинок.
enum ConfettiDirection {
  /// Вибух від центру в усі боки — стандартний ефект.
  centerBurst,

  /// Летить вгору — фонтан знизу вгору.
  up,

  /// Летить вниз — дощ конфетті зверху вниз.
  down,

  /// Летить зліва направо — горизонтальний потік.
  leftToRight,

  /// Летить справа наліво — зворотний горизонтальний потік.
  rightToLeft;

  /// Опис напрямку для налаштувань.
  String get label {
    switch (this) {
      case ConfettiDirection.centerBurst:
        return 'Вибух від центру';
      case ConfettiDirection.up:
        return 'Фонтан вгору';
      case ConfettiDirection.down:
        return 'Дощ зверху';
      case ConfettiDirection.leftToRight:
        return 'Зліва направо';
      case ConfettiDirection.rightToLeft:
        return 'Справа наліво';
    }
  }

  /// Чи напрямок вертикальний.
  bool get isVertical =>
      this == ConfettiDirection.up || this == ConfettiDirection.down;
}

// ═══════════════════════════════════════════════════════════════════════════
// Частинка конфетті (Confetti Particle)
// ═══════════════════════════════════════════════════════════════════════════

/// Дані однієї частинки конфетті.
///
/// Містить фізичні параметри: позицію, швидкість, обертання, гравітацію.
class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
    this.gravity = 9.8,
    this.wind = 0.0,
    this.opacity = 1.0,
    this.drag = 0.98,
  });

  /// Поточна позиція X.
  final double x;

  /// Поточна позиція Y.
  final double y;

  /// Горизонтальна швидкість.
  final double vx;

  /// Вертикальна швидкість.
  final double vy;

  /// Колір частинки.
  final Color color;

  /// Розмір частинки.
  final double size;

  /// Поточний кут обертання.
  final double rotation;

  /// Швидкість обертання.
  final double rotationSpeed;

  /// Форма частинки.
  final ConfettiShape shape;

  /// Сила гравітації (за замовчуванням 9.8).
  final double gravity;

  /// Сила вітру (горизонтальне зміщення).
  final double wind;

  /// Непрозорість частинки (0.0–1.0).
  final double opacity;

  /// Коефіцієнт опору повітря (0.0–1.0).
  final double drag;

  /// Обчислює швидкість частинки.
  double get speed => math.sqrt(vx * vx + vy * vy);

  /// Обчислює кут руху частинки.
  double get angle => math.atan2(vy, vx);
}

// ═══════════════════════════════════════════════════════════════════════════
// Віджет конфетті (Confetti Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Оверлей конфетті з фізичною симуляцією.
///
/// Підтримує:
/// - 7 форм: rectangle, circle, star, ribbon, heart, diamond, triangle
/// - Кастомні кольори або стандартна палітра
/// - 5 напрямків: centerBurst, up, down, leftToRight, rightToLeft
/// - Гравітація та вітер для реалістичного падіння
/// - Контроль fade out (момент початку згасання)
/// - Варіація розмірів частинок
/// - Контроль тривалості
/// - Святковий пресет з автоматичними налаштуваннями
///
/// Приклад використання:
/// ```dart
/// // Пряме використання у Stack
/// AppConfetti(particleCount: 50);
///
/// // Через статичний метод (Overlay)
/// AppConfetti.show(context: context);
///
/// // Святковий пресет
/// AppConfetti.celebration(context: context);
/// ```
class AppConfetti extends StatefulWidget {
  const AppConfetti({
    super.key,
    this.particleCount = 40,
    this.duration,
    this.colors,
    this.direction = ConfettiDirection.centerBurst,
    this.gravity = 9.8,
    this.wind = 0.0,
    this.fadeOutStart = 0.7,
    this.sizeMin = 4.0,
    this.sizeMax = 12.0,
    this.origin,
    this.onComplete,
    this.enableSoundStub = false,
    this.minOpacity = 0.0,
    this.shapes,
    this.drag = 0.98,
    this.maxWindVariation = 0.5,
    this.enableGlow = true,
  });

  /// Кількість частинок конфетті.
  final int particleCount;

  /// Тривалість анімації (null = стандартна з [AppDurations.confetti]).
  final Duration? duration;

  /// Кастомні кольори конфетті (null = стандартна палітра).
  final List<Color>? colors;

  /// Напрямок вибуху конфетті.
  final ConfettiDirection direction;

  /// Сила гравітації (за замовчуванням 9.8 — як на Землі).
  final double gravity;

  /// Сила вітру (горизонтальне зміщення).
  final double wind;

  /// Момент початку fade out (0.0 = одразу, 1.0 = ніколи).
  final double fadeOutStart;

  /// Мінімальний розмір частинки в пікселях.
  final double sizeMin;

  /// Максимальний розмір частинки в пікселях.
  final double sizeMax;

  /// Точка походження вибуху (null = центр екрана).
  final Offset? origin;

  /// Callback при завершенні анімації.
  final VoidCallback? onComplete;

  /// Stub для звукового ефекту святкування.
  final bool enableSoundStub;

  /// Мінімальна непрозорість при fade out (за замовчуванням 0.0).
  final double minOpacity;

  /// Кастомний набір форм частинок (null = всі форми).
  final List<ConfettiShape>? shapes;

  /// Коефіцієнт опору повітря.
  final double drag;

  /// Максимальна варіація вітру між частинками.
  final double maxWindVariation;

  /// Увімкнути ефект свічення для великих частинок.
  final bool enableGlow;

  /// Стандартні кольори конфетті — яскрава святкова палітра.
  static const _defaultColors = [
    Color(0xFFFF6B6B), // Червоний
    Color(0xFF4ECDC4), // Бірюзовий
    Color(0xFFFFD93D), // Жовтий
    Color(0xFF6C5CE7), // Фіолетовий
    Color(0xFFA8E6CF), // М'ятний
    Color(0xFFFF8A5C), // Оранжевий
    Color(0xFF006FCD), // Синій
    Color(0xFFFF4081), // Рожевий
    Color(0xFFFFD600), // Золотий
    Color(0xFF00E5FF), // Блакитний
  ];

  /// Колірне палітро для весняних святкувань.
  static const _springColors = [
    Color(0xFFFF9FF3), // Рожевий
    Color(0xFFFECFEF), // Блідо-рожевий
    Color(0xFFFFD700), // Золотий
    Color(0xFF98FB98), // Блідо-зелений
    Color(0xFF87CEEB), // Небесний
    Color(0xFFFFA07A), // Лососевий
  ];

  /// Новорічна палітра.
  static const _newYearColors = [
    Color(0xFFFFD700), // Золотий
    Color(0xFFFF4444), // Червоний
    Color(0xFFFFFFFF), // Білий
    Color(0xFF0066FF), // Синій
    Color(0xFF00CC00), // Зелений
    Color(0xFFFF6600), // Оранжевий
  ];

  /// Пастельна палітра.
  static const _pastelColors = [
    Color(0xFFFFB3BA), // Пастельний рожевий
    Color(0xFFBAFFC9), // Пастельний зелений
    Color(0xFFBAE1FF), // Пастельний блакитний
    Color(0xFFFFEBA6), // Пастельний жовтий
    Color(0xFFE8BAFF), // Пастельний фіолетовий
  ];

  // ═══════════════════════════════════════════════════════════════════════
  // Validation (Перевірка)
  // ═════════════════════════════════════════════════════════════════════

  /// Перевіряє коректність параметрів конфетті.
  static void validateParams({
    required int particleCount,
    required double gravity,
    required double sizeMin,
    required double sizeMax,
    required double fadeOutStart,
  }) {
    assert(
      particleCount >= 0 && particleCount <= 500,
      'particleCount must be between 0 and 500',
    );
    assert(
      gravity >= 0 && gravity <= 50,
      'gravity must be between 0 and 50',
    );
    assert(
      sizeMin > 0 && sizeMax >= sizeMin,
      'sizeMin must be positive and sizeMax must be >= sizeMin',
    );
    assert(
      fadeOutStart >= 0.0 && fadeOutStart <= 1.0,
      'fadeOutStart must be between 0.0 and 1.0',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Статичний API (Static API)
  // ═════════════════════════════════════════════════════════════════════

  /// Показує оверлей конфетті через Overlay.
  ///
  /// Повертає [OverlayEntry], який можна вручну видалити.
  ///
  /// Приклад:
  /// ```dart
  /// final entry = AppConfetti.show(context: context);
  /// Future.delayed(Duration(seconds: 3), () => entry.remove());
  /// ```
  static OverlayEntry show({
    required BuildContext context,
    int particleCount = 40,
    Duration? duration,
    List<Color>? colors,
    ConfettiDirection direction = ConfettiDirection.centerBurst,
    double gravity = 9.8,
    double wind = 0.0,
    Offset? origin,
    VoidCallback? onComplete,
  }) {
    ConfettiDebugConfig.log('show() called', tag: 'api');
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => AppConfetti(
        particleCount: particleCount,
        duration: duration,
        colors: colors,
        direction: direction,
        gravity: gravity,
        wind: wind,
        origin: origin,
        onComplete: onComplete,
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  /// Святковий пресет з великою кількістю конфетті та усіма формами.
  ///
  /// Ідеально для завершення цілей, level-up, досягнень.
  static OverlayEntry celebration({
    required BuildContext context,
    int particleCount = 100,
    Offset? origin,
    VoidCallback? onComplete,
  }) {
    ConfettiDebugConfig.log('celebration() called', tag: 'api');
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => AppConfetti(
        particleCount: particleCount,
        duration: const Duration(milliseconds: 3000),
        direction: ConfettiDirection.centerBurst,
        gravity: 6.0,
        wind: 1.5,
        fadeOutStart: 0.75,
        sizeMin: 5.0,
        sizeMax: 16.0,
        origin: origin,
        enableSoundStub: true,
        onComplete: onComplete,
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  /// Весняний пресет з м'якими кольорами.
  ///
  /// Для легких святкувань та milestone-ів.
  static OverlayEntry spring({
    required BuildContext context,
    int particleCount = 60,
    Offset? origin,
  }) {
    ConfettiDebugConfig.log('spring() called', tag: 'api');
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => AppConfetti(
        particleCount: particleCount,
        duration: const Duration(milliseconds: 2500),
        direction: ConfettiDirection.down,
        gravity: 4.0,
        wind: 2.0,
        fadeOutStart: 0.7,
        sizeMin: 4.0,
        sizeMax: 10.0,
        colors: _springColors,
        origin: origin,
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  /// Новорічний пресет з золотими та червоними кольорами.
  ///
  /// Для святкування Нового року.
  static OverlayEntry newYear({
    required BuildContext context,
    int particleCount = 120,
    Offset? origin,
  }) {
    ConfettiDebugConfig.log('newYear() called', tag: 'api');
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => AppConfetti(
        particleCount: particleCount,
        duration: const Duration(milliseconds: 4000),
        direction: ConfettiDirection.centerBurst,
        gravity: 5.0,
        wind: 1.0,
        fadeOutStart: 0.8,
        sizeMin: 5.0,
        sizeMax: 18.0,
        colors: _newYearColors,
        origin: origin,
        enableSoundStub: true,
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  /// Пастельний пресет з ніжними кольорами.
  ///
  /// Для стильних святкувань.
  static OverlayEntry pastel({
    required BuildContext context,
    int particleCount = 80,
    Offset? origin,
  }) {
    ConfettiDebugConfig.log('pastel() called', tag: 'api');
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => AppConfetti(
        particleCount: particleCount,
        duration: const Duration(milliseconds: 3000),
        direction: ConfettiDirection.up,
        gravity: 3.0,
        wind: 0.5,
        fadeOutStart: 0.65,
        sizeMin: 6.0,
        sizeMax: 14.0,
        colors: _pastelColors,
        origin: origin,
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  /// Показує конфетті з автоматичним видалення через [autoDismissDelay].
  ///
  /// Зручно для швидких святкувань без ручного управління OverlayEntry.
  static void showAndDismiss({
    required BuildContext context,
    Duration? duration,
    Duration autoDismissDelay = const Duration(seconds: 3),
    int particleCount = 40,
  }) {
    final entry = show(
      context: context,
      particleCount: particleCount,
      duration: duration,
    );
    Future.delayed(autoDismissDelay, () {
      try {
        entry.remove();
      } catch (_) {
        // Overlay вже видалено
      }
    });
  }

  @override
  State<AppConfetti> createState() => _AppConfettiState();
}

class _AppConfettiState extends State<AppConfetti>
    with SingleTickerProviderStateMixin {
  /// Контролер анімації частинок.
  late AnimationController _controller;

  /// Список частинок конфетті.
  late List<_ConfettiParticle> _particles;

  /// Генератор випадкових чисел.
  static final _random = math.Random();

  /// Чи анімація завершена.
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    ConfettiDebugConfig.log('initState', tag: 'lifecycle');

    // Перевірка параметрів
    AppConfetti.validateParams(
      particleCount: widget.particleCount,
      gravity: widget.gravity,
      sizeMin: widget.sizeMin,
      sizeMax: widget.sizeMax,
      fadeOutStart: widget.fadeOutStart,
    );

    // Ініціалізація контролера анімації
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AppDurations.confetti,
    )..addStatusListener(_onAnimationStatusChanged);

    // Генерація частинок
    _particles = _generateParticles();
    ConfettiDebugConfig.logParticleInfo(_particles);

    // Звуковий stub (заглушка)
    if (widget.enableSoundStub) {
      _triggerCelebrationSoundStub();
    }

    // Запуск анімації після першого кадру
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  /// Обробляє зміну статусу анімації.
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isCompleted) {
      _isCompleted = true;
      ConfettiDebugConfig.log('Animation completed', tag: 'lifecycle');
      widget.onComplete?.call();
    }
  }

  /// Stub для звукового ефекту святкування.
  ///
  /// Замініть на реальний аудіоплеєр при інтеграції.
  void _triggerCelebrationSoundStub() {
    ConfettiDebugConfig.log('Sound stub triggered', tag: 'audio');
    // TODO: Підключити аудіоплеєр для звуку святкування
    // Наприклад: AudioPlayer().play(AssetSource('sounds/celebration.mp3'));
  }

  /// Генерує частинки конфетті з випадковими параметрами.
  ///
  /// Кожна частинка отримує випадкову швидкість, напрямок, розмір, форму.
  List<_ConfettiParticle> _generateParticles() {
    final effectiveColors = widget.colors ?? AppConfetti._defaultColors;
    final effectiveShapes = widget.shapes ?? ConfettiShape.values;

    return List.generate(widget.particleCount, (_) {
      final speed = _generateSpeed();
      final shape = effectiveShapes[_random.nextInt(effectiveShapes.length)];

      // Обчислення початкової швидкості залежно від напрямку
      final velocities = _calculateInitialVelocity(speed);

      // Варіація розміру частинки
      final size = widget.sizeMin +
          _random.nextDouble() * (widget.sizeMax - widget.sizeMin);

      return _ConfettiParticle(
        x: 0.0,
        y: 0.0,
        vx: velocities.dx,
        vy: velocities.dy,
        color: effectiveColors[_random.nextInt(effectiveColors.length)],
        size: size,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
        shape: shape,
        gravity: widget.gravity,
        wind: widget.wind + (_random.nextDouble() - 0.5) * widget.maxWindVariation,
        drag: widget.drag,
      );
    });
  }

  /// Генерує випадкову швидкість для частинки.
  ///
  /// Швидкість варіюється від 2.0 до 8.0.
  double _generateSpeed() {
    return 2.0 + _random.nextDouble() * 6.0;
  }

  /// Обчислює початкову швидкість залежно від напрямку.
  ///
  /// [speed] — базова швидкість частинки.
  /// Повертає Offset з vx та vy компонентами.
  Offset _calculateInitialVelocity(double speed) {
    switch (widget.direction) {
      case ConfettiDirection.centerBurst:
        final angle = _random.nextDouble() * 2 * math.pi;
        return Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed - 4.0,
        );
      case ConfettiDirection.up:
        return Offset(
          (_random.nextDouble() - 0.5) * 4,
          -(3.0 + _random.nextDouble() * 6.0),
        );
      case ConfettiDirection.down:
        return Offset(
          (_random.nextDouble() - 0.5) * 3,
          1.0 + _random.nextDouble() * 3.0,
        );
      case ConfettiDirection.leftToRight:
        return Offset(
          2.0 + _random.nextDouble() * 4.0,
          (_random.nextDouble() - 0.5) * 4,
        );
      case ConfettiDirection.rightToLeft:
        return Offset(
          -(2.0 + _random.nextDouble() * 4.0),
          (_random.nextDouble() - 0.5) * 4,
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    ConfettiDebugConfig.log('dispose', tag: 'lifecycle');
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;

            // Обчислення непрозорості з fade out
            final fadeOut = _calculateFadeOut(t);

            return CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: t,
                opacity: fadeOut.clamp(widget.minOpacity, 1.0),
                screenSize: MediaQuery.of(context).size,
                origin: widget.origin,
                gravity: widget.gravity,
                wind: widget.wind,
                enableGlow: widget.enableGlow,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Обчислює непрозорість з урахуванням fade out.
  ///
  /// [t] — поточний прогрес анімації (0.0–1.0).
  double _calculateFadeOut(double t) {
    if (t <= widget.fadeOutStart) return 1.0;
    final fadeRange = 1.0 - widget.fadeOutStart;
    if (fadeRange <= 0) return 1.0;
    return 1.0 - ((t - widget.fadeOutStart) / fadeRange);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Малювальник конфетті (Confetti Painter)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник для CustomPaint — малює всі частинки конфетті.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.opacity,
    required this.screenSize,
    required this.origin,
    required this.gravity,
    required this.wind,
    this.enableGlow = true,
  });

  /// Список частинок для малювання.
  final List<_ConfettiParticle> particles;

  /// Поточний прогрес анімації (0.0–1.0).
  final double progress;

  /// Загальна непрозорість всіх частинок.
  final double opacity;

  /// Розмір екрана для позиціонування.
  final Size screenSize;

  /// Точка походження вибуху.
  final Offset? origin;

  /// Сила гравітації.
  final double gravity;

  /// Сила вітру.
  final double wind;

  /// Увімкнути ефект свічення.
  final bool enableGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        origin ?? Offset(screenSize.width / 2, screenSize.height / 2);

    for (final p in particles) {
      final dt = progress * 2.0;

      // ── Фізична симуляція ──
      // Позиція з урахуванням швидкості, гравітації та вітру
      final x = center.dx +
          p.vx * dt * 30 +
          wind * dt * dt * 15;
      final y = center.dy +
          p.vy * dt * 30 +
          0.5 * p.gravity * dt * dt * 30;

      // Обертання частинки
      final currentRotation = p.rotation + p.rotationSpeed * dt * 10;

      // Затухання розміру з часом
      final sizeScale = 1.0 - progress * 0.3;
      final effectiveSize = p.size * sizeScale;

      // Перевірка: частинка за межами екрана — пропускаємо
      if (x < -50 || x > screenSize.width + 50 ||
          y < -50 || y > screenSize.height + 50) {
        continue;
      }

      final paint = Paint()
        ..color = p.color.withOpacity(opacity * p.opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      // Малювання форми частинки
      p.shape.draw(canvas, Offset.zero, effectiveSize, paint);

      // Ефект тіні/свічення для великих частинок
      if (enableGlow && effectiveSize > 8) {
        final glowPaint = Paint()
          ..color = p.color.withOpacity(opacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        p.shape.draw(canvas, Offset.zero, effectiveSize * 1.3, glowPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions (Утиліти-розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з конфетті.
class AppConfettiHelpers {
  AppConfettiHelpers._();

  /// Обчислює оптимальну кількість частинок залежно від розміру екрана.
  ///
  /// Більший екран — більше частинок.
  static int recommendedParticleCount(Size screenSize) {
    final area = screenSize.width * screenSize.height;
    if (area > 2000000) return 120; // Великий планшет
    if (area > 1000000) return 80; // Планшет
    if (area > 500000) return 60; // Великий телефон
    return 40; // Стандартний телефон
  }

  /// Обчислює оптимальну гравітацію залежно від типу святкування.
  ///
  /// [isIndoor] — чи подія відбувається в приміщенні.
  static double recommendedGravity({bool isIndoor = true}) {
    return isIndoor ? 6.0 : 9.8;
  }

  /// Обирає напрямок залежно від типу події.
  ///
  /// [eventType] — тип події.
  static ConfettiDirection recommendedDirection(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'levelup':
      case 'celebration':
      case 'achievement':
        return ConfettiDirection.centerBurst;
      case 'rain':
      case 'shower':
        return ConfettiDirection.down;
      case 'fountain':
        return ConfettiDirection.up;
      default:
        return ConfettiDirection.centerBurst;
    }
  }

  /// Обчислює тривалість анімації залежно від кількості частинок.
  ///
  /// Більше частинок — довша анімація.
  static Duration recommendedDuration(int particleCount) {
    final baseMs = 2000;
    final extraMs = (particleCount / 10).round() * 100;
    return Duration(milliseconds: baseMs + extraMs);
  }

  /// Обчислює оптимальний розмір частинок залежно від типу події.
  ///
  /// [eventType] — тип події (рівномірний розподіл розмірів).
  static double recommendedMinSize(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'celebration':
      case 'achievement':
        return 5.0;
      case 'rain':
        return 3.0;
      case 'fountain':
        return 4.0;
      default:
        return 4.0;
    }
  }

  /// Обчислює максимальний розмір частинок.
  ///
  /// [eventType] — тип події.
  static double recommendedMaxSize(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'celebration':
      case 'achievement':
        return 16.0;
      case 'rain':
        return 10.0;
      case 'fountain':
        return 14.0;
      default:
        return 12.0;
    }
  }

  /// Обчислює оптимальний fadeOutStart залежно від тривалості.
  ///
  /// Довші анімації — пізніше початок згасання.
  static double recommendedFadeOutStart(Duration duration) {
    final seconds = duration.inMilliseconds / 1000;
    if (seconds <= 2) return 0.6;
    if (seconds <= 3) return 0.7;
    return 0.8;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Theme Data (Тема для конфетті)
// ═══════════════════════════════════════════════════════════════════════════

/// Незмінні дані теми для кастомізації конфетті.
///
/// Дозволяє визначити палітру кольорів, набір форм,
/// гравітацію та вітер для різних типів святкувань.
///
/// Приклад:
/// ```dart
/// final theme = ConfettiThemeData(
///   colors: [Colors.red, Colors.green],
///   shapes: [ConfettiShape.star, ConfettiShape.circle],
///   gravity: 6.0,
/// );
/// AppConfetti(themeData: theme);
/// ```
class ConfettiThemeData {
  /// Створює дані теми для конфетті.
  ///
  /// [colors] — палітра кольорів частинок.
  /// [shapes] — набір форм частинок.
  /// [gravity] — сила гравітації.
  /// [wind] — сила вітру.
  /// [drag] — коефіцієнт опору.
  /// [sizeMin] — мінімальний розмір частинки.
  /// [sizeMax] — максимальний розмір частинки.
  /// [enableGlow] — увімкнути свічення.
  /// [fadeOutStart] — момент початку fade out.
  const ConfettiThemeData({
    this.colors,
    this.shapes,
    this.gravity = 9.8,
    this.wind = 0.0,
    this.drag = 0.98,
    this.sizeMin = 4.0,
    this.sizeMax = 12.0,
    this.enableGlow = true,
    this.fadeOutStart = 0.7,
  });

  /// Палітра кольорів частинок.
  final List<Color>? colors;

  /// Набір форм частинок.
  final List<ConfettiShape>? shapes;

  /// Сила гравітації.
  final double gravity;

  /// Сила вітру.
  final double wind;

  /// Коефіцієнт опору.
  final double drag;

  /// Мінімальний розмір частинки.
  final double sizeMin;

  /// Максимальний розмір частинки.
  final double sizeMax;

  /// Увімкнути свічення.
  final bool enableGlow;

  /// Момент початку fade out.
  final double fadeOutStart;

  /// Стандартна святкова тема.
  static const ConfettiThemeData celebration = ConfettiThemeData(
    gravity: 6.0,
    wind: 1.5,
    fadeOutStart: 0.75,
    sizeMin: 5.0,
    sizeMax: 16.0,
  );

  /// Тема для легкого дощу конфетті.
  static const ConfettiThemeData rain = ConfettiThemeData(
    gravity: 4.0,
    wind: 2.0,
    fadeOutStart: 0.7,
    sizeMin: 4.0,
    sizeMax: 10.0,
  );

  /// Тема для фонтану конфетті.
  static const ConfettiThemeData fountain = ConfettiThemeData(
    gravity: 8.0,
    wind: 0.5,
    fadeOutStart: 0.65,
    sizeMin: 6.0,
    sizeMax: 14.0,
  );

  /// Об'єднує цю тему з [other], заповнюючи null-значення.
  ConfettiThemeData merge(ConfettiThemeData? other) {
    if (other == null) return this;
    return ConfettiThemeData(
      colors: other.colors ?? colors,
      shapes: other.shapes ?? shapes,
      gravity: other.gravity,
      wind: other.wind,
      drag: other.drag,
      sizeMin: other.sizeMin,
      sizeMax: other.sizeMax,
      enableGlow: other.enableGlow,
      fadeOutStart: other.fadeOutStart,
    );
  }

  /// Повертає копію з перезаписаними полями.
  ConfettiThemeData copyWith({
    List<Color>? colors,
    List<ConfettiShape>? shapes,
    double? gravity,
    double? wind,
    double? drag,
    double? sizeMin,
    double? sizeMax,
    bool? enableGlow,
    double? fadeOutStart,
  }) {
    return ConfettiThemeData(
      colors: colors ?? this.colors,
      shapes: shapes ?? this.shapes,
      gravity: gravity ?? this.gravity,
      wind: wind ?? this.wind,
      drag: drag ?? this.drag,
      sizeMin: sizeMin ?? this.sizeMin,
      sizeMax: sizeMax ?? this.sizeMax,
      enableGlow: enableGlow ?? this.enableGlow,
      fadeOutStart: fadeOutStart ?? this.fadeOutStart,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Particle Pool (Пул частинок)
// ═══════════════════════════════════════════════════════════════════════════

/// Управління пулом частинок конфетті.
///
/// Дозволяє повторно використовувати частинки
/// замість створення нових об'єктів при кожній анімації.
class ConfettiParticlePool {
  /// Створює пул з максимальною кількістю частинок.
  ///
  /// [maxSize] — максимальна кількість частинок у пулі.
  ConfettiParticlePool({this.maxSize = 200});

  /// Максимальна кількість частинок.
  final int maxSize;

  /// Поточний список доступних частинок.
  final List<_ConfettiParticle> _pool = [];

  /// Кількість доступних частинок у пулі.
  int get availableCount => _pool.length;

  /// Чи пул порожній.
  bool get isEmpty => _pool.isEmpty;

  /// Чи пул заповнений.
  bool get isFull => _pool.length >= maxSize;

  /// Повертає частинку з пулу або створює нову.
  ///
  /// [x] — початкова позиція X.
  /// [y] — початкова позиція Y.
  /// [vx] — горизонтальна швидкість.
  /// [vy] — вертикальна швидкість.
  /// [color] — колір частинки.
  /// [size] — розмір частинки.
  /// [rotation] — початковий кут обертання.
  /// [rotationSpeed] — швидкість обертання.
  /// [shape] — форма частинки.
  /// [gravity] — сила гравітації.
  /// [wind] — сила вітру.
  /// [drag] — коефіцієнт опору.
  _ConfettiParticle acquire({
    required double x,
    required double y,
    required double vx,
    required double vy,
    required Color color,
    required double size,
    required double rotation,
    required double rotationSpeed,
    required ConfettiShape shape,
    double gravity = 9.8,
    double wind = 0.0,
    double drag = 0.98,
  }) {
    // Повертаємо частинку з пулу, якщо є
    if (_pool.isNotEmpty) {
      return _pool.removeLast();
    }

    // Створюємо нову частинку
    return _ConfettiParticle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      color: color,
      size: size,
      rotation: rotation,
      rotationSpeed: rotationSpeed,
      shape: shape,
      gravity: gravity,
      wind: wind,
      drag: drag,
    );
  }

  /// Повертає частинку в пул.
  ///
  /// Якщо пул заповнений, частинка просто ігнорується.
  void release(_ConfettiParticle particle) {
    if (_pool.length < maxSize) {
      _pool.add(particle);
    }
  }

  /// Повертає кількість частинок у пулі.
  ///
  /// Корисно для debugging.
  void logStats() {
    ConfettiDebugConfig.log(
      'Pool: ${_pool.length}/$maxSize',
      tag: 'pool',
    );
  }

  /// Очищає пул від усіх частинок.
  void clear() {
    _pool.clear();
    ConfettiDebugConfig.log('Pool cleared', tag: 'pool');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Shape Distribution (Розподіл форм)
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для управління розподілом форм частинок конфетті.
///
/// Дозволяє задати ваги для кожної форми,
/// що контролює частоту появи кожної форми.
class ConfettiShapeDistribution {
  ConfettiShapeDistribution._();

  /// Стандартний розподіл: всі форми рівноймовірні.
  static List<ConfettiShape> uniform() {
    return ConfettiShape.values;
  }

  /// Весняний розподіл: переважно серця та круги.
  static List<ConfettiShape> springMix() {
    return [
      ConfettiShape.heart,
      ConfettiShape.heart,
      ConfettiShape.circle,
      ConfettiShape.circle,
      ConfettiShape.diamond,
      ConfettiShape.circle,
    ];
  }

  /// Різдвяний розподіл: зірки, стрічки та прямокутники.
  static List<ConfettiShape> festiveMix() {
    return [
      ConfettiShape.star,
      ConfettiShape.star,
      ConfettiShape.rectangle,
      ConfettiShape.ribbon,
      ConfettiShape.rectangle,
      ConfettiShape.star,
      ConfettiShape.triangle,
    ];
  }

  /// Мінімалістичний розподіл: лише круги та прямокутники.
  static List<ConfettiShape> minimal() {
    return [
      ConfettiShape.circle,
      ConfettiShape.rectangle,
      ConfettiShape.circle,
    ];
  }

  /// Повертає випадкову форму з заданого списку.
  ///
  /// [shapes] — список форм для вибору.
  /// [random] — генератор випадкових чисел.
  static ConfettiShape randomFrom(
    List<ConfettiShape> shapes, {
    math.Random? random,
  }) {
    final rng = random ?? math.Random();
    return shapes[rng.nextInt(shapes.length)];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Color Palettes (Палітри кольорів)
// ═══════════════════════════════════════════════════════════════════════════

/// Попередньо визначені палітри кольорів для конфетті.
///
/// Кожна палітра оптимізована для певного типу святкування.
class ConfettiPalettes {
  ConfettiPalettes._();

  /// Різдвяна палітра: червоний, зелений, золотий, білий.
  static const List<Color> christmas = [
    Color(0xFFCC0000),
    Color(0xFF006600),
    Color(0xFFFFD700),
    Color(0xFFFFFFFF),
    Color(0xFF8B0000),
    Color(0xFF228B22),
  ];

  /// Гелловінська палітра: помаранчевий, чорний, фіолетовий.
  static const List<Color> halloween = [
    Color(0xFFFF6600),
    Color(0xFF333333),
    Color(0xFF6C5CE7),
    Color(0xFFFF9500),
    Color(0xFF1A1A2E),
    Color(0xFFFFD93D),
  ];

  /// Весняна палітра: рожевий, м'ятний, блакитний, жовтий.
  static const List<Color> easter = [
    Color(0xFFFFB3DE),
    Color(0xFF98FB98),
    Color(0xFF87CEEB),
    Color(0xFFFFE066),
    Color(0xFFDDA0DD),
    Color(0xFFB0E0E6),
  ];

  /// Спортивна палітра: синій, червоний, жовтий.
  static const List<Color> sports = [
    Color(0xFF0066FF),
    Color(0xFFFF0000),
    Color(0xFFFFD700),
    Color(0xFFFFFFFF),
    Color(0xFF00CC00),
    Color(0xFFFF6600),
  ];

  /// Повертає випадковий колір із палітри.
  ///
  /// [palette] — палітра кольорів.
  static Color randomFrom(List<Color> palette) {
    return palette[math.Random().nextInt(palette.length)];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Physics Constants (Фізичні константи)
// ═══════════════════════════════════════════════════════════════════════════

/// Незмінні фізичні константи для симуляції конфетті.
///
/// Дозволяє легко налаштувати фізику без зміни коду віджету.
class ConfettiPhysics {
  ConfettiPhysics._();

  /// Стандартна гравітація Землі (9.8 м/с²).
  static const double earthGravity = 9.8;

  /// Знижена гравітація для легкого ефекту.
  static const double lowGravity = 4.0;

  /// Підвищена гравітація для швидкого падіння.
  static const double highGravity = 15.0;

  /// Нульова гравітація (космос).
  static const double zeroGravity = 0.0;

  /// Стандартний коефіцієнт опору повітря.
  static const double standardDrag = 0.98;

  /// Посилений опір (повільніше падіння).
  static const double heavyDrag = 0.92;

  /// Мінімальний опір (швидке падіння).
  static const double lightDrag = 0.995;

  /// Стандартна швидкість вітру.
  static const double standardWind = 0.0;

  /// Помірний вітер зліва.
  static const double leftWind = -2.0;

  /// Помірний вітер справа.
  static const double rightWind = 2.0;

  /// Буревій (сильний вітер).
  static const double stormWind = 5.0;

  /// Повертає параметри фізики для заданого середовища.
  ///
  /// [environment] — тип середовища ('earth', 'moon', 'mars', 'space').
  static ({double gravity, double drag, double wind}) environmentParams(
      String environment) {
    switch (environment.toLowerCase()) {
      case 'moon':
        return (gravity: 1.6, drag: 0.995, wind: 0.0);
      case 'mars':
        return (gravity: 3.7, drag: 0.99, wind: 0.5);
      case 'space':
        return (gravity: 0.0, drag: 1.0, wind: 0.0);
      case 'earth':
      default:
        return (gravity: earthGravity, drag: standardDrag, wind: 0.0);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Validation Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширені методи перевірки для конфетті.
extension ConfettiValidationExt on AppConfetti {
  /// Перевіряє, чи кількість частинок допустима.
  ///
  /// Допустимий діапазон: 0–500.
  static bool isValidParticleCount(int count) =>
      count >= 0 && count <= 500;

  /// Перевіряє, чи гравітація допустима.
  ///
  /// Допустимий діапазон: 0–50.
  static bool isValidGravity(double gravity) =>
      gravity >= 0 && gravity <= 50;

  /// Перевіряє, чи розміри частинок допустимі.
  ///
  /// [sizeMin] має бути > 0, [sizeMax] має бути >= [sizeMin].
  static bool isValidSizes(double sizeMin, double sizeMax) =>
      sizeMin > 0 && sizeMax >= sizeMin;

  /// Перевіряє, чи fadeOutStart допустимий.
  ///
  /// Допустимий діапазон: 0.0–1.0.
  static bool isValidFadeOutStart(double fadeOutStart) =>
      fadeOutStart >= 0.0 && fadeOutStart <= 1.0;

  /// Перевіряє, чи drag допустимий.
  ///
  /// Допустимий діапазон: 0.0–1.0.
  static bool isValidDrag(double drag) => drag >= 0.0 && drag <= 1.0;

  /// Обчислює середню швидкість частинок.
  ///
  /// Корисно для tuning-у продуктивності.
  ///
  /// [particles] — список частинок.
  static double averageSpeed(List<_ConfettiParticle> particles) {
    if (particles.isEmpty) return 0.0;
    final totalSpeed = particles.fold<double>(
      0.0,
      (sum, p) => sum + p.speed,
    );
    return totalSpeed / particles.length;
  }

  /// Обчислює максимальну швидкість частинок.
  ///
  /// [particles] — список частинок.
  static double maxSpeed(List<_ConfettiParticle> particles) {
    if (particles.isEmpty) return 0.0;
    return particles
        .map((p) => p.speed)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Обчислює відсоток частинок, що ще видимі на екрані.
  ///
  /// [particles] — список частинок.
  /// [screenSize] — розмір екрана.
  static double visiblePercentage(
    List<_ConfettiParticle> particles,
    Size screenSize,
  ) {
    if (particles.isEmpty) return 0.0;
    var visible = 0;
    for (final p in particles) {
      if (p.x >= -50 &&
          p.x <= screenSize.width + 50 &&
          p.y >= -50 &&
          p.y <= screenSize.height + 50) {
        visible++;
      }
    }
    return (visible / particles.length) * 100;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Confetti Trajectory Painter (Малювальник траєкторій)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник траєкторій частинок конфетті для debug.
///
/// Малює тонкі лінії від початкової позиції до поточної,
/// дозволяючи візуалізувати рух частинок.
class _ConfettiTrajectoryPainter extends CustomPainter {
  /// Створює малювальник траєкторій.
  ///
  /// [particles] — список частинок.
  /// [progress] — прогрес анімації.
  /// [origin] — точка походження вибуху.
  /// [screenSize] — розмір екрана.
  /// [gravity] — сила гравітації.
  /// [wind] — сила вітру.
  _ConfettiTrajectoryPainter({
    required this.particles,
    required this.progress,
    required this.origin,
    required this.screenSize,
    required this.gravity,
    required this.wind,
  });

  /// Список частинок.
  final List<_ConfettiParticle> particles;

  /// Поточний прогрес анімації.
  final double progress;

  /// Точка походження вибуху.
  final Offset? origin;

  /// Розмір екрана.
  final Size screenSize;

  /// Сила гравітації.
  final double gravity;

  /// Сила вітру.
  final double wind;

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        origin ?? Offset(screenSize.width / 2, screenSize.height / 2);
    final dt = progress * 2.0;

    final linePaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final p in particles) {
      final x = center.dx + p.vx * dt * 30 + wind * dt * dt * 15;
      final y = center.dy + p.vy * dt * 30 + 0.5 * p.gravity * dt * dt * 30;

      if (x < -50 || x > screenSize.width + 50 ||
          y < -50 || y > screenSize.height + 50) {
        continue;
      }

      canvas.drawLine(center, Offset(x, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiTrajectoryPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
