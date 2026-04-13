import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora/core/constants/app_colors.dart';
import 'package:nexora/core/constants/app_spacing.dart';
import 'package:nexora/core/constants/app_typography.dart';
import 'package:nexora/core/constants/app_radii.dart';
import 'package:nexora/core/extensions/build_context_ext.dart';
import 'package:nexora/features/academy/providers/academy_provider.dart';
import 'package:nexora/data/models/academy_model.dart';

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(academyProvider);
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Академія Nexora'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.base),
          children: [
            _buildAcademyHeader(textColor, subColor),
            const SizedBox(height: Spacing.xl),
            Text('Ваші уроки', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.md),
            ...lessons.map((lesson) => _buildLessonTile(context, lesson, textColor, subColor, cardColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademyHeader(Color textColor, Color subColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ставай фінансово грамотним', style: AppTypography.heading2.copyWith(color: textColor)),
        const SizedBox(height: Spacing.xs),
        Text('Проходь уроки, отримуй XP та досягай фінансової свободи.', style: AppTypography.bodyMedium.copyWith(color: subColor)),
      ],
    );
  }

  Widget _buildLessonTile(BuildContext context, AcademyLesson lesson, Color textColor, Color subColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: lesson.isCompleted ? AppColorsPS5.success.withOpacity(0.5) : context.isDark ? AppColorsPS5.border : AppColorsMonitor.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(Spacing.md),
        title: Row(
          children: [
            Expanded(child: Text(lesson.title, style: AppTypography.labelLarge.copyWith(color: textColor))),
            if (lesson.isCompleted)
              Icon(Icons.check_circle_rounded, color: AppColorsPS5.success, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(lesson.description, style: AppTypography.bodySmall.copyWith(color: subColor)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)),
                  child: Text(lesson.category.displayNameUA, style: AppTypography.caption.copyWith(color: AppColorsPS5.accent)),
                ),
                const SizedBox(width: 8),
                Text('+${lesson.xpReward} XP', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp)),
              ],
            ),
          ],
        ),
        onTap: () => _showLessonContent(context, ref, lesson),
      ),
    );
  }

  void _showLessonContent(BuildContext context, WidgetRef ref, AcademyLesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: ListView(
            controller: controller,
            children: [
              Text(lesson.title, style: AppTypography.heading2.copyWith(color: context.isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)),
              const SizedBox(height: Spacing.md),
              Text(lesson.content, style: AppTypography.bodyLarge.copyWith(color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
              const SizedBox(height: Spacing.xl),
              if (!lesson.isCompleted)
                ElevatedButton(
                  onPressed: () {
                    ref.read(academyProvider.notifier).completeLesson(lesson.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Урок «${lesson.title}» завершено! +${lesson.xpReward} XP')),
                    );
                  },
                  child: const Text('Завершити урок та отримати XP'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
