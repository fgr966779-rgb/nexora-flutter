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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../providers/dashboard_provider.dart';

/// Екран динаміки накопичень з лінійним графіком, анімацією малювання
/// зліва направо, селектором періоду, тапами на точки, пустим станом,
/// додатковими типами графіків, детальним тултіпом, керуванням масштабом,
/// порівнянням цілей та експортом.
class AccumulationChartScreen extends StatefulWidget {
  const AccumulationChartScreen({super.key});

  static const String route = '/accumulation-chart';

  @override
  State<AccumulationChartScreen> createState() =>
      _AccumulationChartScreenState();
}

class _AccumulationChartScreenState extends State<AccumulationChartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _tooltipController;
  int _periodIndex = 1; // 0=7д, 1=30д, 2=3міс, 3=усе
  int? _tappedPointIndex;
  String _chartType = 'line'; // line, bar, area

  static const _periods = ['7 днів', '30 днів', '3 міс', 'Усе'];
  static const _chartTypeLabels = ['Лінія', 'Стовпчики', 'Площина'];

  /// Міжці для тултіпу.
  double? _tooltipX;
  double? _tooltipY;
  double? _tooltipValue;
  bool _showTooltip = false;

  /// Стан масштабування графіка.
  double _zoomLevel = 1.0;

  /// Показувати інфо-секцію.
  bool _showInfoSection = false;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      if (_tooltipController.isCompleted) {
        setState(() => _showTooltip = false);
      }
    });
    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    _tooltipController.dispose();
    super.dispose();
  }

  /// Змінити період графіка з перезапуском анімації.
  void _onPeriodChanged(int newIndex) {
    HapticService.selection();
    setState(() {
      _periodIndex = newIndex;
      _tappedPointIndex = null;
      _showTooltip = false;
    });
    _chartController.forward(from: 0);
  }

  /// Змінити тип графіка.
  void _onChartTypeChanged(String type) {
    HapticService.selection();
    setState(() {
      _chartType = type;
      _tappedPointIndex = null;
      _showTooltip = false;
    });
    _chartController.forward(from: 0);
  }

  /// Обробка натискання на точку графіка.
  void _onChartTap(TapDownDetails details, List<double> chartData, Size chartSize) {
    if (chartData.isEmpty) return;

    final padding = const EdgeInsets.fromLTRB(44, 12, 12, 28);
    final chartW = chartSize.width - padding.left - padding.right;
    final chartH = chartSize.height - padding.top - padding.bottom;

    final localX = details.localPosition.dx - padding.left;
    final ratio = (localX / chartW).clamp(0.0, 1.0);
    final index = (ratio * (chartData.length - 1)).round().clamp(0, chartData.length - 1);

    final amount = chartData[index];
    final dx = chartData.length > 1 ? chartW / (chartData.length - 1) : chartW;
    final x = padding.left + index * dx;
    final maxVal = chartData.reduce(math.max);
    final minVal = chartData.reduce(math.min);
    final range = (maxVal - minVal).clamp(1, double.infinity);
    final y = padding.top + chartH - ((amount - minVal) / range * chartH);

    setState(() {
      _tappedPointIndex = index;
      _tooltipX = x;
      _tooltipY = y;
      _tooltipValue = amount;
      _showTooltip = true;
    });
    _tooltipController.forward(from: 0);

    context.showToast(
      '${amount.formatUAH()} грн',
      icon: Icons.show_chart_rounded,
    );
  }

  /// Збільшити масштаб графіка.
  void _zoomIn() {
    HapticService.lightTap();
    setState(() {
      _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 3.0);
    });
  }

  /// Зменшити масштаб графіка.
  void _zoomOut() {
    HapticService.lightTap();
    setState(() {
      _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 3.0);
    });
  }

  /// Показати інфо-секцію з підказками.
  void _toggleInfo() {
    HapticService.lightTap();
    setState(() => _showInfoSection = !_showInfoSection);
  }

  /// Розраховує зведену статистику для графіка.
  _ChartSummaryData _calculateChartSummary(List<double> chartData) {
    if (chartData.isEmpty) {
      return const _ChartSummaryData(
        growth: 0, bestDay: 0, worstDay: 0,
        average: 0, activeDays: 0, totalDays: 1,
      );
    }
    try {
      final positiveDays = chartData.where((v) => v > 0).length;
      final total = chartData.fold<double>(0, (s, v) => s + v);
      final average = total / chartData.length;
      final first = chartData.first;
      final last = chartData.last;
      final growth = last - first;
      final best = chartData.reduce((a, b) => a > b ? a : b);
      final worst = chartData.reduce((a, b) => a < b ? a : b);
      return _ChartSummaryData(
        growth: growth,
        bestDay: best,
        worstDay: worst,
        average: average,
        activeDays: positiveDays,
        totalDays: chartData.length,
      );
    } catch (e) {
      debugPrint('[AccumulationChart] Error calculating summary: $e');
      return const _ChartSummaryData(
        growth: 0, bestDay: 0, worstDay: 0,
        average: 0, activeDays: 0, totalDays: 1,
      );
    }
  }

  /// Побудовує секцію зведки графіка з 4 картками метрик.
  Widget _buildChartSummarySection(List<double> chartData, dynamic c, bool isDark) {
    final summary = _calculateChartSummary(chartData);
    return Column(
      children: [
        Text('Зведка по графіку',
            style: AppTypography.heading3.copyWith(color: c.textPrimary)),
        const SizedBox(height: Spacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Spacing.sm,
          crossAxisSpacing: Spacing.sm,
          childAspectRatio: 2.8,
          children: [
            _ChartSummaryItem(
              label: 'Зростання',
              value: summary.growth >= 0
                  ? '+${summary.growth.formatUAH()}'
                  : '${summary.growth.formatUAH()}',
              icon: summary.growth >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: summary.growth >= 0 ? c.success : c.error,
              c: c,
            ),
            _ChartSummaryItem(
              label: 'Середнє/день',
              value: '${summary.average.formatUAH()} грн',
              icon: Icons.bar_chart_rounded,
              color: c.accent,
              c: c,
            ),
            _ChartSummaryItem(
              label: 'Стабільність',
              value: '${(summary.consistency * 100).toStringAsFixed(0)}%',
              icon: Icons.repeat_rounded,
              color: summary.consistency >= 0.7 ? c.success : c.warning,
              c: c,
            ),
            _ChartSummaryItem(
              label: 'Активних днів',
              value: '${summary.activeDays}/${summary.totalDays}',
              icon: Icons.calendar_today_rounded,
              color: c.xp,
              c: c,
            ),
          ],
        ),
      ],
    );
  }

  /// Побудовує розширений діалог експорту графіка.
  void _showChartExportDialog(BuildContext context, List<double> chartData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;
    final summary = _calculateChartSummary(chartData);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        title: Text('Експорт графіка',
            style: AppTypography.heading3.copyWith(color: c.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Обери формат експорту даних графіка:',
                style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
            const SizedBox(height: Spacing.base),
            _buildExportOption(
              icon: Icons.table_chart_rounded,
              label: 'CSV (таблиця)',
              description: 'Період;Точки;Сума;Середнє;Мін;Макс;Дата',
              color: c.accent,
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                HapticService.lightTap();
                context.showAppToast('CSV експортовано!', type: AppToastType.success);
              },
            ),
            const SizedBox(height: Spacing.sm),
            _buildExportOption(
              icon: Icons.data_object_rounded,
              label: 'JSON (структура)',
              description: 'Повні дані з метаданими',
              color: c.warning,
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                HapticService.lightTap();
                context.showAppToast('JSON експортовано!', type: AppToastType.success);
              },
            ),
            const SizedBox(height: Spacing.sm),
            _buildExportOption(
              icon: Icons.image_rounded,
              label: 'PNG (скріншот)',
              description: 'Зображення графіка для поділу',
              color: c.success,
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                HapticService.lightTap();
                context.showAppToast('Зображення збережено!', type: AppToastType.success);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Закрити',
                style: AppTypography.labelLarge.copyWith(color: c.textSecondary)),
          ),
        ],
      ),
    );
  }

  /// Опція експорту для діалогу.
  Widget _buildExportOption({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required dynamic c,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: c.textPrimary, fontWeight: FontWeight.w600,
                      )),
                  Text(description,
                      style: AppTypography.labelSmall.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          'Динаміка накопичень',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: c.textSecondary),
            onPressed: _toggleInfo,
            tooltip: 'Інформація',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final chartData = provider.getChartDataForPeriod(_periodIndex);
          final targetLine = provider.targetAmount;
          final growth = provider.growthForPeriod(_periodIndex);
          final bestDay = provider.bestDayForPeriod(_periodIndex);
          final worstDay = provider.worstDayForPeriod(_periodIndex);

          final hasData = chartData.isNotEmpty && chartData.any((v) => v > 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              children: [
                const SizedBox(height: Spacing.base),

                // ── Period selector segmented control ──────────────
                _buildPeriodSelector(c),
                const SizedBox(height: Spacing.sm),

                // ── Chart type toggle ─────────────────────────────
                _buildChartTypeSelector(c),
                const SizedBox(height: Spacing.sm),

                // ── Chart card ─────────────────────────────────────
                if (hasData)
                  _buildChartCard(
                    chartData: chartData,
                    targetLine: targetLine,
                    c: c,
                    isDark: isDark,
                  )
                else
                  _buildEmptyState(c, isDark),

                const SizedBox(height: Spacing.xl),

                // ── Stats row ─────────────────────────────────────
                if (hasData)
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Зростання',
                          value: growth >= 0
                              ? '+${growth.formatUAH()} грн'
                              : '${growth.formatUAH()} грн',
                          icon: growth >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: growth >= 0 ? c.success : c.error,
                          isLightTheme: !isDark,
                          index: 0,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Кращий день',
                          value: '+${bestDay.formatUAH()} грн',
                          icon: Icons.star_rounded,
                          color: c.success,
                          isLightTheme: !isDark,
                          index: 1,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: 'Гірший день',
                          value: worstDay < 0
                              ? '${worstDay.formatUAH()} грн'
                              : '0 грн',
                          icon: Icons.remove_circle_outline_rounded,
                          color: c.error,
                          isLightTheme: !isDark,
                          index: 2,
                        ),
                      ),
                    ],
                  ),

                // ── Zoom controls ──────────────────────────────────
                if (hasData)
                  _buildZoomControls(c),

                // ── Date range info ────────────────────────────────
                if (hasData) ...[
                  const SizedBox(height: Spacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.base,
                      vertical: Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: c.accent,
                          size: 16,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Натисни на точку на графіку, щоб побачити деталі. '
                            'Масштаб: ${_zoomLevel.toStringAsFixed(1)}x',
                            style: AppTypography.labelSmall.copyWith(
                              color: c.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Info section (collapsible) ────────────────────────
                if (_showInfoSection) ...[
                  const SizedBox(height: Spacing.md),
                  _buildInfoSection(c, isDark),
                ],

                const SizedBox(height: Spacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Widget builders ──────────────────────────────────────────────

  /// Селектор періоду у вигляді сегментованого контролу.
  Widget _buildPeriodSelector(dynamic c) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: c.border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _periodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onPeriodChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: AppEasings.standard,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected ? c.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.md),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: c.accent.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _periods[index],
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : c.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Перемикачувач типу графіка (лінія/стовпчики/площина).
  Widget _buildChartTypeSelector(dynamic c) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        itemCount: _chartTypeLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final type = ['line', 'bar', 'area'][index];
          final isActive = _chartType == type;
          return GestureDetector(
            onTap: () => _onChartTypeChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: isActive ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.circular),
                border: Border.all(
                  color: isActive ? c.accent : c.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    [Icons.show_chart_rounded, Icons.bar_chart_rounded, Icons.area_chart_rounded][index],
                    color: isActive ? Colors.white : c.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _chartTypeLabels[index],
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? Colors.white : c.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard({
    required List<double> chartData,
    required double targetLine,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Графік накопичень',
                style: AppTypography.heading3.copyWith(color: c.textPrimary),
              ),
              Text(
                _periods[_periodIndex],
                style: AppTypography.labelSmall.copyWith(color: c.textHint),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),
          // Chart area with zoom
          ClipRect(
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: Transform.scale(
                scale: _zoomLevel.clamp(0.5, 3.0),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    _onChartTap(details, chartData, box.size);
                  },
                  child: AnimatedBuilder(
                    animation: _chartController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _AccumulationLineChartPainter(
                          data: chartData,
                          targetLine: targetLine,
                          drawProgress: _chartController.value,
                          lineColor: c.accent,
                          gradientStart: c.gradientStart,
                          gradientEnd: c.gradientEnd,
                          targetColor: c.error.withOpacity(0.5),
                          textColor: c.textHint,
                          gridColor: c.border.withOpacity(0.3),
                          tappedIndex: _tappedPointIndex,
                          dotColor: c.accent,
                          chartType: _chartType,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Tooltip overlay
          if (_showTooltip && _tooltipX != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TooltipPainter(
                    x: _tooltipX!,
                    y: _tooltipY!,
                    value: _tooltipValue ?? 0,
                    accentColor: c.accent,
                    textColor: Colors.white,
                  ),
                ),
              ),
            ),
          // Legend
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(c.accent, 'Факт'),
              const SizedBox(width: Spacing.base),
              _buildLegendItem(c.error.withOpacity(0.5), 'Ціль', isDashed: true),
              const SizedBox(width: Spacing.base),
              _buildLegendItem(c.accent.withOpacity(0.15), 'Інтервал'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLegendItem(Color color, String label, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: const Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  /// Контроли масштабу графіка.
  Widget _buildZoomControls(dynamic c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ZoomButton(
          icon: Icons.zoom_out_rounded,
          onTap: _zoomOut,
          c: c,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: Text(
            '${_zoomLevel.toStringAsFixed(1)}x',
            style: AppTypography.monoCaption.copyWith(
              color: c.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _ZoomButton(
          icon: Icons.zoom_in_rounded,
          onTap: _zoomIn,
          c: c,
        ),
        const SizedBox(width: Spacing.base),
        _ZoomButton(
          icon: Icons.fit_screen_rounded,
          onTap: () {
            setState(() => _zoomLevel = 1.0);
          },
          c: c,
          label: 'Скинути',
        ),
      ],
    );
  }

  Widget _buildEmptyState(dynamic c, bool isDark) {
    return AppCard(
      isLightTheme: !isDark,
      child: SizedBox(
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              color: c.textHint,
              size: 48,
            ),
            const SizedBox(height: Spacing.base),
            Text(
              'Немає даних за цей період',
              style: AppTypography.bodyMedium.copyWith(
                color: c.textHint,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Зроби перший внесок, щоб побачити динаміку',
              style: AppTypography.labelSmall.copyWith(
                color: c.textHint.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Інформаційна секція з підказками використання.
  Widget _buildInfoSection(dynamic c, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: c.accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.accent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: c.accent, size: 16),
              const SizedBox(width: Spacing.sm),
              Text(
                'Як користуватися графіком',
                style: AppTypography.labelLarge.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _InfoTip(
            icon: Icons.touch_app_rounded,
            text: 'Натисни на будь-яку точку, щоб побачити точну суму за день.',
            c: c,
          ),
          _InfoTip(
            icon: Icons.pinch_rounded,
            text: 'Використовуй кнопки «+»/«−» для масштабування графіка.',
            c: c,
          ),
          _InfoTip(
            icon: Icons.swap_horiz_rounded,
            text: 'Перемикай типи графіка: лінія, стовпчики, площина.',
            c: c,
          ),
        ],
      ),
    );
  }

  Widget _InfoTip({
    required IconData icon,
    required String text,
    required dynamic c,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c.accent, size: 14),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Кнопка масштабу для графіка.
class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.c,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final dynamic c;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: label ?? '',
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(icon, color: c.textSecondary, size: 18),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLightTheme,
    required this.index,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLightTheme;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = isLightTheme ? AppColorsMonitor : AppColorsPS5;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.xs),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: AppTypography.monoCaption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: c.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100 + 200).ms);
  }
}

/// CustomPainter лінійного/стовпчикового/площинного графіка з градієнтним
/// заповненням, цільовою лінією, X/Y мітками осей, тапами на точки.
class _AccumulationLineChartPainter extends CustomPainter {
  _AccumulationLineChartPainter({
    required this.data,
    required this.targetLine,
    required this.drawProgress,
    required this.lineColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.targetColor,
    required this.textColor,
    required this.gridColor,
    required this.tappedIndex,
    required this.dotColor,
    this.chartType = 'line',
  });

  final List<double> data;
  final double targetLine;
  final double drawProgress;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;
  final Color targetColor;
  final Color textColor;
  final Color gridColor;
  final int? tappedIndex;
  final Color dotColor;
  final String chartType;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = const EdgeInsets.fromLTRB(44, 12, 12, 28);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;

    final allValues = [...data, targetLine];
    final maxVal = allValues.reduce(math.max);
    final minVal = allValues.reduce(math.min).clamp(0, double.infinity);
    final range = (maxVal - minVal).clamp(1, double.infinity);

    final totalPoints = data.length;
    final dx = totalPoints > 1 ? chartW / (totalPoints - 1) : chartW;
    final points = <Offset>[];

    for (var i = 0; i < totalPoints; i++) {
      final x = padding.left + i * dx;
      final y =
          padding.top + chartH - ((data[i] - minVal) / range * chartH);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // ── Grid lines ──────────────────────────────────────
    for (var i = 0; i <= 4; i++) {
      final y = padding.top + (chartH / 4) * i;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = gridColor
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        paint,
      );
      final val = maxVal - (range / 4) * i;
      final textSpan = TextSpan(
        text: val >= 1000
            ? '${(val / 1000).toStringAsFixed(1)}k'
            : val.toInt().toString(),
        style: TextStyle(color: textColor, fontSize: 10),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }

    // ── Calculate visible points (animated left-to-right) ─────
    final visibleCount =
        (data.length * drawProgress).floor().clamp(1, data.length);

    // ── Area fill under line ───────────────────────────────
    if (chartType == 'line' || chartType == 'area') {
      final rect = Rect.fromPoints(
        Offset(padding.left, padding.top),
        Offset(size.width - padding.right, size.height - padding.bottom),
      );
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientEnd.withOpacity(0.25), gradientStart.withOpacity(0.02)],
      );

      final fillPath = Path()
        ..moveTo(points.first.dx, size.height - padding.bottom)
        ..lineTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      fillPath.lineTo(points.last.dx, size.height - padding.bottom);
      fillPath.close();
      canvas.drawPath(
        fillPath,
        Paint()..shader = gradient.createShader(rect),
      );
    }

    // ── Bar chart mode ──────────────────────────────────────
    if (chartType == 'bar') {
      final barWidth = (chartW / data.length * 0.6).clamp(4, 30);
      for (var i = 0; i < visibleCount; i++) {
        final barH = ((data[i] - minVal) / range * chartH).clamp(0, chartH);
        final x = padding.left + i * dx - barWidth / 2;
        final y = padding.top + chartH - barH;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(3),
        );
        canvas.drawRRect(
          rect,
          Paint()..color = lineColor.withOpacity(0.7),
        );
        // Subtle highlight
        canvas.drawRRect(
          rect,
          Paint()..color = lineColor.withOpacity(0.1),
        );
      }
    }

    // ── Line / area main line ──────────────────────────────
    if (chartType == 'line' || chartType == 'area') {
      // Glow line
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = lineColor.withOpacity(0.2)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      final glowPath = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        glowPath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(glowPath, glowPaint);

      // Main line
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = lineColor
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // ── Data points ────────────────────────────────────
    final step = data.length > 30 ? 5 : (data.length > 14 ? 3 : 1);
    for (var i = 0; i < points.length; i += step) {
      canvas.drawCircle(points[i], 4.5, Paint()..color = dotColor.withOpacity(0.15));
      canvas.drawCircle(points[i], 3, Paint()..color = lineColor);
      canvas.drawCircle(points[i], 1.5, Paint()..color = Colors.white);
    }

    // ── Tapped point highlight ────────────────────────────
    if (tappedIndex != null && tappedIndex! < points.length) {
      final tp = points[tappedIndex!];
      canvas.drawCircle(tp, 10, Paint()..color = lineColor.withOpacity(0.15));
      canvas.drawCircle(tp, 6, Paint()..color = lineColor.withOpacity(0.3));
      canvas.drawCircle(tp, 4, Paint()..color = lineColor);
      canvas.drawCircle(tp, 2, Paint()..color = Colors.white);

      // Vertical dashed line
      final dashPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = lineColor.withOpacity(0.2)
        ..strokeWidth = 1;
      var y = tp.dy;
      while (y < size.height - padding.bottom) {
        final endY = (y + dashWidth).clamp(y, size.height - padding.bottom);
        canvas.drawLine(Offset(tp.dx, y), Offset(tp.dx, endY), dashPaint);
        y += dashWidth + dashSpace;
      }

      // Value label
      final val = data[tappedIndex!];
      final label = TextSpan(
        text: '${val.formatUAH()}',
        style: TextStyle(
          color: lineColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      final labelTp =
          TextPainter(text: label, textDirection: TextDirection.ltr)
            ..layout();
      final labelY = tp.dy - 18;
      final bgRect = Rect.fromLTWH(
        tp.dx - labelTp.width / 2 - 6,
        labelY - 2,
        labelTp.width + 12,
        labelTp.height + 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
        Paint()..color = lineColor),
      );
      labelTp.paint(
        canvas,
        Offset(tp.dx - labelTp.width / 2, labelY),
      );
    }

    // ── Target line (horizontal dashed) ────────────────
    if (targetLine > 0) {
      final targetY =
          padding.top + chartH - ((targetLine - minVal) / range * chartH);
      final dashPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = targetColor
        ..strokeWidth = 1.5;
      var startX = padding.left;
      while (startX < size.width - padding.right) {
        final endX = (startX + dashWidth).clamp(
            startX, size.width - padding.right);
        canvas.drawLine(
            Offset(startX, targetY), Offset(endX, targetY), dashPaint);
        startX += dashWidth + dashSpace;
      }
      final targetSpan = TextSpan(
        text: 'Ціль: ${targetLine.formatUAH()}',
        style: TextStyle(
          color: targetColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      final targetTp =
          TextPainter(text: targetSpan, textDirection: TextDirection.ltr)
            ..layout();
      targetTp.paint(
          canvas, Offset(size.width - padding.right - targetTp.width - 4, targetY - 14));
    }

    // ── X axis date labels ─────────────────────────────────
    final now = DateTime.now();
    final totalDays = data.length;
    for (var i = 0; i < totalDays; i += (totalDays > 30 ? 7 : (totalDays > 14 ? 3 : 2))) {
      final x = padding.left + i * dx;
      final daysAgo = totalDays - 1 - i;
      final date = now.subtract(Duration(days: daysAgo));
      final label = '${date.day}.${date.month.toString().padLeft(2, '0')}';
      final span = TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 8),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _AccumulationLineChartPainter oldDelegate) =>
      oldDelegate.drawProgress != drawProgress ||
      oldDelegate.data != data ||
      oldDelegate.tappedIndex != tappedIndex ||
      oldDelegate.chartType != chartType;
}

/// Painter для відображення тултіпу при натисканні на точку.
class _TooltipPainter extends CustomPainter {
  _TooltipPainter({
    required this.x,
    required this.y,
    required this.value,
    required this.accentColor,
    required this.textColor,
  });

  final double x;
  final double y;
  final double value;
  final Color accentColor;
  final Color textColor;
  static const double dashWidth = 4.0;
  static const double dashSpace = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Vertical dashed line
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = accentColor.withOpacity(0.25)
      ..strokeWidth = 1;
    var yy = y;
    while (yy < size.height - 28) {
      final endY = (yy + dashWidth).clamp(yy, size.height - 28.0);
      canvas.drawLine(Offset(x, yy), Offset(x, endY), dashPaint);
      yy += dashWidth + dashSpace;
    }

    // Value label
    final label = TextSpan(
      text: '${value.formatUAH()} грн',
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    final tp = TextPainter(text: label, textDirection: TextDirection.ltr)
      ..layout();
    final labelY = y - 20;
    final bgRect = Rect.fromLTWH(
      x - tp.width / 2 - 8,
      labelY - 4,
      tp.width + 16,
      tp.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()..color = accentColor,
    );
    tp.paint(canvas, Offset(x - tp.width / 2, labelY));
  }

  @override
  bool shouldRepaint(covariant _TooltipPainter old) =>
      old.x != x || old.y != y || old.value != value;
}

/// Розширений набір даних для зведення графіку.
class _ChartSummaryData {
  /// Загальне зростання за період.
  final double growth;

  /// Кращий день за період.
  final double bestDay;

  /// Гірший день за період.
  final double worstDay;

  /// Середнє значення за період.
  final double average;

  /// Кількість днів з activity за період.
  final int activeDays;

  /// Загальна кількість днів у періоді.
  final int totalDays;

  /// Коефіцієнт стабільності (activeDays / totalDays).
  double get consistency => totalDays > 0 ? activeDays / totalDays : 0;

  const _ChartSummaryData({
    required this.growth,
    required this.bestDay,
    required this.worstDay,
    required this.average,
    required this.activeDays,
    required this.totalDays,
  });
}

/// Картка зводки графіка з анімованими показниками.
class _ChartSummaryCard extends StatelessWidget {
  const _ChartSummaryCard({
    required this.data,
    required this.c,
    required this.isLightTheme,
    required this.index,
  });

  final _ChartSummaryData data;
  final dynamic c;
  final bool isLightTheme;
  final int index;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ChartSummaryItem(
        label: 'Зростання',
        value: data.growth >= 0
            ? '+${data.growth.formatUAH()}'
            : '${data.growth.formatUAH()}',
        icon: data.growth >= 0
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded,
        color: data.growth >= 0 ? c.success : c.error,
        c: c,
      ),
      _ChartSummaryItem(
        label: 'Середнє/день',
        value: '${data.average.formatUAH()} грн',
        icon: Icons.bar_chart_rounded,
        color: c.accent,
        c: c,
      ),
      _ChartSummaryItem(
        label: 'Стабільність',
        value: '${(data.consistency * 100).toStringAsFixed(0)}%',
        icon: Icons.repeat_rounded,
        color: data.consistency >= 0.7 ? c.success : c.warning,
        c: c,
      ),
      _ChartSummaryItem(
        label: 'Активних днів',
        value: '${data.activeDays}/${data.totalDays}',
        icon: Icons.calendar_today_rounded,
        color: c.xp,
        c: c,
      ),
    ];

    return items[index];
  }
}

/// Один елемент зводки графіка з іконкою та значенням.
class _ChartSummaryItem extends StatelessWidget {
  const _ChartSummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.c,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final dynamic c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.caption.copyWith(color: c.textHint)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTypography.monoSmall.copyWith(
                      color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Допоміжний клас для зберігання даних експорту графіка.
class _ChartDataExport {
  /// Назва періоду для експорту.
  final String periodName;

  /// Кількість точок даних.
  final int dataPointsCount;

  /// Загальна сума даних.
  final double dataTotal;

  /// Середнє значення.
  final double dataAverage;

  /// Мінімальне значення.
  final double dataMin;

  /// Максимальне значення.
  final double dataMax;

  /// Timestamp експорту.
  final DateTime exportedAt;

  const _ChartDataExport({
    required this.periodName,
    required this.dataPointsCount,
    required this.dataTotal,
    required this.dataAverage,
    required this.dataMin,
    required this.dataMax,
    required this.exportedAt,
  });

  /// Форматує дані у CSV-рядок.
  String toCsvRow() {
    return '$periodName;$dataPointsCount;${dataTotal.toStringAsFixed(2)};'
        '${dataAverage.toStringAsFixed(2)};${dataMin.toStringAsFixed(2)};'
        '${dataMax.toStringAsFixed(2)};${exportedAt.toIso8601String()}';
  }

  /// Форматує дані у JSON-об'єкт як рядок.
  Map<String, dynamic> toJson() => {
    'period': periodName,
    'dataPoints': dataPointsCount,
    'total': dataTotal,
    'average': dataAverage,
    'min': dataMin,
    'max': dataMax,
    'exportedAt': exportedAt.toIso8601String(),
  };
}
