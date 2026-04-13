import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../providers/dashboard_provider.dart';

/// Екран порівняння двох періодів: стовпчикова діаграма з парними барами,
/// підсумкова картка, порівняння серій, щоденне порівняння, кнопка swap,
/// українські мотивувальні повідомлення.
class PeriodComparisonScreen extends StatefulWidget {
  const PeriodComparisonScreen({super.key});

  static const String route = '/period-comparison';

  @override
  State<PeriodComparisonScreen> createState() =>
      _PeriodComparisonScreenState();
}

class _PeriodComparisonScreenState extends State<PeriodComparisonScreen> {
  DateTime _periodAStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _periodAEnd = DateTime.now();
  DateTime _periodBStart = DateTime.now().subtract(const Duration(days: 60));
  DateTime _periodBEnd = DateTime.now().subtract(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Порівняння',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz_rounded, color: c.textSecondary),
            onPressed: _swapPeriods,
            tooltip: 'Поміняти періоди місцями',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final dataA = provider.getDataForRange(_periodAStart, _periodAEnd);
          final dataB = provider.getDataForRange(_periodBStart, _periodBEnd);

          // Weekly aggregation
          final weeklyA = _aggregateWeekly(dataA);
          final weeklyB = _aggregateWeekly(dataB);
          final totalA = dataA.fold<double>(0, (s, t) => s + t.amount);
          final totalB = dataB.fold<double>(0, (s, t) => s + t.amount);
          final diffPercent = totalB > 0
              ? ((totalA - totalB) / totalB * 100)
              : (totalA > 0 ? 100.0 : 0.0);
          final isMore = diffPercent >= 0;

          final streakA = provider.streakForRange(_periodAStart, _periodAEnd);
          final streakB = provider.streakForRange(_periodBStart, _periodBEnd);

          final avgDailyA = dataA.isNotEmpty
              ? totalA / (_periodAEnd.difference(_periodAStart).inDays + 1)
              : 0.0;
          final avgDailyB = dataB.isNotEmpty
              ? totalB / (_periodBEnd.difference(_periodBStart).inDays + 1)
              : 0.0;

          final bestDayA = dataA.isNotEmpty
              ? dataA.map((t) => t.amount).reduce(math.max)
              : 0.0;
          final bestDayB = dataB.isNotEmpty
              ? dataB.map((t) => t.amount).reduce(math.max)
              : 0.0;

          final worstDayA = dataA.isNotEmpty
              ? dataA.map((t) => t.amount).reduce(math.min)
              : 0.0;
          final worstDayB = dataB.isNotEmpty
              ? dataB.map((t) => t.amount).reduce(math.min)
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              children: [
                const SizedBox(height: Spacing.base),

                // ── Date pickers row ───────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _DateRangeCard(
                        label: 'Період A',
                        start: _periodAStart,
                        end: _periodAEnd,
                        color: c.accent,
                        isLightTheme: !isDark,
                        onTap: () => _pickPeriodA(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.border.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Icon(
                          Icons.compare_arrows_rounded,
                          color: c.textHint,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DateRangeCard(
                        label: 'Період B',
                        start: _periodBStart,
                        end: _periodBEnd,
                        color: c.coin,
                        isLightTheme: !isDark,
                        onTap: () => _pickPeriodB(context),
                      ),
                    ),
                  ],
                ),

                // Swap button
                const SizedBox(height: Spacing.sm),
                Center(
                  child: TextButton.icon(
                    onPressed: _swapPeriods,
                    icon: Icon(Icons.swap_horiz_rounded, size: 16, color: c.accent),
                    label: Text(
                      'Поміняти місцями',
                      style: AppTypography.labelSmall.copyWith(color: c.accent),
                    ),
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                // ── Summary card ───────────────────────────────────
                _buildSummaryCard(
                  isMore: isMore,
                  diffPercent: diffPercent,
                  streakA: streakA,
                  streakB: streakB,
                  totalA: totalA,
                  totalB: totalB,
                  c: c,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: Spacing.xl),

                // ── Bar chart ──────────────────────────────────────
                _buildBarChart(
                  weeklyA: weeklyA,
                  weeklyB: weeklyB,
                  c: c,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: Spacing.xl),

                // ── Detailed comparison ───────────────────────────
                Text(
                  'Детальне порівняння',
                  style: AppTypography.heading3.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Spacing.sm),

                _buildComparisonRow(
                  label: 'Сер./день',
                  valueA: '${avgDailyA.formatUAH()} грн',
                  valueB: '${avgDailyB.formatUAH()} грн',
                  c: c,
                  isDark: isDark,
                  colorA: c.accent,
                  colorB: c.coin,
                  isBetter: avgDailyA >= avgDailyB,
                ),

                _buildComparisonRow(
                  label: 'Найкращий день',
                  valueA: '${bestDayA.formatUAH()} грн',
                  valueB: '${bestDayB.formatUAH()} грн',
                  c: c,
                  isDark: isDark,
                  colorA: c.accent,
                  colorB: c.coin,
                  isBetter: bestDayA >= bestDayB,
                ),

                _buildComparisonRow(
                  label: 'Найгірший день',
                  valueA: '${worstDayA.formatUAH()} грн',
                  valueB: '${worstDayB.formatUAH()} грн',
                  c: c,
                  isDark: isDark,
                  colorA: c.accent,
                  colorB: c.coin,
                  isBetter: worstDayA >= worstDayB,
                ),

                _buildComparisonRow(
                  label: 'Найдовша серія',
                  valueA: '$streakA дн',
                  valueB: '$streakB дн',
                  c: c,
                  isDark: isDark,
                  colorA: c.accent,
                  colorB: c.coin,
                  isBetter: streakA >= streakB,
                ),

                const SizedBox(height: Spacing.xl),

                // ── Motivational message ──────────────────────────
                _buildMotivationMessage(isMore, diffPercent, c, isDark),

                const SizedBox(height: Spacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────

  Future<void> _pickPeriodA(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _periodAStart, end: _periodAEnd),
    );
    if (range != null) {
      HapticService.selection();
      setState(() {
        _periodAStart = range.start;
        _periodAEnd = range.end;
      });
    }
  }

  Future<void> _pickPeriodB(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _periodBStart, end: _periodBEnd),
    );
    if (range != null) {
      HapticService.selection();
      setState(() {
        _periodBStart = range.start;
        _periodBEnd = range.end;
      });
    }
  }

