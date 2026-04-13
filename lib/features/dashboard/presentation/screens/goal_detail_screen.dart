import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_money_display.dart';
import '../../../../core/widgets/app_particle_bg.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

/// Екран деталей цілі з повною статистикою, підцямилями, поділом та zoom-in анімацією.
class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  bool _isEditing = false;
  final _editNameController = TextEditingController();
  final _editTargetController = TextEditingController();
  bool _showSubGoals = false;

  @override
  void dispose() {
    _editNameController.dispose();
    _editTargetController.dispose();
    super.dispose();
  }

  void _showEditDialog(Goal goal) {
    _editNameController.text = goal.name;
    _editTargetController.text = goal.targetAmount.toInt().toString();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редагувати ціль'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editNameController,
                decoration: const InputDecoration(
                  labelText: 'Назва цілі',
                  border: OutlineInputBorder(),
                  hintText: 'Наприклад: PlayStation 5',
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Введи назву' : null,
              ),
              const SizedBox(height: Spacing.base),
              TextFormField(
                controller: _editTargetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Цільова сума (грн)',
                  border: OutlineInputBorder(),
                  prefixText: '₴ ',
                  hintText: 'Наприклад: 25999',
                ),
                validator: (v) {
                  final amount = double.tryParse(v ?? '');
                  if (amount == null || amount <= 0) return 'Введи коректну суму';
                  if (amount < goal.currentAmount) return 'Менше ніж накопичено';
                  return null;
                },
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Поточний внесок: ${goal.currentAmount.toInt().formatUAH()} грн',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorsPS5.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.showToast('Ціль оновлено!', icon: Icons.check_circle_rounded);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  void _shareProgress(Goal goal) {
    final percentage = (goal.progress * 100).toInt();
    context.showToast(
      'Поділитися: $percentage% на ${goal.name}',
      icon: Icons.share_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final goal = state.goal;

    if (goal == null) {
      return Scaffold(
        backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColorsPS5.error),
              const SizedBox(height: Spacing.md),
              Text('Ціль не знайдена', style: AppTypography.heading3),
              const SizedBox(height: Spacing.lg),
              AppButtonSecondary(
                label: 'Повернутися',
                icon: Icons.arrow_back_rounded,
                isLightTheme: isLight,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    }

    final daysPassed = DateTime.now().difference(goal.createdAt).inDays;
    final transactions = state.recentTransactions;
    final avgDeposit = transactions.isNotEmpty
        ? transactions.map((t) => t.amount).reduce((a, b) => a + b) / transactions.length
        : 0.0;
    final largestDeposit = transactions.isNotEmpty
        ? transactions.map((t) => t.amount).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final smallestDeposit = transactions.isNotEmpty
        ? transactions.map((t) => t.amount).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final percentage = (goal.progress * 100).toInt();
    final remaining = (goal.targetAmount - goal.currentAmount).toInt();

    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Деталі цілі',
          style: AppTypography.heading2.copyWith(
            color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
            ),
            onPressed: () => _shareProgress(goal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Силует з прогресом (zoom-in) ────────────────
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 220,
              child: Center(
                child: ParticleSilhouette(
                  goalType: goal.type,
                  progress: goal.progress,
                  isLightTheme: isLight,
                ),
              ),
            ).animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.0, 1.0),
                duration: 700.ms,
                curve: Curves.easeOutBack,
              ),

            const SizedBox(height: Spacing.lg),

            // ── Назва цілі з кнопкою редагування ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    goal.name,
                    style: AppTypography.heading1.copyWith(
                      color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                GestureDetector(
                  onTap: () => _showEditDialog(goal),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

            const SizedBox(height: Spacing.base),

            // ── Поточна / Цільова сума ──────────────────────────
            Center(
              child: Column(
                children: [
                  AppMoneyDisplay(
                    amount: goal.currentAmount,
                    isLightTheme: isLight,
                    style: AppTypography.monoLarge.copyWith(
                      color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'з ${goal.targetAmount.toInt().formatUAH()} грн',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                    ),
                  ),
                  if (remaining > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.xs),
                      child: Text(
                        'Залишилось ${remaining.formatUAH()} грн',
                        style: AppTypography.labelSmall.copyWith(
                          color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

            const SizedBox(height: Spacing.base),

            // ── Широкий прогрес-бар з відсотком ──────────────────
            Column(
              children: [
                AppProgressBar(
                  progress: goal.progress,
                  isLightTheme: isLight,
                  height: 14,
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$percentage% виконано',
                      style: AppTypography.heading3.copyWith(
                        color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: percentage >= 75
                            ? AppColorsPS5.success.withOpacity(0.1)
                            : percentage >= 50
                                ? AppColorsPS5.warning.withOpacity(0.1)
                                : (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      child: Text(
                        percentage >= 75
                            ? '🌟 Майже готово!'
                            : percentage >= 50
                                ? '🔥 Половина!'
                                : '💪 Тримаймо!',
                        style: AppTypography.labelSmall.copyWith(
                          color: percentage >= 75
                              ? AppColorsPS5.success
                              : percentage >= 50
                                  ? AppColorsPS5.warning
                                  : (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: Spacing.xl),

            // ── Деталі (статистика) ──────────────────────────────
            AppCard(
              isLightTheme: isLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                        size: 20,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Статистика',
                        style: AppTypography.heading3.copyWith(
                          color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.base),
                  _DetailRow(label: 'Створено', value: goal.createdAt.formatted(), isLight: isLight),
                  _DetailRow(label: 'Днів пройшло', value: '$daysPassed', isLight: isLight),
                  _DetailRow(
                    label: 'Середній внесок / день',
                    value: '${avgDeposit.toInt().formatUAH()} грн',
                    isLight: isLight,
                  ),
                  _DetailRow(
                    label: 'Найбільший внесок',
                    value: '${largestDeposit.toInt().formatUAH()} грн',
                    isLight: isLight,
                  ),
                  _DetailRow(
                    label: 'Найменший внесок',
                    value: '${smallestDeposit.toInt().formatUAH()} грн',
                    isLight: isLight,
                  ),
                  _DetailRow(label: 'Усього внесків', value: '${transactions.length}', isLight: isLight),
                  _DetailRow(label: 'Найдовша серія', value: '${goal.longestStreak} дн.', isLight: isLight),
                  _DetailRow(
                    label: 'Щоденний середній',
                    value: daysPassed > 0
                        ? '${(goal.currentAmount / daysPassed).toInt().formatUAH()} грн'
                        : '—',
                    isLight: isLight,
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 300.ms),

            const SizedBox(height: Spacing.xl),

            // ── Підцілі ────────────────────────────────────────
            if (goal.subGoals.isNotEmpty) ...[
              AppCard(
                isLightTheme: isLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt_rounded,
                              color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                              size: 20,
                            ),
                            const SizedBox(width: Spacing.sm),
                            Text(
                              'Підцілі (${goal.subGoals.length})',
                              style: AppTypography.heading3.copyWith(
                                color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showSubGoals = !_showSubGoals),
                          child: Text(
                            _showSubGoals ? 'Сховати' : 'Всі →',
                            style: AppTypography.labelMedium.copyWith(
                              color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.base),

                    // Показати 2 або всі
                    ...goal.subGoals.take(_showSubGoals ? goal.subGoals.length : 2).map((sg) => Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          sg.name,
                                          style: AppTypography.labelLarge.copyWith(
                                            color: isLight
                                                ? AppColorsMonitor.textPrimary
                                                : AppColorsPS5.textPrimary,
                                          ),
                                        ),
                                        if (sg.progress >= 1.0) ...[
                                          const SizedBox(width: Spacing.xs),
                                          const Icon(Icons.check_circle_rounded,
                                              color: AppColorsPS5.success, size: 14),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: sg.progress,
                                              minHeight: 4,
                                              backgroundColor:
                                                  (isLight ? AppColorsMonitor.border : AppColorsPS5.border)
                                                      .withOpacity(0.5),
                                              valueColor: AlwaysStoppedAnimation(
                                                isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: Spacing.sm),
                                        Text(
                                          '${sg.currentAmount.toInt().formatUAH()} / '
                                          '${sg.targetAmount.toInt().formatUAH()}',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: isLight
                                                ? AppColorsMonitor.textSecondary
                                                : AppColorsPS5.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),

                    if (!_showSubGoals && goal.subGoals.length > 2)
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _showSubGoals = true),
                          child: Text(
                            '...та ще ${goal.subGoals.length - 2}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 400.ms),
              const SizedBox(height: Spacing.xl),
            ],

            // ── Кнопки дій ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: AppButtonSecondary(
                    label: 'Редагувати',
                    icon: Icons.edit_rounded,
                    isLightTheme: isLight,
                    onPressed: () => _showEditDialog(goal),
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: AppButtonPrimary(
                    label: 'Поділитися',
                    icon: Icons.share_rounded,
                    isLightTheme: isLight,
                    showGlow: true,
                    onPressed: () => _shareProgress(goal),
                  ).animate().fadeIn(duration: 500.ms, delay: 550.ms),
                ),
              ],
            ),

            const SizedBox(height: Spacing.md),

            // ── Кнопка видалити (небезпечно) ───────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Видалити ціль?'),
                      content: Text(
                        'Ціль "${goal.name}" та всі внески буде видалено назавжди.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Скасувати'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.showToast('Ціль видалено', icon: Icons.delete_rounded);
                          },
                          child: Text(
                            'Видалити',
                            style: TextStyle(color: AppColorsPS5.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete_outline_rounded, size: 16, color: AppColorsPS5.error),
                label: Text(
                  'Видалити ціль',
                  style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColorsPS5.error.withOpacity(0.3)),
                ),
              ),
            ),

            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }
}

/// Рядок деталі для картки статистики.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isLight,
  });

  final String label;
  final String value;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
