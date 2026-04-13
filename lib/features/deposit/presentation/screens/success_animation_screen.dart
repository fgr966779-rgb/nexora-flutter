import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_confetti.dart';

/// Повноекранний оверлей успішного внеску з багаторівневою анімацією.
///
/// Фази анімації:
/// 1. Напівпрозорий фоновий оверлей з fade-in
/// 2. Checkmark icon у колі: bounce-in (scale 0→1.2→1.0, 500ms, spring)
/// 3. "+[amount] грн додано!" title (slide-up + fade, delay 250ms)
/// 4. "XP +10 | Монети +5" display (slide-up + fade, delay 400ms)
/// 5. Стрик-індикатор (fade-in, delay 700ms)
/// 6. Підказка "Натисни, щоб закрити" (fade-in, delay 1200ms)
///
/// Features:
/// - Auto-dismiss через 2.5 секунди
/// - Tap anywhere to dismiss
/// - Fade-out animation on dismiss
/// - Success glow ring animation (expand + fade)
/// - Secondary pulse ring animation
/// - Haptic success pattern
/// - Configurable amount, xp, coins via constructor
class SuccessAnimationOverlay extends StatefulWidget {
  const SuccessAnimationOverlay({
    super.key,
    required this.amount,
    this.xpEarned = 10,
    this.coinsEarned = 5,
    this.currentStreak = 0,
    this.onDismiss,
  });

  final double amount;
  final int xpEarned;
  final int coinsEarned;
  final int currentStreak;
  final VoidCallback? onDismiss;

  /// Показує оверлей успіху як OverlayEntry.
  static OverlayEntry show(
    BuildContext context, {
    required double amount,
    int xpEarned = 10,
    int coinsEarned = 5,
    int currentStreak = 0,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => SuccessAnimationOverlay(
        amount: amount,
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        currentStreak: currentStreak,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);

    // Автоматичне закриття через 2.5 секунди
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (entry.mounted) entry.remove();
    });

    return entry;
  }

  @override
  State<SuccessAnimationOverlay> createState() =>
      _SuccessAnimationOverlayState();
}

