import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/build_context_ext.dart';

/// Екран «Прогрес» — великий лінійний XP бар, маркери рівнів, список подій з часовими мітками,
/// загальний XP, індикатор множника, добовий графік XP, джерела, прогноз.
class LevelProgressScreen extends StatefulWidget {
  const LevelProgressScreen({super.key});

  @override
  State<LevelProgressScreen> createState() => _LevelProgressScreenState();
}

class _LevelProgressScreenState extends State<LevelProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;
  late Animation<int> _xpCountAnim;
  int _selectedPeriod = 7; // days for daily chart

  final int currentXp = 1200;
  final int xpForCurrent = 700;
  final int xpForNext = 1500;
  final int totalXp = 3850;
  final double xpMultiplier = 1.15;
  final int avgDailyXp = 28;

  final _levelMarkers = const [
    _LevelMarker(1, 'Новачок', 0),
    _LevelMarker(2, 'Учень', 250),
    _LevelMarker(3, 'Воїн', 500),
    _LevelMarker(4, 'Майстер', 700),
    _LevelMarker(5, 'Чемпіон', 1500),
    _LevelMarker(6, 'Легенда', 2500),
  ];

  final _milestones = const [
    _XpMilestone(800, '800'),
    _XpMilestone(1000, '1K'),
    _XpMilestone(1250, '1.25K'),
  ];

  final _events = const [
    _XpEvent(Icons.edit_rounded, 'Ручний внесок', '+10 XP', '5 хв тому', '14:32'),
    _XpEvent(Icons.login_rounded, 'Щоденний вхід', '+3 XP', '1 год тому', '13:45'),
    _XpEvent(Icons.emoji_events_rounded, 'Виконання виклику', '+50 XP', 'вчора', '18:20'),
    _XpEvent(Icons.local_fire_department_rounded, 'Серія 5 днів', '+20 XP', '2 дні тому', '19:00'),
    _XpEvent(Icons.monetization_on_rounded, 'Щоденний внесок', '+5 XP', '3 дні тому', '14:15'),
    _XpEvent(Icons.star_rounded, 'Перший внесок місяця', '+15 XP', '5 днів тому', '10:30'),
    _XpEvent(Icons.workspace_premium_rounded, 'Новий значок', '+25 XP', '1 тиждень тому', '16:45'),
    _XpEvent(Icons.bolt_rounded, 'Виклик виконано', '+30 XP', '1 тиждень тому', '09:20'),
    _XpEvent(Icons.auto_awesome_rounded, 'Бонус за серію', '+10 XP', '9 днів тому', '20:00'),
    _XpEvent(Icons.trending_up_rounded, 'Підвищення рівня', '+100 XP', '10 днів тому', '12:00'),
  ];

  final _dailyXpData = const [
    _DailyXp('Пн', 15),
    _DailyXp('Вт', 32),
    _DailyXp('Ср', 28),
    _DailyXp('Чт', 45),
    _DailyXp('Пт', 18),
    _DailyXp('Сб', 10),
    _DailyXp('Нд', 35),
  ];

  final _sources = const [
    _SourceData('Ручні внески', 1850, Icons.edit_rounded, 0.48),
    _SourceData('Виклики', 1200, Icons.emoji_events_rounded, 0.31),
    _SourceData('Вхід', 90, Icons.login_rounded, 0.02),
    _SourceData('Серії', 480, Icons.local_fire_department_rounded, 0.12),
    _SourceData('Досягнення', 230, Icons.military_tech_rounded, 0.06),
  ];

  double get _progress {
    final range = xpForNext - xpForCurrent;
    if (range <= 0) return 1.0;
    return ((currentXp - xpForCurrent) / range).clamp(0.0, 1.0);
  }

  int get _xpRemaining => xpForNext - currentXp;
  int get _daysToNextLevel => (avgDailyXp > 0 ? (_xpRemaining / avgDailyXp).ceil() : 0);

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _barAnim = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic),
    );
    _xpCountAnim = IntTween(begin: xpForCurrent, end: currentXp).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOut),
    );
    _barController.forward();
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Прогрес'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Spacing.xl),

            // ─── Загальний XP + Множник ─────────────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Загальний XP',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColorsPS5.textSecondary
                              : AppColorsMonitor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalXp XP',
                        style: AppTypography.monoMedium.copyWith(
                          color: isDark
                              ? AppColorsPS5.xp
                              : AppColorsMonitor.xp,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  // Множник індикатор
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColorsPS5.warning.withOpacity(0.8),
                          AppColorsPS5.warning.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.speed_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'x${xpMultiplier.toStringAsFixed(2)}',
                          style: AppTypography.monoSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'множник',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms),

            const SizedBox(height: Spacing.xl),

            // ─── Рівень + XP текст ──────────────────────────────
            Text(
              'Рівень 4 — Майстер',
              style: AppTypography.heading2.copyWith(
                color: isDark
                    ? AppColorsPS5.textPrimary
                    : AppColorsMonitor.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            AnimatedBuilder(
              animation: _barController,
              builder: (context, _) {
                return Text(
                  '${_xpCountAnim.value} / $xpForNext XP до наступного рівня',
                  style: AppTypography.monoSmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textSecondary
                        : AppColorsMonitor.textSecondary,
                  ),
                );
              },
            ),
            const SizedBox(height: Spacing.xl),

            // ─── Великий лінійний XP бар ───────────────────────
            _buildLargeXpBar(isDark),
            const SizedBox(height: Spacing.lg),

            // ─── Маркери рівнів на барі ────────────────────────
            _buildLevelMarkers(isDark),

            const SizedBox(height: Spacing.xl),

            // ─── Мілі-досягнення ───────────────────────────────
            Text(
              'Мілі-досягнення',
              style: AppTypography.heading3.copyWith(
                color: isDark
                    ? AppColorsPS5.textPrimary
                    : AppColorsMonitor.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.sm,
              children: _milestones.map((m) {
                final reached = currentXp >= m.xpValue;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: reached
                        ? (isDark
                                ? AppColorsPS5.accent
                                : AppColorsMonitor.accent)
                            .withOpacity(0.1)
                        : (isDark
                                ? AppColorsPS5.card
                                : AppColorsMonitor.card),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(
                      color: reached
                          ? (isDark
                                  ? AppColorsPS5.accent
                                  : AppColorsMonitor.accent)
                              .withOpacity(0.3)
                          : (isDark
                                  ? AppColorsPS5.border
                                  : AppColorsMonitor.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        reached
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 14,
                        color: reached
                            ? (isDark
                                    ? AppColorsPS5.accent
                                    : AppColorsMonitor.accent)
                            : (isDark
                                    ? AppColorsPS5.textHint
                                    : AppColorsMonitor.textHint),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${m.label} XP',
                        style: AppTypography.labelSmall.copyWith(
                          color: reached
                              ? (isDark
                                      ? AppColorsPS5.accent
                                      : AppColorsMonitor.accent)
                              : (isDark
                                      ? AppColorsPS5.textHint
                                      : AppColorsMonitor.textHint),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: Spacing.xxl),

            // ─── Добовий графік XP ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Щоденний графік XP',
                        style: AppTypography.heading3.copyWith(
                          color: isDark
                              ? AppColorsPS5.textPrimary
                              : AppColorsMonitor.textPrimary,
                        ),
                      ),
                      Text(
                        'Середнє: $avgDailyXp XP/день',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColorsPS5.textHint
                              : AppColorsMonitor.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  SizedBox(
                    height: 120,
                    child: _buildDailyXpChart(isDark),
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Джерела XP ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Джерела XP',
                    style: AppTypography.heading3.copyWith(
                      color: isDark
                          ? AppColorsPS5.textPrimary
                          : AppColorsMonitor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  ..._sources.asMap().entries.map((entry) {
                    final i = entry.key;
                    final source = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i < _sources.length - 1 ? Spacing.sm : 0,
                      ),
                      child: _buildSourceRow(source, isDark),
                    );
                  }),
                ],
              ),
            ).animate().fade(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Прогноз до наступного рівня ───────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                        .withOpacity(0.12),
                    (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                        .withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                      .withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_rounded,
                          color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                          size: 20),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Прогноз',
                        style: AppTypography.heading3.copyWith(
                          color: isDark
                              ? AppColorsPS5.textPrimary
                              : AppColorsMonitor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _predictionItem(
                        'До наступного рівня',
                        '$_xpRemaining XP',
                        isDark,
                      ),
                      _predictionItem(
                        'Орієнтовних днів',
                        '~$_daysToNextLevel',
                        isDark,
                      ),
                      _predictionItem(
                        'Поточний темп',
                        '$avgDailyXp XP/дн',
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColorsPS5.success : AppColorsMonitor.success)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            size: 16,
                            color: isDark ? AppColorsPS5.success : AppColorsMonitor.success),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Твій темп на 12% вищий за минулий тиждень. Продовжуй у тому ж дусі!',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColorsPS5.textSecondary
                                  : AppColorsMonitor.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Детальний список подій XP ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Історія XP',
                  style: AppTypography.heading3.copyWith(
                    color: isDark
                        ? AppColorsPS5.textPrimary
                        : AppColorsMonitor.textPrimary,
                  ),
                ),
                Text(
                  '${_events.length} подій',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textSecondary
                        : AppColorsMonitor.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            ..._events.asMap().entries.map((entry) {
              final i = entry.key;
              final event = entry.value;
              return _XpEventTile(event: event, isDark: isDark, showTime: i < 3)
                  .animate()
                  .fade(delay: (150 * i).ms, duration: 300.ms)
                  .slideX(
                      begin: -0.1,
                      end: 0,
                      delay: (150 * i).ms,
                      duration: 300.ms);
            }),

            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeXpBar(bool isDark) {
    final barBg = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _barController,
          builder: (context, _) {
            return SizedBox(
              height: 32,
              child: CustomPaint(
                painter: _XpBarPainter(
                  progress: _barAnim.value,
                  bgColor: barBg,
                  fillColor: accent,
                  glowColor: accent,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Рівень 4',
                style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textHint
                        : AppColorsMonitor.textHint)),
            Text('Рівень 5',
                style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textHint
                        : AppColorsMonitor.textHint)),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelMarkers(bool isDark) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Карта рівнів', style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
          )),
          const SizedBox(height: Spacing.md),
          ..._levelMarkers.asMap().entries.map((entry) {
            final i = entry.key;
            final marker = entry.value;
            final reached = totalXp >= marker.xpRequired;
            final isCurrent = marker.level == 4;
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: reached
                          ? accent.withOpacity(0.15)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: reached ? accent : (isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                        width: 1.5,
                      ),
                    ),
                    child: reached
                        ? Icon(Icons.check_rounded, size: 14, color: accent)
                        : null,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Рівень ${marker.level}',
                    style: AppTypography.labelSmall.copyWith(
                      color: isCurrent
                          ? accent
                          : reached
                              ? (isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)
                              : (isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    marker.name,
                    style: AppTypography.bodySmall.copyWith(color: subColor),
                  ),
                  const Spacer(),
                  Text(
                    '${marker.xpRequired} XP',
                    style: AppTypography.monoCaption.copyWith(
                      color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyXpChart(bool isDark) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final maxVal = _dailyXpData.map((d) => d.xp).reduce(math.max).toDouble();
    final barWidth = 24.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _dailyXpData.map((day) {
        final height = (day.xp / maxVal) * 100.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${day.xp}',
              style: AppTypography.monoCaption.copyWith(
                color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.5)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ).animate().fade(delay: 100.ms, duration: 400.ms).scale(
              begin: const Offset(1, 0),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
            ),
            const SizedBox(height: 6),
            Text(
              day.day,
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                fontSize: 10,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSourceRow(_SourceData source, bool isDark) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(source.icon, color: accent, size: 16),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.name,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: source.fraction,
                  minHeight: 4,
                  backgroundColor: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${source.amount} XP',
              style: AppTypography.monoCaption.copyWith(
                color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
              ),
            ),
            Text(
              '${(source.fraction * 100).toInt()}%',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _predictionItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.monoSmall.copyWith(
            color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _XpBarPainter extends CustomPainter {
  const _XpBarPainter({
    required this.progress,
    required this.bgColor,
    required this.fillColor,
    required this.glowColor,
  });

  final double progress;
  final Color bgColor;
  final Color fillColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Fill
    if (progress > 0) {
      final fillWidth = size.width * progress;
      // Glow
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, size.height),
          const Radius.circular(16),
        ),
        glowPaint,
      );

      // Gradient fill
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF006FCD), const Color(0xFF00C6FF)],
        ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, size.height),
          const Radius.circular(16),
        ),
        fillPaint,
      );

      // Shine stripe
      final shinePaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, fillWidth, size.height / 2),
          const Radius.vertical(top: Radius.circular(16)),
        ),
        shinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _XpBarPainter old) => old.progress != progress;
}

class _XpEventTile extends StatelessWidget {
  const _XpEventTile({
    required this.event,
    required this.isDark,
    required this.showTime,
  });

  final _XpEvent event;
  final bool isDark;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(event.icon, color: accent, size: 20),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColorsPS5.textPrimary
                        : AppColorsMonitor.textPrimary,
                  ),
                ),
                Text(
                  showTime ? '${event.timeAgo} · ${event.timestamp}' : event.timeAgo,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textSecondary
                        : AppColorsMonitor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            event.xpAmount,
            style: AppTypography.monoSmall.copyWith(
              color: AppColorsPS5.xp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _XpEvent {
  final IconData icon;
  final String title;
  final String xpAmount;
  final String timeAgo;
  final String timestamp;

  const _XpEvent(this.icon, this.title, this.xpAmount, this.timeAgo, this.timestamp);
}

class _XpMilestone {
  final int xpValue;
  final String label;

  const _XpMilestone(this.xpValue, this.label);
}

class _LevelMarker {
  final int level;
  final String name;
  final int xpRequired;

  const _LevelMarker(this.level, this.name, this.xpRequired);
}

class _DailyXp {
  final String day;
  final int xp;

  const _DailyXp(this.day, this.xp);
}

class _SourceData {
  final String name;
  final int amount;
  final IconData icon;
  final double fraction;

  const _SourceData(this.name, this.amount, this.icon, this.fraction);
}
