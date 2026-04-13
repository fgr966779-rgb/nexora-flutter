import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/widgets/app_card.dart';

/// Екран «Твій рівень» — кільцевий прогрес XP, номер рівня, бонуси, XP розбивка,
/// детальна історія рівнів, попередній перегляд наступного рівня, переваги.
class UserLevelScreen extends StatefulWidget {
  const UserLevelScreen({super.key});

  @override
  State<UserLevelScreen> createState() => _UserLevelScreenState();
}

class _UserLevelScreenState extends State<UserLevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnim;
  late Animation<int> _countAnim;
  late Animation<double> _glowAnim;
  bool _showReplayAnimation = false;

  // Demo data — в реальному додатку бере з provider
  final int currentLevel = 4;
  final String levelName = 'Майстер';
  final int currentXp = 1200;
  final int xpForNext = 1500;
  final int xpForCurrent = 700;
  final int totalXpEarned = 3850;
  final int daysActive = 45;
  final int longestStreak = 14;

  final _levelBonuses = const [
    (Icons.star_rounded, '+15% XP за щоденний вхід'),
    (Icons.monetization_on_rounded, '+10% монет за виклики'),
    (Icons.auto_awesome_rounded, 'Доступ до ексклюзивних значків'),
    (Icons.speed_rounded, 'Пріоритетний доступ до нових функцій'),
    (Icons.palette_rounded, 'Унікальна рамка аватара'),
  ];

  final _nextLevelBonuses = const [
    'x2 множник за виконання викликів',
    'Відкриття преміум теми «Золото»',
    '+500 бонусних монет при підвищенні',
    'Ексклюзивний значок «Чемпіон»',
  ];

  final _xpBreakdown = const [
    _XpSource('Щоденний вхід', 90, Icons.login_rounded, AppColorsPS5.accent),
    _XpSource('Ручні внески', 1850, Icons.edit_rounded, AppColorsPS5.success),
    _XpSource('Виконання викликів', 1200, Icons.emoji_events_rounded, AppColorsPS5.warning),
    _XpSource('Серії', 480, Icons.local_fire_department_rounded, Colors.orangeAccent),
    _XpSource('Досягнення', 230, Icons.military_tech_rounded, Colors.purpleAccent),
  ];

  final _recentLevelUps = const [
    _LevelUpRecord('Рівень 1 — Новачок', '5 січня 2025', '0 XP', 1),
    _LevelUpRecord('Рівень 2 — Учень', '15 січня 2025', '250 XP', 2),
    _LevelUpRecord('Рівень 3 — Воїн', '28 січня 2025', '500 XP', 3),
    _LevelUpRecord('Рівень 4 — Майстер', '10 лютого 2025', '700 XP', 4),
  ];

  double get _progress {
    final range = xpForNext - xpForCurrent;
    if (range <= 0) return 1.0;
    return ((currentXp - xpForCurrent) / range).clamp(0.0, 1.0);
  }

  int get _xpRemaining => xpForNext - currentXp;

  int get _xpThisLevel => currentXp - xpForCurrent;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _ringAnim = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic),
    );

    _countAnim = IntTween(begin: 0, end: currentLevel).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    _ringController.forward();
  }

  void _replayAnimation() {
    setState(() => _showReplayAnimation = true);
    _ringController.reset();
    _ringController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showReplayAnimation = false);
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Твій рівень'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded),
            onPressed: _replayAnimation,
            tooltip: 'Повторити анімацію',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: Spacing.lg),

            // ─── Кільцевий прогрес з glow ─────────────────────────
            AnimatedBuilder(
              animation: _ringController,
              builder: (context, _) {
                return SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: _LevelRingPainter(
                      progress: _ringAnim.value,
                      strokeWidth: 16,
                      ringColor:
                          isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                      bgColor:
                          isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                      glowOpacity: _glowAnim.value,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Рівень з count-up анімацією
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (_, __) => Text(
                              '${_countAnim.value}',
                              style: AppTypography.displayLarge.copyWith(
                                color: isDark
                                    ? AppColorsPS5.textPrimary
                                    : AppColorsMonitor.textPrimary,
                                fontSize: 56,
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          // Назва рівня
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColorsPS5.accent
                                      : AppColorsMonitor.accent)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(Radii.xl),
                            ),
                            child: Text(
                              levelName,
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColorsPS5.accent
                                    : AppColorsMonitor.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                .animate()
                .scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 600.ms,
                    curve: Curves.easeOutBack)
                .then()
                .shimmer(duration: 1800.ms, color: Colors.white.withOpacity(0.2)),

            const SizedBox(height: Spacing.xl),

            // ─── XP текст ────────────────────────────────────────
            Text(
              '$currentXp / $xpForNext XP',
              style: AppTypography.monoMedium.copyWith(
                color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Ще $_xpRemaining XP до наступного рівня',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColorsPS5.textSecondary
                    : AppColorsMonitor.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Загалом накопичено $totalXpEarned XP',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColorsPS5.textHint
                    : AppColorsMonitor.textHint,
              ),
            ),

            const SizedBox(height: Spacing.xl),

            // ─── Швидка статистика ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _quickStat('Днів активності', '$daysActive', isDark),
                Container(width: 1, height: 32, color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                _quickStat('Найдовша серія', '$longestStreak дн', isDark),
                Container(width: 1, height: 32, color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                _quickStat('XP на рівні', '$_xpThisLevel', isDark),
              ],
            ),

            const SizedBox(height: Spacing.xxl),

            // ─── Розподіл XP за джерелами ────────────────────────
            AppCard(
              isLightTheme: !isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart_rounded,
                          color: isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent,
                          size: 20),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Розподіл XP',
                        style: AppTypography.heading3.copyWith(
                          color: isDark
                              ? AppColorsPS5.textPrimary
                              : AppColorsMonitor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  ..._xpBreakdown.asMap().entries.map((entry) {
                    final i = entry.key;
                    final source = entry.value;
                    final fraction = source.amount / totalXpEarned;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < _xpBreakdown.length - 1 ? Spacing.sm : 0),
                      child: _buildXpSourceRow(source, fraction, isDark),
                    );
                  }),
                ],
              ),
            ).animate().fade(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Бонуси поточного рівня ──────────────────────────
            AppCard(
              isLightTheme: !isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_giftcard_rounded,
                          color: isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent,
                          size: 20),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Бонуси рівня $currentLevel',
                        style: AppTypography.heading3.copyWith(
                          color: isDark
                              ? AppColorsPS5.textPrimary
                              : AppColorsMonitor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  ..._levelBonuses.asMap().entries.map((entry) {
                    final i = entry.key;
                    final bonus = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < _levelBonuses.length - 1 ? Spacing.sm : 0),
                      child: _buildBonusRow(
                          bonus.$1, bonus.$2, isDark),
                    );
                  }),
                ],
              ),
            ).animate().fade(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Наступний рівень з прев'ю ──────────────────────
            AppCard(
              isLightTheme: !isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColorsPS5.accent
                                  : AppColorsMonitor.accent)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Рівень ${currentLevel + 1}: Чемпіон',
                              style: AppTypography.labelLarge.copyWith(
                                color: isDark
                                    ? AppColorsPS5.textPrimary
                                    : AppColorsMonitor.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$xpForNext XP для розблокування',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColorsPS5.textSecondary
                                    : AppColorsMonitor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  // Міні прогрес бар
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppColorsPS5.border
                          : AppColorsMonitor.border,
                      valueColor: AlwaysStoppedAnimation(
                        isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Що розблокується:',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColorsPS5.textSecondary
                          : AppColorsMonitor.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  ..._nextLevelBonuses.map((bonus) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.xs),
                        child: Row(
                          children: [
                            Icon(Icons.lock_open_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColorsPS5.accent
                                    : AppColorsMonitor.accent),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: Text(
                                bonus,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColorsPS5.textSecondary
                                      : AppColorsMonitor.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  // Оцінка часу до наступного рівня
                  const SizedBox(height: Spacing.md),
                  Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent)
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 16,
                            color: isDark
                                ? AppColorsPS5.accent
                                : AppColorsMonitor.accent),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          'Приблизно ~7 днів при нинішньому темпі',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColorsPS5.textSecondary
                                : AppColorsMonitor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Детальна історія рівнів ─────────────────────────
            AppCard(
              isLightTheme: !isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Історія рівнів',
                    style: AppTypography.heading3.copyWith(
                      color: isDark
                          ? AppColorsPS5.textPrimary
                          : AppColorsMonitor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  ..._recentLevelUps.asMap().entries.map((entry) {
                    final i = entry.key;
                    final record = entry.value;
                    final isLast = i == _recentLevelUps.length - 1;
                    return _buildLevelHistoryItem(record, isLast, isDark);
                  }),
                ],
              ),
            ).animate().fade(delay: 800.ms, duration: 400.ms),

            const SizedBox(height: Spacing.xxl),

            // ─── Повторити анімацію ──────────────────────────────
            if (_showReplayAnimation)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColorsPS5.accent
                            : AppColorsMonitor.accent)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Radii.xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.animation_rounded, size: 16),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Анімація відтворюється...',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 300.ms),

            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _quickStat(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColorsPS5.textHint
                  : AppColorsMonitor.textHint,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpSourceRow(_XpSource source, double fraction, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: source.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(source.icon, size: 14, color: source.color),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.name,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColorsPS5.textPrimary
                      : AppColorsMonitor.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 4,
                  backgroundColor: isDark
                      ? AppColorsPS5.border
                      : AppColorsMonitor.border,
                  valueColor: AlwaysStoppedAnimation(source.color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          '${source.amount}',
          style: AppTypography.monoCaption.copyWith(
            color: isDark
                ? AppColorsPS5.textSecondary
                : AppColorsMonitor.textSecondary,
          ),
        ),
        Text(
          ' (${(fraction * 100).toInt()}%)',
          style: AppTypography.caption.copyWith(
            color: isDark
                ? AppColorsPS5.textHint
                : AppColorsMonitor.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildBonusRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color:
                (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(icon,
              size: 16,
              color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColorsPS5.textSecondary
                  : AppColorsMonitor.textSecondary,
            ),
          ),
        ),
        Icon(Icons.check_rounded,
            size: 16,
            color: isDark ? AppColorsPS5.success : AppColorsMonitor.success),
      ],
    );
  }

  Widget _buildLevelHistoryItem(
      _LevelUpRecord record, bool isLast, bool isDark) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline dot + line
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.3), blurRadius: 4),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColorsPS5.textPrimary
                          : AppColorsMonitor.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        record.date,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColorsPS5.textHint
                              : AppColorsMonitor.textHint,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        record.xpReq,
                        style: AppTypography.monoCaption.copyWith(
                          color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpSource {
  final String name;
  final int amount;
  final IconData icon;
  final Color color;

  const _XpSource(this.name, this.amount, this.icon, this.color);
}

class _LevelUpRecord {
  final String title;
  final String date;
  final String xpReq;
  final int level;

  const _LevelUpRecord(this.title, this.date, this.xpReq, this.level);
}

/// CustomPainter: кільцевий прогрес з градієнтом та glow-ефектом.
class _LevelRingPainter extends CustomPainter {
  _LevelRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.ringColor,
    required this.bgColor,
    required this.glowOpacity,
  });

  final double progress;
  final double strokeWidth;
  final Color ringColor;
  final Color bgColor;
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Фон кільця
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Прогрес
    if (progress > 0) {
      // Glow шар
      final glowPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi * progress,
          colors: [
            const Color(0xFF006FCD).withOpacity(glowOpacity * 0.5),
            const Color(0xFF00C6FF).withOpacity(glowOpacity * 0.5),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );

      // Основний градієнтний прогрес
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [const Color(0xFF006FCD), const Color(0xFF00C6FF)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Кінцева точка (крапка)
      final endAngle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelRingPainter old) =>
      old.progress != progress || old.glowOpacity != glowOpacity;
}
