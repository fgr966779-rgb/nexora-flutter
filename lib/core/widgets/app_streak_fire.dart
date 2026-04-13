import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Тематичні пресети вогню (Fire Theme Presets)
// ═══════════════════════════════════════════════════════════════════════════

/// Тематичні пресети кольорів для вогню серії.
///
/// Кожен пресет визначає основний колір, колір сяйва,
/// колір частинок та іконку для відображення.
enum FireTheme {
  /// Стандартний помаранчево-червоний вогонь.
  fire(
    name: 'Вогонь',
    primaryColor: Color(0xFFFF5722),
    glowColor: Color(0xFFFF5722).withOpacity(0.35),
    particleColor: Color(0xFFFF9800),
    icon: Icons.local_fire_department_rounded,
    emoji: '🔥',
  ),

  /// Льодяна тема — блакитний крижаний вогонь.
  ice(
    name: 'Лід',
    primaryColor: Color(0xFF64B5F6),
    glowColor: Color(0xFF64B5F6).withOpacity(0.3),
    particleColor: Color(0xFFBBDEFB),
    icon: Icons.ac_unit_rounded,
    emoji: '❄️',
  ),

  /// Золота тема — для досягнень та рекордів.
  gold(
    name: 'Золото',
    primaryColor: Color(0xFFFFD700),
    glowColor: Color(0xFFFFD700).withOpacity(0.4),
    particleColor: Color(0xFFFFC107),
    icon: Icons.emoji_events_rounded,
    emoji: '🏆',
  ),

  /// Синя тема — для стабільних серій.
  blue(
    name: 'Блакитний',
    primaryColor: Color(0xFF2196F3),
    glowColor: Color(0xFF2196F3).withOpacity(0.35),
    particleColor: Color(0xFF64B5F6),
    icon: Icons.water_drop_rounded,
    emoji: '💧',
  ),

  /// Веселкова тема — для максимальних серій.
  rainbow(
    name: 'Веселка',
    primaryColor: Color(0xFFE040FB),
    glowColor: Color(0xFFE040FB).withOpacity(0.4),
    particleColor: Color(0xFFFFD600),
    icon: Icons.auto_awesome_rounded,
    emoji: '🌈',
  );

  const FireTheme({
    required this.name,
    required this.primaryColor,
    required this.glowColor,
    required this.particleColor,
    required this.icon,
    required this.emoji,
  });

  /// Назва теми для налаштувань.
  final String name;

  /// Основний колір вогню.
  final Color primaryColor;

  /// Колір сяйва навколо вогню.
  final Color glowColor;

  /// Колір частинок навколо вогню.
  final Color particleColor;

  /// Іконка для відображення.
  final IconData icon;

  /// Емодзі теми (для сповіщень).
  final String emoji;

