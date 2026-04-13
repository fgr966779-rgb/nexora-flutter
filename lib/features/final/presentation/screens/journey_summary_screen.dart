import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/extensions/build_context_ext.dart';

/// Екран «Твій шлях до [цілі]» — вертикальний timeline з етапами,
/// повний лінійний графік, статистика серій та кнопки дій.
///
/// Містить:
/// - Title: "Твій шлях до [PS5/Монітора]"
/// - Вертикальний timeline з milestone markers (Початок, 25%, 50%, 75%, 100%)
/// - Повний journey line chart (CustomPainter)
/// - Статистика: total saved, deposit count, avg deposit, time, max deposit, streak
/// - "Поділитися" button
/// - "Нова мета" button
/// - Timeline animations (stagger from top to bottom)
class JourneySummaryScreen extends StatefulWidget {
  const JourneySummaryScreen({
    super.key,
    this.goalName = 'PlayStation 5',
    this.goalIcon = Icons.gamepad_rounded,
  });

  final String goalName;
  final IconData goalIcon;

  @override
  State<JourneySummaryScreen> createState() => _JourneySummaryScreenState();
}

class _JourneySummaryScreenState extends State<JourneySummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timelineController;

  /// Tracks whether the user has scrolled past the timeline section.
  bool _timelineScrolledPast = false;

  /// Controls the visibility of the comparison tooltip on the chart.
  bool _showChartTooltip = false;

  /// Index of the currently highlighted data point on the chart.
  int _highlightedDataPoint = -1;

  /// The selected time range filter for the chart data.
  String _selectedTimeRange = 'Усе';

  /// Scroll controller for detecting scroll position.
  final ScrollController _scrollController = ScrollController();

  /// Timestamp when the screen was first displayed.
  final DateTime _screenEnterTime = DateTime.now();

  /// Available time range filter options.
  static const _timeRangeOptions = ['Усе', '1 міс', '2 міс', '3 міс'];

  // Mock data
  final _timelineData = const [
    _TimelinePoint('Початок', '1 січня 2025', 0, daysTaken: 0),
    _TimelinePoint('25%', '15 січня 2025', 6500, daysTaken: 14),
    _TimelinePoint('50%', '1 лютого 2025', 13000, daysTaken: 31),
    _TimelinePoint('75%', '10 лютого 2025', 19500, daysTaken: 40),
    _TimelinePoint('100%', '15 лютого 2025', 25999, daysTaken: 45),
  ];

  final _chartData = const [
    0, 1200, 2800, 4200, 6500, 7800, 9800, 11500, 13000, 14200,
    15800, 17000, 18000, 19500, 21000, 22500, 23800, 25000, 25999,
  ];

  final _summaryStats = const [
    _SummaryStat(
      icon: Icons.savings_rounded,
      label: 'Всього накопичено',
      value: '25 999 грн',
      colorKey: 'success',
    ),
    _SummaryStat(
      icon: Icons.receipt_long_rounded,
      label: 'Кількість внесків',
      value: '47',
      colorKey: 'accent',
    ),
    _SummaryStat(
      icon: Icons.trending_flat_rounded,
      label: 'Середній внесок',
      value: '553 грн',
      colorKey: 'accent',
    ),
    _SummaryStat(
      icon: Icons.schedule_rounded,
      label: 'Час досягнення',
      value: '1 міс 15 дн',
      colorKey: 'accent',
    ),
    _SummaryStat(
      icon: Icons.arrow_upward_rounded,
      label: 'Найбільший внесок',
      value: '2 000 грн',
      colorKey: 'success',
    ),
    _SummaryStat(
      icon: Icons.local_fire_department_rounded,
      label: 'Найдовша серія',
      value: '21 день',
      colorKey: 'coin',
    ),
  ];

  /// Additional motivational insights generated from the journey data.
  static const _insights = [
    ('Ти накопичував у 2.5 рази швидше за середній темп!', Icons.speed_rounded, 'speed'),
    ('Твоя серія 21 день — це топ 10% серед користувачів!', Icons.leaderboard_rounded, 'rank'),
    ('Найуспішніший день: середа (в середньому +620 грн)', Icons.today_rounded, 'day'),
    ('Ти пропустив лише 3 дні за весь період!', Icons.check_circle_rounded, 'consistency'),
  ];

  /// Weekly breakdown data for the bar chart (mock).
  static const _weeklyBreakdown = [
    _WeeklyData('Тиждень 1', 3200, 5),
    _WeeklyData('Тиждень 2', 5800, 7),
    _WeeklyData('Тиждень 3', 4100, 6),
    _WeeklyData('Тиждень 4', 7200, 7),
    _WeeklyData('Тиждень 5', 3200, 5),
    _WeeklyData('Тиждень 6', 2499, 4),
  ];

  /// Comparison benchmark data — average user performance.
  static const _benchmarkData = {
    'averageDaily': 180.0,
    'averageStreak': 7.0,
    'averageCompletionDays': 60.0,
    'percentile': 85,
  };

  /// Total accumulated amount (computed from chart data).
  double get _totalAccumulated =>
      _chartData.fold<double>(0, (sum, val) => sum + val);

  /// Number of data points in the chart.
  int get _dataPointCount => _chartData.length;

  /// Elapsed time on this screen.
  Duration get _timeOnScreen =>
      DateTime.now().difference(_screenEnterTime);

  /// Whether the chart tooltip should be visible.
  bool get _isTooltipVisible => _showChartTooltip && _highlightedDataPoint >= 0;

  /// The value of the currently highlighted data point.
  double get _highlightedValue {
    if (_highlightedDataPoint < 0 || _highlightedDataPoint >= _chartData.length) {
      return 0;
    }
    return _chartData[_highlightedDataPoint].toDouble();
  }

  /// The maximum value in the chart data.
  double get _chartMaxValue =>
      _chartData.fold<double>(0, (max, val) => val > max ? val.toDouble() : max);

  /// The average value across all chart data points.
  double get _chartAverage =>
      _dataPointCount > 0 ? _totalAccumulated / _dataPointCount : 0;

  /// Weekly breakdown stats — total weeks and best week.
  ({String label, int amount}) get _bestWeek {
    int bestIdx = 0;
    for (int i = 1; i < _weeklyBreakdown.length; i++) {
      if (_weeklyBreakdown[i].amount > _weeklyBreakdown[bestIdx].amount) {
        bestIdx = i;
      }
    }
    return (
      label: _weeklyBreakdown[bestIdx].label,
      amount: _weeklyBreakdown[bestIdx].amount,
    );
  }

  @override
  void initState() {
    super.initState();
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _scrollController.addListener(_onScroll);
  }

  /// Listens to scroll events and triggers chart animation.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    if (offset > 300 && !_timelineScrolledPast) {
      setState(() => _timelineScrolledPast = true);
    }
  }

  /// Validates that all chart data points are non-negative.
  bool _validateChartData() {
    return _chartData.every((val) => val >= 0);
  }

  /// Computes the percentile rank of the user's streak.
  int _computeStreakPercentile() {
    const userStreak = 21;
    final benchmark = _benchmarkData['averageStreak']!;
    final ratio = userStreak / benchmark;
    return ((ratio * 50).clamp(50, 99)).round();
  }

  /// Formats a monetary value with thousand separators.
  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Additional computed properties ──────────────────────────────

  /// The total number of days in the journey timeline.
  int get _totalTimelineDays =>
      _timelineData.lastOrNull?.daysTaken ?? 0;

  /// The median data point value in the chart data.
  double get _chartMedian {
    if (_chartData.isEmpty) return 0;
    final sorted = List<int>.from(_chartData)..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid].toDouble()
        : (sorted[mid] + sorted[mid - 1]) / 2.0;
  }

  /// The standard deviation of chart data values.
  double get _chartStdDev {
    if (_dataPointCount <= 1) return 0;
    final avg = _chartAverage;
    final variance =
        _chartData.fold<double>(0, (sum, v) => sum + (v - avg) * (v - avg)) /
            _dataPointCount;
    return math.sqrt(variance);
  }

  /// The coefficient of variation (CV) — a normalised measure of
  /// data dispersion. Values < 1.0 indicate relatively stable data.
  double get _chartCoefficientOfVariation {
    if (_chartAverage <= 0) return 0;
    return _chartStdDev / _chartAverage;
  }

  /// The percentage of data points above the average value.
  double get _aboveAveragePercentage {
    if (_dataPointCount == 0) return 0;
    final above = _chartData.where((v) => v > _chartAverage).length;
    return (above / _dataPointCount) * 100;
  }

  /// The best single-day deposit amount (max value in chart data).
  int get _bestSingleDeposit => _chartData.fold<int>(
      0, (max, v) => v > max ? v : max);

  /// The worst single-day deposit amount (min non-zero value).
  int get _worstSingleDeposit => _chartData
      .where((v) => v > 0)
      .fold<int>(double.maxFinite.toInt(), (min, v) => v < min ? v : min);

  /// The total number of deposits represented in the chart data
  /// (excludes the starting zero).
  int get _nonZeroDeposits => _chartData.where((v) => v > 0).length;

  /// The consistency score — how evenly distributed the deposits are.
  /// Returns a value in [0, 100] where 100 means perfectly even.
  int get _consistencyScore {
    if (_nonZeroDeposits <= 1) return 100;
    final cv = _chartCoefficientOfVariation;
    if (cv <= 0.1) return 95;
    if (cv <= 0.3) return 80;
    if (cv <= 0.5) return 60;
    if (cv <= 1.0) return 40;
    return 20;
  }

  /// The formatted total accumulated amount with currency symbol.
  String get _formattedTotal => _formatMoney(_totalAccumulated.toInt());

  /// The overall journey performance grade (A+ through D).
  String get _journeyGrade {
    final score = _consistencyScore;
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    return 'D';
  }

  // ── Additional validation helpers ──────────────────────────────

  /// Validates that the chart data has no sudden drops (which could
  /// indicate data corruption). Returns a list of suspicious indices.
  List<int> _detectAnomalousDrops() {
    final anomalies = <int>[];
    for (int i = 1; i < _chartData.length; i++) {
      if (_chartData[i - 1] > 0) {
        final dropRatio = _chartData[i] / _chartData[i - 1];
        if (dropRatio < -0.5) {
          anomalies.add(i);
        }
      }
    }
    return anomalies;
  }

  /// Validates that all timeline points are chronologically ordered
  /// by their days-taken values. Returns `true` if valid.
  bool _validateTimelineOrder() {
    for (int i = 1; i < _timelineData.length; i++) {
      if (_timelineData[i].daysTaken < _timelineData[i - 1].daysTaken) {
        return false;
      }
    }
    return true;
  }

  /// Checks whether the total accumulated amount matches the
  /// last chart data point. Returns `true` if consistent.
  bool _validateDataConsistency() {
    if (_chartData.isEmpty) return true;
    final lastPoint = _chartData.last;
    final accumulated = _totalAccumulated;
    // The last point should be close to the total of all points
    return (lastPoint - accumulated).abs() < lastPoint * 0.1;
  }

  // ── Additional widget builders ─────────────────────────────────

  /// Builds a journey performance summary card with grade,
  /// consistency score, and key highlights.
  Widget _buildPerformanceSummary(
    Color accent, Color textColor, Color subColor, Color cardColor, Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⭐ Оцінка подорожі',
                style: AppTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _consistencyScore >= 80
                      ? AppColorsPS5.success.withOpacity(0.12)
                      : accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(Radii.circular),
                ),
                child: Text(
                  _journeyGrade,
                  style: AppTypography.labelMedium.copyWith(
                    color: _consistencyScore >= 80
                        ? AppColorsPS5.success
                        : accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildDetailStatRow(
            'Стабільність',
            '$_consistencyScore / 100',
            _consistencyScore >= 80
                ? AppColorsPS5.success
                : AppColorsPS5.warning,
            subColor,
          ),
          _buildDetailStatRow(
            'Найкращий день',
            '${_formatMoney(_bestSingleDeposit)} грн',
            AppColorsPS5.coin,
            subColor,
          ),
          _buildDetailStatRow(
            'Вище середнього',
            '${_aboveAveragePercentage.toStringAsFixed(0)}%',
            accent,
            subColor,
          ),
          _buildDetailStatRow(
            'Медіана накопичення',
            '${_chartMedian.toStringAsFixed(0)} грн',
            subColor,
            subColor,
          ),
        ],
      ),
    ).animate().fade(delay: 800.ms, duration: 500.ms);
  }

  /// Builds a single key-value detail row for the performance summary.
  Widget _buildDetailStatRow(
    String label, String value, Color valueColor, Color labelColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: labelColor),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a deposits distribution visualisation showing how
  /// deposits are spread across the journey.
  Widget _buildDistributionVisualisation(
    Color accent, Color subColor, Color cardColor, Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📉 Розподіл внесків',
            style: AppTypography.labelLarge.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '$_nonZeroDeposits внесків за $_totalTimelineDays днів',
            style: AppTypography.labelSmall.copyWith(color: subColor),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 60,
            child: CustomPaint(
              painter: _MiniBarChartPainter(
                data: _chartData.skip(1).toList(),
                accentColor: accent,
                subColor: subColor,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 1000.ms, duration: 500.ms);
  }

  /// Builds a quick-share summary card suitable for generating
  /// a shareable image snippet.
  Widget _buildShareSummaryCard(
    Color accent, Color textColor, Color subColor, Color cardColor, Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.08),
            cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.goalIcon,
              color: accent,
              size: 24,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🏆 ${widget.goalName} — досягнуто!',
                  style: AppTypography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$_formattedTotal за $_totalTimelineDays днів · $_journeyGrade',
                  style: AppTypography.labelSmall.copyWith(color: subColor),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 1200.ms, duration: 400.ms);
  }

  void _onShare() {
    HapticService.lightTap();
    context.showAppToast('Звіт скопійовано!', type: AppToastType.success);
  }

  void _onNewGoal() {
    HapticService.mediumTap();
    context.showAppToast('Створення нової цілі...', type: AppToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final bgColor = isDark ? AppColorsPS5.background : AppColorsMonitor.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Твій шлях до ${widget.goalName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Spacing.lg),

            // ── Goal header ──────────────────────────────────────
            _buildGoalHeader(accent, textColor, subColor, cardColor, borderColor),

            const SizedBox(height: Spacing.xxl),

            // ─── Вертикальний Timeline ───────────────────────────
            Text(
              'Хронологія',
              style: AppTypography.heading3.copyWith(color: textColor),
            ),
            const SizedBox(height: Spacing.md),
            _buildTimeline(accent, textColor, subColor, cardColor),

            const SizedBox(height: Spacing.xxl),

            // ─── Лінійний графік ───────────────────────────────
            Text(
              'Прогрес накопичення',
              style: AppTypography.heading3.copyWith(color: textColor),
            ),
            const SizedBox(height: Spacing.md),
            _buildJourneyChart(accent, subColor, cardColor, borderColor),

            const SizedBox(height: Spacing.xxl),

            // ─── Summary stats ──────────────────────────────────
            Text(
              'Підсумкова статистика',
              style: AppTypography.heading3.copyWith(color: textColor),
            ),
            const SizedBox(height: Spacing.md),
            _buildSummaryStats(accent, textColor, subColor, cardColor, borderColor),

            const SizedBox(height: Spacing.xxl),

            // ─── Buttons ────────────────────────────────────────
            AppButtonSecondary(
              label: 'Поділитися результатом',
              icon: Icons.share_rounded,
              onPressed: _onShare,
            ),
            const SizedBox(height: Spacing.md),
            AppButtonPrimary(
              label: 'Нова мета',
              icon: Icons.add_rounded,
              showGlow: true,
              onPressed: _onNewGoal,
            ),

            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }

  // ── Widget builders ──────────────────────────────────────────────

  Widget _buildGoalHeader(
    Color accent, Color textColor, Color subColor, Color cardColor, Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Icon(
              widget.goalIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ціль досягнута!',
                  style: AppTypography.heading3.copyWith(
                    color: AppColorsPS5.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.goalName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '25 999 грн з 25 999 грн • 100%',
                  style: AppTypography.labelSmall.copyWith(
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFD600),
            size: 32,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      duration: 400.ms,
      curve: AppEasings.spring,
    );
  }

  Widget _buildTimeline(
    Color accent, Color textColor, Color subColor, Color cardColor,
  ) {
    return Column(
      children: List.generate(_timelineData.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final lineIndex = i ~/ 2;
          final progress = _timelineController.value;
          final itemDelay = lineIndex / _timelineData.length;
          final opacity = (progress * _timelineData.length - lineIndex)
              .clamp(0.0, 1.0);
          return FractionallySizedBox(
            widthFactor: 0.06,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.3 * opacity),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }
        final index = i ~/ 2;
        final point = _timelineData[index];
        final isMilestone = point.label == '100%';
        final progress = _timelineController.value;
        final itemDelay = index / _timelineData.length;
        final opacity = (progress * _timelineData.length - index)
            .clamp(0.0, 1.0);
        final slideOffset = (1.0 - opacity) * 20;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slideOffset),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot / milestone marker
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isMilestone
                            ? accent
                            : accent.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: isMilestone
                            ? null
                            : Border.all(color: accent, width: 2),
                        boxShadow: isMilestone
                            ? [
                                BoxShadow(
                                  color: accent.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isMilestone
                          ? const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : Center(
                              child: Text(
                                '${(index * 25)}%',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(width: Spacing.md),
                // Content card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(
                        color: isMilestone
                            ? accent.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              point.label,
                              style: AppTypography.labelLarge.copyWith(
                                color: isMilestone
                                    ? accent
                                    : textColor,
                                fontWeight: isMilestone
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              point.date,
                              style: AppTypography.bodySmall.copyWith(
                                color: subColor,
                              ),
                            ),
                            if (point.daysTaken > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${point.daysTaken} ${point.daysTaken.pluralUAH("день", "дні", "днів")}',
                                style: AppTypography.caption.copyWith(
                                  color: subColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (point.amount > 0)
                          Text(
                            '${point.amount.formatUAH()} грн',
                            style: AppTypography.monoSmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildJourneyChart(
    Color accent, Color subColor, Color cardColor, Color borderColor,
  ) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: CustomPaint(
        painter: _JourneyLineChartPainter(
          data: _chartData,
          targetLine: 25999,
          accentColor: accent,
          textColor: subColor,
          successColor: AppColorsPS5.success,
        ),
        size: Size.infinite,
      ),
    ).animate().fade(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildSummaryStats(
    Color accent, Color textColor, Color subColor, Color cardColor, Color borderColor,
  ) {
    return Column(
      children: _summaryStats.asMap().entries.map((entry) {
        final i = entry.key;
        final stat = entry.value;
        final statColor = _getStatColor(stat.colorKey, accent);

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Icon(stat.icon, color: statColor, size: 20),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    stat.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  stat.value,
                  style: AppTypography.monoSmall.copyWith(
                    color: statColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * i + 400),
          duration: 300.ms,
        ).slideX(
          begin: 0.05,
          end: 0,
          delay: Duration(milliseconds: 100 * i + 400),
          duration: 300.ms,
        );
      }).toList(),
    );
  }

  Color _getStatColor(String colorKey, Color accent) {
    switch (colorKey) {
      case 'success':
        return AppColorsPS5.success;
      case 'coin':
        return AppColorsPS5.coin;
      case 'accent':
        return accent;
      case 'xp':
        return AppColorsPS5.xp;
      case 'warning':
        return AppColorsPS5.warning;
      default:
        return accent;
    }
  }

  // ── Additional widget builders ──────────────────────────────────────

  /// Builds the insights section with motivational cards.
  Widget _buildInsightsSection(Color accent, Color textColor, Color subColor, Color cardColor) {
    return Column(
      children: [
        Text('💡 Інсайти', style: AppTypography.heading3.copyWith(color: textColor)),
        const SizedBox(height: Spacing.md),
        ..._insights.asMap().entries.map((entry) {
          final i = entry.key;
          final insight = entry.value;
          final insightColor = _getInsightColor(insight.$3, accent);
          return Container(
            margin: const EdgeInsets.only(bottom: Spacing.sm),
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: insightColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: insightColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(insight.$2, color: insightColor, size: 20),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(insight.$1, style: AppTypography.labelSmall.copyWith(color: textColor)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 200 * i + 600), duration: 400.ms);
        }),
      ],
    );
  }

  /// Returns a colour for the insight card based on its category key.
  Color _getInsightColor(String categoryKey, Color accent) {
    switch (categoryKey) {
      case 'speed': return AppColorsPS5.success;
      case 'rank': return AppColorsPS5.coin;
      case 'day': return accent;
      case 'consistency': return AppColorsPS5.xp;
      default: return accent;
    }
  }

  /// Builds the weekly breakdown bar chart section.
  Widget _buildWeeklyBreakdown(Color accent, Color subColor, Color cardColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text('📊 Підсумок по тижнях', style: AppTypography.labelLarge.copyWith(color: accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          ..._weeklyBreakdown.map((week) {
            final maxAmount = _bestWeek.amount;
            final barFraction = week.amount / maxAmount;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(week.label, style: AppTypography.caption.copyWith(color: subColor)),
                      Text('${_formatMoney(week.amount)} грн', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barFraction,
                      backgroundColor: accent.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: Spacing.sm),
          Text('Найкращий: ${_bestWeek.label} (${_formatMoney(_bestWeek.amount)} грн)', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fade(delay: 600.ms, duration: 500.ms);
  }

  /// Builds the benchmark comparison section.
  Widget _buildBenchmarkComparison(Color accent, Color textColor, Color subColor, Color cardColor, Color borderColor) {
    final percentile = _computeStreakPercentile();
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text('🏆 Порівняння з середнім', style: AppTypography.labelLarge.copyWith(color: accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.md),
          _buildBenchmarkRow('Твоя серія', '21 дн', 'Сер. користувача', '${_benchmarkData['averageStreak']!.toInt()} дн', true, accent, subColor),
          _buildBenchmarkRow('Час досягнення', '45 дн', 'Середній', '${_benchmarkData['averageCompletionDays']!.toInt()} дн', true, AppColorsPS5.success, subColor),
          _buildBenchmarkRow('Середній внесок', '553 грн', 'Середній', '${_benchmarkData['averageDaily']!.toInt()} грн', true, accent, subColor),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: AppColorsPS5.coin.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Text('Ти кращий за $percentile% користувачів! 🎉', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  /// Builds a single benchmark comparison row.
  Widget _buildBenchmarkRow(String yourLabel, String yourValue, String avgLabel, String avgValue, bool youAreBetter, Color valueColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(yourLabel, style: AppTypography.caption.copyWith(color: labelColor)),
                Text(yourValue, style: AppTypography.labelSmall.copyWith(color: valueColor, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Icon(youAreBetter ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, color: youAreBetter ? AppColorsPS5.success : AppColorsPS5.warning, size: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(avgLabel, style: AppTypography.caption.copyWith(color: labelColor.withOpacity(0.6))),
                Text(avgValue, style: AppTypography.labelSmall.copyWith(color: labelColor.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the time range filter chips for the chart.
  Widget _buildTimeRangeFilter(Color accent, Color subColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _timeRangeOptions.map((range) {
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () {
              HapticService.selection();
              setState(() => _selectedTimeRange = range);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: Spacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
              decoration: BoxDecoration(
                color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.circular),
                border: Border.all(color: isSelected ? accent : subColor.withOpacity(0.3), width: 1),
              ),
              child: Text(range, style: AppTypography.labelSmall.copyWith(color: isSelected ? accent : subColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelinePoint {
  final String label;
  final String date;
  final int amount;
  final int daysTaken;

  const _TimelinePoint(
    this.label,
    this.date,
    this.amount, {
    required this.daysTaken,
  });
}

class _SummaryStat {
  final IconData icon;
  final String label;
  final String value;
  final String colorKey;

  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorKey,
  });
}

/// Represents weekly breakdown data for the bar chart.
class _WeeklyData {
  final String label;
  final int amount;
  final int depositCount;

  const _WeeklyData(this.label, this.amount, this.depositCount);
}

/// CustomPainter: повний лінійний графік з цільовою лінією, градієнтом
/// та анотованими точками етапів.
class _JourneyLineChartPainter extends CustomPainter {
  const _JourneyLineChartPainter({
    required this.data,
    required this.targetLine,
    required this.accentColor,
    required this.textColor,
    required this.successColor,
  });

  final List<int> data;
  final int targetLine;
  final Color accentColor;
  final Color textColor;
  final Color successColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxValue = data.reduce(math.max).toDouble();
    final minValue = 0.0;
    final range = (maxValue - minValue).clamp(1, double.infinity);
    final targetD = targetLine.toDouble();
    final allMax = math.max(maxValue, targetD);

    final padding = const EdgeInsets.only(left: 40, right: 16, top: 8, bottom: 24);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // ── Grid lines ──────────────────────────────────────────────
    for (int i = 0; i <= 4; i++) {
      final y = padding.top + chartHeight * (1 - i / 4);
      final paint = Paint()
        ..color = textColor.withOpacity(0.1)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        paint,
      );

      final value = (allMax * i / 4);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(value / 1000).toStringAsFixed(0)}K',
          style: AppTypography.monoCaption.copyWith(
            color: textColor,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // ── Line path ───────────────────────────────────────────────
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (chartWidth / (data.length - 1)) * i;
      final y = padding.top + chartHeight * (1 - (data[i] - minValue) / allMax);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Gradient fill
    final fillPath = Path()
      ..moveTo(padding.left, size.height - padding.bottom)
      ..lineTo(padding.left, padding.top + chartHeight - (data[0] / allMax * chartHeight));
    for (int i = 1; i < data.length; i++) {
      final x = padding.left + (chartWidth / (data.length - 1)) * i;
      final y = padding.top + chartHeight * (1 - (data[i] - minValue) / allMax);
      fillPath.lineTo(x, y);
    }
    fillPath.lineTo(
      padding.left + chartWidth,
      size.height - padding.bottom,
    );
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        successColor.withOpacity(0.15),
        successColor.withOpacity(0.01),
      ],
    );
    canvas.drawPath(
      fillPath,
      Paint()..shader = fillGradient.createShader(Rect.fromLTWH(
        padding.left,
        padding.top,
        chartWidth,
        chartHeight,
      )),
    );

    // Glow
    final glowPaint = Paint()
      ..color = successColor.withOpacity(0.25)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // Line
    final linePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [successColor, accentColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // ── Target dashed line ─────────────────────────────────────
    final targetY = padding.top +
        chartHeight * (1 - targetD / allMax);
    final dashPaint = Paint()
      ..color = successColor.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    var x = padding.left;
    while (x < size.width - padding.right) {
      final endX = (x + dashWidth).clamp(x, size.width - padding.right);
      canvas.drawLine(
        Offset(x, targetY),
        Offset(endX, targetY),
        dashPaint,
      );
      x += dashWidth + dashSpace;
    }
    // Target label
    final targetLabel = TextPainter(
      text: TextSpan(
        text: 'Ціль',
        style: TextStyle(
          color: successColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    targetLabel.paint(
      canvas,
      Offset(size.width - padding.right - targetLabel.width - 4, targetY - 14),
    );

    // ── Dots at data points ────────────────────────────────────
    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (chartWidth / (data.length - 1)) * i;
      final y = padding.top +
          chartHeight * (1 - (data[i] - minValue) / allMax);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = accentColor);
    }

    // Milestone dots at 25%, 50%, 75%, 100%
    final milestones = [0.25, 0.5, 0.75, 1.0];
    for (final m in milestones) {
      final targetVal = targetD * m;
      // Find closest data point
      int closestIdx = 0;
      double minDiff = double.infinity;
      for (int i = 0; i < data.length; i++) {
        final diff = (data[i] - targetVal).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIdx = i;
        }
      }
      final x = padding.left +
          (chartWidth / (data.length - 1)) * closestIdx;
      final y = padding.top +
          chartHeight * (1 - (data[closestIdx] - minValue) / allMax);
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = successColor.withOpacity(0.3),
      );
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = successColor,
      );
    }

    // ── X-axis labels ──────────────────────────────────────────
    final totalDays = data.length;
    final totalDuration = 45; // days
    for (int i = 0; i < data.length; i += 4) {
      final x = padding.left + (chartWidth / (data.length - 1)) * i;
      final dayLabel = 'Д${(totalDuration * i ~/ totalDays)}';
      final span = TextSpan(
        text: dayLabel,
        style: TextStyle(color: textColor, fontSize: 8),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyLineChartPainter old) => old.data != data;
}

// ──────────────────────────────────────────────────────────────────────
// Smooth Area Chart Painter
// ──────────────────────────────────────────────────────────────────────

/// Renders a smooth area chart with a vertical gradient fill.
///
/// Uses Bézier curve interpolation for smoother lines compared to
/// the straight-segment [_JourneyLineChartPainter].
class _SmoothAreaChartPainter extends CustomPainter {
  const _SmoothAreaChartPainter({
    required this.data,
    required this.fillColor,
    required this.strokeColor,
    this.curveTension = 0.3,
  });

  final List<int> data;
  final Color fillColor;
  final Color strokeColor;
  final double curveTension;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final maxValue = data.reduce(math.max).toDouble().clamp(1, double.infinity);
    final padding = const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (chartWidth / (data.length - 1)) * i;
      final y = padding.top + chartHeight * (1 - data[i] / maxValue);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = padding.left + (chartWidth / (data.length - 1)) * (i - 1);
        final prevY = padding.top + chartHeight * (1 - data[i - 1] / maxValue);
        final controlX = (prevX + x) / 2;
        path.cubicTo(controlX, prevY + (y - prevY) * curveTension, controlX, prevY + (y - prevY) * (1 - curveTension), x, y);
      }
    }

    final fillPath = Path()..addPath(path, Offset.zero);
    fillPath.lineTo(padding.left + chartWidth, size.height - padding.bottom);
    fillPath.lineTo(padding.left, size.height - padding.bottom);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [fillColor.withOpacity(0.25), fillColor.withOpacity(0.02)],
    );
    canvas.drawPath(fillPath, Paint()..shader = fillGradient.createShader(Rect.fromLTWH(padding.left, padding.top, chartWidth, chartHeight)));

    final glowPaint = Paint()
      ..color = strokeColor.withOpacity(0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    canvas.drawPath(path, Paint()
      ..color = strokeColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    for (int i = 0; i < data.length; i++) {
      final x = padding.left + (chartWidth / (data.length - 1)) * i;
      final y = padding.top + chartHeight * (1 - data[i] / maxValue);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = strokeColor);
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothAreaChartPainter old) => old.data != data;
}

// ──────────────────────────────────────────────────────────────────────
// Mini Bar Chart Painter
// ──────────────────────────────────────────────────────────────────────

/// Renders a compact bar chart with rounded tops for the deposits
/// distribution visualisation.
///
/// Each bar represents a single deposit value. The chart auto-scales
/// to the maximum value in the data set and uses [accentColor] for
/// bars that exceed the average and [subColor] for those below.
class _MiniBarChartPainter extends CustomPainter {
  const _MiniBarChartPainter({
    required this.data,
    required this.accentColor,
    required this.subColor,
    this.barGap = 2.0,
  });

  final List<int> data;
  final Color accentColor;
  final Color subColor;
  final double barGap;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce(math.max).toDouble().clamp(1, double.infinity);
    final barWidth =
        ((size.width - barGap * (data.length - 1)) / data.length)
            .clamp(2.0, double.infinity);
    final avgVal = data.reduce((a, b) => a + b) / data.length;

    for (int i = 0; i < data.length; i++) {
      final fraction = data[i] / maxVal;
      final barHeight = fraction * size.height;
      final x = i * (barWidth + barGap);
      final y = size.height - barHeight;

      final paint = Paint()
        ..color = data[i] >= avgVal ? accentColor : subColor.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarChartPainter old) => old.data != data;
}
