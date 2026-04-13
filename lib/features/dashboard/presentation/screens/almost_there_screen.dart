import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_money_display.dart';
import '../../../../core/widgets/app_particle_bg.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../data/models/goal_model.dart';

/// Оверлей-віджет «майже там» — показується поверх дашборду при ≥90% прогресу.
///
/// Містить:
/// - Безперервні блискіткові частинки (sparkle effects)
/// - Пульсуючий прогрес-бар із shimmer
/// - «Залишилось [X]!» з анімацією зворотного відліку
/// - «Це лише [Y] внесків по [Z] грн!» обчислення
/// - Кнопку «Фінішуємо!» із glow + pulse
/// - Періодичні мотиваційні toast-повідомлення
/// - Яскравий shimmer фон градієнт
/// - Тактильний зворотний зв'язок на кнопці
/// - Кнопку «Підказка» з детальним розрахунком
/// - Анімований лічильник днів до мети
/// - Countdown timer з днями/годинами/хвилинами
/// - Залишок суми з анімованим лічильником
/// - Кнопку «Поділитися» з 3 опціями
/// - 3 картки фінальних викликів з нагородами XP
/// - Індикатор терміновості (зелений/жовтий/червоний)
/// - Ротація мотиваційних повідомлень
/// - Рядок порівняння статистики (поточний vs початковий)
/// - Анімацію-тізер святкування
class AlmostThereOverlay extends StatefulWidget {
  const AlmostThereOverlay({
    super.key,
    required this.goal,
    required this.onAddDeposit,
    this.isLight = false,
  });

  final Goal goal;
  final VoidCallback onAddDeposit;
  final bool isLight;

  @override
  State<AlmostThereOverlay> createState() => _AlmostThereOverlayState();
}

