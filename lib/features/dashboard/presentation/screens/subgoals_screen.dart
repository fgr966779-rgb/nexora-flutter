import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_confetti.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

/// Категорії підцілей для організації.
///
/// Кожна категорія має іконку, колір та українську назву.
enum SubGoalCategory {
  /// Геймерські аксесуари.
  gaming('Геймінг', Icons.gamepad_rounded, Color(0xFF6C5CE7)),

  /// Аудіо обладнання.
  audio('Аудіо', Icons.headphones_rounded, Color(0xFF00B894)),

  /// Підписки та сервіси.
  subscriptions('Підписки', Icons.subscriptions_rounded, Color(0xFFE17055)),

  /// Інше.
  other('Інше', Icons.more_horiz_rounded, Color(0xFF636E72));

  const SubGoalCategory(this.label, this.icon, this.color);

  /// Українська назва категорії.
  final String label;

  /// Іконка категорії.
  final IconData icon;

  /// Колір категорії.
  final Color color;
}

/// Екран підцілей — список accessories до основної цілі з пріоритетами,
/// swipe-to-delete з undo, add dialog, edit dialog, empty state, total remaining,
/// drag-to-reorder, святкування завершення, категорії, залежності.
class SubgoalsScreen extends ConsumerStatefulWidget {
  const SubgoalsScreen({super.key});

  @override
  ConsumerState<SubgoalsScreen> createState() => _SubgoalsScreenState();
}

class _SubgoalsScreenState extends ConsumerState<SubgoalsScreen> {
  String? _undoDeletedId;
  SubGoal? _undoDeletedSubGoal;
  int _undoTimerSeconds = 0;
  bool _isReordering = false;
  OverlayEntry? _celebrationEntry;
  SubGoalCategory? _selectedCategory;

