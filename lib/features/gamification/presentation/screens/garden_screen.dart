import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../../data/models/garden_state_model.dart';

/// Екран віртуального саду — візуалізація фінансового прогресу.
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = state.goal?.progress ?? 0.0;

    // Створюємо mock-рослини на основі прогресу
    final plants = _generatePlants(progress);

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Мій фінансовий сад'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Spacing.base),
            _buildGardenHeader(context, progress, isDark),
            const SizedBox(height: Spacing.lg),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
                decoration: BoxDecoration(
                  color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(Radii.xl),
                  border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                ),
                child: Stack(
                  children: [
                    // Почва/Трава
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Radii.xl)),
                        ),
                      ),
                    ),
                    // Рослини
                    GridView.builder(
                      padding: const EdgeInsets.all(Spacing.lg),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: Spacing.xl,
                        crossAxisSpacing: Spacing.xl,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        if (index < plants.length) {
                          return _PlantWidget(plant: plants[index]);
                        }
                        return _EmptyPlotWidget(isDark: isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),
            _buildLegend(isDark),
            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildGardenHeader(BuildContext context, double progress, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: AppCard(
        isLightTheme: !isDark,
        child: Column(
          children: [
            Text(
              'Твій сад росте разом з твоїми заощадженнями!',
              style: AppTypography.labelLarge.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
              valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
              minHeight: 8,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Прогрес цілі: ${(progress * 100).toStringAsFixed(1)}%',
              style: AppTypography.caption.copyWith(color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('🌱 <20%', isDark),
          _legendItem('🪴 <50%', isDark),
          _legendItem('🌳 <80%', isDark),
          _legendItem('🌸 >80%', isDark),
        ],
      ),
    );
  }

  Widget _legendItem(String text, bool isDark) {
    return Text(
      text,
      style: AppTypography.caption.copyWith(color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
    );
  }

  List<GardenPlant> _generatePlants(double progress) {
    final List<GardenPlant> plants = [];
    final int count = (progress * 10).clamp(1, 9).toInt();

    for (int i = 0; i < count; i++) {
      PlantGrowthStage stage = PlantGrowthStage.seed;
      if (progress > 0.8) {
        stage = PlantGrowthStage.flowering;
      } else if (progress > 0.5) {
        stage = PlantGrowthStage.mature;
      } else if (progress > 0.2) {
        stage = PlantGrowthStage.growing;
      }

      plants.add(GardenPlant(
        id: i.toString(),
        name: 'Рослина $i',
        stage: stage,
        plantedAt: DateTime.now(),
      ));
    }
    return plants;
  }
}

class _PlantWidget extends StatelessWidget {
  final GardenPlant plant;
  const _PlantWidget({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          plant.stage.emoji,
          style: const TextStyle(fontSize: 40),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
        const SizedBox(height: 4),
        Text(
          plant.stage.displayNameUA,
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _EmptyPlotWidget extends StatelessWidget {
  final bool isDark;
  const _EmptyPlotWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.add_circle_outline_rounded,
          color: (isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint).withOpacity(0.2),
          size: 20,
        ),
      ),
    );
  }
}