  /// Визначає тему за кількістю днів серії.
  ///
  /// - 0-2: ice (лід — початок)
  /// - 3-13: fire (стандартний вогонь)
  /// - 14-29: blue (блакитний — стабільність)
  /// - 30-59: gold (золото — легенда)
  /// - 60+: rainbow (веселка — максимальна серія)
  static FireTheme fromDays(int days) {
    if (days >= 60) return FireTheme.rainbow;
    if (days >= 30) return FireTheme.gold;
    if (days >= 14) return FireTheme.blue;
    if (days >= 3) return FireTheme.fire;
    return FireTheme.ice;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Етапи серії (Streak Milestones)
// ═══════════════════════════════════════════════════════════════════════════

/// Етапи серії з відповідними кольорами, назвами та емодзі.
///
/// Кожен етап визначає візуальний вигляд вогню:
/// кількість шарів полум'я, колір, назву та емодзі.
/// Розширені етапи: 3, 7, 14, 30, 60, 90 днів.
enum StreakMilestone {
  /// 0-2 дні: початок шляху заощаджень.
  ///
  /// Сіра іконка без вогню — користувач тільки почав.
  starter(
    minDays: 0,
    label: 'Початок',
    description: 'Тільки почали! Продовжуйте щоденні внески.',
    emoji: '🌱',
    color: Color(0xFF9E9EB0),
    glowColor: Color(0xFF9E9EB0).withOpacity(0.2),
    flameLayers: 0,
    particleCount: 0,
    xpBonus: 0,
  ),

  /// 3-6 днів: перший вогонь заохочення.
  ///
  /// Одне помаранчеве полум'я — серія запалена!
  warmUp(
    minDays: 3,
    label: 'Розігрів',
    description: 'Серія запалена! Тримайте ритм.',
    emoji: '🔥',
    color: Color(0xFFFF9800),
    glowColor: Color(0xFFFF9800).withOpacity(0.3),
    flameLayers: 1,
    particleCount: 0,
    xpBonus: 10,
  ),

  /// 7-13 днів: стабільна серія — користувач надійний.
  ///
  /// Два шари вогню — серія стабільна.
  onFire(
    minDays: 7,
    label: 'На вогні',
    description: 'Серія стабільна! Ви на правильному шляху.',
    emoji: '🔥',
    color: Color(0xFFFF5722),
    glowColor: Color(0xFFFF5722).withOpacity(0.35),
    flameLayers: 2,
    particleCount: 2,
    xpBonus: 25,
  ),

  /// 14-29 днів: потужна серія — серйозний заощаджувач.
  ///
  /// Три шари червоного вогню з частинками.
  inferno(
    minDays: 14,
    label: 'Пекло',
    description: 'Ви — машина заощаджень! Неймовірна серія.',
    emoji: '🔥',
    color: Color(0xFFF44336),
    glowColor: Color(0xFFF44336).withOpacity(0.4),
    flameLayers: 3,
    particleCount: 4,
    xpBonus: 50,
  ),

  /// 30-59 днів: потрійне полум'я — легендарна серія.
  ///
  /// Три полум'я з частинками та посиленим сяйвом.
  tripleFlame(
    minDays: 30,
    label: 'Потрійне полум\'я',
    description: 'Легендарна серія! Ви — справжній майстер заощаджень.',
    emoji: '🔥',
    color: Color(0xFFD50000),
    glowColor: Color(0xFFD50000).withOpacity(0.5),
    flameLayers: 3,
    particleCount: 6,
    xpBonus: 100,
  ),

  /// 60-89 днів: золотий вогонь — безперервна дисципліна.
  ///
  /// Золотий вогонь з магнітним сяйвом та хвилями частинок.
  goldenBlaze(
    minDays: 60,
    label: 'Золоте полум\'я',
    description: 'Золота серія! Ваша дисципліна безмежна.',
    emoji: '👑',
    color: Color(0xFFFFD700),
    glowColor: Color(0xFFFFD700).withOpacity(0.55),
    flameLayers: 3,
    particleCount: 8,
    xpBonus: 200,
  ),

  /// 90+ днів: веселковий вогонь — абсолютна майстерність.
  ///
  /// Веселковий вогонь з магнітним сяйвом, частинками та хвилями.
  rainbowInferno(
    minDays: 90,
    label: 'Веселковий вогонь',
    description: 'Безмежна серія! Ви — легенда заощаджень Nexora!',
    emoji: '🌈',
    color: Color(0xFFE040FB),
    glowColor: Color(0xFFE040FB).withOpacity(0.6),
    flameLayers: 3,
    particleCount: 10,
    xpBonus: 500,
  );

  const StreakMilestone({
    required this.minDays,
    required this.label,
    required this.description,
    required this.emoji,
    required this.color,
    required this.glowColor,
    required this.flameLayers,
    required this.particleCount,
    required this.xpBonus,
  });

  /// Мінімальна кількість днів для цього етапу.
  final int minDays;

  /// Коротка назва етапу (для відображення під числом).
  final String label;

  /// Опис етапу (для tooltip або popup).
  final String description;

  /// Емодзі етапу (для сповіщень або чатів).
  final String emoji;

  /// Основний колір вогню / іконки.
  final Color color;

  /// Колір сяйва навколо вогню.
  final Color glowColor;

  /// Кількість шарів полум'я (0 = без вогню).
  final int flameLayers;

  /// Кількість частинок навколо вогню.
  final int particleCount;

  /// Бонус XP за досягнення цього етапу.
  final int xpBonus;

  /// Визначає етап за кількістю днів серії.
  ///
  /// Повертає відповідний [StreakMilestone] залежно від кількості днів.
  /// Розширені етапи включають 60 та 90 днів.
  static StreakMilestone fromDays(int days) {
    if (days >= 90) return StreakMilestone.rainbowInferno;
    if (days >= 60) return StreakMilestone.goldenBlaze;
    if (days >= 30) return StreakMilestone.tripleFlame;
    if (days >= 14) return StreakMilestone.inferno;
    if (days >= 7) return StreakMilestone.onFire;
    if (days >= 3) return StreakMilestone.warmUp;
    return StreakMilestone.starter;
  }

  /// Визначає етап за відсотком прогресу до наступного етапу.
  ///
  /// Корисно для відображення "скільки залишилось до наступного етапу".
  static StreakMilestone nextMilestone(int currentDays) {
    if (currentDays >= 90) return StreakMilestone.rainbowInferno;
    if (currentDays >= 60) return StreakMilestone.rainbowInferno;
    if (currentDays >= 30) return StreakMilestone.goldenBlaze;
    if (currentDays >= 14) return StreakMilestone.tripleFlame;
    if (currentDays >= 7) return StreakMilestone.inferno;
    if (currentDays >= 3) return StreakMilestone.onFire;
    return StreakMilestone.warmUp;
  }

  /// Кількість днів до наступного етапу.
  ///
  /// Повертає 0, якщо вже на максимальному етапі.
  int daysToNext(int currentDays) {
    final next = nextMilestone(currentDays);
    if (next == this) return 0;
    return next.minDays - currentDays;
  }

  /// Варіант анімації полум'я залежно від етапу.
  ///
  /// - single: одинарне полум'я (0-6 днів)
  /// - double: подвійне полум'я (7-13 днів)
  /// - triple: потрійне полум'я (14+ днів)
  String get flameVariant {
    if (minDays >= 14) return 'triple';
    if (minDays >= 7) return 'double';
    return 'single';
  }

  /// Інтенсивність полум'я (0.0–1.0).
  ///
  /// Більша серія → більша інтенсивність.
  double get intensity {
    if (minDays >= 90) return 1.0;
    if (minDays >= 60) return 0.9;
    if (minDays >= 30) return 0.8;
    if (minDays >= 14) return 0.6;
    if (minDays >= 7) return 0.4;
    if (minDays >= 3) return 0.25;
    return 0.0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Хвильовий ефект (Heat Wave Background Effect)
// ═══════════════════════════════════════════════════════════════════════════

/// Малювальник хвильового ефекту тепла на фоні.
///
/// Створює м'які теплові хвилі під вогнем серії,
/// які пульсують залежно від інтенсивності серії.
class _HeatWavePainter extends CustomPainter {
  _HeatWavePainter({
    required this.progress,
    required this.color,
    required this.intensity,
  });

  /// Прогрес анімації (0.0–1.0).
  final double progress;

  /// Колір хвиль.
  final Color color;

  /// Інтенсивність хвиль (0.0–1.0).
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final waveCount = (intensity * 5).ceil();
    for (var i = 0; i < waveCount; i++) {
      final t = (progress + i * 0.2) % 1.0;
      final waveY = size.height * 0.7 + math.sin(t * math.pi * 2 + i) * 8;
      final waveOpacity = intensity * 0.08 * (1.0 - t * 0.5);
      final waveWidth = size.width * (0.6 + i * 0.08);

      final paint = Paint()
        ..color = color.withOpacity(waveOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, waveY),
          width: waveWidth,
          height: 6 + i * 2,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeatWavePainter old) =>
      old.progress != progress || old.intensity != intensity;
}

// ═══════════════════════════════════════════════════════════════════════════
// Віджет (Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Анімований вогонь серії з кількістю днів.
///
/// Має декілька шарів полум'я залежно від етапу серії:
/// - 0-2 дні: сіра іконка без вогню (немає енергії)
/// - 3-6 днів: 1 шар помаранчевого вогню (розігрів)
/// - 7-13 днів: 2 шари вогню (на вогні)
/// - 14-29 днів: 3 шари червоного вогню з частинками (пекло)
/// - 30+ днів: "Потрійне полум'я" з частинками та сяйвом
/// - 60+ днів: Золоте полум'я з хвилями частинок
/// - 90+ днів: Веселковий вогонь з магнітним сяйвом
///
/// При розриві серії відображає крижаний оверлей.
/// Підтримує тематичні пресети вогню, хвильовий ефект,
/// анімований лічильник та перехід «лід → вогонь».
class AppStreakFire extends StatefulWidget {
  const AppStreakFire({
    super.key,
    required this.streakDays,
    this.isLightTheme = false,
    this.isBroken = false,
    this.showLabel = true,
    this.showMilestoneLabel = false,
    this.showDescription = false,
    this.animateGrowth = true,
    this.size = 28.0,
    this.onTap,
    this.fireTheme,
    this.showHeatWave = false,
    this.showAnimatedCounter = false,
    this.previousStreakDays,
  });

  /// Кількість днів поточної серії.
  final int streakDays;

  /// Використовувати світлу тему (Monitor).
  final bool isLightTheme;

  /// Чи розірвана серія (показати крижаний оверлей).
  final bool isBroken;

  /// Показувати напис "серія" під числом.
  final bool showLabel;

  /// Показувати назву етапу (наприклад, "Потрійне полум'я").
  final bool showMilestoneLabel;

  /// Показувати опис етапу (для expanded вигляду).
  final bool showDescription;

  /// Анімувати зростання при збільшенні серії.
  final bool animateGrowth;

  /// Базовий розмір іконки в пікселях.
  final double size;

  /// Зворотний виклик при натисканні на віджет.
  final VoidCallback? onTap;

  /// Кастомна тема вогню (якщо не вказано — визначається автоматично).
  final FireTheme? fireTheme;

  /// Показувати хвильовий ефект тепла на фоні.
  final bool showHeatWave;

  /// Показувати анімований лічильник днів (count-up ефект).
  final bool showAnimatedCounter;

  /// Попереднє значення днів для count-up анімації.
  final int? previousStreakDays;

  @override
  State<AppStreakFire> createState() => _AppStreakFireState();
}

class _AppStreakFireState extends State<AppStreakFire>
    with SingleTickerProviderStateMixin {
  /// Попереднє значення днів (для визначення зростання).
  int _previousDays = 0;

  /// Поточне відображуване число (для count-up анімації).
  int _displayedDays = 0;

  /// Контролер хвильового ефекту.
  late AnimationController _heatWaveController;

  /// Чи виконується перехід «лід → вогонь».
  bool _isTransitioning = false;

  /// Прогрес переходу (0.0 = лід, 1.0 = вогонь).
  double _transitionProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previousDays = widget.streakDays;
    _displayedDays = widget.streakDays;

    // Контролер хвильового ефекту тепла
    _heatWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Перевіряємо чи потрібен перехід лід → вогонь
    if (widget.previousStreakDays != null) {
      _previousDays = widget.previousStreakDays!;
      if (_previousDays < 3 && widget.streakDays >= 3) {
        _isTransitioning = true;
        _displayedDays = _previousDays;
        _animateTransition();
      } else {
        _displayedDays = widget.streakDays;
      }
    }

    // Count-up анімація
    if (widget.showAnimatedCounter && !widget.isBroken) {
      _animateCountUp();
    }
  }

  @override
  void didUpdateWidget(covariant AppStreakFire oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousDays = oldWidget.streakDays;

    if (widget.streakDays != oldWidget.streakDays) {
      if (widget.showAnimatedCounter && !widget.isBroken) {
        _animateCountUp();
      } else {
        setState(() => _displayedDays = widget.streakDays);
      }
    }

    // Перевіряємо перехід лід → вогонь при оновленні
    if (oldWidget.streakDays < 3 && widget.streakDays >= 3 && !_isTransitioning) {
      _isTransitioning = true;
      _displayedDays = oldWidget.streakDays;
      _animateTransition();
    }
  }

  @override
  void dispose() {
    _heatWaveController.dispose();
    super.dispose();
  }

  /// Анімує перехід від крижаного стану до вогню.
  ///
  /// Плавно змінює прозорість від льоду до вогню.
  void _animateTransition() {
    const steps = 30;
    const stepDuration = Duration(milliseconds: 33);
    var step = 0;

    void tick() {
      if (!mounted || step >= steps) {
        if (mounted) {
          setState(() {
            _isTransitioning = false;
            _transitionProgress = 1.0;
            _displayedDays = widget.streakDays;
          });
        }
        return;
      }
      step++;
      setState(() {
        _transitionProgress = step / steps;
        _displayedDays = (_previousDays + (widget.streakDays - _previousDays) * _transitionProgress).round();
      });
      Future.delayed(stepDuration, tick);
    }

    tick();
  }

  /// Анімує лічильник днів (count-up ефект).
  void _animateCountUp() {
    final start = _displayedDays;
    final end = widget.streakDays;
    if (start == end) return;

    final range = (end - start).abs();
    final stepMs = (300 / range).clamp(8, 50).toInt();
    final isIncreasing = end > start;
    var current = start;

    void step() {
      if (!mounted) return;
      if ((isIncreasing && current >= end) || (!isIncreasing && current <= end)) {
        setState(() => _displayedDays = end);
        return;
      }
      current += isIncreasing ? 1 : -1;
      setState(() => _displayedDays = current);
      Future.delayed(Duration(milliseconds: stepMs), step);
    }

    step();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Обчислення (Calculations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Поточний етап серії.
  StreakMilestone get _milestone => StreakMilestone.fromDays(widget.streakDays);

  /// Поточна тема вогню.
  FireTheme get _fireTheme => widget.fireTheme ?? FireTheme.fromDays(widget.streakDays);

  /// Множник масштабу залежно від етапу.
  ///
  /// Більша серія → більша іконка. Розширено для 60/90 днів.
  double get _scaleFactor {
    if (widget.streakDays >= 90) return 2.4;
    if (widget.streakDays >= 60) return 2.2;
    if (widget.streakDays >= 30) return 2.0;
    if (widget.streakDays >= 14) return 1.7;
    if (widget.streakDays >= 7) return 1.4;
    if (widget.streakDays >= 3) return 1.1;
    return 0.85;
  }

  /// Масштаб інтенсивності полум'я (0.0–1.0).
  double get _intensityScale => _milestone.intensity;

  /// Колір полум'я (або крижаний при розриві).
  Color get _flameColor {
    if (widget.isBroken) return Colors.blue.shade200;
    return _fireTheme.primaryColor;
  }

  /// Колір сяйва навколо вогню.
  Color get _glowColor {
    if (widget.isBroken) return Colors.blue.shade100.withOpacity(0.2);
    return _fireTheme.glowColor;
  }

  /// Базовий розмір з урахуванням масштабу.
  double get _baseSize => widget.size * _scaleFactor;

  /// Чи потрібно анімувати зростання.
  bool get _shouldAnimateGrowth =>
      widget.animateGrowth &&
      widget.streakDays > _previousDays &&
      _previousDays > 0;

  /// Колір тексту "серія".
  Color get _textColor => widget.isLightTheme
      ? AppColorsMonitor.textSecondary
      : AppColorsPS5.textSecondary;

  /// Колір тексту опису етапу.
  Color get _descriptionColor => widget.isLightTheme
      ? AppColorsMonitor.textHint
      : AppColorsPS5.textHint;

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Хвильовий ефект тепла ──
        if (widget.showHeatWave && widget.streakDays >= 3 && !widget.isBroken)
          SizedBox(
            width: _baseSize * 2.5,
            height: _baseSize * 0.6,
            child: AnimatedBuilder(
              animation: _heatWaveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _HeatWavePainter(
                    progress: _heatWaveController.value,
                    color: _flameColor,
                    intensity: _intensityScale,
                  ),
                );
              },
            ),
          ),

        // ── Шари полум'я ──
        if (_isTransitioning)
          _buildTransitionFlame()
        else
          _buildFlameStack(),

        const SizedBox(height: 2),

        // ── Кількість днів (з анімованим лічильником) ──
        Text(
          '${_displayedDays}',
          style: AppTypography.labelSmall.copyWith(
            color: _flameColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ── Напис "серія" ──
        if (widget.showLabel) ...[
          const SizedBox(height: 1),
          Text(
            'серія',
            style: AppTypography.labelSmall.copyWith(
              color: _textColor,
              fontSize: 8,
            ),
          ),
        ],
        // ── Назва етапу ──
        if (widget.showMilestoneLabel && widget.streakDays >= 3) ...[
          const SizedBox(height: 2),
          Text(
            _milestone.label,
            style: AppTypography.labelSmall.copyWith(
              color: _flameColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        // ── Опис етапу ──
        if (widget.showDescription && widget.streakDays >= 3) ...[
          const SizedBox(height: 2),
          Text(
            _milestone.description,
            style: AppTypography.caption.copyWith(
              color: _descriptionColor,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // ── Назва теми ──
        if (widget.showDescription && widget.streakDays >= 14) ...[
          const SizedBox(height: 1),
          Text(
            '${_fireTheme.emoji} ${_fireTheme.name}',
            style: AppTypography.caption.copyWith(
              color: _descriptionColor,
              fontSize: 7,
            ),
          ),
        ],
      ],
    );

    // Обгортаємо у GestureDetector якщо є callback
    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Перехід лід → вогонь (Frost-to-Fire Transition)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує перехідний ефект від крижаного стану до вогню.
  ///
  /// Крижана іконка плавно змінюється на вогняну
  /// з проміжним станом напівпрозорості.
  Widget _buildTransitionFlame() {
    final iceOpacity = 1.0 - _transitionProgress;
    final fireOpacity = _transitionProgress;

    return SizedBox(
      width: _baseSize * 1.5,
      height: _baseSize * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Крижана іконка (зникає)
          if (iceOpacity > 0)
            Opacity(
              opacity: iceOpacity,
              child: Icon(
                Icons.ac_unit_rounded,
                color: Colors.blue.shade200,
                size: _baseSize,
              ),
            ),
          // Вогняна іконка (з'являється)
          if (fireOpacity > 0)
            Opacity(
              opacity: fireOpacity,
              child: _buildSingleFlame(
                icon: _fireTheme.icon,
                size: _baseSize * fireOpacity,
                color: _flameColor,
                animate: fireOpacity > 0.5,
              ),
            ),
          // Іскри переходу
          if (_transitionProgress > 0.2 && _transitionProgress < 0.8)
            ..._buildTransitionSparks(),
        ],
      ),
    );
  }

  /// Будує іскри під час переходу лід → вогонь.
  List<Widget> _buildTransitionSparks() {
    final sparks = <Widget>[];
    final sparkCount = 4;

    for (var i = 0; i < sparkCount; i++) {
      final angle = (i / sparkCount) * 2 * math.pi;
      final distance = _baseSize * 0.5 * _transitionProgress;
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance;

      sparks.add(
        Positioned(
          left: _baseSize * 0.75 + dx,
          top: _baseSize * 0.4 + dy,
          child: Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.blue.shade200, _flameColor, _transitionProgress),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _flameColor.withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.3, 0.3),
                end: const Offset(1.0, 1.0),
                duration: Duration(milliseconds: 300 + i * 100),
              )
              .fadeIn(duration: const Duration(milliseconds: 200))
              .then()
              .fadeOut(duration: const Duration(milliseconds: 200)),
        ),
      );
    }

    return sparks;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Стек полум'я (Flame Stack)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує стек полум'я з кількома шарами залежно від етапу.
  ///
  /// Варіанти анімації:
  /// - single: одне полум'я (3-6 днів)
  /// - double: два шари (7-13 днів)
  /// - triple: три шари з частинками (14+ днів)
  Widget _buildFlameStack() {
    // Без вогню — проста іконка (старт або розрив)
    if (widget.streakDays < 3 || widget.isBroken) {
      return _buildSingleFlame(
        icon: widget.isBroken
            ? Icons.ac_unit_rounded
            : Icons.local_fire_department_rounded,
        size: _baseSize,
        color: _flameColor,
        animate: !widget.isBroken,
      );
    }

    final layers = _milestone.flameLayers;
    final variant = _milestone.flameVariant;

    return SizedBox(
      width: _baseSize * (variant == 'triple' ? 2.2 : variant == 'double' ? 1.6 : 1.2),
      height: _baseSize * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Задній шар (дим / друге полум'я) ──
          if (layers >= 2)
            Positioned(
              left: variant == 'triple' ? _baseSize * 0.15 : 0,
              child: _buildSingleFlame(
                icon: _fireTheme.icon,
                size: _baseSize * 0.8,
                color: _milestone.color.withOpacity(0.5),
                animate: true,
                delay: 100,
              ),
            ),
          // ── Перший шар (основне полум'я) ──
          Positioned(
            left: variant == 'triple' ? _baseSize * 0.6 : _baseSize * 0.15,
            child: _buildSingleFlame(
              icon: _fireTheme.icon,
              size: _baseSize,
              color: _flameColor,
              animate: true,
              delay: 0,
            ),
          ),
          // ── Третій шар (тільки для triple) ──
          if (variant == 'triple')
            Positioned(
              right: 0,
              child: _buildSingleFlame(
                icon: _fireTheme.icon,
                size: _baseSize * 0.8,
                color: _milestone.color.withOpacity(0.5),
                animate: true,
                delay: 200,
              ),
            ),
          // ── Частинки навколо вогню ──
          if (layers >= 2) ..._buildParticles(),
        ],
      ),
    );
  }

  /// Будує один шар полум'я з анімацією мерехтіння.
  ///
  /// [icon] — іконка для відображення.
  /// [size] — розмір іконки.
  /// [color] — колір іконки.
  /// [animate] — чи анімувати мерехтіння.
  /// [delay] — затримка анімації в мілісекундах.
  ///
  /// Інтенсивність мерехтіння масштабується залежно від етапу.
  Widget _buildSingleFlame({
    required IconData icon,
    required double size,
    required Color color,
    required bool animate,
    int delay = 0,
  }) {
    final scaleEnd = 1.0 + _intensityScale * 0.15;

    final flame = Icon(
      icon,
      color: color,
      size: size,
    );

    // Статична іконка — без анімації
    if (!animate) {
      // Крижаний оверлей для розірваної серії
      if (widget.isBroken) {
        return Stack(
          children: [
            flame,
            // Крижинка поверх вогню
            Icon(
              Icons.ac_unit_rounded,
              color: Colors.blue.shade100.withOpacity(0.7),
              size: size * 0.9,
            ),
          ],
        );
      }
      return flame;
    }

    // Анімована іконка — мерехтіння + shimmer з масштабуванням інтенсивності
    return flame
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: Offset(scaleEnd, scaleEnd),
          duration: AppDurations.pulse,
          curve: AppEasings.standard,
          delay: Duration(milliseconds: delay),
        )
        .shimmer(
          duration: AppDurations.skeleton,
          color: Colors.yellow.withOpacity(0.2 + _intensityScale * 0.3),
          delay: Duration(milliseconds: delay),
        );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Частинки (Particles)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує частинки навколо вогню.
  ///
  /// Кількість частинок залежить від етапу:
  /// - 7-13 днів: 2 частинки
  /// - 14+ днів: 4-10 частинок
  ///
  /// Колір частинок визначається темою вогню.
  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final particleCount = _milestone.particleCount;

    for (var i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = _baseSize * 0.6;
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance - _baseSize * 0.3;

      // Колір частинки — з теми вогню
      final particleColor = _fireTheme.particleColor.withOpacity(0.6);

      particles.add(
        Positioned(
          left: _baseSize * 0.8 + dx,
          top: _baseSize * 0.3 + dy,
          child: Container(
            width: 3 + _intensityScale,
            height: 3 + _intensityScale,
            decoration: BoxDecoration(
              color: particleColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: particleColor.withOpacity(0.3),
                  blurRadius: 3 + _intensityScale * 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.2, 1.2),
                duration: Duration(milliseconds: 800 + i * 150),
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: const Duration(milliseconds: 400))
              .then()
              .fadeOut(duration: const Duration(milliseconds: 400)),
        ),
      );
    }

    return particles;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Helper Methods)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з віджетом серії.
class AppStreakFireHelpers {
  AppStreakFireHelpers._();

  /// Форматує кількість днів серії для відображення.
  ///
  /// [days] — кількість днів серії.
  ///
  /// Приклади:
  /// - `formatDays(1)` → "1 день"
  /// - `formatDays(5)` → "5 днів"
  /// - `formatDays(21)` → "21 день"
  static String formatDays(int days) {
    if (days == 1) return '1 день';
    if (days >= 2 && days <= 4) return '$days дні';
    return '$days днів';
  }

  /// Повертає повідомлення про розрив серії.
  static String brokenStreakMessage(int lostDays) {
    return 'Серію з ${formatDays(lostDays)} розірвано! Почніть знову.';
  }

  /// Повертає повідомлення про новий рекорд серії.
  static String newRecordMessage(int days) {
    return '🎯 Новий рекорд: ${formatDays(days)} поспіль!';
  }

  /// Повертає повідомлення про наближення до наступного етапу.
  static String nextMilestoneMessage(int currentDays) {
    final milestone = StreakMilestone.fromDays(currentDays);
    final daysLeft = milestone.daysToNext(currentDays);
    if (daysLeft == 0) {
      return '✅ Ви досягли етапу «${milestone.label}»!';
    }
    return ' ще ${formatDays(daysLeft)} до «${StreakMilestone.nextMilestone(currentDays).label}»';
  }

  /// Повертає повний текст для accessibility.
  static String accessibilityDescription(int days, bool isBroken) {
    if (isBroken) {
      return 'Серію розірвано. Попередня серія: ${formatDays(days)}.';
    }
    final milestone = StreakMilestone.fromDays(days);
    final theme = FireTheme.fromDays(days);
    return 'Серія: ${formatDays(days)}. Етап: ${milestone.label}. Тема: ${theme.name}. ${milestone.description}';
  }

  /// Обчислює бонус XP за серію.
  static int calculateXpBonus(int streakDays) {
    final milestone = StreakMilestone.fromDays(streakDays);
    return milestone.xpBonus;
  }

  /// Повертає опис теми вогню для користувача.
  static String fireThemeDescription(FireTheme theme) {
    return '${theme.emoji} Тема вогню: ${theme.name}';
  }

  /// Повертає повідомлення про досягнення нового етапу.
  static String milestoneReachedMessage(StreakMilestone milestone) {
    return '${milestone.emoji} Новий етап: «${milestone.label}»! +${milestone.xpBonus} XP бонус!';
  }

  /// Повертає повідомлення про тему вогню для даної серії.
  static String fireThemeForDays(int days) {
    final theme = FireTheme.fromDays(days);
    return 'Тема вогню: ${theme.emoji} ${theme.name}';
  }

  /// Обчислює прогрес до наступного етапу у відсотках.
  ///
  /// Повертає значення від 0.0 до 1.0.
  static double progressToNextMilestone(int currentDays) {
    if (currentDays >= 90) return 1.0;
    final milestones = [3, 7, 14, 30, 60, 90];
    int prevMilestone = 0;
    int nextMilestone = 3;
    for (var i = 0; i < milestones.length; i++) {
      if (currentDays >= milestones[i]) {
        prevMilestone = milestones[i];
        nextMilestone = i < milestones.length - 1 ? milestones[i + 1] : milestones[i];
      } else {
        nextMilestone = milestones[i];
        break;
      }
    }
    if (nextMilestone == prevMilestone) return 1.0;
    final range = nextMilestone - prevMilestone;
    final progress = currentDays - prevMilestone;
    return (progress / range).clamp(0.0, 1.0);
  }

  /// Повертає кольори для анімації переходу між етапами.
  ///
  /// Корисно для градієнтних переходів між двома етапами.
  static List<Color> transitionGradientColors(
    StreakMilestone from,
    StreakMilestone to,
  ) {
    return [from.color, to.color];
  }

  /// Повертає список усіх етапів серії у хронологічному порядку.
  static List<StreakMilestone> allMilestones() {
    return StreakMilestone.values.toList()
      ..sort((a, b) => a.minDays.compareTo(b.minDays));
  }

  /// Повертає список етапів які ще не досягнуті.
  static List<StreakMilestone> upcomingMilestones(int currentDays) {
    return allMilestones()
        .where((m) => m.minDays > currentDays)
        .toList();
  }

  /// Перевіряє чи поточна серія є новим рекордом.
  static bool isNewRecord(int currentDays, int previousRecord) {
    return currentDays > previousRecord && previousRecord > 0;
  }

  /// Повертає повідомлення про сумарний XP за всі досягнуті етапи.
  static String totalXpSummary(int streakDays) {
    final milestone = StreakMilestone.fromDays(streakDays);
    return 'Бонус XP за етап «${milestone.label}»: +${milestone.xpBonus}';
  }

  /// Повертає пораду для продовження серії.
  static String streakTip(int currentDays) {
    if (currentDays == 0) return '🌱 Почніть сьогодні!';
    if (currentDays < 3) return '💧 Ще трохи — до вогню залишилось ${3 - currentDays} дн.';
    if (currentDays < 7) return '🔥 Тримайте ритм! До нового етапу ${7 - currentDays} дн.';
    if (currentDays < 14) return '⚡ Ви на вогні! До пекла ${14 - currentDays} дн.';
    if (currentDays < 30) return '🔥 Inferno mode! До потрійного полум\'я ${30 - currentDays} дн.';
    if (currentDays < 60) return '👑 Золота зона! ${60 - currentDays} дн до золотого полум\'я.';
    if (currentDays < 90) return '🌟 Золотий вогонь! ${90 - currentDays} дн до веселки!';
    return '🌈 Ви — легенда! Продовжуйте!';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація вогню серії (Streak Fire Configuration)
// ═══════════════════════════════════════════════════════════════════════════

/// Клас конфігурації для віджету вогню серії.
///
/// Об'єднує всі налаштування в один об'єкт для зручного
/// управління та повторного використання.
///
/// Приклад створення:
/// ```dart
/// final config = StreakFireConfig(
///   isLightTheme: true,
///   showHeatWave: true,
///   showAnimatedCounter: true,
/// );
/// ```
class StreakFireConfig {
  /// Створює конфігурацію з усіма параметрами.
  const StreakFireConfig({
    this.isLightTheme = false,
    this.showLabel = true,
    this.showMilestoneLabel = false,
    this.showDescription = false,
    this.animateGrowth = true,
    this.size = 28.0,
    this.showHeatWave = false,
    this.showAnimatedCounter = false,
    this.fireTheme,
  });

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Показувати напис "серія" під числом.
  final bool showLabel;

  /// Показувати назву етапу.
  final bool showMilestoneLabel;

  /// Показувати опис етапу.
  final bool showDescription;

  /// Анімувати зростання.
  final bool animateGrowth;

  /// Базовий розмір іконки.
  final double size;

  /// Показувати хвильовий ефект.
  final bool showHeatWave;

  /// Показувати анімований лічильник.
  final bool showAnimatedCounter;

  /// Кастомна тема вогню.
  final FireTheme? fireTheme;

  /// Створює розширену конфігурацію з описом.
  const StreakFireConfig.expanded({
    this.isLightTheme = false,
    this.showLabel = true,
    this.showMilestoneLabel = true,
    this.showDescription = true,
    this.animateGrowth = true,
    this.size = 28.0,
    this.showHeatWave = true,
    this.showAnimatedCounter = true,
    this.fireTheme,
  });

  /// Створює мінімальну конфігурацію.
  const StreakFireConfig.minimal({
    this.isLightTheme = false,
    this.showLabel = true,
    this.showMilestoneLabel = false,
    this.showDescription = false,
    this.animateGrowth = false,
    this.size = 20.0,
    this.showHeatWave = false,
    this.showAnimatedCounter = false,
    this.fireTheme,
  });

  /// Створює копію конфігурації з перевизначенням.
  StreakFireConfig copyWith({
    bool? isLightTheme,
    bool? showLabel,
    bool? showMilestoneLabel,
    bool? showDescription,
    bool? animateGrowth,
    double? size,
    bool? showHeatWave,
    bool? showAnimatedCounter,
    FireTheme? fireTheme,
  }) {
    return StreakFireConfig(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      showLabel: showLabel ?? this.showLabel,
      showMilestoneLabel: showMilestoneLabel ?? this.showMilestoneLabel,
      showDescription: showDescription ?? this.showDescription,
      animateGrowth: animateGrowth ?? this.animateGrowth,
      size: size ?? this.size,
      showHeatWave: showHeatWave ?? this.showHeatWave,
      showAnimatedCounter: showAnimatedCounter ?? this.showAnimatedCounter,
      fireTheme: fireTheme ?? this.fireTheme,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakFireConfig &&
          runtimeType == other.runtimeType &&
          isLightTheme == other.isLightTheme &&
          showLabel == other.showLabel &&
          showMilestoneLabel == other.showMilestoneLabel &&
          showDescription == other.showDescription &&
          animateGrowth == other.animateGrowth &&
          size == other.size &&
          showHeatWave == other.showHeatWave &&
          showAnimatedCounter == other.showAnimatedCounter &&
          fireTheme == other.fireTheme;

  @override
  int get hashCode => Object.hash(
        isLightTheme,
        showLabel,
        showMilestoneLabel,
        showDescription,
        animateGrowth,
        size,
        showHeatWave,
        showAnimatedCounter,
        fireTheme,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Предвизначені конфігурації (Preset Configurations)
// ═══════════════════════════════════════════════════════════════════════════

/// Передвизначені конфігурації для вогню серії.
///
/// Дозволяє швидко обрати потрібний стиль відображення.
class StreakFireConfigs {
  StreakFireConfigs._();

  /// Стандартна конфігурація для темної теми PS5.
  static const StreakFireConfig ps5 = StreakFireConfig(
    isLightTheme: false,
    showLabel: true,
  );

  /// Стандартна конфігурація для світлої теми Monitor.
  static const StreakFireConfig monitor = StreakFireConfig(
    isLightTheme: true,
    showLabel: true,
  );

  /// Розширена конфігурація з усіма ефектами.
  static const StreakFireConfig fullEffects = StreakFireConfig.expanded(
    showHeatWave: true,
    showAnimatedCounter: true,
  );

  /// Мінімальна конфігурація без зайвих елементів.
  static const StreakFireConfig minimal = StreakFireConfig.minimal();

  /// Конфігурація з хвильовим ефектом.
  static const StreakFireConfig withHeatWave = StreakFireConfig(
    showHeatWave: true,
  );

  /// Конфігурація з анімованим лічильником.
  static const StreakFireConfig withCounter = StreakFireConfig(
    showAnimatedCounter: true,
  );

  /// Конфігурація для екрана профілю (розширена).
  static const StreakFireConfig profile = StreakFireConfig.expanded(
    size: 36.0,
    showHeatWave: true,
    showAnimatedCounter: true,
  );

  /// Конфігурація для списку (компактна з бейджем).
  static const StreakFireConfig listBadge = StreakFireConfig(
    size: 20.0,
    showLabel: true,
    showMilestoneLabel: false,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення типів (Type Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [FireTheme] з додатковими властивостями.
extension FireThemeExtension on FireTheme {
  /// Чи тема має активний вогонь (не лід).
  bool get hasFlame => this != FireTheme.ice;

  /// Чи тема є максимально досяжною.
  bool get isMaxTier => this == FireTheme.rainbow;

  /// Чи тема використовує градієнтні кольори.
  bool get isGradient => this == FireTheme.rainbow || this == FireTheme.gold;

  /// Повертає темний варіант кольору для тіней.
  Color darken([double amount = 0.3]) {
    return Color.lerp(primaryColor, Colors.black, amount)!;
  }

  /// Повертає світлий варіант кольору для підсвітки.
  Color lighten([double amount = 0.3]) {
    return Color.lerp(primaryColor, Colors.white, amount)!;
  }

  /// Повертає опис теми для сповіщень.
  String notificationText(int days) {
    return '$emoji $name — ${AppStreakFireHelpers.formatDays(days)} поспіль!';
  }

  /// Порівнює дві теми за "рівнем" (по кількості днів).
  int tierLevel() {
    switch (this) {
      case FireTheme.ice:
        return 0;
      case FireTheme.fire:
        return 1;
      case FireTheme.blue:
        return 2;
      case FireTheme.gold:
        return 3;
      case FireTheme.rainbow:
        return 4;
    }
  }
}

/// Розширення для [StreakMilestone] з додатковими властивостями.
extension StreakMilestoneExtension on StreakMilestone {
  /// Чи етап має хоча б один шар полум'я.
  bool get hasFlame => flameLayers > 0;

  /// Чи етап має частинки.
  bool get hasParticles => particleCount > 0;

  /// Чи це максимальний етап.
  bool get isMaxMilestone => this == StreakMilestone.rainbowInferno;

  /// Чи це мінімальний етап.
  bool get isMinMilestone => this == StreakMilestone.starter;

  /// Повертає ширину进度-бару для етапу (0.0–1.0).
  double progressWidth(int currentDays) {
    if (currentDays >= minDays) return 1.0;
    if (minDays == 0) return 1.0;
    // Знаходимо попередній етап
    final allMilestones = StreakMilestone.values.toList()
      ..sort((a, b) => a.minDays.compareTo(b.minDays));
    int prevDays = 0;
    for (final m in allMilestones) {
      if (m.minDays >= minDays) break;
      prevDays = m.minDays;
    }
    final range = minDays - prevDays;
    if (range <= 0) return 1.0;
    return ((currentDays - prevDays) / range).clamp(0.0, 1.0);
  }

  /// Повертає відсоток прогресу текстом.
  String progressText(int currentDays) {
    final progress = progressWidth(currentDays);
    return '${(progress * 100).round()}%';
  }

  /// Кількість повних тижнів у етапі.
  int weeksInMilestone(int currentDays) {
    if (currentDays < minDays) return 0;
    return ((currentDays - minDays) / 7).floor();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідація (Validation)
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатори для параметрів віджету вогню серії.
///
/// Забезпечують безпечні значення для всіх конфігураційних параметрів.
class StreakFireValidators {
  StreakFireValidators._();

  /// Мінімальна кількість днів серії.
  static const int minDays = 0;

  /// Максимальна кількість днів серії (для відображення).
  static const int maxDisplayDays = 9999;

  /// Мінімальний розмір іконки.
  static const double minSize = 12.0;

  /// Максимальний розмір іконки.
  static const double maxSize = 120.0;

  /// Мінімальний множник швидкості анімації.
  static const double minSpeedMultiplier = 0.1;

  /// Максимальний множник швидкості анімації.
  static const double maxSpeedMultiplier = 5.0;

  /// Валідує кількість днів серії.
  ///
  /// Повертає значення в безпечному діапазоні [0, maxDisplayDays].
  static int validateDays(int days) {
    return days.clamp(minDays, maxDisplayDays);
  }

  /// Валідує розмір іконки.
  ///
  /// Повертає значення в безпечному діапазоні.
  static double validateSize(double size) {
    return size.clamp(minSize, maxSize);
  }

  /// Перевіряє чи кількість днів є позитивною.
  static bool isValidDays(int days) {
    return days >= minDays;
  }

  /// Перевіряє чи перехід між етапами валідний.
  static bool isValidTransition(int fromDays, int toDays) {
    return fromDays >= 0 && toDays >= 0 && fromDays != toDays;
  }

  /// Перевіряє чи розрив серії валідний.
  static bool isValidBrokenState(int days, bool isBroken) {
    return isBroken ? days > 0 : true;
  }

  /// Повертає безпечне значення для множника швидкості.
  static double validateSpeedMultiplier(double multiplier) {
    return multiplier.clamp(minSpeedMultiplier, maxSpeedMultiplier);
  }

  /// Обчислює безпечну затримку анімації переходу.
  ///
  /// [steps] — кількість кроків анімації.
  static int validateTransitionSteps(int steps) {
    return steps.clamp(5, 60);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Тема-білдер для вогню (Fire Theme Builder)
// ═══════════════════════════════════════════════════════════════════════════

/// Білдер кастомної теми вогню серії.
///
/// Дозволяє створювати кастомні палітри кольорів
/// для різних стилів вогню.
///
/// Приклад використання:
/// ```dart
/// final theme = FireThemeBuilder()
///   .withPrimaryColor(const Color(0xFFFF5722))
///   .withGlowOpacity(0.5)
///   .build();
/// ```
class FireThemeBuilder {
  /// Створює білдер з початковими значеннями.
  FireThemeBuilder({
    this.primaryColor,
    this.glowColor,
    this.particleColor,
    this.icon = Icons.local_fire_department_rounded,
    this.name = 'Custom',
    this.emoji = '🔥',
    this.glowOpacity = 0.35,
  });

  /// Основний колір вогню.
  final Color? primaryColor;

  /// Колір сяйва.
  final Color? glowColor;

  /// Колір частинок.
  final Color? particleColor;

  /// Іконка для відображення.
  final IconData icon;

  /// Назва теми.
  final String name;

  /// Емодзі теми.
  final String emoji;

  /// Прозорість сяйва (0.0–1.0).
  final double glowOpacity;

  /// Встановлює основний колір.
  FireThemeBuilder withPrimaryColor(Color color) {
    return FireThemeBuilder(
      primaryColor: color,
      glowColor: glowColor,
      particleColor: particleColor,
      icon: icon,
      name: name,
      emoji: emoji,
      glowOpacity: glowOpacity,
    );
  }

  /// Встановлює колір сяйва з автоматичною прозорістю.
  FireThemeBuilder withGlowColor(Color color, [double opacity = 0.35]) {
    return FireThemeBuilder(
      primaryColor: primaryColor,
      glowColor: color.withOpacity(opacity),
      particleColor: particleColor,
      icon: icon,
      name: name,
      emoji: emoji,
      glowOpacity: opacity,
    );
  }

  /// Встановлює колір частинок.
  FireThemeBuilder withParticleColor(Color color) {
    return FireThemeBuilder(
      primaryColor: primaryColor,
      glowColor: glowColor,
      particleColor: color,
      icon: icon,
      name: name,
      emoji: emoji,
      glowOpacity: glowOpacity,
    );
  }

  /// Встановлює іконку.
  FireThemeBuilder withIcon(IconData data) {
    return FireThemeBuilder(
      primaryColor: primaryColor,
      glowColor: glowColor,
      particleColor: particleColor,
      icon: data,
      name: name,
      emoji: emoji,
      glowOpacity: glowOpacity,
    );
  }

  /// Встановлює прозорість сяйва.
  FireThemeBuilder withGlowOpacity(double opacity) {
    return FireThemeBuilder(
      primaryColor: primaryColor,
      glowColor: glowColor,
      particleColor: particleColor,
      icon: icon,
      name: name,
      emoji: emoji,
      glowOpacity: opacity.clamp(0.0, 1.0),
    );
  }

  /// Створює [FireTheme]-сумісний об'єкт для використання з віджетом.
  ///
  /// Повертає кастомну конфігурацію або fallback до стандартної.
  StreakFireConfig buildConfig({bool isLightTheme = false}) {
    return StreakFireConfig(
      isLightTheme: isLightTheme,
      fireTheme: primaryColor != null
          ? _buildFireTheme()
          : null,
    );
  }

  /// Створює кастомний [FireTheme]-подібний об'єкт.
  ///
  /// Оскільки [FireTheme] є enum, повертає найближчий стандартний.
  FireTheme buildFireTheme() {
    if (primaryColor == null) return FireTheme.fire;
    // Знаходимо найближчий за основним кольором
    final themes = FireTheme.values;
    for (final theme in themes) {
      if (_colorDistance(primaryColor!, theme.primaryColor) < 50) {
        return theme;
      }
    }
    return FireTheme.fire;
  }

  /// Обчислює відстань між двома кольорами (Euclidean).
  double _colorDistance(Color a, Color b) {
    final dr = a.red - b.red;
    final dg = a.green - b.green;
    final db = a.blue - b.blue;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  @override
  String toString() =>
      'FireThemeBuilder(name: $name, '
      'primaryColor: $primaryColor, '
      'glowOpacity: $glowOpacity)';
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація серії (Streak Configuration)
// ═══════════════════════════════════════════════════════════════════════════

/// Незмінна конфігурація для віджета вогню серії.
///
/// Об'єднує всі параметри в один об'єкт для зручного управління.
///
/// Приклад:
/// ```dart
/// final config = StreakFireConfig(
///   isLightTheme: true,
///   showHeatWave: true,
///   size: 32.0,
/// );
/// ```
class StreakFireConfig {
  const StreakFireConfig({
    this.isLightTheme = false,
    this.isBroken = false,
    this.showLabel = true,
    this.showMilestoneLabel = false,
    this.showDescription = false,
    this.animateGrowth = true,
    this.size = 28.0,
    this.fireTheme,
    this.showHeatWave = false,
    this.showAnimatedCounter = false,
    this.enableHapticOnTap = false,
    this.maxSize = 80.0,
    this.minSize = 16.0,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Чи розірвана серія.
  final bool isBroken;

  /// Показувати напис "серія".
  final bool showLabel;

  /// Показувати назву етапу.
  final bool showMilestoneLabel;

  /// Показувати опис етапу.
  final bool showDescription;

  /// Анімувати зростання.
  final bool animateGrowth;

  /// Базовий розмір.
  final double size;

  /// Кастомна тема вогню.
  final FireTheme? fireTheme;

  /// Показувати хвильовий ефект.
  final bool showHeatWave;

  /// Показувати анімований лічильник.
  final bool showAnimatedCounter;

  /// Тактильний відгук при натисканні.
  final bool enableHapticOnTap;

  /// Максимальний розмір.
  final double maxSize;

  /// Мінімальний розмір.
  final double minSize;

  /// Створює копію з перевизначенням.
  StreakFireConfig copyWith({
    bool? isLightTheme,
    bool? isBroken,
    bool? showLabel,
    bool? showMilestoneLabel,
    bool? showDescription,
    bool? animateGrowth,
    double? size,
    FireTheme? fireTheme,
    bool? showHeatWave,
    bool? showAnimatedCounter,
    bool? enableHapticOnTap,
  }) {
    return StreakFireConfig(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      isBroken: isBroken ?? this.isBroken,
      showLabel: showLabel ?? this.showLabel,
      showMilestoneLabel: showMilestoneLabel ?? this.showMilestoneLabel,
      showDescription: showDescription ?? this.showDescription,
      animateGrowth: animateGrowth ?? this.animateGrowth,
      size: size ?? this.size,
      fireTheme: fireTheme ?? this.fireTheme,
      showHeatWave: showHeatWave ?? this.showHeatWave,
      showAnimatedCounter: showAnimatedCounter ?? this.showAnimatedCounter,
      enableHapticOnTap: enableHapticOnTap ?? this.enableHapticOnTap,
    );
  }

  /// Обмежує розмір в межах min/max.
  double get clampedSize => size.clamp(minSize, maxSize);

  /// Створює AppStreakFire з цією конфігурацією.
  AppStreakFire build({
    required int streakDays,
    int? previousStreakDays,
    VoidCallback? onTap,
  }) {
    return AppStreakFire(
      streakDays: streakDays,
      isLightTheme: isLightTheme,
      isBroken: isBroken,
      showLabel: showLabel,
      showMilestoneLabel: showMilestoneLabel,
      showDescription: showDescription,
      animateGrowth: animateGrowth,
      size: clampedSize,
      onTap: onTap,
      fireTheme: fireTheme,
      showHeatWave: showHeatWave,
      showAnimatedCounter: showAnimatedCounter,
      previousStreakDays: previousStreakDays,
    );
  }

  /// Створює компактний вигляд (тільки число).
  StreakFireConfig compact() => copyWith(
        showLabel: false,
        showMilestoneLabel: false,
        showDescription: false,
        showHeatWave: false,
        size: 22.0,
      );

  /// Створює розширений вигляд (з описом).
  StreakFireConfig expanded() => copyWith(
        showLabel: true,
        showMilestoneLabel: true,
        showDescription: true,
        showHeatWave: true,
        showAnimatedCounter: true,
        size: 36.0,
      );

  /// Створює вигляд для розірваної серії.
  StreakFireConfig broken() => copyWith(
        isBroken: true,
        showHeatWave: false,
        showAnimatedCounter: false,
      );

  @override
  String toString() =>
      'StreakFireConfig(size: $size, broken: $isBroken, '
      'theme: ${fireTheme?.name ?? "auto"})';
}

// ═══════════════════════════════════════════════════════════════════════════
// Предвизначені конфігурації серії (Streak Presets)
// ═══════════════════════════════════════════════════════════════════════════

/// Предвизначені конфігурації для типових випадків.
class StreakFirePresets {
  StreakFirePresets._();

  /// Компактний вигляд для списків.
  static const StreakFireConfig compact = StreakFireConfig(
    showLabel: false,
    showMilestoneLabel: false,
    showDescription: false,
    size: 20.0,
  );

  /// Стандартний вигляд для карток.
  static const StreakFireConfig standard = StreakFireConfig(
    showLabel: true,
    showMilestoneLabel: false,
    size: 28.0,
  );

  /// Розширений вигляд для детальної сторінки.
  static const StreakFireConfig detailed = StreakFireConfig(
    showLabel: true,
    showMilestoneLabel: true,
    showDescription: true,
    showHeatWave: true,
    size: 36.0,
  );

  /// Геройський вигляд для головного екрана.
  static const StreakFireConfig hero = StreakFireConfig(
    showLabel: true,
    showMilestoneLabel: true,
    showDescription: true,
    showHeatWave: true,
    showAnimatedCounter: true,
    size: 48.0,
  );

  /// Розірвана серія.
  static const StreakFireConfig broken = StreakFireConfig(
    isBroken: true,
    showHeatWave: false,
    showAnimatedCounter: false,
    size: 28.0,
  );

  /// Мінімальний вигляд для бейджів.
  static const StreakFireConfig badge = StreakFireConfig(
    showLabel: false,
    size: 16.0,
    minSize: 12.0,
    maxSize: 24.0,
  );

  /// Повертає конфігурацію залежно від кількості днів.
  static StreakFireConfig forDays(int days) {
    if (days >= 30) return detailed;
    if (days >= 7) return standard;
    if (days >= 3) return standard;
    return compact;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Калькулятор прогресу серії (Streak Progress Calculator)
// ═══════════════════════════════════════════════════════════════════════════

/// Калькулятор прогресу серії між етапами.
///
/// Обчислює прогрес, відсоток, XP-бонуси та інші метрики.
class StreakProgressCalculator {
  StreakProgressCalculator({required this.currentDays});

  /// Поточна кількість днів серії.
  final int currentDays;

  /// Поточний етап серії.
  StreakMilestone get milestone => StreakMilestone.fromDays(currentDays);

  /// Наступний етап серії.
  StreakMilestone get nextMilestone => StreakMilestone.nextMilestone(currentDays);

  /// Днів до наступного етапу (0 = максимальний).
  int get daysToNext => milestone.daysToNext(currentDays);

  /// Прогрес до наступного етапу (0.0–1.0).
  ///
  /// Обчислюється відносно діапазону між поточним та наступним етапом.
  double get progressToNext {
    if (daysToNext == 0) return 1.0;
    final rangeStart = milestone.minDays;
    final rangeEnd = nextMilestone.minDays;
    final range = rangeEnd - rangeStart;
    if (range <= 0) return 1.0;
    return ((currentDays - rangeStart) / range).clamp(0.0, 1.0);
  }

  /// Загальний XP-бонус за поточний етап.
  int get xpBonus => milestone.xpBonus;

  /// Загальний XP за всі досягнуті етапи.
  int get totalXpEarned {
    var total = 0;
    for (final ms in StreakMilestone.values) {
      if (ms.minDays < currentDays) {
        total += ms.xpBonus;
      }
    }
    return total;
  }

  /// XP-бонус за наступний етап.
  int get nextXpBonus => nextMilestone.xpBonus;

  /// Загальна кількість завершених етапів.
  int get completedMilestones {
    var count = 0;
    for (final ms in StreakMilestone.values) {
      if (currentDays >= ms.minDays) count++;
    }
    return count;
  }

  /// Загальна кількість етапів.
  int get totalMilestones => StreakMilestone.values.length;

  /// Відсоток завершених етапів (0.0–1.0).
  double get milestoneProgress {
    if (totalMilestones == 0) return 0.0;
    return completedMilestones / totalMilestones;
  }

  /// Чи на максимальному етапі.
  bool get isMaxMilestone => daysToNext == 0;

  /// Чи серія тільки почалась.
  bool get isStarter => currentDays < 3;

  /// Чи серія активна (≥ 3 дні).
  bool get isActive => currentDays >= 3;

  /// Інтенсивність вогню (0.0–1.0).
  double get intensity => milestone.intensity;

  /// Опис прогресу для відображення.
  String get progressDescription {
    if (isMaxMilestone) {
      return '${milestone.emoji} Максимальний етап: ${milestone.label}';
    }
    return '${milestone.emoji} ${milestone.label} — ще $daysToNext днів до ${nextMilestone.label}';
  }

  /// Повертає текст прогресу для сповіщення.
  String notificationText() {
    if (currentDays == 0) return '🌱 Почніть нову серію заощаджень!';
    if (isStarter) return '🌱 $currentDays днів. Продовжуйте щоденно!';
    return '${milestone.emoji} Серія: ${AppStreakFireHelpers.formatDays(currentDays)} — ${milestone.label}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор серії (Streak Validator)
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатор параметрів серії.
///
/// Перевіряє коректність значень перед створенням віджета.
class StreakValidator {
  StreakValidator._();

  /// Перевіряє кількість днів серії.
  static String? validateDays(int days) {
    if (days < 0) return 'Кількість днів не може бути від\'ємною';
    if (days > 3650) return 'Кількість днів перевищує максимальне значення (3650)';
    return null;
  }

  /// Перевіряє розмір віджета.
  static String? validateSize(double size) {
    if (size <= 0) return 'Розмір повинен бути > 0';
    if (size > 200) return 'Розмір занадто великий (макс: 200)';
    return null;
  }

  /// Перевіряє множник швидкості.
  static String? validateSpeed(double speed) {
    if (speed <= 0) return 'Швидкість повинна бути > 0';
    if (speed > 5.0) return 'Швидкість занадто велика (макс: 5.0)';
    return null;
  }

  /// Перевіряє затримку анімації.
  static String? validateDelay(double delay) {
    if (delay < 0) return 'Затримка не може бути від\'ємною';
    if (delay > 3.0) return 'Затримка занадто велика (макс: 3.0с)';
    return null;
  }

  /// Повна валідація всіх параметрів.
  static List<String> validateAll({
    required int days,
    required double size,
    double speed = 1.0,
    double delay = 0.0,
  }) {
    final errors = <String>[];
    final d = validateDays(days);
    if (d != null) errors.add(d);
    final s = validateSize(size);
    if (s != null) errors.add(s);
    final sp = validateSpeed(speed);
    if (sp != null) errors.add(sp);
    final dl = validateDelay(delay);
    if (dl != null) errors.add(dl);
    return errors;
  }

  /// Швидка перевірка без деталей.
  static bool isValid({required int days, required double size}) {
    return validateDays(days) == null && validateSize(size) == null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Метрики серії (Streak Metrics)
// ═══════════════════════════════════════════════════════════════════════════

/// Збирає та обчислює метрики серії.
class StreakMetrics {
  StreakMetrics({
    required this.currentStreak,
    required this.bestStreak,
    this.totalDaysActive = 0,
    this.totalContributions = 0,
    this.averageStreak = 0.0,
  });

  /// Поточна серія в днях.
  final int currentStreak;

  /// Найкраща серія в днях.
  final int bestStreak;

  /// Загальна кількість активних днів.
  final int totalDaysActive;

  /// Загальна кількість внесків.
  final int totalContributions;

  /// Середня серія.
  final double averageStreak;

  /// Відсоток від рекорду (0.0–1.0).
  double get recordPercentage {
    if (bestStreak <= 0) return 0.0;
    return (currentStreak / bestStreak).clamp(0.0, 1.0);
  }

  /// Чи новий рекорд.
  bool get isNewRecord => currentStreak >= bestStreak && currentStreak > 0;

  /// Чи близько до рекорду (≥ 80%).
  bool get isNearRecord => recordPercentage >= 0.8 && !isNewRecord;

  /// Днів до нового рекорду (0 = вже рекорд).
  int get daysToRecord {
    if (isNewRecord) return 0;
    return bestStreak - currentStreak;
  }

  /// Поточний етап.
  StreakMilestone get currentMilestone => StreakMilestone.fromDays(currentStreak);

  /// Етап найкращої серії.
  StreakMilestone get bestMilestone => StreakMilestone.fromDays(bestStreak);

  /// Коефіцієнт стабільності (0.0–1.0).
  ///
  /// Відношення активних днів до загальної кількості днів.
  double stabilityFactor({int totalDays = 365}) {
    if (totalDays <= 0) return 0.0;
    return (totalDaysActive / totalDays).clamp(0.0, 1.0);
  }

  /// Формує текстовий звіт.
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('🔥 Звіт серії:');
    buffer.writeln('  Поточна серія: $currentStreak днів');
    buffer.writeln('  Найкраща серія: $bestStreak днів');
    buffer.writeln('  Активних днів: $totalDaysActive');
    buffer.writeln('  Внесків: $totalContributions');
    buffer.writeln('  Середня серія: ${averageStreak.toStringAsFixed(1)}');
    buffer.writeln('  Етап: ${currentMilestone.label}');
    if (daysToRecord > 0) {
      buffer.writeln('  До рекорду: $daysToRecord днів');
    } else {
      buffer.writeln('  🏆 Новий рекорд!');
    }
    return buffer.toString();
  }
}