  void _swapPeriods() {
    HapticService.mediumTap();
    setState(() {
      final tempStart = _periodAStart;
      final tempEnd = _periodAEnd;
      _periodAStart = _periodBStart;
      _periodAEnd = _periodBEnd;
      _periodBStart = tempStart;
      _periodBEnd = tempEnd;
    });
  }

  // ── Widget builders ──────────────────────────────────────────────

  Widget _buildSummaryCard({
    required bool isMore,
    required double diffPercent,
    required int streakA,
    required int streakB,
    required double totalA,
    required double totalB,
    required dynamic c,
    required bool isDark,
  }) {
    final motivationalMsg = isMore
        ? _getPositiveMessage(diffPercent)
        : _getMotivationalMessage(diffPercent);

    return AppCard(
      isLightTheme: !isDark,
      child: Column(
        children: [
          Text(
            'Ти накопичив на',
            style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),

          // Big percentage
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: (isMore ? c.success : c.error).withOpacity(0.08),
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMore
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isMore ? c.success : c.error,
                  size: 24,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  '${isMore ? '+' : ''}${diffPercent.toStringAsFixed(1)}%',
                  style: AppTypography.monoLarge.copyWith(
                    fontSize: 36,
                    color: isMore ? c.success : c.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  isMore ? 'більше' : 'менше',
                  style: AppTypography.bodyLarge.copyWith(
                    color: isMore ? c.success : c.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.base),

          // Period totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StreakCompare(
                label: 'Період A',
                value: '${totalA.formatUAH()} грн',
                streak: streakA,
                color: c.accent,
              ),
              _StreakCompare(
                label: 'Період B',
                value: '${totalB.formatUAH()} грн',
                streak: streakB,
                color: c.coin,
              ),
            ],
          ),

          const SizedBox(height: Spacing.sm),

          // Motivational message
          Text(
            motivationalMsg,
            style: AppTypography.labelSmall.copyWith(
              color: isMore ? c.success.withOpacity(0.7) : c.error.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPositiveMessage(double percent) {
    if (percent >= 50) return 'Неймовірний результат! Ти справжній чемпіон заощаджень! 🔥';
    if (percent >= 30) return 'Вражаючий прогрес! Так тримати, ти на правильному шляху! 💪';
    if (percent >= 15) return 'Хороше зростання! Кожен внесок наближає тебе до цілі! 📈';
    if (percent >= 5) return 'Невелике, але стабільне зростання. Продовжуй у тому ж дусі! ✨';
    return 'Ти трохи випереджаєш минулий період. Не зупиняйся! 🎯';
  }

  String _getMotivationalMessage(double percent) {
    if (percent <= -50) return 'Не здавайся! Навіть найменший внесок має значення. Почни сьогодні! 💫';
    if (percent <= -30) return 'Складний період, але ти вже довів, що можеш! Повертайся до ритму! 🌟';
    if (percent <= -15) return 'Трохи відстав від минулого темпу. Але ти все ще на шляху до мети! 🚶';
    return 'Майже на рівні з минулим періодом. Ще трохи зусиль і ти випередиш! 💡';
  }

  Widget _buildBarChart({
    required List<double> weeklyA,
    required List<double> weeklyB,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Порівняння по тижнях',
            style: AppTypography.heading3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Spacing.base),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _GroupedBarChartPainter(
                dataA: weeklyA,
                dataB: weeklyB,
                colorA: c.accent,
                colorB: c.coin,
                textColor: c.textHint,
                gridColor: c.border.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                'Період A',
                style: AppTypography.labelSmall.copyWith(
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(width: Spacing.base),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: c.coin,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                'Період B',
                style: AppTypography.labelSmall.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String valueA,
    required String valueB,
    required dynamic c,
    required bool isDark,
    required Color colorA,
    required Color colorB,
    required bool isBetter,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Container(
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
            // Label
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            // Value A
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorA,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      valueA,
                      style: AppTypography.monoSmall.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // VS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'vs',
                style: AppTypography.caption.copyWith(
                  color: c.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Value B
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorB,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      valueB,
                      style: AppTypography.monoSmall.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationMessage(
    bool isMore, double diffPercent, dynamic c, bool isDark,
  ) {
    final message = isMore
        ? _getPositiveMessage(diffPercent)
        : _getMotivationalMessage(diffPercent);
    final color = isMore ? c.success : c.coin;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            isMore ? Icons.auto_awesome_rounded : Icons.favorite_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: c.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<double> _aggregateWeekly(List transactions) {
    final weeklyTotals = <double>[];
    final weeklyMap = <int, double>{};
    for (final t in transactions) {
      final week = t.createdAt.millisecondsSinceEpoch ~/ (7 * 24 * 3600 * 1000);
      weeklyMap[week] = (weeklyMap[week] ?? 0) + (t.amount as double);
    }
    weeklyTotals.addAll(weeklyMap.values);
    return weeklyTotals;
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.label,
    required this.start,
    required this.end,
    required this.color,
    required this.isLightTheme,
    required this.onTap,
  });

  final String label;
  final DateTime start;
  final DateTime end;
  final Color color;
  final bool isLightTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = isLightTheme ? AppColorsMonitor : AppColorsPS5;
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        isLightTheme: isLightTheme,
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.xs),
              ),
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              '${start.day}.${start.month.toString().padLeft(2, '0')} – ${end.day}.${end.month.toString().padLeft(2, '0')}',
              style: AppTypography.monoSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCompare extends StatelessWidget {
  const _StreakCompare({
    required this.label,
    required this.value,
    required this.streak,
    required this.color,
  });

  final String label;
  final String value;
  final int streak;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: AppTypography.monoCaption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, color: color, size: 14),
            const SizedBox(width: 2),
            Text(
              '$streak дн',
              style: AppTypography.monoCaption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Grouped bar chart CustomPainter with value labels on bars.
class _GroupedBarChartPainter extends CustomPainter {
  _GroupedBarChartPainter({
    required this.dataA,
    required this.dataB,
    required this.colorA,
    required this.colorB,
    required this.textColor,
    required this.gridColor,
  });

  final List<double> dataA;
  final List<double> dataB;
  final Color colorA;
  final Color colorB;
  final Color textColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.fromLTRB(8, 24, 8, 28);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;

    final allVals = [...dataA, ...dataB];
    final maxVal = allVals.isEmpty || allVals.every((v) => v == 0)
        ? 1.0
        : allVals.reduce(math.max);
    final groupCount = math.max(dataA.length, dataB.length);
    if (groupCount == 0) return;

    final groupWidth = chartW / groupCount;
    final barWidth = (groupWidth * 0.35).clamp(4, 30);

    // Grid lines
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (var i = 0; i <= 3; i++) {
      final y = padding.top + (chartH / 3) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
    }

    for (var g = 0; g < groupCount; g++) {
      final groupX = padding.left + g * groupWidth + groupWidth / 2;

      // Bar A
      if (g < dataA.length && dataA[g] > 0) {
        final barH = (dataA[g] / maxVal) * chartH;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            groupX - barWidth - 1,
            padding.top + chartH - barH,
            barWidth,
            barH,
          ),
          const Radius.circular(3),
        );

        // Bar shadow/glow
        canvas.drawRRect(
          rect,
          Paint()..color = colorA.withOpacity(0.15),
        );

        canvas.drawRRect(
          rect,
          Paint()..color = colorA,
        );

        // Value label on top
        if (barH > 15) {
          final label = TextSpan(
            text: dataA[g] >= 1000
                ? '${(dataA[g] / 1000).toStringAsFixed(1)}k'
                : dataA[g].toInt().toString(),
            style: TextStyle(color: colorA, fontSize: 8, fontWeight: FontWeight.w600),
          );
          final tp = TextPainter(text: label, textDirection: TextDirection.ltr)
            ..layout();
          tp.paint(
            canvas,
            Offset(
              groupX - barWidth / 2 - tp.width / 2,
              padding.top + chartH - barH - 14,
            ),
          );
        }
      }

      // Bar B
      if (g < dataB.length && dataB[g] > 0) {
        final barH = (dataB[g] / maxVal) * chartH;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            groupX + 1,
            padding.top + chartH - barH,
            barWidth,
            barH,
          ),
          const Radius.circular(3),
        );

        canvas.drawRRect(
          rect,
          Paint()..color = colorB.withOpacity(0.15),
        );

        canvas.drawRRect(
          rect,
          Paint()..color = colorB,
        );

        // Value label on top
        if (barH > 15) {
          final label = TextSpan(
            text: dataB[g] >= 1000
                ? '${(dataB[g] / 1000).toStringAsFixed(1)}k'
                : dataB[g].toInt().toString(),
            style: TextStyle(color: colorB, fontSize: 8, fontWeight: FontWeight.w600),
          );
          final tp = TextPainter(text: label, textDirection: TextDirection.ltr)
            ..layout();
          tp.paint(
            canvas,
            Offset(
              groupX + barWidth / 2 - tp.width / 2,
              padding.top + chartH - barH - 14,
            ),
          );
        }
      }

      // Week label
      final labelSpan = TextSpan(
        text: 'Т${g + 1}',
        style: TextStyle(color: textColor, fontSize: 9),
      );
      final labelTp =
          TextPainter(text: labelSpan, textDirection: TextDirection.ltr)
            ..layout();
      labelTp.paint(
        canvas,
        Offset(groupX - labelTp.width / 2, padding.top + chartH + 6),
      );
    }

    // Y-axis labels
    for (var i = 0; i <= 3; i++) {
      final y = padding.top + (chartH / 3) * i;
      final val = maxVal - (maxVal / 3) * i;
      final textSpan = TextSpan(
        text: val >= 1000
            ? '${(val / 1000).toStringAsFixed(1)}k'
            : val.toInt().toString(),
        style: TextStyle(color: textColor, fontSize: 8),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _GroupedBarChartPainter oldDelegate) =>
      oldDelegate.dataA != dataA || oldDelegate.dataB != dataB;
}
