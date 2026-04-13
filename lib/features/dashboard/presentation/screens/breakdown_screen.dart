import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

/// Екран розбивки джерел коштів із донат-діаграмою.
///
/// Використовує CustomPainter замість fl_chart.
/// Містить: донат-діаграму з анімацією, легенду з відсотками,
/// пораду залежно від розподілу, стан порожніх даних, скелетон
/// завантаження, інтерактивні сегменти, переключення періоду.
class BreakdownScreen extends ConsumerStatefulWidget {
  const BreakdownScreen({super.key});

  @override
  ConsumerState<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends ConsumerState<BreakdownScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  int _selectedPeriodIndex = 0;
  bool _showPercentages = true;
  int? _highlightedSegment;

  /// Доступні періоди аналізу.
  static const _periods = ['Цей місяць', 'Попередній', 'За весь час', 'Цей тиждень'];

  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  void _onPeriodTap(int index) {
    HapticService.selection();
    setState(() {
      _selectedPeriodIndex = index;
      _isLoading = true;
    });
    // Імітація завантаження
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _onSegmentTap(int index) {
    HapticService.lightTap();
    setState(() {
      _highlightedSegment = _highlightedSegment == index ? null : index;
    });
  }

  void _togglePercentages() {
    HapticService.selection();
    setState(() => _showPercentages = !_showPercentages);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final transactions = state.recentTransactions;

    // Групуємо транзакції за типом.
    final manualTotal = transactions
        .where((t) => t.type == TransactionType.manual)
        .fold(0.0, (sum, t) => sum + t.amount);
    final roundUpTotal = transactions
        .where((t) => t.type == TransactionType.roundUp)
        .fold(0.0, (sum, t) => sum + t.amount);
    final autoTotal = transactions
        .where((t) => t.type == TransactionType.autoPayment)
        .fold(0.0, (sum, t) => sum + t.amount);
    final challengeTotal = transactions
        .where((t) => t.type == TransactionType.challenge)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalAmount = manualTotal + roundUpTotal + autoTotal + challengeTotal;
    final transactionCount = transactions.length;

    final segments = <_DonutSegment>[
      _DonutSegment(label: 'Вручну', value: manualTotal, color: AppColorsPS5.success, icon: Icons.touch_app_rounded),
      _DonutSegment(label: 'Округлення', value: roundUpTotal, color: AppColorsPS5.accent, icon: Icons.sync_rounded),
      _DonutSegment(label: 'Авто-платіж', value: autoTotal, color: AppColorsPS5.warning, icon: Icons.autorenew_rounded),
      _DonutSegment(label: 'Виклик', value: challengeTotal, color: const Color(0xFFFF6D00), icon: Icons.emoji_events_rounded),
    ];

    // Найбільший сегмент.
    final maxSegment = segments.fold<_DonutSegment>(
      segments.first,
      (max, seg) => seg.value > max.value ? seg : max,
    );

    if (_isLoading) return _buildLoadingSkeleton(isLight);

    return Scaffold(
      backgroundColor:
          isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Звідки надходять кошти',
          style: AppTypography.heading2.copyWith(
            color: isLight
                ? AppColorsMonitor.textPrimary
                : AppColorsPS5.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isLight
                ? AppColorsMonitor.textPrimary
                : AppColorsPS5.textPrimary,
          ),
          onPressed: () {
            HapticService.lightTap();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Перемикач відсотків
          IconButton(
            icon: Icon(
              _showPercentages ? Icons.percent_rounded : Icons.bar_chart_rounded,
              color: isLight
                  ? AppColorsMonitor.textSecondary
                  : AppColorsPS5.textSecondary,
            ),
            onPressed: _togglePercentages,
            tooltip: _showPercentages ? 'Сховати відсотки' : 'Показати відсотки',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          children: [
            const SizedBox(height: Spacing.base),

            // ── Загальна статистика ──────────────────────────────────
            _buildSummaryRow(isLight, totalAmount, transactionCount),

            const SizedBox(height: Spacing.lg),

            // ── Переключення періоду ────────────────────────────────
            _buildPeriodSelector(isLight),

            const SizedBox(height: Spacing.lg),

            // ── Донат-діаграма ──────────────────────────────────────
            SizedBox(
              height: 200,
              child: Center(
                child: totalAmount > 0
                    ? AnimatedBuilder(
                        animation: _chartController,
                        builder: (context, _) {
                          return Transform.rotate(
                            angle: math.sin(_chartController.value * math.pi * 2) * 0.02,
                            child: CustomPaint(
                              size: const Size(180, 180),
                              painter: _DonutPainter(
                                segments: segments,
                                total: totalAmount,
                                centerText:
                                    '${totalAmount.toInt().formatUAH()} грн',
                                isLight: isLight,
                                highlightedIndex: _highlightedSegment,
                                animProgress: _chartController.value,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildEmptyDonutState(isLight),
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),

            const SizedBox(height: Spacing.xl),

            // ── Легенда з інтерактивними сегментами ──────────────────
            ...segments.asMap().entries.map((entry) {
              final index = entry.key;
              final seg = entry.value;
              final pct = totalAmount > 0
                  ? ((seg.value / totalAmount) * 100).toStringAsFixed(1)
                  : '0.0';
              final isHighlighted = _highlightedSegment == index;

              return GestureDetector(
                onTap: () => _onSegmentTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isHighlighted ? 16 : 12,
                        height: isHighlighted ? 16 : 12,
                        decoration: BoxDecoration(
                          color: seg.color,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: isHighlighted
                              ? [BoxShadow(color: seg.color.withOpacity(0.4), blurRadius: 8)]
                              : null,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Icon(seg.icon, color: seg.color, size: 18),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seg.label,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isLight
                                    ? AppColorsMonitor.textPrimary
                                    : AppColorsPS5.textPrimary,
                                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            if (isHighlighted && seg.value > 0)
                              Text(
                                'Найбільший внесок: ${seg.value.toInt().formatUAH()} грн',
                                style: AppTypography.caption.copyWith(
                                  color: isLight
                                      ? AppColorsMonitor.textSecondary
                                      : AppColorsPS5.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${seg.value.toInt().formatUAH()} грн',
                        style: AppTypography.labelLarge.copyWith(
                          color: isLight
                              ? AppColorsMonitor.textPrimary
                              : AppColorsPS5.textPrimary,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      if (_showPercentages)
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$pct%',
                            style: AppTypography.labelMedium.copyWith(
                              color: isLight
                                  ? AppColorsMonitor.textSecondary
                                  : AppColorsPS5.textSecondary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: Spacing.xl),

            // ── Картка лідера ────────────────────────────────────────
            if (totalAmount > 0)
              _buildLeaderCard(isLight, maxSegment),

            const SizedBox(height: Spacing.xl),

            // ── Порада ──────────────────────────────────────────────
            AppCard(
              isLightTheme: isLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: isLight
                            ? AppColorsMonitor.warning
                            : AppColorsPS5.warning,
                        size: 20,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Порада',
                        style: AppTypography.heading3.copyWith(
                          color: isLight
                              ? AppColorsMonitor.textPrimary
                              : AppColorsPS5.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    totalAmount > 0 && manualTotal / totalAmount > 0.8
                        ? 'Спробуй увімкнути автоматичне округлення — це дозволить накопичувати без зусиль!'
                        : totalAmount > 0 && roundUpTotal / totalAmount > 0.5
                            ? 'Округлення працює чудово! Ти автоматично накопичуєш кожного дня!'
                            : 'Чудовий розподіл! Продовжуй у тому ж темпі.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isLight
                          ? AppColorsMonitor.textSecondary
                          : AppColorsPS5.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

            // ── Порада щодо автоматизації ────────────────────────────
            const SizedBox(height: Spacing.md),
            if (autoTotal == 0 && totalAmount > 0)
              AppCard(
                isLightTheme: isLight,
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                      size: 18,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'Авто-платіж ще не налаштовано. Спробуй — це заощадить час!',
                        style: AppTypography.bodySmall.copyWith(
                          color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }

  // ── Загальна статистика ──────────────────────────────────────────
  Widget _buildSummaryRow(bool isLight, double total, int count) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(Spacing.base),
            decoration: BoxDecoration(
              color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border),
            ),
            child: Column(
              children: [
                Text(
                  '${total.toInt().formatUAH()} грн',
                  style: AppTypography.monoMedium.copyWith(
                    color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text('Загальна сума', style: AppTypography.labelSmall.copyWith(
                  color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                )),
              ],
            ),
          ),
        ).animate().fade(duration: 400.ms),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(Spacing.base),
            decoration: BoxDecoration(
              color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: AppTypography.monoMedium.copyWith(
                    color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text('Транзакцій', style: AppTypography.labelSmall.copyWith(
                  color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                )),
              ],
            ),
          ),
        ).animate().fade(duration: 400.ms, delay: 100.ms),
      ],
    );
  }

  // ── Переключення періоду ─────────────────────────────────────────
  Widget _buildPeriodSelector(bool isLight) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final isActive = _selectedPeriodIndex == index;
          return GestureDetector(
            onTap: () => _onPeriodTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
              decoration: BoxDecoration(
                color: isActive ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(
                  color: isActive
                      ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)
                      : (isLight ? AppColorsMonitor.border : AppColorsPS5.border),
                ),
              ),
              child: Center(
                child: Text(
                  _periods[index],
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive ? Colors.white : (isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Порожній стан діаграми ───────────────────────────────────────
  Widget _buildEmptyDonutState(bool isLight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.pie_chart_outline_rounded,
          size: 48,
          color: (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint).withOpacity(0.5),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          'Немає даних',
          style: AppTypography.bodyMedium.copyWith(
            color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Зроби перший внесок, щоб побачити розбивку!',
          style: AppTypography.labelSmall.copyWith(
            color: (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint).withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fade(duration: 500.ms);
  }

  // ── Картка лідера ────────────────────────────────────────────────
  Widget _buildLeaderCard(bool isLight, _DonutSegment leader) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: leader.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: leader.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(leader.icon, color: leader.color, size: 22),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Найбільше: ${leader.label}',
                  style: AppTypography.labelMedium.copyWith(
                    color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${leader.value.toInt().formatUAH()} грн з ${leader.icon == Icons.touch_app_rounded ? 'ручних внесків' : 'автоматичних джерел'}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(
              color: leader.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Radii.circular),
            ),
            child: Text(
              '🥇 Лідер',
              style: AppTypography.labelSmall.copyWith(
                color: leader.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 300.ms);
  }

  // ── Скелетон завантаження ────────────────────────────────────────
  Widget _buildLoadingSkeleton(bool isLight) {
    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(width: 40),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          children: [
            const SizedBox(height: Spacing.base),
            // Фейкові картки статистики
            Row(
              children: [
                Expanded(child: _skeletonBox(200, 80, isLight)),
                const SizedBox(width: Spacing.sm),
                Expanded(child: _skeletonBox(200, 80, isLight)),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            // Фейкова діаграма
            Center(child: _skeletonBox(180, 180, isLight)),
            const SizedBox(height: Spacing.xl),
            // Фейкові сегменти
            for (int i = 0; i < 4; i++) _skeletonBox(double.infinity, 40, isLight),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBox(double width, double height, bool isLight) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
    );
  }
}

/// Модель сегмента донат-діаграми.
class _DonutSegment {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _DonutSegment({
    required this.label,
    required this.value,
    required this.color,
    this.icon = Icons.circle_rounded,
  });
}

/// CustomPainter для малювання donut chart з анімацією.
class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.total,
    required this.centerText,
    required this.isLight,
    this.highlightedIndex,
    this.animProgress = 1.0,
  });

  final List<_DonutSegment> segments;
  final double total;
  final String centerText;
  final bool isLight;
  final int? highlightedIndex;
  final double animProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 28.0;
    final radius = (size.width - strokeWidth) / 2;

    var startAngle = -math.pi / 2;

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.value <= 0) continue;
      final sweepAngle = (seg.value / total) * 2 * math.pi * animProgress;
      final isHighlighted = highlightedIndex == i;
      final strokeWidthFinal = isHighlighted ? strokeWidth + 6 : strokeWidth;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidthFinal
        ..strokeCap = StrokeCap.round;

      if (isHighlighted) {
        paint.shader = LinearGradient(
          colors: [seg.color, seg.color.withOpacity(0.7)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Центральний текст
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: AppTypography.monoSmall.copyWith(
          color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.highlightedIndex != highlightedIndex ||
        oldDelegate.animProgress != animProgress;
  }
}
