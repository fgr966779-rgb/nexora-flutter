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

/// Екран активності з GitHub-style heatmap-каленарем, статистикою серій,
/// легендою кольорів, підказками при натисканні, прогресивною анімацією,
/// секцією пов'язаних транзакцій, хронологією активності,
/// нотатками до активності, аналітикою та перемикачами.
class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key});

  static const String route = '/activity-detail';

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heatmapController;

  /// Зсув зсуву місяця для перегляду.
  int _selectedMonthOffset = 0;

  /// Показувати секцію пов'язаних транзакцій.
  bool _showRelatedTransactions = false;

  /// Показати нотатку до активності (редагування).
  bool _showActivityNote = false;

  /// Текст нотатки до активності.
  final _noteController = TextEditingController();

  /// Показати секцію порівняння.
  bool _showAnalytics = false;

  @override
  void initState() {
    super.initState();
    _heatmapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _noteController.text = 'Хороший місяць для накопичення — поєднуй регулярність!';
  }

  @override
  void dispose() {
    _heatmapController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Змінити місяць для перегляду.
  void _onMonthChange(int delta) {
    HapticService.selection();
    setState(() => _selectedMonthOffset += delta);
    _heatmapController.forward(from:0);
  }

  /// Перемкнути секцію пов'язаних транзакцій.
  void _toggleRelatedTransactions() {
    HapticService.lightTap();
    setState(() => _showRelatedTransactions = !_showRelatedTransactions);
  }

  /// Перемкнути нотатку.
  void _toggleNote() {
    HapticService.lightTap();
    setState(() => _showActivityNote = !_showActivityNote);
  }

  /// Перемкнути аналітику.
  void _toggleAnalytics() {
    HapticService.lightTap();
    setState(() => _showAnalytics = !_showAnalytics);
  }

  /// Зберегти нотатку.
  void _saveNote() {
    if (_noteController.text.trim().isNotEmpty) {
      HapticService.success();
      context.showAppToast('Нотатку збережено!', type: AppToastType.success);
      setState(() => _showActivityNote = false);
    }
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
          'Активність',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final heatmapData = provider.heatmapData;
          final activeDays = provider.activeDaysCount;
          final avgPerDay = provider.averagePerActiveDay;
          final recordStreak = provider.longestStreak;
          final currentStreak = provider.currentStreak;
          final totalSaved = provider.currentAmount;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.base),

                // ── Month selector ────────────────────────────────
                _buildMonthSelector(c),

                const SizedBox(height: Spacing.lg),

                // ── Heatmap calendar card ─────────────────────────────
                _buildHeatmapCard(
                  heatmapData: heatmapData,
                  c: c,
                  isDark: isDark,
                ),

                const SizedBox(height: Spacing.xl),

                // ── Legend ────────────────────────────────────────
                _buildLegend(c),

                const SizedBox(height: Spacing.xl),

                // ── Stats grid ────────────────────────────────────
                Text(
                  'Статистика активності',
                  style: AppTypography.heading3.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _ActivityStat(
                        label: 'Активних днів',
                        value: '$activeDays',
                        icon: Icons.calendar_today_rounded,
                        color: c.accent,
                        isLightTheme: !isDark,
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: _ActivityStat(
                        label: 'Сер./актив. день',
                        value: '${avgPerDay.formatUAH()} грн',
                        icon: Icons.trending_up_rounded,
                        color: c.success,
                        isLightTheme: !isDark,
                        index: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _ActivityStat(
                        label: 'Рекорд серії',
                        value: '$recordStreak дн',
                        icon: Icons.emoji_events_rounded,
                        color: c.xp,
                        isLightTheme: !isDark,
                        index: 2,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: _ActivityStat(
                        label: 'Поточна серія',
                        value: '$currentStreak дн',
                        icon: Icons.local_fire_department_rounded,
                        color: c.coin,
                        isLightTheme: !isDark,
                        index: 3,
                      ),
                    ),
                  ],
                ),

                // ── Summary row ────────────────────────────────
                const SizedBox(height: Spacing.sm),
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      _MiniChip(
                        icon: Icons.savings_rounded,
                        label: 'Всього: ${totalSaved.formatUAH()} грн',
                        color: c.accent,
                        c: c,
                      ),
                      _MiniChip(
                        icon: Icons.show_chart_rounded,
                        label: 'XP: ${provider.totalXP}',
                        color: AppColorsPS5.xp,
                        c: c,
                      ),
                      _MiniChip(
                        icon: Icons.monetization_on_rounded,
                        label: 'Монет: ${provider.totalCoins}',
                        color: AppColorsPS5.coin,
                        c: c,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                // ── Related transactions (collapsible) ────────────────
                _buildCollapsibleSection(
                  title: 'Пов\'язані транзакції',
                  icon: Icons.link_rounded,
                  isExpanded: _showRelatedTransactions,
                  onTap: _toggleRelatedTransactions,
                  textColor: c.textPrimary,
                  child: _buildRelatedTransactions(provider, c),
                ),

                const SizedBox(height: Spacing.xl),

                // ── Activity note (collapsible) ────────────────────
                _buildCollapsibleSection(
                  title: 'Нотатка до активності',
                  icon: Icons.edit_note_rounded,
                  isExpanded: _showActivityNote,
                  onTap: _toggleNote,
                  textColor: c.textPrimary,
                  child: _buildActivityNote(c),
                ),

                const SizedBox(height: Spacing.xl),

                // ── Analytics section (collapsible) ──────────────────
                _buildCollapsibleSection(
                  title: 'Аналітика',
                  icon: Icons.analytics_rounded,
                  isExpanded: _showAnalytics,
                  onTap: _toggleAnalytics,
                  textColor: c.textPrimary,
                  child: _buildAnalyticsSection(provider, c),
                ),

                // ── Motivational section ─────────────────────────
                _buildMotivationSection(
                  currentStreak,
                  recordStreak,
                  c,
                  isDark,
                ),

                const SizedBox(height: Spacing.xxxl),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Widget builders ──────────────────────────────────────

  Widget _buildMonthSelector(dynamic c) {
    final now = DateTime.now();
    final selectedDate = DateTime(
        now.year,
        now.month - _selectedMonthOffset,
        1,
    );
    final monthName = selectedDate.monthUAH;
    final year = selectedDate.year;
    final canGoForward = _selectedMonthOffset < 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _onMonthChange(-1),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: c.textSecondary,
              size: 22,
            ),
          ),
        ),
        Text(
          '$monthName $year',
          style: AppTypography.heading3.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: canGoForward ? () => _onMonthChange(1) : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: canGoForward
                  ? c.border.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: canGoForward
                  ? c.textSecondary
                  : c.border.withOpacity(0.2),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapCard({
    required Map<DateTime, double> heatmapData,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Карта активності',
            style: AppTypography.heading3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Spacing.base),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _heatmapController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _HeatmapPainter(
                    data: heatmapData,
                    baseColor: c.accent,
                    emptyColor: c.border.withOpacity(0.3),
                    textColor: c.textHint,
                    progress: _heatmapController.value,
                    monthOffset: _selectedMonthOffset,
                    onCellTap: (date, amount) {
                      final dateStr =
                          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                      if (amount > 0) {
                        context.showToast(
                          '$dateStr: ${amount.formatUAH()} грн',
                          icon: Icons.attach_money_rounded,
                          color: c.cardElevated,
                        );
                      } else {
                        context.showToast(
                          '$dateStr: немає внесків',
                          icon: Icons.remove_circle_outline_rounded,
                          color: c.cardElevated,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLegend(dynamic c) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: c.border.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Менше',
            style: AppTypography.labelSmall.copyWith(color: c.textHint),
          ),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: c.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              ...List.generate(4, (i) {
                final opacity = 0.25 + (i * 0.25);
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: c.accent.withOpacity(
                      opacity.clamp(0.0, 1.0),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ],
          ),
          Text(
            'Більше',
            style: AppTypography.labelSmall.copyWith(color: c.textHint),
          ),
        ],
      ),
    );
  }

  /// Розширена мотиваційна секція з динамічними повідомленнями.
  Widget _buildMotivationSection(
    int currentStreak,
    int recordStreak,
    dynamic c,
    bool isDark,
  ) {
    String message;
    IconData icon;
    Color color;

    if (currentStreak >= recordStreak && currentStreak >= 7) {
      message = 'Новий рекорд серії! Ти на вогні!';
      icon = Icons.local_fire_department_rounded;
      color = c.coin;
    } else if (currentStreak >= 7) {
      message = 'Серія триває! Не зупиняйся!';
      icon = Icons.bolt_rounded;
      color = c.accent;
    } else if (currentStreak >= 3) {
      message = 'Хороший початок! Продовжуй у тому ж дусі!';
      icon = Icons.trending_up_rounded;
      color = c.success;
    } else {
      message = 'Почни серію вже сьогодні! Маленькі кроки ведуть до великих результатів.';
      icon = Icons.lightbulb_rounded;
      color = c.textHint;
    }

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: color.withOpacity(0.15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  /// Колабсабельна секція з заголовком та вмістком.
  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color textColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Icon(icon, color: textColor, size: 18),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: textColor,
                size: 20,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: child,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  /// Пов'язані транзакції — моковий список з іконками типів.
  Widget _buildRelatedTransactions(DashboardProvider provider, dynamic c) {
    final related = provider.recentTransactions;
    return related.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Center(
              child: Text(
                'Немає пов\'язаних транзакцій',
                style: AppTypography.labelMedium.copyWith(color: c.textHint),
              ),
            ),
          )
        : Column(
          children: related.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(color: c.border.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Icon(
                      t.type == TransactionType.manual
                          ? Icons.touch_app_rounded
                          : Icons.autorenew_rounded,
                      color: c.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.amount.formatUAH()} грн',
                          style: AppTypography.monoSmall.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatRelDate(t.createdAt),
                          style: AppTypography.labelSmall.copyWith(
                            color: c.textHint,
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

  /// Нотатка до активності з полем для редагування.
  Widget _buildActivityNote(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Залиш нотатку',
          style: AppTypography.labelLarge.copyWith(
            color: c.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: _noteController,
          maxLines: 4,
          maxLength: 300,
          style: AppTypography.bodyMedium.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: 'Напиши нотатку до цього дня...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: c.textHint.withOpacity(0.5),
            ),
            filled: true,
            fillColor: c.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              borderSide: BorderSide(color: c.border),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.md),
                borderSide: BorderSide(color: c.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: 14,
              ),
            ),
          ),
        const SizedBox(height: Spacing.md),
        SizedBox(
          width: double.infinity,
          child: AppButtonSecondary(
            label: 'Зберегти',
            icon: Icons.save_rounded,
            onPressed: _saveNote,
            isLightTheme: !Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ],
    );
  }

  /// Секція аналітики з метриками продуктивності.
  Widget _buildAnalyticsSection(DashboardProvider provider, dynamic c) {
    final streak = provider.currentStreak;
    final efficiency = provider.depositCount > 0
        ? (provider.totalXP / provider.depositCount).round()
        : 0;
    final consistency = streak / 30 * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Аналітика',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: Spacing.sm),
        _AnalyticsMetric(
          icon: Icons.bolt_rounded,
          label: 'Ефективність (XP/внесок)',
          value: '$efficiency XP',
          color: c.accent,
          c: c,
        ),
        _AnalyticsMetric(
          icon: Icons.repeat_rounded,
          label: 'Стабільність',
          value: '$consistency%',
          color: consistency >= 70 ? c.success : c.warning,
          c: c,
        ),
        _AnalyticsMetric(
          icon: Icons.local_fire_department_rounded,
          label: 'Поточна серія',
          value: '$streak дн',
          color: streak >= 7 ? c.coin : c.textHint,
          c: c,
        ),
        _AnalyticsMetric(
          icon: Icons.insights_rounded,
          label: 'Загальна сума',
          value: '${provider.currentAmount.formatUAH()} грн',
          color: c.success,
          c: c,
        ),
        const SizedBox(height: Spacing.md),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: c.accent.withOpacity(0.04),
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.accent.withOpacity(0.1)),
          child: Text(
            '💡 Збільш ефективність — виконуй щоденні виклики!',
            style: AppTypography.labelSmall.copyWith(
              color: c.accent,
            ),
          ),
        ),
      ],
    );
  }

  String _formatRelDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }
}

