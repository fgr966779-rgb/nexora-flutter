import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_money_display.dart';
import '../../../../core/widgets/app_particle_bg.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/goal_model.dart';

/// Оверлей-віджет для «замороженого» дашборду.
///
/// Показується поверх дашборду при тривалій відсутності внесків.
/// Містить розмиту підкладку, сніжинки, крижаний фільтр, кнопку відновлення,
/// міні-статистику, лічильник днів неактивності, haptic frostCrack,
/// мотиваційні цитати українською, швидкі дії відновлення, план відновлення серії,
/// бонус за повернення, тижневу міні-діаграму активності, нагадування про прогрес.
class InactiveOverlay extends StatefulWidget {
  const InactiveOverlay({
    super.key,
    required this.goal,
    required this.onResume,
    this.isLight = false,
    this.daysInactive = 7,
  });

  final Goal goal;
  final VoidCallback onResume;
  final bool isLight;
  final int daysInactive;

  @override
  State<InactiveOverlay> createState() => _InactiveOverlayState();
}

class _InactiveOverlayState extends State<InactiveOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _frostController;
  late AnimationController _quoteController;
  int _pulseCount = 0;
  bool _isDefrosting = false;
  int _currentQuoteIndex = 0;

  /// 10 мотиваційних цитат українською з ротацією.
  static const _motivationalQuotes = [
    'Кожна гривня наближає тебе до мрії 💰',
    'Дисципліна — це міст між метою та досягненням 🌉',
    'Найкращий час почати — зараз! 🔥',
    'Маленькі кроки щодня ведуть до великих результатів 🚶',
    'Ти вже довів, що можеш. Повернись! 💪',
    'Заощадження — це не обмеження, а свобода 🕊️',
    'Справжня сила — не здаватися після паузи 🏆',
    'Твій майбутній «я» дякує тобі за сьогоднішній внесок 🙏',
    'Накопичення — це найкращий подарунок собі 🎁',
    'Фінансова грамотність починається з першого внеску 📚',
  ];

  /// 3 варіанти швидкого відновлення.
  static const _quickResumeOptions = [
    _ResumeOption(amount: 50, label: '50 грн', description: 'Кава на тиждень', icon: Icons.coffee_rounded),
    _ResumeOption(amount: 100, label: '100 грн', description: 'Обід на 2 дні', icon: Icons.restaurant_rounded),
    _ResumeOption(amount: 200, label: '200 грн', description: 'Серйозний внесок', icon: Icons.trending_up_rounded),
  ];

  /// План відновлення серії з кроками.
  static const _recoverySteps = [
    'Зроби мінімальний внесок сьогодні',
    'Встанови щоденне нагадування',
    'Налаштуй автоплатіж від 50 грн',
    'Досягни 3-денної серії',
    'Підтримай серію протягом тижня',
  ];

  /// Дані тижневої міні-діаграми активності (імітація).
  static const _weeklyActivity = [
    _DayActivity(day: 'Пн', active: true, amount: 200),
    _DayActivity(day: 'Вт', active: true, amount: 150),
    _DayActivity(day: 'Ср', active: false, amount: 0),
    _DayActivity(day: 'Чт', active: true, amount: 300),
    _DayActivity(day: 'Пт', active: false, amount: 0),
    _DayActivity(day: 'Сб', active: false, amount: 0),
    _DayActivity(day: 'Нд', active: false, amount: 0),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _pulseCount < 3) {
        _pulseCount++;
        _pulseController.forward(from: 0);
      }
    });
    _pulseController.forward();

    _frostController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _quoteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Ротація цитат кожні 8 секунд
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _motivationalQuotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _frostController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _onResumeTap() {
    HapticService.frostCrack();
    setState(() => _isDefrosting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onResume();
    });
  }

  void _onQuickResume(int amount) {
    HapticService.mediumTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Додаємо $amount грн до цілі «${widget.goal.name}»',
          style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onResume();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDefrosting) {
      return _buildDefrostOverlay();
    }

    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)
                      .withOpacity(0.2),
                  (widget.isLight ? AppColorsMonitor.background : AppColorsPS5.background)
                      .withOpacity(0.95),
                ],
              ),
            ),
            child: Stack(
              children: [
                // ── Ледяний блакитний фільтр ──────────────────────
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFB0D4F1).withOpacity(0.15),
                  ),
                ),

                // ── Сніжинки на фоні ───────────────────────────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SnowflakePainter(
                      color: widget.isLight
                          ? AppColorsMonitor.accent
                          : AppColorsPS5.accent,
                    ),
                  ),
                ),

                // ── Анімовані частинки інею ───────────────────────
                Positioned.fill(
                  child: _FrostParticles(
                    color: widget.isLight
                        ? AppColorsMonitor.accent
                        : AppColorsPS5.accent,
                  ),
                ),

                // ── Контент ────────────────────────────────────────
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.base),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Сніжинка-іконка з обертанням та пульсом
                        AnimatedBuilder(
                          animation: _frostController,
                          builder: (context, child) {
                            final glow = 0.2 + 0.15 * _frostController.value;
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (widget.isLight
                                            ? AppColorsMonitor.accent
                                            : AppColorsPS5.accent)
                                        .withOpacity(glow),
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.ac_unit_rounded,
                            size: 84,
                            color: widget.isLight
                                ? AppColorsMonitor.accent
                                : AppColorsPS5.accent,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .rotate(
                              begin: -0.15,
                              end: 0.15,
                              duration: const Duration(milliseconds: 3000),
                              curve: Curves.easeInOut,
                            )
                            .fade(
                              begin: 0.6,
                              end: 1.0,
                              duration: const Duration(milliseconds: 1500),
                            ),

                        const SizedBox(height: Spacing.lg),

                        // Лічильник днів неактивності — великий
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.lg,
                            vertical: Spacing.sm + Spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: (widget.isLight
                                    ? AppColorsMonitor.accent
                                    : AppColorsPS5.accent)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Radii.circular),
                            border: Border.all(
                              color: (widget.isLight
                                      ? AppColorsMonitor.accent
                                      : AppColorsPS5.accent)
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: widget.isLight
                                    ? AppColorsMonitor.accent
                                    : AppColorsPS5.accent,
                              ),
                              const SizedBox(width: Spacing.xs),
                              Text(
                                '${widget.daysInactive} дн. без внеску',
                                style: AppTypography.labelLarge.copyWith(
                                  color: widget.isLight
                                      ? AppColorsMonitor.accent
                                      : AppColorsPS5.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: Spacing.xl),

                        // Текст «Твій прогрес чекає на тебе»
                        Text(
                          'Твій прогрес чекає на тебе',
                          style: AppTypography.displaySmall.copyWith(
                            color: widget.isLight
                                ? AppColorsMonitor.textPrimary
                                : AppColorsPS5.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 600.ms,
                              delay: 300.ms,
                            ),

                        const SizedBox(height: Spacing.sm),

                        Text(
                          'Повернися та продовж накопичувати —\nкожен внесок має значення!',
                          style: AppTypography.bodyMedium.copyWith(
                            color: widget.isLight
                                ? AppColorsMonitor.textSecondary
                                : AppColorsPS5.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                        // ── Мотиваційна цитата з ротацією ──────────
                        const SizedBox(height: Spacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                          decoration: BoxDecoration(
                            color: (widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(Radii.md),
                            border: Border.all(color: (widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.1)),
                          ),
                          child: Text(
                            _motivationalQuotes[_currentQuoteIndex],
                            style: AppTypography.labelSmall.copyWith(
                              color: widget.isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 600.ms),

                        const SizedBox(height: Spacing.xxl),

                        // ── Міні-статистика ────────────────────────────
                        AppCard(
                          isLightTheme: widget.isLight,
                          child: Column(
                            children: [
                              // Заморожена візуалізація з десатурацією
                              SizedBox(
                                height: 80,
                                child: Center(
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(<double>[
                                      0.5, 0.5, 0.5, 0, 0,
                                      0.5, 0.5, 0.5, 0, 0,
                                      0.5, 0.5, 0.5, 0, 0,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: ParticleSilhouette(
                                      goalType: widget.goal.type,
                                      progress: widget.goal.progress,
                                      isLightTheme: widget.isLight,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: Spacing.sm),
                              Text(
                                widget.goal.name,
                                style: AppTypography.heading3.copyWith(
                                  color: widget.isLight
                                      ? AppColorsMonitor.textPrimary
                                      : AppColorsPS5.textPrimary,
                                ),
                              ),
                              const SizedBox(height: Spacing.sm),
                              AppProgressBar(
                                progress: widget.goal.progress,
                                isLightTheme: widget.isLight,
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                '${widget.goal.currentAmount.toInt().formatUAH()} / '
                                '${widget.goal.targetAmount.toInt().formatUAH()} грн',
                                style: AppTypography.labelMedium.copyWith(
                                  color: widget.isLight
                                      ? AppColorsMonitor.textSecondary
                                      : AppColorsPS5.textSecondary,
                                ),
                              ),
                              const SizedBox(height: Spacing.sm),

                              // Мотиваційний рядок з двома показниками
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStatChip(
                                      icon: Icons.trending_up_rounded,
                                      label: 'Прогрес',
                                      value: '${(widget.goal.progress * 100).toInt()}%',
                                      accent: widget.isLight
                                          ? AppColorsMonitor.accent
                                          : AppColorsPS5.accent,
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.sm),
                                  Expanded(
                                    child: _MiniStatChip(
                                      icon: Icons.coins_rounded,
                                      label: 'Залишилось',
                                      value: '${(widget.goal.targetAmount - widget.goal.currentAmount).toInt().formatUAH()}',
                                      accent: AppColorsPS5.warning,
                                    ),
                                  ),
                                ],
                              ),

                              // Мотиваційний текст
                              Container(
                                margin: const EdgeInsets.only(top: Spacing.sm),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm,
                                  vertical: Spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorsPS5.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(Radii.sm),
                                ),
                                child: Text(
                                  'Ти накопичив ${widget.goal.currentAmount.toInt().formatUAH()} з '
                                  '${widget.goal.targetAmount.toInt().formatUAH()}. '
                                  'Це ${(widget.goal.progress * 100).toInt()}% — не гай це!',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColorsPS5.warning,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          delay: 600.ms,
                          curve: Curves.easeOutBack,
                        ),

                        // ── Швидкі дії відновлення ───────────────────
                        const SizedBox(height: Spacing.lg),
                        Text(
                          'Швидке відновлення',
                          style: AppTypography.labelLarge.copyWith(
                            color: widget.isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
                        const SizedBox(height: Spacing.sm),
                        Row(
                          children: _quickResumeOptions.map((opt) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _onQuickResume(opt.amount),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.md),
                                  decoration: BoxDecoration(
                                    color: (widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(Radii.md),
                                    border: Border.all(color: (widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(opt.icon, color: widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 20),
                                      const SizedBox(height: Spacing.xs),
                                      Text(opt.label, style: AppTypography.labelMedium.copyWith(color: widget.isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
                                      Text(opt.description, style: AppTypography.caption.copyWith(color: widget.isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // ── Тижнева міні-діаграмa активності ───────────
                        const SizedBox(height: Spacing.lg),
                        _buildWeeklyMiniChart(),

                        // ── Бонус за повернення ──────────────────────
                        const SizedBox(height: Spacing.md),
                        _buildReturnBonusCard(),

                        // ── План відновлення серії ───────────────────
                        const SizedBox(height: Spacing.md),
                        _buildRecoveryPlan(),

                        const SizedBox(height: Spacing.xl),

                        // ── Кнопка «Розпочати з 50 грн» з пульсом ─────
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + 0.05 * math.sin(_pulseController.value * math.pi);
                            return Transform.scale(
                              scale: _pulseCount < 3 ? scale : 1.0,
                              child: child,
                            );
                          },
                          child: AppButtonPrimary(
                            label: 'Розпочати з 50 грн',
                            onPressed: _onResumeTap,
                            showPulse: true,
                            icon: Icons.play_arrow_rounded,
                            isLightTheme: widget.isLight,
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 800.ms),

                        const SizedBox(height: Spacing.md),

                        // Альтернативна кнопка
                        TextButton(
                          onPressed: () {
                            HapticService.frostCrack();
                            widget.onResume();
                          },
                          child: Text(
                            'Або вибери іншу суму',
                            style: AppTypography.labelMedium.copyWith(
                              color: widget.isLight
                                  ? AppColorsMonitor.textSecondary
                                  : AppColorsPS5.textSecondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),

                        const SizedBox(height: Spacing.sm),

                        // Лічильник з удвох сторін
                        Text(
                          '${widget.daysInactive} днів тому був твій останній внесок',
                          style: AppTypography.labelSmall.copyWith(
                            color: widget.isLight
                                ? AppColorsMonitor.textHint
                                : AppColorsPS5.textHint,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),

                        const SizedBox(height: Spacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  /// Тижнева міні-діаграма активності.
  Widget _buildWeeklyMiniChart() {
    final accent = widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Тиждень', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _weeklyActivity.map((d) {
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: d.active ? accent.withOpacity(0.2) : (widget.isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: d.active ? Border.all(color: accent, width: 1.5) : null,
                    ),
                    child: Center(
                      child: d.active
                          ? Icon(Icons.check_rounded, color: accent, size: 14)
                          : Icon(Icons.remove_rounded, color: (widget.isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint).withOpacity(0.3), size: 14),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(d.day, style: AppTypography.caption.copyWith(color: widget.isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 750.ms);
  }

  /// Картка бонусу за повернення.
  Widget _buildReturnBonusCard() {
    final accent = widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final bonusXp = widget.daysInactive >= 7 ? 50 : widget.daysInactive >= 3 ? 25 : 10;
    final bonusCoins = widget.daysInactive >= 7 ? 20 : widget.daysInactive >= 3 ? 10 : 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withOpacity(0.08), accent.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: accent.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.card_giftcard_rounded, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎁 Бонус за повернення!', style: AppTypography.labelMedium.copyWith(color: widget.isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
                Text('+$bonusXp XP та +$bonusCoins монет за відновлення', style: AppTypography.labelSmall.copyWith(color: widget.isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 800.ms);
  }

  /// План відновлення серії з кроками.
  Widget _buildRecoveryPlan() {
    final accent = widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 План відновлення', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          ..._recoverySteps.asMap().entries.map((entry) {
            final step = entry.key + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: step == 1 ? accent : accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$step', style: AppTypography.caption.copyWith(color: step == 1 ? Colors.white : accent, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTypography.labelSmall.copyWith(
                        color: step == 1 ? (widget.isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary) : (widget.isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary),
                        fontWeight: step == 1 ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 850.ms);
  }

  /// Оверлей розморожування.
  Widget _buildDefrostOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Icon(
            Icons.ac_unit_rounded,
            size: 100,
            color: widget.isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
          )
              .animate()
              .fadeOut(duration: 600.ms)
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(2.0, 2.0), duration: 600.ms),
        ),
      ),
    );
  }
}

/// Міні-статистика чип для overlay.
class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: AppTypography.labelSmall.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Варіант швидкого відновлення.
class _ResumeOption {
  final int amount;
  final String label;
  final String description;
  final IconData icon;
  const _ResumeOption({required this.amount, required this.label, required this.description, required this.icon});
}

/// Дані про активність за день.
class _DayActivity {
  final String day;
  final bool active;
  final int amount;
  const _DayActivity({required this.day, required this.active, required this.amount});
}

/// CustomPainter для сніжинок — статичний фон.
class _SnowflakePainter extends CustomPainter {
  _SnowflakePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(123);
    for (int i = 0; i < 25; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 1.5 + rng.nextDouble() * 3.5;
      final opacity = 0.06 + rng.nextDouble() * 0.14;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // Намалювати кілька сніжинок-зірочок
    for (int i = 0; i < 6; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final size2 = 6 + rng.nextDouble() * 8;
      final opacity2 = 0.04 + rng.nextDouble() * 0.08;

      final paint = Paint()
        ..color = color.withOpacity(opacity2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        canvas.drawLine(
          Offset(x, y),
          Offset(x + math.cos(angle) * size2, y + math.sin(angle) * size2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SnowflakePainter oldDelegate) => false;
}

/// Анімовані частинки інею — повільно падають вниз.
class _FrostParticles extends StatefulWidget {
  const _FrostParticles({required this.color});

  final Color color;

  @override
  State<_FrostParticles> createState() => _FrostParticlesState();
}

class _FrostParticlesState extends State<_FrostParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _particles = <_FrostParticle>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    final rng = math.Random(42);
    for (int i = 0; i < 18; i++) {
      _particles.add(_FrostParticle(
        x: rng.nextDouble(),
        startY: rng.nextDouble(),
        speed: 0.12 + rng.nextDouble() * 0.28,
        size: 1.5 + rng.nextDouble() * 3.5,
        opacity: 0.08 + rng.nextDouble() * 0.14,
        wobble: rng.nextDouble() * 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _FrostParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _FrostParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double opacity;
  final double wobble;

  _FrostParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.wobble,
  });
}

class _FrostParticlesPainter extends CustomPainter {
  _FrostParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  final List<_FrostParticle> particles;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.startY + progress * p.speed) % 1.0) * size.height;
      final xOffset = math.sin(progress * math.pi * 2 + p.x * 10) * p.wobble * 20;
      final x = p.x * size.width + xOffset;

      final paint = Paint()
        ..color = color.withOpacity(p.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FrostParticlesPainter oldDelegate) => true;
}
