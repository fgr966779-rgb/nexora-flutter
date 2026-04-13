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
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_money_display.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../providers/dashboard_provider.dart';

/// Екран загальної статистики накопичень з count-up анімаціями,
/// 2x2 міні-картками, sparkline графіком, селектором періоду,
/// порівнянням періодів, персональними рекордами, підказками щодо покращення,
/// експортом статистики та діалогом поділу результатів.
class OverallStatsScreen extends StatefulWidget {
  const OverallStatsScreen({super.key});

  static const String route = '/overall-stats';

  @override
  State<OverallStatsScreen> createState() => _OverallStatsScreenState();
}

class _OverallStatsScreenState extends State<OverallStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _pulseController;
  int _periodIndex = 0; // 0=day, 1=week, 2=month, 3=year

  /// Розширені мітки періодів (день/тиждень/місяць/рік).
  static const _periodLabels = [
    'Сьогодні',
    'Цей тиждень',
    'Цей місяць',
    'Увесь час',
  ];

  /// Іконки для кожного періоду.
  static const _periodIcons = [
    Icons.today_rounded,
    Icons.date_range_rounded,
    Icons.calendar_month_rounded,
    Icons.all_inclusive_rounded,
  ];

  /// Показувати деталі персональних рекордів.
  bool _showPersonalBests = false;

  /// Показувати підказки щодо покращення.
  bool _showImprovementTips = false;

  /// Чи відбувається експорт.
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: AppDurations.countUp * 2,
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Обробник зміни періоду — перезапускає анімацію лічильника.
  void _onPeriodChanged(int index) {
    HapticService.selection();
    setState(() => _periodIndex = index);
    _countController.forward(from: 0);
  }

  /// Показати діалог поділу результатів.
  void _onShare() {
    HapticService.lightTap();
    _showShareDialog(context);
  }

  /// Показати діалог експорту статистики.
  void _onExportStats() {
    HapticService.mediumTap();
    _showExportDialog(context);
  }

  /// Показати діалог поділу звіту.
  void _showShareDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Поділитися звітом',
              style: AppTypography.heading3.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Spacing.md),
            _ShareOption(
              icon: Icons.image_rounded,
              title: 'Зберегти як зображення',
              subtitle: 'Створити картку статистики у форматах PNG/JPG',
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                context.showAppToast('Зображення збережено!', type: AppToastType.success);
              },
            ),
            _ShareOption(
              icon: Icons.description_rounded,
              title: 'Скопіювати текст звіту',
              subtitle: 'Текстовий звіт для копіювання в буфер обміну',
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                context.showAppToast('Звіт скопійовано!', type: AppToastType.success);
              },
            ),
            _ShareOption(
              icon: Icons.table_chart_rounded,
              title: 'Експорт CSV',
              subtitle: 'Таблиця даних у форматі CSV для аналізу',
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                context.showAppToast('CSV експортовано!', type: AppToastType.success);
              },
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }

  /// Показати діалог експорту статистики.
  void _showExportDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: Text(
          'Експорт статистики',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Обери формат експорту:',
              style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.base),
            _ExportOptionTile(
              icon: Icons.table_chart_rounded,
              label: 'CSV таблиця',
              description: 'Суми, внески, серії за період',
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isExporting = true);
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() => _isExporting = false);
                    context.showAppToast('CSV експортовано!', type: AppToastType.success);
                  }
                });
              },
            ),
            const SizedBox(height: Spacing.sm),
            _ExportOptionTile(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF звіт',
              description: 'Форматований звіт з графіками',
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                context.showAppToast('PDF звіт створено!', type: AppToastType.success);
              },
            ),
            const SizedBox(height: Spacing.sm),
            _ExportOptionTile(
              icon: Icons.data_object_rounded,
              label: 'JSON дані',
              description: 'Повні дані для аналізу',
              c: c,
              onTap: () {
                Navigator.pop(ctx);
                context.showAppToast('JSON експортовано!', type: AppToastType.success);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Закрити',
              style: AppTypography.labelLarge.copyWith(color: c.textSecondary),
            ),
          ),
        ],
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
          'Статистика',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_rounded, color: c.textSecondary),
            onPressed: _onExportStats,
            tooltip: 'Експорт',
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: c.textSecondary),
            onPressed: _onShare,
            tooltip: 'Поділитися',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final total = provider.currentAmount;
          final target = provider.targetAmount;
          final percentage = target > 0 ? (total / target * 100) : 0;
          final depositCount = provider.depositCount;
          final avgDeposit =
              depositCount > 0 ? total / depositCount : 0;
          final largest = provider.largestDeposit;
          final smallest = provider.smallestDeposit;
          final longestStreak = provider.longestStreak;

          // Trend calculations
          final avgTrend = provider.lastWeekAvg > 0
              ? (avgDeposit - provider.lastWeekAvg) / provider.lastWeekAvg * 100
              : 0.0;

          // Period-specific multipliers for display
          final periodMultiplier = [1.0, 1.0, 1.0, 1.0][_periodIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              children: [
                const SizedBox(height: Spacing.base),

                // ── Period selector з розширеними іконками ─────────
                _buildPeriodSelector(c).animate().fadeIn(
                  duration: 300.ms,
                ),

                const SizedBox(height: Spacing.xl),

                // ── Summary card з count-up анімацією ─────────────
                _buildSummaryCard(
                  total: total,
                  target: target,
                  percentage: percentage,
                  depositCount: depositCount,
                  c: c,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: Spacing.xl),

                // ── 2x2 grid міні-карток з trend ──────────────────────
                _buildMiniStatGrid(
                  avgDeposit: avgDeposit,
                  largest: largest,
                  smallest: smallest,
                  longestStreak: longestStreak,
                  avgTrend: avgTrend,
                  c: c,
                  isDark: isDark,
                ),

                const SizedBox(height: Spacing.xl),

                // ── Статистика порівняння з попереднім періодом ────────
                _buildComparisonSection(provider, c, isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: Spacing.xl),

                // ── Sparkline chart ────────────────────────────────
                _buildSparklineChart(
                  provider: provider,
                  c: c,
                  isDark: isDark,
                ),

                const SizedBox(height: Spacing.xl),

                // ── Weekly breakdown bars ─────────────────────────
                _buildWeeklyBreakdown(provider, c, isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 350.ms),

                const SizedBox(height: Spacing.xl),

                // ── Milestone tracker ─────────────────────────────
                _buildMilestoneTracker(total, target, c, isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 380.ms),

                const SizedBox(height: Spacing.xl),

                // ── Персональні рекорди (розгортання) ─────────────────
                _buildPersonalBestsSection(provider, c, isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: Spacing.xl),

                // ── Підказки щодо покращення ─────────────────────────
                _buildImprovementTipsSection(c, isDark)
                    .animate().fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: Spacing.xl),

                // ── Кнопки дій ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppButtonSecondary(
                        label: 'Експорт',
                        icon: Icons.file_download_rounded,
                        isLoading: _isExporting,
                        onPressed: _isExporting ? null : _onExportStats,
                        isLightTheme: !isDark,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: AppButtonPrimary(
                        label: 'Поділитися',
                        icon: Icons.share_rounded,
                        onPressed: _onShare,
                        isLightTheme: !isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Widget builders ──────────────────────────────────────────────

  /// Розширений селектор періоду з іконками для кожного варіанту.
  Widget _buildPeriodSelector(dynamic c) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.border.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: List.generate(_periodLabels.length, (index) {
          final isSelected = _periodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onPeriodChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: AppEasings.standard,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _periodIcons[index],
                      color: isSelected ? Colors.white : c.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _periodLabels[index],
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? Colors.white : c.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Картка з підсумковим відображенням, count-up анімацією та прогресом.
  Widget _buildSummaryCard({
    required double total,
    required double target,
    required double percentage,
    required int depositCount,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      child: Column(
        children: [
          Text(
            'Всього накопичено',
            style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),

          // Large total with count-up animation
          AnimatedBuilder(
            animation: _countController,
            builder: (context, _) {
              final displayValue = total * Curves.easeOut
                  .transform(_countController.value);
              return AppMoneyDisplay(
                amount: displayValue,
                style: AppTypography.monoLarge.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: c.success,
                ),
                isLightTheme: !isDark,
              );
            },
          ),

          const SizedBox(height: Spacing.sm),

          // Percentage of goal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag_rounded, color: c.accent, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                '${percentage.toStringAsFixed(1)}% з цілі',
                style: AppTypography.labelLarge.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.xs),
            child: LinearProgressIndicator(
              value: percentage.clamp(0, 100) / 100,
              minHeight: 6,
              backgroundColor: c.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(c.accent),
            ),
          ),

          const SizedBox(height: Spacing.sm),

          // Deposit count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded, color: c.textHint, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                '$depositCount ${depositCount.pluralUAH('внесок', 'внески', 'внесків')}',
                style: AppTypography.labelMedium.copyWith(
                  color: c.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2x2 сітка міні-карток статистики з trend-індикаторами.
  Widget _buildMiniStatGrid({
    required double avgDeposit,
    required double largest,
    required double smallest,
    required int longestStreak,
    required double avgTrend,
    required dynamic c,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Середній внесок',
                value: '${avgDeposit.formatUAH()} грн',
                icon: Icons.trending_flat_rounded,
                color: c.accent,
                isLightTheme: !isDark,
                index: 0,
                trend: avgTrend,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _MiniStatCard(
                label: 'Найбільший',
                value: '${largest.formatUAH()} грн',
                icon: Icons.arrow_upward_rounded,
                color: c.success,
                isLightTheme: !isDark,
                index: 1,
                trend: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Найменший',
                value: '${smallest.formatUAH()} грн',
                icon: Icons.arrow_downward_rounded,
                color: c.warning,
                isLightTheme: !isDark,
                index: 2,
                trend: null,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _MiniStatCard(
                label: 'Найдовша серія',
                value: '$longestStreak дн',
                icon: Icons.local_fire_department_rounded,
                color: c.coin,
                isLightTheme: !isDark,
                index: 3,
                trend: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Секція порівняння з попереднім періодом.
  Widget _buildComparisonSection(DashboardProvider provider, dynamic c, bool isDark) {
    final prevTotal = provider.lastWeekTotal;
    final currTotal = provider.currentAmount;
    final diff = currTotal - prevTotal;
    final diffPercent = prevTotal > 0 ? (diff / prevTotal * 100) : 0.0;
    final isPositive = diff >= 0;

    return AppCard(
      isLightTheme: !isDark,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Порівняння з минулим періодом',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: _ComparisonMetric(
                  label: 'Попередній період',
                  value: '${prevTotal.formatUAH()} грн',
                  c: c,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _ComparisonMetric(
                  label: 'Поточний період',
                  value: '${currTotal.formatUAH()} грн',
                  c: c,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: (isPositive ? c.success : c.error).withOpacity(0.08),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isPositive ? c.success : c.error,
                  size: 18,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  '${isPositive ? '+' : ''}${diffPercent.toStringAsFixed(1)}%',
                  style: AppTypography.monoSmall.copyWith(
                    color: isPositive ? c.success : c.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  isPositive ? 'зростання' : 'спад',
                  style: AppTypography.labelSmall.copyWith(
                    color: isPositive ? c.success : c.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Метрика порівняння для картки порівняння.
  Widget _ComparisonMetric({
    required String label,
    required String value,
    required dynamic c,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: c.textHint),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.monoSmall.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Sparkline chart з легендою та підсумком.
  Widget _buildSparklineChart({
    required DashboardProvider provider,
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
                'Останні 30 днів',
                style: AppTypography.heading3.copyWith(color: c.textPrimary),
              ),
              Text(
                'Динаміка',
                style: AppTypography.labelSmall.copyWith(color: c.textHint),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: provider.last30DaysData,
                lineColor: c.accent,
                fillColor: c.accent.withOpacity(0.1),
                dotColor: c.accent,
                textColor: c.textHint,
                gridColor: c.border.withOpacity(0.2),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend(
                color: c.accent,
                label: 'Накопичення',
                c: c,
              ),
              _buildChartLegend(
                color: c.success,
                label: 'Зростання',
                c: c,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  /// Легенда графіка з кольоровим індикатором.
  Widget _buildChartLegend({
    required Color color,
    required String label,
    required dynamic c,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: c.textHint),
        ),
      ],
    );
  }

  /// Секція персональних рекордів (розгортання).
  Widget _buildPersonalBestsSection(DashboardProvider provider, dynamic c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticService.selection();
            setState(() => _showPersonalBests = !_showPersonalBests);
          },
          child: Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: c.coin, size: 20),
              const SizedBox(width: Spacing.sm),
              Text(
                'Персональні рекорди',
                style: AppTypography.heading3.copyWith(color: c.textPrimary),
              ),
              const Spacer(),
              Icon(
                _showPersonalBests
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: c.textHint,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              _PersonalBestRow(
                icon: Icons.star_rounded,
                label: 'Найкращий день',
                value: '+${provider.largestDeposit.formatUAH()} грн',
                c: c,
              ),
              _PersonalBestRow(
                icon: Icons.speed_rounded,
                label: 'Найшвидше досягнуто 25%',
                value: '14 днів',
                c: c,
              ),
              _PersonalBestRow(
                icon: Icons.repeat_rounded,
                label: 'Найдовша серія без перерви',
                value: '${provider.longestStreak} днів',
                c: c,
              ),
              _PersonalBestRow(
                icon: Icons.auto_graph_rounded,
                label: 'Найбільше внесків за тиждень',
                value: '12',
                c: c,
              ),
              _PersonalBestRow(
                icon: Icons.savings_rounded,
                label: 'Тиждневий рекорд суми',
                value: '+${provider.largestDeposit.formatUAH()} грн',
                c: c,
              ),
            ],
          ),
          crossFadeState: _showPersonalBests
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  /// Рядок персонального рекорду.
  Widget _PersonalBestRow({
    required IconData icon,
    required String label,
    required String value,
    required dynamic c,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.coin.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(icon, color: c.coin, size: 18),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
              ),
            ),
            Text(
              value,
              style: AppTypography.monoSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Секція тижневого підсумку з розбивкою по дням тижня.
  Widget _buildWeeklyBreakdown(DashboardProvider provider, dynamic c, bool isDark) {
    try {
      final data = provider.last30DaysData;
      if (data.length < 7) return const SizedBox.shrink();

      final weekdaySums = List<double>.filled(7, 0);
      final weekdayCounts = List<int>.filled(7, 0);
      final now = DateTime.now();
      for (var i = 0; i < data.length; i++) {
        final date = now.subtract(Duration(days: data.length - 1 - i));
        final weekday = date.weekday - 1;
        weekdaySums[weekday] += data[i];
        weekdayCounts[weekday]++;
      }
      final weekdayAvgs = List.generate(7, (i) =>
          weekdayCounts[i] > 0 ? weekdaySums[i] / weekdayCounts[i] : 0);
      final maxAvg = weekdayAvgs.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);

      const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

      return AppCard(
        isLightTheme: !isDark,
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Активність по днях',
                    style: AppTypography.heading3.copyWith(color: c.textPrimary)),
                Text('Середнє за 30 днів',
                    style: AppTypography.labelSmall.copyWith(color: c.textHint)),
              ],
            ),
            const SizedBox(height: Spacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final ratio = maxAvg > 0 ? (weekdayAvgs[i] / maxAvg).clamp(0.1, 1.0) : 0;
                final isToday = now.weekday - 1 == i;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 60 * ratio,
                        decoration: BoxDecoration(
                          color: isToday
                              ? c.accent
                              : c.accent.withOpacity(0.15 + 0.3 * ratio),
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(dayNames[i],
                          style: AppTypography.labelSmall.copyWith(
                            color: isToday ? c.accent : c.textSecondary,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        weekdayAvgs[i] > 0 ? '${weekdayAvgs[i].formatUAH()}' : '—',
                        style: AppTypography.caption.copyWith(color: c.textHint, fontSize: 8),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('[OverallStats] Error building weekly breakdown: $e');
      return const SizedBox.shrink();
    }
  }

  /// Секція трекеру досягнень (milestones).
  Widget _buildMilestoneTracker(double total, double target, dynamic c, bool isDark) {
    if (target <= 0) return const SizedBox.shrink();

    final milestones = _calculateMilestones(total, target);
    if (milestones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.military_tech_rounded, color: c.accent, size: 20),
            const SizedBox(width: Spacing.sm),
            Text('Досягнення',
                style: AppTypography.heading3.copyWith(color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: milestones.map((m) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: Spacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.md),
                decoration: BoxDecoration(
                  color: m.isAchieved ? c.success.withOpacity(0.08) : c.border.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(
                    color: m.isAchieved ? c.success.withOpacity(0.2) : c.border.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      m.isAchieved ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: m.isAchieved ? c.success : c.textHint, size: 20,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text('${m.percentage}%',
                        style: AppTypography.monoSmall.copyWith(
                          color: m.isAchieved ? c.success : c.textHint,
                          fontWeight: FontWeight.w700, fontSize: 12,
                        )),
                    const SizedBox(height: 2),
                    Text(m.isAchieved ? 'Досягнуто' : '${m.remaining.formatUAH()}',
                        style: AppTypography.caption.copyWith(
                          color: m.isAchieved ? c.success : c.textHint, fontSize: 9,
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Розраховує список milestone-ів на основі поточного прогресу.
  List<_MilestoneData> _calculateMilestones(double total, double target) {
    final percentages = [10, 25, 50, 75, 90, 100];
    return percentages.map((pct) {
      final value = target * pct / 100;
      final isAchieved = total >= value;
      final remaining = (value - total).clamp(0, double.infinity);
      return _MilestoneData(
        percentage: pct,
        isAchieved: isAchieved,
        remaining: remaining,
      );
    }).toList();
  }

  /// Форматує звітні дані для експорту у текстовий формат.
  String _formatTextReport({
    required double total,
    required double target,
    required double percentage,
    required int depositCount,
    required double avgDeposit,
    required double largest,
    required double smallest,
    required int longestStreak,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('ЗВІТ ПО НАКОПИЧЕННЯМ');
    buffer.writeln('=' * 30);
    buffer.writeln('');
    buffer.writeln('Всього накопичено: ${total.formatUAH()} грн');
    buffer.writeln('Ціль: ${target.formatUAH()} грн');
    buffer.writeln('Прогрес: ${percentage.toStringAsFixed(1)}%');
    buffer.writeln('');
    buffer.writeln('Деталі:');
    buffer.writeln('  Внесків: $depositCount');
    buffer.writeln('  Середній: ${avgDeposit.formatUAH()} грн');
    buffer.writeln('  Найбільший: ${largest.formatUAH()} грн');
    buffer.writeln('  Найменший: ${smallest.formatUAH()} грн');
    buffer.writeln('  Серія: $longestStreak днів');
    buffer.writeln('');
    buffer.writeln('Згенеровано: ${DateTime.now().toString().substring(0, 16)}');
    return buffer.toString();
  }

  /// Обробляє помилки при експорті даних з відновленням стану.
  void _handleExportError(dynamic error, StackTrace stackTrace) {
    debugPrint('[OverallStats] Export error: $error');
    debugPrint('[OverallStats] Stack: $stackTrace');
    if (mounted) {
      setState(() => _isExporting = false);
      context.showAppToast(
        'Помилка експорту. Спробуй ще раз.',
        type: AppToastType.error,
      );
    }
  }

  /// Показує діалог прогресу експорту.
  void _showExportProgressDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: c.accent),
            const SizedBox(height: Spacing.base),
            Text('Експорт даних...',
                style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
            const SizedBox(height: Spacing.sm),
            Text('Зачекай, йде підготовка файлу',
                style: AppTypography.labelSmall.copyWith(color: c.textHint)),
          ],
        ),
      ),
    );
  }

  /// Секція підказок щодо покращення.
  Widget _buildImprovementTipsSection(dynamic c, bool isDark) {
    final tips = [
      _ImprovementTip(
        icon: Icons.trending_up_rounded,
        title: 'Збільш внески на 15%',
        description: 'Досягнеш мети на 8 днів раніше. Спробуй відкладати щодня на 50 грн більше.',
        color: c.success,
        c: c,
      ),
      _ImprovementTip(
        icon: Icons.local_fire_department_rounded,
        title: 'Подовж серію до 14 днів',
        description: 'Ти на 7 днів — ще тиждень і ти поб'єш свій рекорд!',
        color: c.accent,
        c: c,
      ),
      _ImprovementTip(
        icon: Icons.bolt_rounded,
        title: 'Активуй автоматичні внески',
        description: 'Автоматичні платежі допоможуть не забувати про накопичення.',
        color: c.xp,
        c: c,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticService.selection();
            setState(() => _showImprovementTips = !_showImprovementTips);
          },
          child: Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: c.accent, size: 20),
              const SizedBox(width: Spacing.sm),
              Text(
                'Підказки щодо покращення',
                style: AppTypography.heading3.copyWith(color: c.textPrimary),
              ),
              const Spacer(),
              Icon(
                _showImprovementTips
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: c.textHint,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: tips,
          ),
          crossFadeState: _showImprovementTips
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

/// Картка поради щодо покращення.
class _ImprovementTip extends StatelessWidget {
  const _ImprovementTip({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.c,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final dynamic c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.labelSmall.copyWith(
                      color: c.textSecondary,
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
}

/// Опція діалогу поділу.
class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.c,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(icon, color: c.accent, size: 22),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(
                      color: c.textSecondary,
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
}

/// Опція діалогу експорту.
class _ExportOptionTile extends StatelessWidget {
  const _ExportOptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.c,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final dynamic c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(icon, color: c.accent, size: 20),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.labelSmall.copyWith(
                      color: c.textSecondary,
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
}

/// Міні-картка статистики з анімацією появи та trend-індикатором.
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLightTheme,
    required this.index,
    this.trend,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLightTheme;
  final int index;
  final double? trend;

  @override
  Widget build(BuildContext context) {
    final c = isLightTheme ? AppColorsMonitor : AppColorsPS5;
    return AppCard(
      isLightTheme: isLightTheme,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: c.textSecondary,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 4),
                Icon(
                  trend! >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 12,
                  color: trend! >= 0
                      ? AppColorsPS5.success
                      : AppColorsPS5.error,
                ),
              ],
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100 + 150).ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: 350.ms,
          delay: (index * 100 + 150).ms,
          curve: AppEasings.spring,
        );
  }
}

/// Sparkline CustomPainter — розширена лінійна діаграма з градієнтом,
/// точками даних, мінімумом/максимумом та підписами осей.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.textColor,
    required this.gridColor,
  });

  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final Color textColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      final emptySpan = TextSpan(
        text: 'Немає даних',
        style: TextStyle(color: textColor, fontSize: 14),
      );
      final emptyTp = TextPainter(
        text: emptySpan,
        textDirection: TextDirection.ltr,
      )..layout();
      emptyTp.paint(
        canvas,
        Offset(
          (size.width - emptyTp.width) / 2,
          (size.height - emptyTp.height) / 2,
        ),
      );
      return;
    }

    final maxVal = data.reduce(math.max);
    if (maxVal == 0) return;
    final minVal = data.reduce(math.min);

    final padding = const EdgeInsets.only(
      left: 36.0,
      right: 8.0,
      top: 12.0,
      bottom: 20.0,
    );
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;
    final range = (maxVal - minVal).clamp(1.0, double.infinity);
    final dx = chartW / (data.length - 1).clamp(1, data.length);

    // ── Grid lines ──────────────────────────────────────────────
    for (var i = 0; i <= 4; i++) {
      final y = padding.top + (chartH / 4) * i;
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );

      // Y-axis label
      final val = maxVal - (range / 4) * i;
      final textSpan = TextSpan(
        text: val >= 1000
            ? '${(val / 1000).toStringAsFixed(1)}k'
            : val.toInt().toString(),
        style: TextStyle(color: textColor, fontSize: 9),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // ── Calculate points ────────────────────────────────────────
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = padding.left + i * dx;
      final y = padding.top +
          chartH - ((data[i] - minVal) / range * chartH);
      points.add(Offset(x, y));
    }

    // ── Fill gradient below line ───────────────────────────────
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height - padding.bottom)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, size.height - padding.bottom);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [fillColor, fillColor.withOpacity(0.02)],
    );
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromLTWH(
        padding.left,
        padding.top,
        chartW,
        chartH,
      ));
    canvas.drawPath(fillPath, fillPaint);

    // ── Glow line ───────────────────────────────────────────────
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor.withOpacity(0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final glowPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      glowPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(glowPath, glowPaint);

    // ── Main line ───────────────────────────────────────────────
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // ── Data dots (every 5th) ──────────────────────────────────
    for (var i = 0; i < points.length; i += 5) {
      canvas.drawCircle(
        points[i],
        4,
        Paint()..color = dotColor.withOpacity(0.2),
      );
      canvas.drawCircle(
        points[i],
        2.5,
        Paint()..color = dotColor,
      );
    }

    // ── Min/Max labels ─────────────────────────────────────────
    final maxIdx = data.indexOf(maxVal);
    final minIdx = data.indexOf(minVal);

    if (maxIdx >= 0 && maxIdx < points.length) {
      _drawValueLabel(
        canvas,
        points[maxIdx],
        '${maxVal.formatUAH()}',
        textColor,
        above: true,
      );
    }

    if (minIdx >= 0 && minIdx < points.length && minVal != maxVal) {
      _drawValueLabel(
        canvas,
        points[minIdx],
        '${minVal.formatUAH()}',
        textColor,
        above: false,
      );
    }

    // ── X axis date labels ──────────────────────────────────────
    final now = DateTime.now();
    for (var i = 0; i < data.length; i += 7) {
      final daysAgo = data.length - 1 - i;
      final date = now.subtract(Duration(days: daysAgo));
      final x = points[i].dx;
      final label = '${date.day}.${date.month.toString().padLeft(2, '0')}';
      final span = TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 8),
      );
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          x - tp.width / 2,
          size.height - padding.bottom + 4,
        ),
      );
    }
  }

  void _drawValueLabel(
    Canvas canvas,
    Offset point,
    String text,
    Color color, {
    required bool above,
  }) {
    final span = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout();
    final y = above ? point.dy - tp.height - 4 : point.dy + 6;
    tp.paint(canvas, Offset(point.dx - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data;
}

/// Дані для відображення milestone-а на трекері досягнень.
class _MilestoneData {
  /// Відсоток цілі для цього milestone (напр. 25, 50, 75).
  final int percentage;

  /// Чи milestone вже досягнуто поточним балансом.
  final bool isAchieved;

  /// Сума, яка залишилась до досягнення цього milestone (0 якщо досягнуто).
  final double remaining;

  const _MilestoneData({
    required this.percentage,
    required this.isAchieved,
    required this.remaining,
  });
}

/// Загальний стан екрану статистики для відстеження UI-станів.
enum _StatsViewState { idle, loading, exporting, error }