class _SuccessAnimationOverlayState extends State<SuccessAnimationOverlay>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────
  late AnimationController _circleController;
  late AnimationController _checkController;
  late AnimationController _particleController;
  late AnimationController _glowRingController;
  late AnimationController _secondaryRingController;
  late AnimationController _dismissController;
  late AnimationController _pulseController;

  OverlayEntry? _confettiEntry;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    // ── Контролер для фону кола (fade-in + scale, 500ms) ────
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // ── Контролер для галочки (bounce-in з затримкою) ──────────
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _checkController.forward();
    });

    // ── Контролер для частинок (XP/монети fly-in) ────────────
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _particleController.forward();
    });

    // ── Primary glow ring animation (expand + fade, 1500ms) ───
    _glowRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _glowRingController.forward();
    });

    // ── Secondary pulse ring (delayed, 2000ms, repeat) ────────
    _secondaryRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _secondaryRingController.forward();
    });

    // ── Pulse effect on checkmark circle ──────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // ── Dismiss fade-out controller (300ms) ────────────────────
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // ── Haptic success pattern ────────────────────────────────
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticService.success();
    });

    // ── Показати конфетті з невеликою затримкою ────────────────
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _confettiEntry = AppConfetti.show(context: context);
      }
    });
  }

  @override
  void dispose() {
    _confettiEntry?.remove();
    _circleController.dispose();
    _checkController.dispose();
    _particleController.dispose();
    _glowRingController.dispose();
    _secondaryRingController.dispose();
    _dismissController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    HapticService.lightTap();
    _dismissController.forward().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _dismissController,
        builder: (context, _) {
          final dismissOpacity = 1.0 - _dismissController.value;
          final dismissScale =
              1.0 - _dismissController.value * 0.05;

          return Opacity(
            opacity: dismissOpacity,
            child: Transform.scale(
              scale: dismissScale,
              child: GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.black.withOpacity(0.6 * dismissOpacity),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),

                          // ── Secondary glow ring (delayed) ────────
                          _buildSecondaryRing(),

                          const SizedBox(height: 4),

                          // ── Primary glow ring ────────────────────
                          _buildPrimaryGlowRing(),

                          // ── Checkmark circle with bounce-in ────
                          _buildCheckmarkCircle(),

                          const SizedBox(height: Spacing.xxl),

                          // ── Amount text (slide-up + fade) ────────
                          _buildAmountText(),

                          const SizedBox(height: Spacing.base),

                          // ── XP and Coins badges (fly-in) ───────
                          _buildRewardBadges(),

                          // ── Streak indicator ────────────────────
                          if (widget.currentStreak > 0) ...[
                            const SizedBox(height: Spacing.base),
                            _buildStreakIndicator(),
                          ],

                          // ── Dismiss hint ───────────────────────
                          const SizedBox(height: Spacing.xxl),
                          _buildDismissHint(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Widget builders
  // ══════════════════════════════════════════════════════════════════

  /// Primary expanding glow ring behind checkmark circle.
  /// Анімація: кільце розширюється та зникає (1500ms, repeat).
  Widget _buildPrimaryGlowRing() {
    return AnimatedBuilder(
      animation: _glowRingController,
      builder: (context, _) {
        final t = _glowRingController.value;
        final ringSize = 120.0 + t * 50;
        final ringOpacity = (1.0 - t).clamp(0.0, 0.6);

        return Container(
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColorsPS5.success.withOpacity(ringOpacity),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColorsPS5.success.withOpacity(ringOpacity * 0.5),
                blurRadius: 20 + t * 30,
                spreadRadius: 4 + t * 10,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Secondary delayed glow ring — ефект хвилі.
  Widget _buildSecondaryRing() {
    return AnimatedBuilder(
      animation: _secondaryRingController,
      builder: (context, _) {
        final t = _secondaryRingController.value;
        final ringSize = 140.0 + t * 60;
        final ringOpacity = (1.0 - t).clamp(0.0, 0.3);

        return Container(
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColorsPS5.success.withOpacity(ringOpacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }

  /// Зелене коло з галочкою, bounce-in анімація (scale 0→1.2→1.0, 500ms, spring).
  /// Зміщується з subtle pulse-ефектом після появи.
  Widget _buildCheckmarkCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_circleController, _pulseController]),
      builder: (context, circleChild) {
        final circleT = _circleController.value;
        // Bounce curve: 0 → 1.2 → 1.0
        final circleScale = circleT < 0.6
            ? (circleT / 0.6) * 1.2
            : 1.2 - ((circleT - 0.6) / 0.4) * 0.2;

        // Subtle pulse after appearance
        final pulseT = _pulseController.value;
        final pulseScale = 1.0 + pulseT * 0.03;

        return AnimatedBuilder(
          animation: _checkController,
          builder: (context, checkChild) {
            final checkScale = Curves.elasticOut.transform(
              _checkController.value.clamp(0.0, 1.0),
            );

            final finalScale = math.max(circleScale, 0.0) *
                checkScale *
                pulseScale;

            // Dynamic glow based on pulse
            final glowSpread = 8.0 + pulseT * 6.0;
            final glowBlur = 32.0 + pulseT * 12.0;

            return Transform.scale(
              scale: finalScale,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorsPS5.success,
                      AppColorsPS5.success.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    // Primary shadow
                    BoxShadow(
                      color: AppColorsPS5.success.withOpacity(0.4),
                      blurRadius: glowBlur,
                      spreadRadius: glowSpread,
                    ),
                    // Wide glow
                    BoxShadow(
                      color: AppColorsPS5.success.withOpacity(0.2),
                      blurRadius: 60 + pulseT * 20,
                      spreadRadius: 16 + pulseT * 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            );
          },
          child: const SizedBox.shrink(),
        );
      },
    );
  }

  /// Текст «+[amount] грн додано!» з slide-up та fade-in.
  /// Анімація починається через 250ms.
  Widget _buildAmountText() {
    return Text(
      '+${widget.amount.formatUAH()} грн додано!',
      style: AppTypography.displayMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 26,
        shadows: [
          Shadow(
            color: AppColorsPS5.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: 250.ms)
        .slideY(
          begin: 0.35,
          end: 0,
          duration: 350.ms,
          delay: 250.ms,
          curve: AppEasings.decelerate,
        );
  }

  /// Бейджі XP та Монети з fly-анімацією знизу вгору.
  /// XP з'являється через 400ms, Монети — через 600ms.
  Widget _buildRewardBadges() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final t = _particleController.value;
        // Fly-in from below with easing
        final easedT = Curves.easeOut.transform(t);
        return Transform.translate(
          offset: Offset(0, 24 * (1 - easedT)),
          child: Opacity(
            opacity: easedT.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // XP badge
          _buildRewardBadge(
            icon: Icons.star_rounded,
            label: 'XP +${widget.xpEarned}',
            color: AppColorsPS5.xp,
            delay: 400,
          ),
          const SizedBox(width: Spacing.sm),
          // Divider between badges
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(width: Spacing.sm),
          // Coins badge
          _buildRewardBadge(
            icon: Icons.monetization_on_rounded,
            label: 'Монети +${widget.coinsEarned}',
            color: AppColorsPS5.coin,
            delay: 600,
          ),
        ],
      ),
    );
  }

  /// Один бейдж нагороди з fly-анімацією (scale 0.7→1.0 + fade-in).
  /// Містить іконку, текст та кольорову рамку.
  Widget _buildRewardBadge({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with subtle glow
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: Spacing.xs),
          // Label text
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: delay.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: delay.ms,
          curve: AppEasings.spring,
        );
  }

  /// Індикатор серії, що з'являється якщо currentStreak > 0.
  /// Показує іконку вогню та текст «X день поспіль».
  Widget _buildStreakIndicator() {
    final streak = widget.currentStreak;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fire icon with glow
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColorsPS5.coin.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColorsPS5.coin.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: AppColorsPS5.coin,
            size: 16,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        // Streak text
        Text(
          'Серія: $streak ${streak.pluralUAH('день', 'дні', 'днів')} поспіль!',
          style: AppTypography.labelMedium.copyWith(
            color: AppColorsPS5.coin,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 700.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 350.ms,
          delay: 700.ms,
          curve: AppEasings.decelerate,
        );
  }

  /// Тонкий підказка «Натисни, щоб закрити» в нижній частині.
  /// З'являється через 1200ms з плавним fade-in.
  Widget _buildDismissHint() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated tap icon
        Icon(
          Icons.touch_app_rounded,
          color: Colors.white.withOpacity(0.2),
          size: 14,
        ).animate().fadeIn(
          duration: 400.ms,
          delay: 1200.ms,
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          'Натисни, щоб закрити',
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Additional widget builders (extended)
  // ══════════════════════════════════════════════════════════════════

  /// Будує анімований фон з частинками (sparkle-ефект).
  ///
  /// Показує кілька дрібних кружечків, що розлітаються від центру.
  Widget _buildSparkleParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        final t = _particleController.value;
        final easedT = Curves.easeOut.transform(t);
        return Stack(
          children: List.generate(8, (index) {
            final angle = (index / 8) * 2 * math.pi;
            final distance = 40.0 + 80.0 * easedT;
            final x = math.cos(angle) * distance;
            final y = math.sin(angle) * distance;
            final particleOpacity = (1.0 - easedT).clamp(0.0, 0.8);
            final particleSize = 3.0 + 2.0 * (1.0 - easedT);
            return Positioned(
              left: x - particleSize / 2,
              top: y - particleSize / 2,
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorsPS5.success.withOpacity(particleOpacity),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsPS5.success.withOpacity(
                          particleOpacity * 0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// Будує кільце прогресу навколо галочки.
  ///
  /// Показує круговий прогрес завершення операції.
  Widget _buildProgressRing() {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, _) {
        final t = _checkController.value;
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColorsPS5.success.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: CustomPaint(
            painter: _SuccessProgressPainter(
              progress: t,
              color: AppColorsPS5.success,
              strokeWidth: 2.5,
            ),
          ),
        );
      },
    );
  }

  /// Будує badge «Новий рівень!» якщо було підвищення.
  ///
  /// З'являється з анімацією масштабу.
  Widget _buildLevelUpBadge() {
    if (widget.currentStreak < 7) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColorsPS5.coin.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: AppColorsPS5.coin.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsPS5.coin.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColorsPS5.coin,
            size: 18,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            'Майстер внесків!',
            style: AppTypography.labelMedium.copyWith(
              color: AppColorsPS5.coin,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 900.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          delay: 900.ms,
          curve: AppEasings.spring,
        );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Success Progress Ring Painter
// ═══════════════════════════════════════════════════════════════════════════

/// Кастомний painter для кільця прогресу навколо галочки успіху.
///
/// Малює дугу, що заповнюється по мірі прогресу анімації (0.0 → 1.0).
class _SuccessProgressPainter extends CustomPainter {
  /// Поточний прогрес (0.0 — 1.0).
  final double progress;

  /// Колір кільця.
  final Color color;

  /// Товщина лінії кільця.
  final double strokeWidth;

  _SuccessProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Фонове кільце
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Прогрес-дуга
    final progressPaint = Paint()
      ..color = color
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
  }

  @override
  bool shouldRepaint(_SuccessProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Success Animation Constants
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для анімації успішного внеску.
///
/// Включає тривалості, розміри, затримки та порогові значення.
class SuccessAnimationConstants {
  /// Константа — не дозволяємо створювати екземпляри.
  SuccessAnimationConstants._();

  /// Тривалість анімації кола фону.
  static const Duration circleAnimationDuration = Duration(milliseconds: 500);

  /// Тривалість bounce-анімації галочки.
  static const Duration checkBounceDuration = Duration(milliseconds: 600);

  /// Затримка перед bounce галочки.
  static const Duration checkBounceDelay = Duration(milliseconds: 150);

  /// Тривалість анімації частинок.
  static const Duration particleAnimationDuration = Duration(milliseconds: 800);

  /// Затримка перед анімацією частинок.
  static const Duration particleAnimationDelay = Duration(milliseconds: 400);

  /// Тривалість кільця glow.
  static const Duration glowRingDuration = Duration(milliseconds: 1500);

  /// Тривалість вторинного кільця.
  static const Duration secondaryRingDuration = Duration(milliseconds: 2000);

  /// Затримка вторинного кільця.
  static const Duration secondaryRingDelay = Duration(milliseconds: 600);

  /// Тривалість пульсації.
  static const Duration pulseDuration = Duration(milliseconds: 1200);

  /// Тривалість анімації закриття.
  static const Duration dismissAnimationDuration = Duration(milliseconds: 300);

  /// Тривалість автозакриття.
  static const Duration autoDismissDuration = Duration(milliseconds: 2500);

  /// Затримка тактильного відгуку.
  static const Duration hapticDelay = Duration(milliseconds: 100);

  /// Затримка показу конфетті.
  static const Duration confettiDelay = Duration(milliseconds: 250);

  /// Розмір кола галочки (діаметр).
  static const double checkmarkCircleSize = 96.0;

  /// Розмір іконки галочки.
  static const double checkmarkIconSize = 52.0;

  /// Розмір primary glow ring (початковий).
  static const double primaryGlowRingBase = 120.0;

  /// Розмір розширення primary glow ring.
  static const double primaryGlowRingExpansion = 50.0;

  /// Розмір secondary ring (початковий).
  static const double secondaryRingBase = 140.0;

  /// Розмір розширення secondary ring.
  static const double secondaryRingExpansion = 60.0;

  /// Товщина лінії primary glow ring.
  static const double primaryRingStrokeWidth = 2.5;

  /// Товщина лінії secondary ring.
  static const double secondaryRingStrokeWidth = 1.5;

  /// Максимальна непрозорість primary ring.
  static const double primaryRingMaxOpacity = 0.6;

  /// Максимальна непрозорість secondary ring.
  static const double secondaryRingMaxOpacity = 0.3;

  /// Непрозорість фонового оверлея.
  static const double backdropOpacity = 0.6;

  /// Розмір тексту суми.
  static const double amountTextFontSize = 26.0;

  /// Затримка появи тексту суми.
  static const Duration amountTextDelay = Duration(milliseconds: 250);

  /// Тривалість анімації тексту суми.
  static const Duration amountTextDuration = Duration(milliseconds: 350);

  /// Відступ зсуву тексту суми (початковий).
  static const double amountTextSlideBegin = 0.35;

  /// Затримка появи XP badge.
  static const Duration xpBadgeDelay = Duration(milliseconds: 400);

  /// Затримка появи Coins badge.
  static const Duration coinsBadgeDelay = Duration(milliseconds: 600);

  /// Тривалість анімації badge.
  static const Duration badgeFadeDuration = Duration(milliseconds: 350);

  /// Тривалість масштабування badge.
  static const Duration badgeScaleDuration = Duration(milliseconds: 400);

  /// Початковий масштаб badge.
  static const double badgeScaleBegin = 0.7;

  /// Затримка появи streak indicator.
  static const Duration streakDelay = Duration(milliseconds: 700);

  /// Затримка появи підказки закриття.
  static const Duration dismissHintDelay = Duration(milliseconds: 1200);

  /// Тривалість fade підказки.
  static const Duration dismissHintFadeDuration = Duration(milliseconds: 400);

  /// Розмір іконки підказки.
  static const double dismissHintIconSize = 14.0;

  /// Кількість sparkle-частинок.
  static const int sparkleParticleCount = 8;

  /// Мінімальна дистанція частинки від центру.
  static const double sparkleMinDistance = 40.0;

  /// Максимальна дистанція частинки від центру.
  static const double sparkleMaxDistance = 120.0;

  /// Мінімальний розмір частинки.
  static const double sparkleMinSize = 3.0;

  /// Максимальний розмір частинки.
  static const double sparkleMaxSize = 5.0;

  /// Мінімальна streak для показу «Майстер внесків» badge.
  static const int masterStreakThreshold = 7;

  /// Непрозорість backdrop при закритті (зменшується).
  static const double dismissScaleReduction = 0.05;

  /// Розмір контейнера progress ring.
  static const double progressRingSize = 110.0;

  /// Товщина лінії progress ring.
  static const double progressRingStrokeWidth = 2.5;
}

// ═══════════════════════════════════════════════════════════════════════════
// Success Theme Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Тематичні допоміжні методи для анімації успіху.
///
/// Надає доступ до кольорів, градієнтів та стилів.
class SuccessThemeHelper {
  /// Константа — не дозволяємо створювати екземпляри.
  SuccessThemeHelper._();

  /// Повертає градієнт для кола галочки.
  static LinearGradient checkmarkGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColorsPS5.success,
        Color(0xFF2ECC71),
      ],
    );
  }

  /// Повертає колір фону оверлея.
  static Color backdropColor(double opacity) {
    return Colors.black.withOpacity(opacity);
  }

  /// Повертає колір тіні glow.
  static Color glowShadowColor(double opacity) {
    return AppColorsPS5.success.withOpacity(opacity);
  }

  /// Повертає стиль тіні для галочки.
  static List<BoxShadow> checkmarkShadows({
    required double pulseT,
    double baseOpacity = 0.4,
    double wideOpacity = 0.2,
  }) {
    return [
      BoxShadow(
        color: AppColorsPS5.success.withOpacity(baseOpacity),
        blurRadius: 32.0 + pulseT * 12.0,
        spreadRadius: 8.0 + pulseT * 6.0,
      ),
      BoxShadow(
        color: AppColorsPS5.success.withOpacity(wideOpacity),
        blurRadius: 60.0 + pulseT * 20.0,
        spreadRadius: 16.0 + pulseT * 8.0,
      ),
    ];
  }

  /// Повертає стиль тіні тексту для суми.
  static List<Shadow> amountTextShadows({double opacity = 0.3}) {
    return [
      Shadow(
        color: AppColorsPS5.success.withOpacity(opacity),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Обчислює фінальний масштаб для bounce-ефекту.
  ///
  /// [t] — прогрес анімації (0.0 — 1.0).
  /// [bounceHeight] — максимальне перевищення масштабу (за замовч. 1.2).
  static double computeBounceScale(double t, {double bounceHeight = 1.2}) {
    if (t < 0.6) {
      return (t / 0.6) * bounceHeight;
    }
    return bounceHeight - ((t - 0.6) / 0.4) * (bounceHeight - 1.0);
  }

  /// Обчислює непрозорість кільця на основі прогресу.
  ///
  /// [t] — прогрес анімації (0.0 — 1.0).
  /// [maxOpacity] — максимальна непрозорість.
  static double computeRingOpacity(double t, {double maxOpacity = 0.6}) {
    return (1.0 - t).clamp(0.0, maxOpacity);
  }

  /// Обчислює розмір кільця на основі прогресу.
  ///
  /// [baseSize] — початковий розмір.
  /// [expansion] — максимальне розширення.
  static double computeRingSize(double t, double baseSize, double expansion) {
    return baseSize + t * expansion;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Reward Calculator (Розрахунок нагород)
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для розрахунку та форматування нагород за внесок.
///
/// Надає методи для обчислення XP, монет, серій та їх форматування.
class RewardCalculator {
  /// Константа — не дозволяємо створювати екземпляри.
  RewardCalculator._();

  /// Базовий XP за звичайний внесок.
  static const int baseXpPerDeposit = 10;

  /// Базові монети за звичайний внесок.
  static const int baseCoinsPerDeposit = 5;

  /// Множник XP за перший внесок.
  static const double firstDepositMultiplier = 2.0;

  /// Бонус XP за streak (за кожен день серії).
  static const int streakXpBonusPerDay = 2;

  /// Максимальний бонус XP за streak.
  static const int maxStreakXpBonus = 20;

  /// Бонус монет за підвищення рівня.
  static const int levelUpCoinBonus = 25;

  /// Обчислює XP за внесок з урахуванням бонусів.
  ///
  /// [isFirstDeposit] — чи це перший внесок користувача.
  /// [streakDays] — поточна серія днів.
  static int calculateDepositXp({
    bool isFirstDeposit = false,
    int streakDays = 0,
  }) {
    var xp = baseXpPerDeposit;

    if (isFirstDeposit) {
      xp = (xp * firstDepositMultiplier).round();
    }

    if (streakDays > 0) {
      final streakBonus = (streakDays * streakXpBonusPerDay)
          .clamp(0, maxStreakXpBonus);
      xp += streakBonus;
    }

    return xp;
  }

  /// Обчислює монети за внесок.
  ///
  /// [leveledUp] — чи було підвищення рівня.
  static int calculateDepositCoins({bool leveledUp = false}) {
    var coins = baseCoinsPerDeposit;
    if (leveledUp) {
      coins += levelUpCoinBonus;
    }
    return coins;
  }

  /// Обчислює бонус серії (множник для нагород).
  ///
  /// Повертає множник від 1.0 до 2.0 залежно від тривалості серії.
  static double streakMultiplier(int streakDays) {
    if (streakDays <= 0) return 1.0;
    if (streakDays >= 30) return 2.0;
    return 1.0 + (streakDays / 30.0);
  }

  /// Форматує XP для відображення.
  ///
  /// Наприклад: «XP +15».
  static String formatXp(int xp) {
    return 'XP +$xp';
  }

  /// Форматує монети для відображення.
  ///
  /// Наприклад: «Монети +10».
  static String formatCoins(int coins) {
    return 'Монети +$coins';
  }

  /// Форматує серію для відображення.
  ///
  /// Наприклад: «Серія: 5 днів поспіль!».
  static String formatStreak(int streakDays) {
    final dayWord = _pluralize(streakDays, 'день', 'дні', 'днів');
    return 'Серія: $streakDays $dayWord поспіль!';
  }

  /// Склонює слово залежно від числа.
  ///
  /// [count] — число.
  /// [one] — форма для 1.
  /// [few] — форма для 2-4.
  /// [many] — форма для 5+.
  static String _pluralize(int count, String one, String few, String many) {
    if (count == 1) return one;
    if (count >= 2 && count <= 4) return few;
    return many;
  }

  /// Визначає рівень серії для іконки.
  ///
  /// < 3 — звичайна, 3-6 — срібна, 7-13 — золота, 14+ — діамантова.
  static String streakLevel(int streakDays) {
    if (streakDays < 3) return 'normal';
    if (streakDays < 7) return 'silver';
    if (streakDays < 14) return 'gold';
    return 'diamond';
  }

  /// Колір іконки серії на основі рівня.
  static Color streakColor(int streakDays) {
    switch (streakLevel(streakDays)) {
      case 'normal':
        return AppColorsPS5.coin.withOpacity(0.6);
      case 'silver':
        return Colors.grey.shade400;
      case 'gold':
        return AppColorsPS5.coin;
      case 'diamond':
        return Colors.cyanAccent;
      default:
        return AppColorsPS5.coin;
    }
  }
}