/// Міні-картка статистики з анімацією появи та trend-індикатором.
class _ActivityStat extends StatelessWidget {
  const _ActivityStat({
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
    return AppCard(
      isLightTheme: isLightTheme,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
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
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: c.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 80 + 150).ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          delay: (index * 80 + 150).ms,
          curve: AppEasings.spring,
        );
  }
}

/// Міні-чип з іконкою та значенням.
class _MiniChip {
  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.c,
  });

  final IconData icon;
  final String label;
  final Color color;
  final dynamic c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// GitHub-style heatmap calendar CustomPainter.
class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.data,
    required this.baseColor,
    required this.emptyColor,
    required this.textColor,
    required this.progress,
    this.monthOffset = 0,
    this.onCellTap,
  });

  final Map<DateTime, double> data;
  final Color baseColor;
  final Color emptyColor;
  final Color textColor;
  final double progress;
  final int monthOffset;
  final void Function(DateTime date, double amount)? onCellTap;

  static const _dayLabels =
      ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - monthOffset, 1);
    final daysInMonth = targetMonth.daysInMonth;
    final firstDayWeekday = targetMonth.weekday;

    final leftPad = 28.0;
    final topPad = 16.0;
    final rightPad = 4.0;
    final bottomPad = 4.0;

    final availW = size.width - leftPad - rightPad;
    final availH = size.height - topPad - bottomPad;
    final cellW = availW / 7;
    final cellH = availH /
        ((daysInMonth + firstDayWeekday - 1) / 7).ceil();
    final cellSize = math.min(cellW, cellH);
    final cellGap = 2.0;
    final actualCellSize = cellSize - cellGap;
    final cellRadius = 3.0;

    // Month label
    final monthSpan = TextSpan(
      text: targetMonth.monthShortUAH,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    final monthTp = TextPainter(
      text: monthSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    monthTp.paint(canvas, Offset(leftPad, 0));

    // Day-of-week labels (left side)
    final dayLabelStyle =
        TextStyle(color: textColor, fontSize: 9);
    for (var row = 0; row < 7; row++) {
      final span = TextSpan(text: _dayLabels[row], style: dayLabelStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(
        canvas,
        Offset(0, topPad + row * cellSize + cellSize / 2 - tp.height / 2),
      );
    }

    // Calculate max amount for color intensity
    final monthData = data.entries.where((e) {
      return e.key.year == targetMonth.year && e.key.month == targetMonth.month;
    }).toList();
    final maxAmount = monthData.isEmpty
        ? 1.0
        : monthData.map((e) => e.value).reduce(math.max).clamp(1, double.infinity);

    // Total cells to animate
    final totalCells = daysInMonth + firstDayWeekday - 1;
    final visibleCells = (totalCells * progress).floor();

    // Cells
    for (var i = 0; i < totalCells; i++) {
      if (i >= visibleCells) break;

      final col = i % 7;
      final row = i ~/ 7;
      final day = i - firstDayWeekday + 2;

      final x = leftPad + col * cellSize;
      final y = topPad + row * cellSize;

      if (day < 1 || day > daysInMonth) continue;

      final date = DateTime(targetMonth.year, targetMonth.month, day);
      final amount =
          data[DateTime(date.year, date.month, date.day)] ?? 0.0;

      final opacity = amount > 0
          ? (0.2 + 0.8 * (amount / maxAmount))
              .clamp(0.2, 1.0)
          : 0.0;

      final cellFade =
          ((progress * totalCells - i) / 3).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = amount > 0
            ? baseColor.withOpacity(opacity * cellFade)
            : emptyColor.withOpacity(cellFade),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + cellGap / 2,
            y + cellGap / 2,
            actualCellSize,
            actualCellSize,
          ),
          Radius.circular(cellRadius),
        ),
        paint,
      );

      // Day number inside cell (subtle)
      if (cellFade > 0.5 && cellSize > 22) {
        final daySpan = TextSpan(
          text: '$day',
          style: TextStyle(
            color: amount > 0
                ? baseColor.withOpacity(0.6 * cellFade)
                : textColor.withOpacity(0.3 * cellFade),
            fontSize: 8,
          ),
        );
        final dayTp = TextPainter(
          text: daySpan,
          textDirection: TextDirection.ltr,
        )..layout();
        dayTp.paint(
          canvas,
          Offset(
            x + cellSize / 2 - dayTp.width / 2,
            y + cellSize / 2 - dayTp.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.progress != progress ||
      oldDelegate.monthOffset != monthOffset;
}

/// Дані для розрахунку продуктивності активності.
class _ActivityProductivityData {
  /// Загальна кількість активних днів.
  final int activeDays;

  /// Загальна сума заощаджень.
  final double totalSaved;

  /// Середня сума за активний день.
  final double avgPerActiveDay;

  /// Оцінка ефективності (від 0 до 100).
  final double efficiencyScore;

  /// Кількість XP на один внесок.
  final double xpPerDeposit;

  /// Кількість монет на один внесок.
  final double coinsPerDeposit;

  const _ActivityProductivityData({
    required this.activeDays,
    required this.totalSaved,
    required this.avgPerActiveDay,
    required this.efficiencyScore,
    required this.xpPerDeposit,
    required this.coinsPerDeposit,
  });
}

/// Розширена картка розподілу активності по дням тижня.
class _WeekdayDistribution extends StatelessWidget {
  const _WeekdayDistribution({
    required this.data,
    required this.c,
    required this.isLightTheme,
  });

  final Map<int, int> data;
  final dynamic c;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
    final maxVal = data.values.fold<int>(0, (a, b) => a > b ? a : b).clamp(1, 100);

    return AppCard(
      isLightTheme: isLightTheme,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Активність по дням тижня',
              style: AppTypography.heading3.copyWith(color: c.textPrimary)),
          const SizedBox(height: Spacing.base),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final count = (data[i] ?? 0);
              final ratio = maxVal > 0 ? count / maxVal : 0.0;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 40 * ratio.clamp(0.1, 1.0),
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.15 + 0.5 * ratio),
                      borderRadius: BorderRadius.circular(Radii.xs),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(dayLabels[i],
                      style: AppTypography.caption.copyWith(
                        color: ratio > 0 ? c.accent : c.textHint,
                        fontWeight: ratio > 0 ? FontWeight.w600 : FontWeight.w400,
                      )),
                  const SizedBox(height: 2),
                  Text('$count',
                      style: AppTypography.caption.copyWith(
                        color: c.textHint, fontSize: 9,
                      )),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Картка прогрес-кільця для відображення цілі.
class _GoalProgressRing extends StatelessWidget {
  const _GoalProgressRing({
    required this.current,
    required this.target,
    required this.c,
    required this.isLightTheme,
  });

  final double current;
  final double target;
  final dynamic c;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (current / target * 100).clamp(0, 100) : 0;
    final remaining = (target - current).clamp(0, double.infinity);

    return AppCard(
      isLightTheme: isLightTheme,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Прогрес цілі',
                  style: AppTypography.heading3.copyWith(color: c.textPrimary)),
              Text('${percentage.toStringAsFixed(1)}%',
                  style: AppTypography.monoMedium.copyWith(
                    color: percentage >= 50 ? c.success : c.accent,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: Spacing.base),
          // Progress ring using ClipRect + CircularProgressIndicator
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: c.border.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 100
                          ? c.coin
                          : (percentage >= 50 ? c.success : c.accent),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${percentage.toInt()}%',
                          style: AppTypography.monoLarge.copyWith(
                            color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 24,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        remaining > 0
                            ? 'Залишилось: ${remaining.formatUAH()} грн'
                            : 'Ціль досягнуто!',
                        style: AppTypography.caption.copyWith(
                          color: remaining > 0 ? c.textSecondary : c.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Діалог експорту звіту активності.
void _showActivityExportDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final c = isDark ? AppColorsPS5 : AppColorsMonitor;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
      title: Text('Експорт активності',
          style: AppTypography.heading3.copyWith(color: c.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Обери формат звіту активності:',
              style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
          const SizedBox(height: Spacing.base),
          _ActivityExportOption(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF звіт',
            description: 'Форматований звіт з heatmap та статистикою',
            color: c.accent,
            c: c,
            onTap: () {
              Navigator.pop(ctx);
              // ignore: use_build_context_synchronously
              context.showAppToast('PDF експортовано!', type: AppToastType.success);
            },
          ),
          const SizedBox(height: Spacing.sm),
          _ActivityExportOption(
            icon: Icons.table_chart_rounded,
            label: 'CSV таблиця',
            description: 'Дані по днях тижня для аналізу',
            color: c.success,
            c: c,
            onTap: () {
              Navigator.pop(ctx);
              context.showAppToast('CSV експортовано!', type: AppToastType.success);
            },
          ),
          const SizedBox(height: Spacing.sm),
          _ActivityExportOption(
            icon: Icons.share_rounded,
            label: 'Зображення heatmap',
            description: 'Карта активності для поділу',
            color: c.coin,
            c: c,
            onTap: () {
              Navigator.pop(ctx);
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

/// Опція експорту активності для діалогу.
class _ActivityExportOption extends StatelessWidget {
  const _ActivityExportOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.c,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final dynamic c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
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
}
