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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../providers/dashboard_provider.dart';

/// Екран прогнозу досягнення цілі з графіком фактичних даних,
/// прогнозованою лінією, довірчим інтервалом, сезонними коригуваннями
/// та пропозиціями прискорення.
class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  static const String route = '/forecast';

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
          'Прогноз',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final targetDate = provider.forecastedTargetDate;
          final daysLeft = provider.forecastedDaysLeft;
          final perDay = provider.forecastedPerDay;
          final actualData = provider.last30DaysData;
          final forecastData = provider.forecastData;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              children: [
                const SizedBox(height: Spacing.base),

                // ── Central forecast card ──────────────────────────
                _buildCentralForecastCard(
                  targetDate: targetDate,
                  daysLeft: daysLeft,
                  perDay: perDay,
                  c: c,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: Spacing.xl),

                // ── Forecast chart ─────────────────────────────────
                _buildForecastChart(
                  actualData: actualData,
                  forecastData: forecastData,
                  targetAmount: provider.targetAmount,
                  c: c,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: Spacing.xl),

                // ── Acceleration suggestions ───────────────────────
                _buildAccelerationSuggestions(c, isDark, daysLeft, perDay)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: Spacing.xl),

                // ── Seasonal adjustments ──────────────────────────
                _buildSeasonalAdjustments(c, isDark)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: Spacing.xl),

                // ── Accelerate button ─────────────────────────────
                AppButtonPrimary(
                  label: 'Прискорити',
                  icon: Icons.rocket_launch_rounded,
                  showPulse: true,
                  onPressed: () {
                    HapticService.mediumTap();
                    _showAccelerationDialog(context, daysLeft, c);
                  },
                  isLightTheme: !isDark,
                  showGlow: true,
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

  Widget _buildCentralForecastCard({
    required DateTime targetDate,
    required int daysLeft,
    required double perDay,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      child: Column(
        children: [
          // Caption
          Text(
            'При поточному темпі ти досягнеш мети',
            style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.base),

          // Target date (typewriter, 34pt, accent)
          _TypewriterDate(
            date: targetDate,
            isLightTheme: !isDark,
            accentColor: c.success,
          ),
          const SizedBox(height: Spacing.base),

          // Days remaining + per day
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: c.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Days remaining
                Icon(Icons.schedule_rounded, color: c.accent, size: 18),
                const SizedBox(width: Spacing.xs),
                Text(
                  '$daysLeft днів залишилось',
                  style: AppTypography.monoSmall.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                // Divider
                Container(
                  width: 1,
                  height: 20,
                  color: c.border,
                ),
                const SizedBox(width: Spacing.md),
                // Per day
                Icon(Icons.attach_money_rounded, color: c.textPrimary, size: 18),
                const SizedBox(width: Spacing.xs),
                Text(
                  '~${perDay.formatUAH()} грн / день',
                  style: AppTypography.monoSmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.xs),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 4,
              backgroundColor: c.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(c.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart({
    required List<double> actualData,
    required List<double> forecastData,
    required double targetAmount,
    required dynamic c,
    required bool isDark,
  }) {
    return AppCard(
      isLightTheme: !isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Графік прогнозу',
            style: AppTypography.heading3.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: Spacing.base),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _ForecastChartPainter(
                actualData: actualData,
                forecastData: forecastData,
                targetLine: targetAmount,
                lineColor: c.accent,
                forecastColor: c.accent.withOpacity(0.4),
                confidenceColor: c.accent.withOpacity(0.08),
                targetColor: c.error.withOpacity(0.5),
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
              _LegendItem(color: c.accent, label: 'Факт'),
              const SizedBox(width: Spacing.base),
              _LegendItem(
                color: c.accent.withOpacity(0.4),
                label: 'Прогноз',
                isDashed: true,
              ),
              const SizedBox(width: Spacing.base),
              _LegendItem(
                color: c.accent.withOpacity(0.15),
                label: 'Інтервал',
              ),
              const SizedBox(width: Spacing.base),
              _LegendItem(
                color: c.error.withOpacity(0.5),
                label: 'Ціль',
                isDashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccelerationSuggestions(
    dynamic c, bool isDark, int daysLeft, double perDay,
  ) {
    final suggestions = [
      _AccelerationSuggestion(
        title: 'Збільш внески на 20 грн/день',
        description: 'Досягнеш на ${math.max(1, daysLeft ~/ 7)} днів раніше',
        icon: Icons.trending_up_rounded,
        color: c.success,
      ),
      _AccelerationSuggestion(
        title: 'Додай щотижневий бонус',
        description: '+500 грн/тиждень прискорить на ${math.max(1, daysLeft ~/ 10)} днів',
        icon: Icons.add_circle_outline_rounded,
        color: c.accent,
      ),
      _AccelerationSuggestion(
        title: 'Активуй щоденний челендж',
        description: 'Додатково +50–200 грн на день',
        icon: Icons.emoji_events_rounded,
        color: c.xp,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Як прискорити',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: Spacing.sm),
        ...suggestions.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: AppCard(
              isLightTheme: !isDark,
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          s.description,
                          style: AppTypography.labelSmall.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: c.textHint,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeasonalAdjustments(dynamic c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сезонні коригування',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: Spacing.sm),
        AppCard(
          isLightTheme: !isDark,
          padding: const EdgeInsets.all(Spacing.base),
          child: Column(
            children: [
              _buildSeasonRow('Зима', '-5%', 'Сезонні витрати', c, AppColorsPS5.warning),
              const SizedBox(height: Spacing.sm),
              _buildSeasonRow('Весна', '+3%', 'Бонуси та подарунки', c, AppColorsPS5.success),
              const SizedBox(height: Spacing.sm),
              _buildSeasonRow('Літо', '+8%', 'Відпусткові заощадження', c, AppColorsPS5.success),
              const SizedBox(height: Spacing.sm),
              _buildSeasonRow('Осінь', '0%', 'Стабільний період', c, c.accent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonRow(
    String season, String percent, String note, dynamic c, Color color,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            season,
            style: AppTypography.labelLarge.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            percent,
            style: AppTypography.monoSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            note,
            style: AppTypography.labelSmall.copyWith(
              color: c.textHint,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showAccelerationDialog(
    BuildContext context, int daysLeft, dynamic c,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: Text(
          'Прискорити досягнення',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Обери спосіб прискорити накопичення:',
              style: AppTypography.bodyMedium.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.base),
            _buildAccelerationOption(
              icon: Icons.trending_up_rounded,
              title: 'Збільшити щоденний внесок',
              subtitle: '+20 грн/день → на ${math.max(1, daysLeft ~/ 7)} днів раніше',
              color: c.accent,
              c: c,
            ),
            const SizedBox(height: Spacing.sm),
            _buildAccelerationOption(
              icon: Icons.calendar_today_rounded,
              title: 'Додати щотижневий внесок',
              subtitle: '+300 грн/тиждень → на ${math.max(1, daysLeft ~/ 10)} днів раніше',
              color: c.success,
              c: c,
            ),
            const SizedBox(height: Spacing.sm),
            _buildAccelerationOption(
              icon: Icons.emoji_events_rounded,
              title: 'Виконувати щоденні виклики',
              subtitle: '+50–200 грн/день бонус',
              color: c.xp,
              c: c,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Закрити'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccelerationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required dynamic c,
  }) {
    return Container(
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
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
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
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  final Color color;
  final String label;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: isDashed ? 0 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        if (isDashed)
          CustomPaint(
            size: const Size(20, 3),
            painter: _DashedLinePainter(color: color),
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
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 4, size.height / 2), paint);
      x += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) => old.color != color;
}

class _AccelerationSuggestion {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _AccelerationSuggestion({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Typewriter animation for the target date.
class _TypewriterDate extends StatefulWidget {
  const _TypewriterDate({
    required this.date,
    required this.isLightTheme,
    required this.accentColor,
  });

  final DateTime date;
  final bool isLightTheme;
  final Color accentColor;

  @override
  State<_TypewriterDate> createState() => _TypewriterDateState();
}

class _TypewriterDateState extends State<_TypewriterDate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    final fullText = _formatDate(widget.date);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fullText.length * 50),
    )..addListener(() {
        final chars = (_controller.value * fullText.length).floor();
        if (_displayedText.length != chars) {
          setState(() => _displayedText = fullText.substring(0, chars));
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
      'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText.isEmpty ? ' ' : _displayedText,
      style: AppTypography.displayLarge.copyWith(
        fontSize: 34,
        color: widget.accentColor,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// CustomPainter графіку: фактичні дані (суцільна лінія) + прогноз
/// (пунктирна) + довірчий інтервал (затінена область).
class _ForecastChartPainter extends CustomPainter {
  _ForecastChartPainter({
    required this.actualData,
    required this.forecastData,
    required this.targetLine,
    required this.lineColor,
    required this.forecastColor,
    required this.confidenceColor,
    required this.targetColor,
    required this.textColor,
    required this.gridColor,
  });

  final List<double> actualData;
  final List<double> forecastData;
  final double targetLine;
  final Color lineColor;
  final Color forecastColor;
  final Color confidenceColor;
  final Color targetColor;
  final Color textColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final allData = [...actualData, ...forecastData, targetLine];
    if (allData.isEmpty) return;

    final padding = const EdgeInsets.fromLTRB(40, 12, 12, 24);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;
    final totalPoints = actualData.length + forecastData.length;
    final maxVal = allData.reduce(math.max).clamp(1, double.infinity);
    final minVal = 0.0;
    final range = maxVal - minVal;

    final dx = totalPoints > 1 ? chartW / (totalPoints - 1) : chartW;

    // ── Grid ────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (var i = 0; i <= 4; i++) {
      final y = padding.top + (chartH / 4) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
      final val = maxVal - (range / 4) * i;
      final span = TextSpan(
        text: val >= 1000
            ? '${(val / 1000).toStringAsFixed(1)}k'
            : val.toInt().toString(),
        style: TextStyle(color: textColor, fontSize: 10),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }

    double toY(double val) =>
        padding.top + chartH - ((val - minVal) / range * chartH);

    // ── Confidence interval (shaded area) ─────────────────────
    if (forecastData.length >= 2) {
      final startIdx = actualData.length > 0 ? actualData.length - 1 : 0;
      final lastActualVal =
          actualData.isNotEmpty ? actualData.last : forecastData.first;

      final upperPath = Path();
      final lowerPath = Path();

      // Upper bound
      upperPath.moveTo(
        Offset(padding.left + startIdx * dx, toY(lastActualVal * 1.05)),
      );
      for (var i = 0; i < forecastData.length; i++) {
        upperPath.lineTo(
          Offset(
            padding.left + (startIdx + 1 + i) * dx,
            toY(forecastData[i] * 1.15),
          ),
        );
      }

      // Lower bound (reversed)
      for (var i = forecastData.length - 1; i >= 0; i--) {
        lowerPath.lineTo(
          Offset(
            padding.left + (startIdx + 1 + i) * dx,
            toY(forecastData[i] * 0.85),
          ),
        );
      }
      lowerPath.lineTo(
        Offset(padding.left + startIdx * dx, toY(lastActualVal * 0.95)),
      );

      upperPath.addPath(lowerPath);
      upperPath.close();

      canvas.drawPath(
        upperPath,
        Paint()..color = confidenceColor,
      );
    }

    // ── Actual data line (solid) ───────────────────────────────
    if (actualData.length >= 2) {
      final points = <Offset>[];
      for (var i = 0; i < actualData.length; i++) {
        points.add(Offset(padding.left + i * dx, toY(actualData[i])));
      }
      // Glow
      canvas.drawPath(
        Path()..moveTo(points.first.dx, points.first.dy)
          ..addAll(points.skip(1).map((p) => p)),
        Paint()
          ..color = lineColor.withOpacity(0.2)
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Line
      canvas.drawPath(
        Path()..moveTo(points.first.dx, points.first.dy)
          ..addAll(points.skip(1).map((p) => p)),
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      // Dots
      for (final p in points) {
        canvas.drawCircle(p, 2.5, Paint()..color = lineColor);
      }
    }

    // ── Forecast data line (dashed) ────────────────────────────
    if (forecastData.length >= 2) {
      final startIdx = actualData.length > 0 ? actualData.length - 1 : 0;
      final lastActualVal =
          actualData.isNotEmpty ? actualData.last : forecastData.first;

      final points = <Offset>[
        Offset(padding.left + startIdx * dx, toY(lastActualVal)),
      ];
      for (var i = 0; i < forecastData.length; i++) {
        points.add(
          Offset(
            padding.left + (startIdx + 1 + i) * dx,
            toY(forecastData[i]),
          ),
        );
      }

      const dashWidth = 6.0;
      const dashSpace = 4.0;
      for (var i = 0; i < points.length - 1; i++) {
        var startX = points[i].dx;
        final startY = points[i].dy;
        final endX = points[i + 1].dx;
        final endY = points[i + 1].dy;

        while (startX < endX) {
          final segEnd = (startX + dashWidth).clamp(startX, endX);
          final t = endX > startX ? (segEnd - startX) / (endX - startX) : 0;
          canvas.drawLine(
            Offset(startX, startY),
            Offset(segEnd, startY + (endY - startY) * t),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = forecastColor
              ..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round,
          );
          startX += dashWidth + dashSpace;
        }
      }

      // Forecast dots (every 3rd)
      for (var i = 0; i < points.length; i += 3) {
        canvas.drawCircle(
          points[i],
          2,
          Paint()..color = forecastColor,
        );
      }
    }

    // ── Target line (horizontal dashed) ────────────────────────
    if (targetLine > 0) {
      final targetY = toY(targetLine);
      const dashW = 8.0;
      const dashS = 4.0;
      var x = padding.left;
      while (x < size.width - padding.right) {
        final endX = (x + dashW).clamp(x, size.width - padding.right);
        canvas.drawLine(
          Offset(x, targetY),
          Offset(endX, targetY),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = targetColor
            ..strokeWidth = 1.5,
        );
        x += dashW + dashS;
      }
      // Label
      final label = TextPainter(
        text: TextSpan(
          text: 'Ціль',
          style: TextStyle(
            color: targetColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(size.width - padding.right - label.width - 4, targetY - 14));
    }

    // ── X axis labels ─────────────────────────────────────────
    final now = DateTime.now();
    final totalLen = totalPoints;
    for (var i = 0; i < totalLen; i += (totalLen > 30 ? 7 : 3)) {
      final x = padding.left + i * dx;
      final daysAgo = actualData.length - 1 - i;
      final label = daysAgo >= 0
          ? '${math.abs(daysAgo)}д'
          : '+${math.abs(daysAgo)}д';
      final span = TextSpan(
        text: label,
        style: TextStyle(color: textColor, fontSize: 8),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant _ForecastChartPainter oldDelegate) =>
      oldDelegate.actualData != actualData ||
      oldDelegate.forecastData != forecastData;
}

/// Дані сценарію прискорення з розрахованими датою та сумою.
class _AccelerationScenarioData {
  /// Назва сценарію для відображення.
  final String title;

  /// Опис сценарію для відображення.
  final String description;

  /// Іконка для відображення.
  final IconData icon;

  /// Кількість днів скорочення.
  final int daysSaved;

  /// Додаткова сума за день у цьому сценарії.
  final double extraPerDay;

  /// Кольор для відображення.
  final Color color;

  /// Загальна економія у цьому сценарії.
  double get totalSaved => daysSaved * extraPerDay;

  const _AccelerationScenarioData({
    required this.title,
    required this.description,
    required this.icon,
    required this.daysSaved,
    required this.extraPerDay,
    required this.color,
  });
}

/// Детальний розрахунок прогнозу з довірчим інтервалом.
class _ForecastCalculation {
  /// Розраховує очікувану дату досягнення цілі.
  static DateTime estimateTargetDate({
    required double currentAmount,
    required double targetAmount,
    required double dailyRate,
  }) {
    if (dailyRate <= 0 || targetAmount <= currentAmount) return DateTime.now();
    final remaining = (targetAmount - currentAmount).clamp(0, double.infinity);
    final daysNeeded = (remaining / dailyRate).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  /// Розраховує кількість днів до досягнення цілі з різними темпами.
  static int daysToTarget({
    required double current,
    required double target,
    required double dailyRate,
  }) {
    if (dailyRate <= 0 || target <= current) return 0;
    return ((target - current) / dailyRate).ceil();
  }

  /// Розраховує прогрес у відсотках.
  static double progressPercent({
    required double current,
    required double target,
  }) {
    if (target <= 0) return 0;
    return (current / target * 100).clamp(0, 100);
  }

  /// Розраховує кількість днів скорочення при збільшенні темпу.
  static int calculateDaysSaved({
    required double current,
    required double target,
    required double currentDailyRate,
    required double newDailyRate,
  }) {
    if (newDailyRate <= currentDailyRate || currentDailyRate <= 0) return 0;
    final normalDays = daysToTarget(
      current: current,
      target: target,
      dailyRate: currentDailyRate,
    );
    final acceleratedDays = daysToTarget(
      current: current,
      target: target,
      dailyRate: newDailyRate,
    );
    return (normalDays - acceleratedDays).clamp(0, 9999);
  }

  /// Генерує список сценаріїв прискорення.
  static List<_AccelerationScenarioData> generateScenarios({
    required int baseDaysLeft,
    required double currentDaily,
  }) {
    return [
      _AccelerationScenarioData(
        title: 'Консервативний (+10%)',
        description: '+${(currentDaily * 0.1).formatUAH()} грн/день → на ${math.max(1, baseDaysLeft ~/ 10)} днів раніше',
        icon: Icons.trending_up_rounded,
        daysSaved: math.max(1, baseDaysLeft ~/ 10),
        extraPerDay: currentDaily * 0.1,
        color: const Color(0xFF4CAF50),
      ),
      _AccelerationScenarioData(
        title: 'Помірний (+25%)',
        description: '+${(currentDaily * 0.25).formatUAH()} грн/день → на ${math.max(1, baseDaysLeft ~/ 7)} днів раніше',
        icon: Icons.speed_rounded,
        daysSaved: math.max(1, baseDaysLeft ~/ 7),
        extraPerDay: currentDaily * 0.25,
        color: const Color(0xFF2196F3),
      ),
      _AccelerationScenarioData(
        title: 'Агресивний (+50%)',
        description: '+${(currentDaily * 0.5).formatUAH()} грн/день → на ${math.max(1, baseDaysLeft ~/ 4)} днів раніше',
        icon: Icons.bolt_rounded,
        daysSaved: math.max(1, baseDaysLeft ~/ 4),
        extraPerDay: currentDaily * 0.5,
        color: const Color(0xFFFF9800),
      ),
      _AccelerationScenarioData(
        title: 'Максимальний (+100%)',
        description: 'Подвій每天的 внесок → на ${math.max(1, baseDaysLeft ~/ 2)} днів раніше',
        icon: Icons.rocket_launch_rounded,
        daysSaved: math.max(1, baseDaysLeft ~/ 2),
        extraPerDay: currentDaily,
        color: const Color(0xFFE91E63),
      ),
    ];
  }
}

/// Карта сценарію прискорення з анімацією та даними.
class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.index,
    required this.c,
    required this.isLightTheme,
  });

  final _AccelerationScenarioData scenario;
  final int index;
  final dynamic c;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300 + index * 50),
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scenario.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: scenario.color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scenario.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(scenario.icon, color: scenario.color, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scenario.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: c.textPrimary, fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(scenario.description,
                    style: AppTypography.labelSmall.copyWith(color: c.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  'Економія: ${scenario.totalSaved.formatUAH()} грн за ${scenario.daysSaved} днів',
                  style: AppTypography.caption.copyWith(
                    color: scenario.color, fontWeight: FontWeight.w600,
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

/// Секція чутливості прогнозу з анімованою та рекомендаціями.
class _ForecastSensitivitySection extends StatelessWidget {
  const _ForecastSensitivitySection({
    required this.daysLeft,
    required this.perDay,
    required this.c,
    required this.isLightTheme,
  });

  final int daysLeft;
  final double perDay;
  final dynamic c;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    final scenarios = _ForecastCalculation.generateScenarios(
      baseDaysLeft: daysLeft,
      currentDaily: perDay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Аналіз чутливості',
            style: AppTypography.heading3.copyWith(color: c.textPrimary)),
        const SizedBox(height: Spacing.sm),
        Text(
          'Якщо ти змінюш темп внесків, ось що станеться:',
          style: AppTypography.labelSmall.copyWith(color: c.textHint),
        ),
        const SizedBox(height: Spacing.sm),
        ...scenarios.map((s) => _ScenarioCard(
          scenario: s,
          index: scenarios.indexOf(s),
          c: c,
          isLightTheme: isLightTheme,
        )),
      ],
    );
  }
}

/// Кнопка дії для прискорення з підсвіткою.
class _AccelerateActionButton extends StatelessWidget {
  const _AccelerateActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.c,
    required this.isLightTheme,
    this.showGlow = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final dynamic c;
  final bool isLightTheme;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(Radii.lg),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: c.accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: Spacing.sm),
            Text(label,
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

/// Прогрес-індикатор для прогнозу з метою та відстанню.
class _ForecastProgressIndicator extends StatelessWidget {
  const _ForecastProgressIndicator({
    required this.percentage,
    required this.targetLabel,
    required this.c,
  });

  final double percentage;
  final String targetLabel;
  final dynamic c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(targetLabel,
                style: AppTypography.labelMedium.copyWith(color: c.textSecondary)),
            Text('${percentage.toStringAsFixed(1)}%',
                style: AppTypography.monoSmall.copyWith(
                  color: percentage >= 50 ? c.success : c.accent,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.xs),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: c.border.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 100 ? c.coin : (percentage >= 75 ? c.success : c.accent),
            ),
          ),
        ),
      ],
    );
  }
}