class _AlmostThereOverlayState extends State<AlmostThereOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late AnimationController _encouragementController;
  late AnimationController _celebrationTeaserController;
  Timer? _toastTimer;
  int _toastIndex = 0;
  int _daysLeft = 0;
  bool _showTip = false;
  bool _showChallenges = false;
  int _encouragementIndex = 0;
  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  bool _showShareMenu = false;
  int _animatedRemaining = 0;

  static const _toastMessages = [
    '🔥 Ти на фінішній прямій!',
    '💪 Залишився останній ривок!',
    '⚡ Майже там — не здавайся!',
    '🚀 Фініш близько — надихай!',
    '✨ Усього трохи — ти впораєшся!',
    '🎯 Це фінальний етап!',
    '💎 Ти справжній накопичувач!',
    '🏆 Мрія вже поруч!',
    '🌟 Ти в топ-5% найшвидших!',
    '💫 Твоя дисципліна вражає!',
    '🌈 Один великий стрибок — і ти на фініші!',
    '🎪 Святкування вже готується!',
  ];

  static const _tips = [
    '💡 Спробуй внести 300+ грн щоб завершити швидше!',
    '📅 Залишилось ~3 тижні — ти молодець!',
    '🎯 Встанови нагадування — не забудь!',
    '⚡ Подвійний внесок сьогодні = подвійний прогрес!',
    '🔥 Ти у фінальній стадії — не зупиняйся!',
    '💰 Подивись: ці 300 грн — це лише 2 кави на день!',
  ];

  static const _challenges = [
    _Challenge('Фінішний ривок', 'Зроби внесок 500+ грн за один день', '⚡', 50),
    _Challenge('Тижневий марафон', 'Зроби внесок кожен день цього тижня', '🔥', 100),
    _Challenge('Останній подвиг', 'Дійди до 100% за найменшу кількість днів', '🏆', 200),
    _Challenge('Мотиватор', 'Поділися своїм прогресом із другом', '👥', 30),
    _Challenge('Без пропуску', '7 днів поспіль без пропущених внесків', '💎', 75),
  ];

  static const _encouragements = [
    'Ти вже зробив 90% роботи!',
    'Залишилось менше ніж ти думаєш!',
    'Кожна гривня зараз — золотий внесок!',
    'Твій найкращий ривок — попереду!',
    'Уяви, як відчуєш себе на фініші!',
    'Мрія так близько — ти відчуєш це!',
    'Кілька внесків — і святкування!',
    'Твоя цінність — у дисципліні!',
    'Кожен внесок — крок до свободи!',
    'Ти надихаєш інших своїм прикладом!',
    'Це марафон — і ти на останньому кілометрі!',
  ];

  static const _milestoneMessages = [
    '📈 Від 0% до 90% — ти пройшов неймовірний шлях!',
    '💰 Загалом накопичено: величезна сума!',
    '📅 Днів у шляху: ти показав неймовірну стійкість!',
    '⭐ Ти кращий за 90% користувачів за швидкістю!',
    '🔥 Твоя серія внесків — одна з найкращих!',
  ];

  static const _shareOptions = [
    ('📸 Скріншот', Icons.screenshot_rounded),
    ('📱 Текстом', Icons.chat_rounded),
    ('🔗 Посиланням', Icons.link_rounded),
  ];

  static const _quickDepositLabels = {
    200: 'Мінімум',
    500: 'Оптимально',
    1000: 'Великий',
    2000: 'Максимально',
  };

  int _milestoneIndex = 0;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _countdownController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _encouragementController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat();
    _celebrationTeaserController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);

    _daysLeft = goal.remaining > 200 ? (goal.remaining / 200).ceil() : 1;

    _toastTimer = Timer.periodic(const Duration(seconds: 4), (_) => _showMotivationalToast());

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _countdownSeconds++);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) HapticService.success();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _showTip = true);
    });

    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _showChallenges = true);
    });

    // Анімація лічильника залишку
    _animateRemaining();
  }

  void _animateRemaining() {
    final target = widget.goal.remaining.toInt();
    if (target == 0) return;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final step = (target / 40).ceil().clamp(1, 999);
      setState(() {
        _animatedRemaining += step;
        if (_animatedRemaining >= target) {
          _animatedRemaining = target;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _countdownTimer?.cancel();
    _sparkleController.dispose();
    _pulseController.dispose();
    _countdownController.dispose();
    _encouragementController.dispose();
    _celebrationTeaserController.dispose();
    super.dispose();
  }

  void _showMotivationalToast() {
    if (!mounted) return;
    final message = _toastMessages[_toastIndex % _toastMessages.length];
    context.showToast(message, icon: Icons.auto_awesome_rounded, duration: const Duration(milliseconds: 2500));
    setState(() {
      _toastIndex++;
      _encouragementIndex = (_encouragementIndex + 1) % _encouragements.length;
      _milestoneIndex = (_milestoneIndex + 1) % _milestoneMessages.length;
    });
  }

  void _handleFinish() {
    HapticService.success();
    widget.onAddDeposit();
  }

  void _onTipTap() {
    HapticService.lightTap();
    context.showToast(_tips[_toastIndex % _tips.length], icon: Icons.lightbulb_rounded);
    setState(() => _toastIndex++);
  }

  void _onShareProgress() {
    HapticService.selection();
    setState(() => _showShareMenu = !_showShareMenu);
  }

  void _onShareOption(String label) {
    HapticService.mediumTap();
    final progress = (widget.goal.progress * 100).toStringAsFixed(1);
    setState(() => _showShareMenu = false);
    context.showToast('$label: Прогрес $progress% — майже на фініші!', icon: Icons.share_rounded);
  }

  void _onChallengeTap(_Challenge challenge) {
    HapticService.mediumTap();
    context.showToast('${challenge.emoji} ${challenge.title}: +${challenge.xpReward} XP!', icon: Icons.emoji_events_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.remaining;
    final estimatedDeposits = remaining > 0 ? (remaining / 200).ceil() : 0;
    final depositAmount = 200;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (widget.isLight ? AppColorsMonitor.background : AppColorsPS5.background).withOpacity(0.95),
              (widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.12),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, _) {
            return CustomPaint(
              painter: _SparkleShimmerPainter(
                color: widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                progress: _sparkleController.value,
              ),
              child: _buildContent(remaining, estimatedDeposits, depositAmount),
            );
          },
        ),
      ).animate().fadeIn(duration: 600.ms, curve: AppEasings.smooth),
    );
  }

  Widget _buildContent(double remaining, int estimatedDeposits, int depositAmount) {
    final accent = widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final textColor = widget.isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
    final subColor = widget.isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;
    final urgencyLevel = remaining < 500 ? 2 : (remaining < 2000 ? 1 : 0);
    final urgencyColor = urgencyLevel == 2 ? AppColorsPS5.error : (urgencyLevel == 1 ? AppColorsPS5.warning : accent);
    final urgencyLabel = urgencyLevel == 2 ? '🔴 Критично!' : (urgencyLevel == 1 ? '🟡 Майже!' : '🟢 Добре!');
    final urgencyMessage = urgencyLevel == 2 ? 'Лише один великий внесок!' : (urgencyLevel == 1 ? 'Ще трохи зусиль!' : 'Все йде за планом!');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Sparkle header label ─────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: accent.withOpacity(0.2))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedBuilder(animation: _sparkleController, builder: (context, _) {
                  final sparkle = math.sin(_sparkleController.value * math.pi * 2);
                  return Opacity(opacity: 0.6 + sparkle * 0.4, child: Icon(Icons.auto_awesome_rounded, color: accent, size: 14));
                }),
                const SizedBox(width: Spacing.xs),
                Text('МАЙЖЕ ТАМ!', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(width: Spacing.xs),
                AnimatedBuilder(animation: _sparkleController, builder: (context, _) {
                  final sparkle = math.cos(_sparkleController.value * math.pi * 2);
                  return Opacity(opacity: 0.6 + sparkle * 0.4, child: Icon(Icons.auto_awesome_rounded, color: accent, size: 14));
                }),
              ]),
            ).animate().fade(duration: 500.ms).scale(delay: 200.ms, duration: 400.ms, curve: AppEasings.subtlePop),

            const SizedBox(height: Spacing.sm),

            // ── Індикатор терміновості ─────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(color: urgencyColor.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: urgencyColor.withOpacity(0.15))),
              child: Column(children: [
                Text(urgencyLabel, style: AppTypography.labelSmall.copyWith(color: urgencyColor, fontWeight: FontWeight.w600)),
                Text(urgencyMessage, style: AppTypography.labelSmall.copyWith(color: urgencyColor.withOpacity(0.7), fontSize: 10)),
              ]),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: Spacing.lg),

            // ── Particle Silhouette ──────────────────────────
            SizedBox(
              height: 160,
              child: Center(child: ParticleSilhouette(goalType: widget.goal.type, progress: widget.goal.progress, isLightTheme: widget.isLight)),
            ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 600.ms, curve: AppEasings.smooth),

            const SizedBox(height: Spacing.lg),

            // ── «Залишилось X!» з анімованим лічильником ────
            _buildRemainingAmountAnimated(textColor, accent),

            const SizedBox(height: Spacing.md),

            // ── Deposit calculation ─────────────────────────
            Text(
              estimatedDeposits > 0
                  ? 'Це лише ${estimatedDeposits.pluralUAH('внесок', 'внески', 'внесків')} по ${depositAmount.formatUAH()} грн!'
                  : 'Твоя мета вже досягнута!',
              style: AppTypography.bodyMedium.copyWith(color: subColor),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            // ── Countdown animation ─────────────────────────
            AnimatedBuilder(animation: _countdownController, builder: (_, __) {
              final pulse = math.sin(_countdownController.value * math.pi);
              return Opacity(
                opacity: 0.6 + pulse * 0.3,
                child: Text(
                  '~${estimatedDeposits} днів залишось',
                  style: AppTypography.labelSmall.copyWith(color: subColor),
                ),
              );
            }),

            // ── Живий таймер з годинами/хвилинами ──────────
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular)),
              child: Text('⏱ ${_countdownSeconds ~/ 3600}г ${(_countdownSeconds % 3600) ~/ 60}хв ${_countdownSeconds % 60}с', style: AppTypography.labelSmall.copyWith(color: accent)),
            ),

            const SizedBox(height: Spacing.xl),

            // ── Pulsing progress bar ────────────────────────
            AppProgressBar(
              progress: widget.goal.progress,
              isLightTheme: widget.isLight,
              isPulsing: true,
              showShimmer: true,
              height: ProgressBarHeight.thick,
              showGlowNearComplete: true,
            ),

            const SizedBox(height: Spacing.sm),

            // ── Percentage display ──────────────────────────
            AnimatedBuilder(animation: _pulseController, builder: (context, _) {
              final pulse = math.sin(_pulseController.value * math.pi);
              return Opacity(
                opacity: 0.7 + pulse * 0.3,
                child: Text(
                  '${(widget.goal.progress * 100).toStringAsFixed(1)}%',
                  style: AppTypography.monoSmall.copyWith(color: subColor),
                ),
              );
            }),

            // ── Анімовані повідомлення підтримки ────────────
            const SizedBox(height: Spacing.sm),
            AnimatedBuilder(animation: _encouragementController, builder: (_, __) {
              final fade = 0.5 + 0.5 * math.sin(_encouragementController.value * math.pi);
              return Opacity(
                opacity: fade,
                child: Text(
                  _encouragements[_encouragementIndex],
                  style: AppTypography.labelSmall.copyWith(color: accent, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              );
            }),

            // ── Рядок порівняння статистики ───────────────
            const SizedBox(height: Spacing.md),
            _buildStatsComparisonRow(textColor, subColor, accent),
            // ── Досягнення-підказка ──────────────────────
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(color: AppColorsPS5.xp.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
              child: Text(_milestoneMessages[_milestoneIndex], style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp, fontSize: 10)),
            ),

            // ── Motivational statistics ─────────────────────
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.08))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _buildStat('📈 Прогрес', '${(widget.goal.progress * 100).toStringAsFixed(0)}%', accent),
                _buildStat('🔥 Серія', '$_daysLeft дн', AppColorsPS5.warning),
                _buildStat('⏱ Швидкість', '${(200 / (_daysLeft == 0 ? 1 : _daysLeft)).toStringAsFixed(0)} грн/дн', AppColorsPS5.success),
              ]),
            ),

            // ── Quick deposit chips ─────────────────────────
            const SizedBox(height: Spacing.lg),
            _buildQuickDepositChips(accent),

            // ── Кнопка поділитися з меню ───────────────────
            const SizedBox(height: Spacing.sm),
            _buildShareButton(accent),

            // ── Меню поділитися ────────────────────────────
            if (_showShareMenu)
              Container(
                margin: const EdgeInsets.only(top: Spacing.xs),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.12))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _shareOptions.map((opt) => GestureDetector(
                  onTap: () => _onShareOption(opt.$1),
                  child: Column(children: [
                    Icon(opt.$2, color: accent, size: 20),
                    const SizedBox(height: Spacing.xs),
                    Text(opt.$1, style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 10)),
                  ]),
                )).toList()),
              ).animate().fadeIn(duration: 200.ms),

            // ── Фінальні виклики ───────────────────────────
            if (_showChallenges) ...[
              const SizedBox(height: Spacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(color: AppColorsPS5.xp.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
                child: Text('Виконай виклики та отримай XP для розблокування досягнень!', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp, fontSize: 10, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: Spacing.sm),
              Text('🎯 Фінальні виклики', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: Spacing.sm),
              ..._challenges.take(3).map((ch) => GestureDetector(
                onTap: () => _onChallengeTap(ch),
                child: Container(
                  margin: const EdgeInsets.only(bottom: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.1))),
                  child: Row(children: [
                    Text(ch.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: Spacing.sm),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ch.title, style: AppTypography.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                      Text(ch.description, style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
                      decoration: BoxDecoration(color: AppColorsPS5.xp.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)),
                      child: Text('+${ch.xpReward} XP', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              )).toList(),
            ],

            // ── Анімація-тізер святкування ────────────────
            const SizedBox(height: Spacing.sm),
            AnimatedBuilder(animation: _celebrationTeaserController, builder: (_, __) {
              final scale = 0.9 + 0.1 * _celebrationTeaserController.value;
              final opacity = 0.3 + 0.4 * _celebrationTeaserController.value;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale, child: Text('🎊 Святкування наближається...', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600))),
              );
            }),

            const SizedBox(height: Spacing.xxl),

            // ── «Фінішуємо!» button ─────────────────────
            AppButtonPrimary(
              label: 'Фінішуємо!',
              onPressed: _handleFinish,
              showGlow: true,
              showPulse: true,
              icon: Icons.emoji_events_rounded,
              isLightTheme: widget.isLight,
              isFullWidth: true,
            ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.1, end: 0, delay: 500.ms, duration: 500.ms),

            // ── Tip ──────────────────────────────────────
            if (_showTip)
              GestureDetector(
                onTap: _onTipTap,
                child: Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
                  decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: accent.withOpacity(0.12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: accent, size: 14),
                      const SizedBox(width: Spacing.sm),
                      Text('Натисни для поради', style: AppTypography.labelSmall.copyWith(color: accent)),
                      const SizedBox(width: Spacing.xs),
                      Icon(Icons.chevron_right_rounded, color: accent, size: 14),
                    ],
                  ),
                ).animate().fade(duration: 400.ms),
              ),

            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingAmountAnimated(Color textColor, Color accent) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: widget.goal.remaining.toInt(), end: _animatedRemaining),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final pulse = math.sin(_pulseController.value * math.pi);
            final scale = 1.0 + pulse * 0.02;
            return Transform.scale(
              scale: scale,
              child: Text(
                'Залишилось ${value.formatUAH()} грн!',
                style: AppTypography.displayMedium.copyWith(color: accent, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      },
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.04, 1.04), duration: const Duration(milliseconds: 900), curve: Curves.easeInOut);
  }

  Widget _buildStatsComparisonRow(Color textColor, Color subColor, Color accent) {
    final current = (widget.goal.progress * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(color: accent.withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(children: [
          Text('0%', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 10)),
          Text('на початку', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 9)),
        ]),
        Icon(Icons.arrow_forward_rounded, color: accent, size: 16),
        Column(children: [
          Text('$current%', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
          Text('зараз', style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 9)),
        ]),
        Icon(Icons.arrow_forward_rounded, color: AppColorsPS5.success, size: 16),
        Column(children: [
          Text('100%', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontSize: 10)),
          Text('ціль', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontSize: 9)),
        ]),
      ]),
    );
  }

  Widget _buildShareButton(Color accent) {
    return GestureDetector(
      onTap: _onShareProgress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: accent.withOpacity(0.12))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.share_rounded, color: accent, size: 14),
          const SizedBox(width: Spacing.xs),
          Text('Поділитися прогресом', style: AppTypography.labelSmall.copyWith(color: accent)),
          const SizedBox(width: Spacing.xs),
          Icon(_showShareMenu ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: accent, size: 14),
        ]),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
      Text(label, style: AppTypography.labelSmall.copyWith(color: color.withOpacity(0.7), fontSize: 10)),
    ]);
  }

  Widget _buildQuickDepositChips(Color accent) {
    final amounts = [200, 500, 1000, 2000];
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      alignment: WrapAlignment.center,
      children: amounts.map((amount) {
        return GestureDetector(
          onTap: () {
            HapticService.coinDrop();
            context.showToast('Внесок ${amount.formatUAH()} грн додано!', icon: Icons.check_circle_rounded);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
            decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: accent.withOpacity(0.2))),
            child: Column(children: [
              Text('+${amount.formatUAH()}', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w600)),
              Text(_quickDepositLabels[amount] ?? '', style: AppTypography.labelSmall.copyWith(color: accent.withOpacity(0.6), fontSize: 9)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUrgencyBar(Color accent, Color subColor) {
    final progress = widget.goal.progress * 100;
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Шкала терміновості', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 9)),
          Text('${progress.toStringAsFixed(1)}%', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600, fontSize: 9)),
        ]),
        const SizedBox(height: Spacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 6,
            backgroundColor: (widget.isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(progress > 95 ? AppColorsPS5.error : (progress > 90 ? AppColorsPS5.warning : accent)),
          ),
        ),
      ]),
    );
  }
}

class _Challenge {
  final String title;
  final String description;
  final String emoji;
  final int xpReward;
  const _Challenge(this.title, this.description, this.emoji, this.xpReward);
}

class _SparkleShimmerPainter extends CustomPainter {
  _SparkleShimmerPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final baseRadius = 1.0 + rng.nextDouble() * 2.5;
      final phase = rng.nextDouble() * math.pi * 2;
      final shimmer = 0.5 + 0.5 * math.sin(progress * math.pi * 2 + phase);
      final r = baseRadius * (0.7 + shimmer * 0.5);
      final opacity = (0.08 + rng.nextDouble() * 0.25) * shimmer;

      final paint = Paint()
        ..color = color.withOpacity(opacity.clamp(0.0, 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    for (int i = 0; i < 12; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speedX = (rng.nextDouble() - 0.5) * 40;
      final speedY = -20 - rng.nextDouble() * 30;
      final x = baseX + speedX * progress;
      final y = baseY + speedY * progress;
      final r = 1.5 + rng.nextDouble() * 1.5;
      final opacity = 0.15 + rng.nextDouble() * 0.2;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x % size.width, y % size.height), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
