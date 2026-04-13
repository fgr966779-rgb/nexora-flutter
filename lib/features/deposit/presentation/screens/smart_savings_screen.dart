import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora/core/constants/app_colors.dart';
import 'package:nexora/core/constants/app_spacing.dart';
import 'package:nexora/core/constants/app_typography.dart';
import 'package:nexora/core/constants/app_radii.dart';
import 'package:nexora/core/extensions/build_context_ext.dart';

final smartSavingsProvider = StateNotifierProvider<SmartSavingsNotifier, SmartSavingsConfig>((ref) {
  return SmartSavingsNotifier();
});

class SmartSavingsConfig {
  final bool roundUpEnabled;
  final double roundUpTo; // e.g., 10, 50, 100
  final bool paySelfFirstEnabled;
  final double paySelfFirstPercent;

  SmartSavingsConfig({
    this.roundUpEnabled = false,
    this.roundUpTo = 10,
    this.paySelfFirstEnabled = false,
    this.paySelfFirstPercent = 10,
  });

  SmartSavingsConfig copyWith({
    bool? roundUpEnabled,
    double? roundUpTo,
    bool? paySelfFirstEnabled,
    double? paySelfFirstPercent,
  }) {
    return SmartSavingsConfig(
      roundUpEnabled: roundUpEnabled ?? this.roundUpEnabled,
      roundUpTo: roundUpTo ?? this.roundUpTo,
      paySelfFirstEnabled: paySelfFirstEnabled ?? this.paySelfFirstEnabled,
      paySelfFirstPercent: paySelfFirstPercent ?? this.paySelfFirstPercent,
    );
  }
}

class SmartSavingsNotifier extends StateNotifier<SmartSavingsConfig> {
  SmartSavingsNotifier() : super(SmartSavingsConfig());

  void toggleRoundUp(bool value) => state = state.copyWith(roundUpEnabled: value);
  void setRoundUpTo(double value) => state = state.copyWith(roundUpTo: value);
  void togglePaySelfFirst(bool value) => state = state.copyWith(paySelfFirstEnabled: value);
  void setPaySelfFirstPercent(double value) => state = state.copyWith(paySelfFirstPercent: value);
}

class SmartSavingsScreen extends ConsumerWidget {
  const SmartSavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(smartSavingsProvider);
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Розумні заощадження'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.base),
          children: [
            _buildRoundUpSection(context, ref, config, textColor, subColor, cardColor, accent),
            const SizedBox(height: Spacing.xl),
            _buildPaySelfFirstSection(context, ref, config, textColor, subColor, cardColor, accent),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundUpSection(BuildContext context, WidgetRef ref, SmartSavingsConfig config, Color textColor, Color subColor, Color cardColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: config.roundUpEnabled ? accent.withOpacity(0.5) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: accent),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Округлення транзакцій', style: AppTypography.labelLarge.copyWith(color: textColor)),
                    Text('Автоматично відкладай решту', style: AppTypography.caption.copyWith(color: subColor)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: config.roundUpEnabled,
                onChanged: (v) => ref.read(smartSavingsProvider.notifier).toggleRoundUp(v),
                activeColor: accent,
              ),
            ],
          ),
          if (config.roundUpEnabled) ...[
            const SizedBox(height: Spacing.md),
            Text('Округляти до найближчих:', style: AppTypography.bodySmall.copyWith(color: subColor)),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [10.0, 50.0, 100.0].map((val) {
                final isSelected = config.roundUpTo == val;
                return GestureDetector(
                  onTap: () => ref.read(smartSavingsProvider.notifier).setRoundUpTo(val),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? accent : accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Text('${val.toInt()} ₴', style: TextStyle(color: isSelected ? Colors.white : accent, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaySelfFirstSection(BuildContext context, WidgetRef ref, SmartSavingsConfig config, Color textColor, Color subColor, Color cardColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: config.paySelfFirstEnabled ? accent.withOpacity(0.5) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.volunteer_activism_rounded, color: accent),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Плати собі першому', style: AppTypography.labelLarge.copyWith(color: textColor)),
                    Text('Відсоток від кожного доходу', style: AppTypography.caption.copyWith(color: subColor)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: config.paySelfFirstEnabled,
                onChanged: (v) => ref.read(smartSavingsProvider.notifier).togglePaySelfFirst(v),
                activeColor: accent,
              ),
            ],
          ),
          if (config.paySelfFirstEnabled) ...[
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Відсоток:', style: AppTypography.bodySmall.copyWith(color: subColor)),
                Text('${config.paySelfFirstPercent.toInt()}%', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider.adaptive(
              value: config.paySelfFirstPercent,
              min: 1,
              max: 50,
              divisions: 49,
              activeColor: accent,
              onChanged: (v) => ref.read(smartSavingsProvider.notifier).setPaySelfFirstPercent(v),
            ),
          ],
        ],
      ),
    );
  }
}