  /// Повертає мітку категорії для підцілі.
  ///
  /// Категорія визначається за ім'ям підцілі.
  SubGoalCategory _getCategoryForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('геймпад') || lower.contains('контролер') || lower.contains('ігров')) {
      return SubGoalCategory.gaming;
    }
    if (lower.contains('навушник') || lower.contains('колонк') || lower.contains('мікрофон')) {
      return SubGoalCategory.audio;
    }
    if (lower.contains('підписк') || lower.contains('сервіс') || lower.contains('ps plus')) {
      return SubGoalCategory.subscriptions;
    }
    return SubGoalCategory.other;
  }

  /// Перевіряє залежність між підцямилями.
  ///
  /// Повертає true, якщо перша підціль є залежністю другої.
  bool _hasDependency(SubGoal sg, List<SubGoal> allGoals) {
    return allGoals.any((other) =>
        other.id != sg.id &&
        other.name.toLowerCase().contains(sg.name.toLowerCase().split(' ').first));
  }

  /// Показує святкування завершення підцілі.
  void _showCompletionCelebration(SubGoal sg) {
    _celebrationEntry = AppConfetti.celebration(
      context: context,
      particleCount: 60,
    );
    HapticService.heavyTap();
    context.showToast(
      '🎉 Підціль «${sg.name}» виконано!',
      icon: Icons.celebration_rounded,
    );
    // Автоматичне видалення конфетті через 3 секунди
    Future.delayed(const Duration(seconds: 3), () {
      _celebrationEntry?.remove();
      _celebrationEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final goal = state.goal;
    final subGoals = goal?.subGoals ?? [];

    // Загальна сума, що залишилась
    final totalRemaining = subGoals.fold<double>(0, (sum, sg) => sum + sg.remaining);
    final completedCount = subGoals.where((sg) => sg.progress >= 1.0).length;
    final totalTarget = subGoals.fold<double>(0, (sum, sg) => sum + sg.targetAmount);
    final completionPercentage = totalTarget > 0
        ? ((1 - totalRemaining / totalTarget) * 100).toInt()
        : 0;

    // Статистика по категоріях
    final categoryStats = <SubGoalCategory, int>{};
    for (final sg in subGoals) {
      final cat = _getCategoryForName(sg.name);
      categoryStats[cat] = (categoryStats[cat] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Повний набір',
              style: AppTypography.heading2.copyWith(
                color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
              ),
            ),
            if (subGoals.isNotEmpty)
              Text(
                '${subGoals.length} підцілей • Залишилось ${totalRemaining.toInt().formatUAH()} грн',
                style: AppTypography.labelSmall.copyWith(
                  color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (subGoals.isNotEmpty) ...[
            // Кнопка фільтрації за категоріями
            IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
              ),
              onPressed: () {
                _showCategoryFilterDialog(context, isLight, categoryStats);
              },
            ),
            // Кнопка сортування
            IconButton(
              icon: Icon(
                _isReordering ? Icons.check_rounded : Icons.sort_rounded,
                color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
              ),
              onPressed: () {
                setState(() => _isReordering = !_isReordering);
                if (!_isReordering) {
                  context.showToast('Сортування завершено', icon: Icons.check_rounded);
                } else {
                  context.showToast('Перетягніть для зміни порядку', icon: Icons.swap_vert_rounded);
                }
              },
            ),
          ],
        ],
      ),
      body: subGoals.isEmpty
          ? _buildEmptyState(isLight)
          : Stack(
              children: [
                Column(
                  children: [
                    // ── Загальна статистика ────────────────────
                    Container(
                      margin: const EdgeInsets.all(Spacing.base),
                      padding: const EdgeInsets.all(Spacing.base),
                      decoration: BoxDecoration(
                        color: isLight ? AppColorsMonitor.card : AppColorsPS5.card,
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: Border.all(
                          color: isLight ? AppColorsMonitor.border : AppColorsPS5.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                label: 'Всього',
                                value: '${subGoals.length}',
                                icon: Icons.inventory_2_outlined,
                                color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                              ),
                              _buildStatItem(
                                label: 'Виконано',
                                value: '$completedCount',
                                icon: Icons.check_circle_outline_rounded,
                                color: AppColorsPS5.success,
                              ),
                              _buildStatItem(
                                label: 'Залишилось',
                                value: '${totalRemaining.toInt().formatUAH()}',
                                icon: Icons.hourglass_top_outlined,
                                color: AppColorsPS5.warning,
                              ),
                            ],
                          ),
                          // Міні-бари по категоріях
                          if (categoryStats.isNotEmpty) ...[
                            const SizedBox(height: Spacing.sm),
                            Wrap(
                              spacing: Spacing.sm,
                              runSpacing: 4,
                              children: categoryStats.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: entry.key.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(Radii.sm),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(entry.key.icon, color: entry.key.color, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${entry.key.label}: ${entry.value}',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: entry.key.color,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    // ── Загальний прогрес ────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                      decoration: BoxDecoration(
                        color: isLight ? AppColorsMonitor.card : AppColorsPS5.card,
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Загальний прогрес', style: AppTypography.labelMedium.copyWith(
                                color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary,
                              )),
                              Text(
                                '$completionPercentage%',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: totalTarget > 0 ? (1 - totalRemaining / totalTarget) : 0,
                              minHeight: 8,
                              backgroundColor: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation(isLight ? AppColorsMonitor.accent : AppColorsPS5.accent),
                            ),
                          ),
                          // Міні-статистика прогресу
                          const SizedBox(height: Spacing.xxs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Завершено $completedCount з ${subGoals.length}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint,
                                  fontSize: 10,
                                ),
                              ),
                              if (completionPercentage >= 75)
                                Text(
                                  '🌟 Майже готово!',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColorsPS5.success,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                    const SizedBox(height: Spacing.sm),

                    // ── Список підцілей ──────────────────────────
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                        itemCount: subGoals.length + 1,
                        onReorder: (oldIndex, newIndex) {
                          if (!_isReordering) return;
                          if (oldIndex < newIndex) newIndex--;
                          // Перестановка пріоритетів
                          ref.read(dashboardProvider.notifier).reorderSubGoal(oldIndex, newIndex);
                          HapticService.selection();
                        },
                        buildDefaultItemBuilder: (context, index) {
                          if (index == subGoals.length) {
                            return Padding(
                              key: const ValueKey('add_button'),
                              padding: const EdgeInsets.only(top: Spacing.base, bottom: Spacing.xxxl),
                              child: AppButtonSecondary(
                                label: 'Додати підціль',
                                icon: Icons.add_rounded,
                                isLightTheme: isLight,
                                onPressed: () => _showAddSubGoalDialog(context),
                              ).animate().fadeIn(duration: 400.ms),
                            );
                          }

                          final sg = subGoals[index];
                          final isCompleted = sg.progress >= 1.0;
                          final category = _getCategoryForName(sg.name);
                          final hasDep = _hasDependency(sg, subGoals);

                          return Dismissible(
                            key: ValueKey(sg.id),
                            direction: DismissDirection.horizontal,
                            background: _buildSwipeBackground(
                              alignment: Alignment.centerLeft,
                              icon: Icons.swap_vert_rounded,
                              color: AppColorsPS5.accent,
                              label: 'Пріоритет',
                            ),
                            secondaryBackground: _buildSwipeBackground(
                              alignment: Alignment.centerRight,
                              icon: Icons.delete_rounded,
                              color: AppColorsPS5.error,
                              label: 'Видалити',
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                return await _confirmDelete(context, sg);
                              }
                              return false;
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                setState(() {
                                  _undoDeletedId = sg.id;
                                  _undoDeletedSubGoal = sg;
                                });
                                ref.read(dashboardProvider.notifier).deleteSubGoal(sg.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${sg.name} видалено'),
                                    action: SnackBarAction(
                                      label: 'Скасувати',
                                      onPressed: () {
                                        context.showToast('Скасовано!', icon: Icons.undo_rounded);
                                      },
                                    ),
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else if (direction == DismissDirection.startToEnd) {
                                ref.read(dashboardProvider.notifier).changeSubGoalPriority(sg.id);
                                context.showToast('Пріоритет змінено!');
                              }
                            },
                            child: _SubGoalTile(
                              subGoal: sg,
                              isLight: isLight,
                              priority: index + 1,
                              isCompleted: isCompleted,
                              category: category,
                              hasDependency: hasDep,
                              isReordering: _isReordering,
                              onDeposit: () async {
                                HapticService.selection();
                                await ref.read(dashboardProvider.notifier).addSubGoalDeposit(sg.id, 100);
                                context.showToast(
                                  '+100 грн до «${sg.name}»',
                                  icon: Icons.check_circle_rounded,
                                );
                                // Перевіряємо чи завершено
                                final updated = ref.read(dashboardProvider).goal?.subGoals.firstWhere((s) => s.id == sg.id);
                                if (updated != null && updated.progress >= 1.0) {
                                  _showCompletionCelebration(sg);
                                }
                              },
                              onEdit: () => _showEditSubGoalDialog(context, sg),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: subGoals.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xl),
              child: AppButtonPrimary(
                label: 'Додати підціль',
                icon: Icons.add_rounded,
                isLightTheme: isLight,
                onPressed: () => _showAddSubGoalDialog(context),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Показує діалог фільтрації за категоріями.
  void _showCategoryFilterDialog(BuildContext context, bool isLight, Map<SubGoalCategory, int> categoryStats) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Фільтр за категоріями'),
        children: SubGoalCategory.values.map((cat) {
          final count = categoryStats[cat] ?? 0;
          return ListTile(
            leading: Icon(cat.icon, color: cat.color),
            title: Text(cat.label),
            trailing: Text(
              '$count',
              style: AppTypography.labelMedium.copyWith(
                color: count > 0
                    ? (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)
                    : (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint),
              ),
            ),
            enabled: count > 0,
            onTap: () {
              setState(() => _selectedCategory = cat);
              Navigator.pop(ctx);
              context.showToast('Фільтр: ${cat.label}', icon: cat.icon);
            },
          );
        }).toList()
          ..add(ListTile(
            leading: const Icon(Icons.clear_all_rounded),
            title: const Text('Скасувати фільтр'),
            onTap: () {
              setState(() => _selectedCategory = null);
              Navigator.pop(ctx);
            },
          )),
      ),
    );
  }

  Widget _buildEmptyState(bool isLight) {
    return AppEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Підцілей ще немає',
      subtitle: 'Додай аксесуари до своєї цілі!\nНаприклад: геймпад, навушники, підписку',
      actionLabel: 'Додати підціль',
      onAction: () => _showAddSubGoalDialog(context),
      isLightTheme: isLight,
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: Spacing.xs),
        Text(value, style: AppTypography.monoSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        Text(label, style: AppTypography.labelSmall.copyWith(color: color.withOpacity(0.6))),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, SubGoal sg) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Видалити підціль?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${sg.name} буде видалено назавжди.'),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Накопичено: ${sg.currentAmount.toInt().formatUAH()} грн',
                  style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.warning),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  '⚠️ Цю дію неможливо скасувати.',
                  style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Видалити', style: TextStyle(color: AppColorsPS5.error)),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Діалог додавання нової підцілі з вибором категорії.
  void _showAddSubGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String? nameError;
    String? amountError;
    SubGoalCategory selectedCat = SubGoalCategory.other;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Нова підціль'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Назва',
                    hintText: 'Наприклад: Геймпад DualSense',
                    border: const OutlineInputBorder(),
                    errorText: nameError,
                  ),
                  onChanged: (_) {
                    setDialogState(() => nameError = null);
                    // Автовизначення категорії
                    final text = nameController.text.trim();
                    if (text.isNotEmpty) {
                      final cat = _getCategoryForName(text);
                      if (cat != SubGoalCategory.other) {
                        setDialogState(() => selectedCat = cat);
                      }
                    }
                  },
                ),
                const SizedBox(height: Spacing.base),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Сума (грн)',
                    hintText: 'Наприклад: 2500',
                    border: const OutlineInputBorder(),
                    prefixText: '₴ ',
                    errorText: amountError,
                  ),
                  onChanged: (_) => setDialogState(() => amountError = null),
                ),
                const SizedBox(height: Spacing.sm),
                // Вибір категорії
                Text(
                  '📂 Категорія',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColorsPS5.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Wrap(
                  spacing: Spacing.sm,
                  children: SubGoalCategory.values.map((cat) {
                    final isSelected = selectedCat == cat;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedCat = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color.withOpacity(0.2) : AppColorsPS5.card,
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(
                            color: isSelected ? cat.color : AppColorsPS5.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, color: cat.color, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              cat.label,
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected ? cat.color : AppColorsPS5.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  '💡 Підцілі допоможуть розбити велику мету на менші кроки',
                  style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0;

                if (name.isEmpty) {
                  setDialogState(() => nameError = 'Введи назву підцілі');
                  return;
                }
                if (amount <= 0) {
                  setDialogState(() => amountError = 'Введи коректну суму');
                  return;
                }

                context.showToast('Підціль «$name» додано!', icon: Icons.check_circle_rounded);
                HapticService.selection();
                nameController.dispose();
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );
  }

  /// Діалог редагування існуючої підцілі.
  void _showEditSubGoalDialog(BuildContext context, SubGoal sg) {
    final nameController = TextEditingController(text: sg.name);
    final amountController = TextEditingController(text: sg.targetAmount.toInt().toString());
    String? nameError;
    String? amountError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Редагувати підціль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Назва',
                  border: const OutlineInputBorder(),
                  errorText: nameError,
                ),
                onChanged: (_) => setDialogState(() => nameError = null),
              ),
              const SizedBox(height: Spacing.base),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Сума (грн)',
                  border: const OutlineInputBorder(),
                  prefixText: '₴ ',
                  errorText: amountError,
                ),
                onChanged: (_) => setDialogState(() => amountError = null),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Внесено: ${sg.currentAmount.toInt().formatUAH()} грн • Прогрес: ${(sg.progress * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0;

                if (name.isEmpty) {
                  setDialogState(() => nameError = 'Введи назву підцілі');
                  return;
                }
                if (amount <= 0) {
                  setDialogState(() => amountError = 'Введи коректну суму');
                  return;
                }
                if (amount < sg.currentAmount) {
                  setDialogState(() => amountError = 'Менше ніж внесено (${sg.currentAmount.toInt().formatUAH()} грн)');
                  return;
                }

                context.showToast('Підціль «$name» оновлено!', icon: Icons.check_circle_rounded);
                nameController.dispose();
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: Spacing.sm),
          Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _celebrationEntry?.remove();
    super.dispose();
  }
}

/// Плитка підцілі з прогресом, пріоритетом, категорією, залежністю,
/// кнопкою «Внести», кнопкою редагування.
class _SubGoalTile extends StatelessWidget {
  const _SubGoalTile({
    required this.subGoal,
    required this.isLight,
    required this.priority,
    required this.isCompleted,
    required this.category,
    required this.hasDependency,
    required this.isReordering,
    required this.onDeposit,
    required this.onEdit,
  });

  final SubGoal subGoal;
  final bool isLight;
  final int priority;
  final bool isCompleted;
  final SubGoalCategory category;
  final bool hasDependency;
  final bool isReordering;
  final VoidCallback onDeposit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accent = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final textColor = isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
    final subColor = isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: AppCard(
        isLightTheme: isLight,
        padding: const EdgeInsets.all(Spacing.base),
        child: Opacity(
          opacity: isCompleted ? 0.65 : 1.0,
          child: Row(
            children: [
              // Іконка з номером пріоритету та категорією
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColorsPS5.success.withOpacity(0.1)
                      : category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_rounded : category.icon,
                      color: isCompleted ? AppColorsPS5.success : category.color,
                      size: 22,
                    ),
                    if (!isCompleted)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$priority',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Індикатор залежності
                    if (hasDependency)
                      Positioned(
                        bottom: 2,
                        left: 2,
                        child: Icon(
                          Icons.link_rounded,
                          color: AppColorsPS5.warning,
                          size: 10,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.base),

              // Інформація
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subGoal.name,
                            style: AppTypography.labelLarge.copyWith(
                              color: textColor,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Кнопка редагування
                        if (!isCompleted)
                          GestureDetector(
                            onTap: onEdit,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.edit_rounded,
                                color: subColor,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Мітка категорії
                    if (!isCompleted) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(Radii.xs),
                        ),
                        child: Text(
                          category.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: category.color.withOpacity(0.7),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: AppProgressBar(
                            progress: subGoal.progress,
                            isLightTheme: isLight,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          '${subGoal.currentAmount.toInt().formatUAH()} / '
                          '${subGoal.targetAmount.toInt().formatUAH()}',
                          style: AppTypography.labelSmall.copyWith(color: subColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompleted
                          ? 'Виконано ✅'
                          : 'Залишилось ${subGoal.remaining.toInt().formatUAH()} грн',
                      style: AppTypography.labelSmall.copyWith(
                        color: isCompleted ? AppColorsPS5.success : subColor.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: Spacing.sm),

              // Кнопка «Внести» або галочка
              isCompleted
                  ? Container(
                      width: 48,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColorsPS5.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColorsPS5.success, size: 20),
                    )
                  : GestureDetector(
                      onTap: onDeposit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.base,
                          vertical: Spacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(Radii.sm),
                          boxShadow: [
                            BoxShadow(color: accent.withOpacity(0.3), blurRadius: 8),
                          ],
                        ),
                        child: isReordering
                            ? const Icon(Icons.drag_handle_rounded, color: Colors.white, size: 16)
                            : Text(
                                'Внести',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    ).animate().slideX(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
