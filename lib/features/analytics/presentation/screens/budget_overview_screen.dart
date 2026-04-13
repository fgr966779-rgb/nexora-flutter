import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora/core/constants/app_colors.dart';
import 'package:nexora/core/constants/app_spacing.dart';
import 'package:nexora/core/constants/app_typography.dart';
import 'package:nexora/core/constants/app_radii.dart';
import 'package:nexora/core/extensions/build_context_ext.dart';
import 'package:nexora/features/analytics/providers/budget_provider.dart';
import 'package:nexora/data/models/budget_model.dart';

class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetProvider);
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;

    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
    final totalLimit = budgets.fold(0.0, (sum, b) => sum + b.limitAmount);

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Бюджет та Витрати'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.base),
          children: [
            _buildSummaryCard(totalSpent, totalLimit, textColor, subColor, cardColor),
            const SizedBox(height: Spacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('За категоріями', style: AppTypography.heading3.copyWith(color: textColor)),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: AppColorsPS5.accent),
                  onPressed: () => _showAddExpenseDialog(context, ref, budgets),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            ...budgets.map((budget) => _buildBudgetTile(budget, textColor, subColor, cardColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double spent, double limit, Color textColor, Color subColor, Color cardColor) {
    final progress = (spent / limit).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text('Загальний бюджет', style: AppTypography.labelLarge.copyWith(color: subColor)),
          const SizedBox(height: Spacing.sm),
          Text('${spent.toInt()} / ${limit.toInt()} грн', style: AppTypography.heading1.copyWith(color: textColor)),
          const SizedBox(height: Spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: textColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(progress > 0.9 ? AppColorsPS5.error : AppColorsPS5.success),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            progress > 1.0 ? 'Ліміт перевищено!' : 'Залишилося ${(limit - spent).toInt()} грн',
            style: AppTypography.caption.copyWith(color: progress > 0.9 ? AppColorsPS5.error : AppColorsPS5.success),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTile(CategoryBudget budget, Color textColor, Color subColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(budget.icon, color: budget.color, size: 24),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(budget.categoryName, style: AppTypography.labelMedium.copyWith(color: textColor)),
              ),
              Text('${budget.spentAmount.toInt()} ₴', style: AppTypography.monoSmall.copyWith(color: textColor)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: budget.progress,
              minHeight: 4,
              backgroundColor: textColor.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation(budget.color),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ліміт: ${budget.limitAmount.toInt()} ₴', style: AppTypography.caption.copyWith(color: subColor)),
              Text(
                budget.isExceeded ? 'Перевищення!' : 'Ще ${budget.remaining.toInt()} ₴',
                style: AppTypography.caption.copyWith(color: budget.isExceeded ? AppColorsPS5.error : subColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref, List<CategoryBudget> budgets) {
    String selectedCategory = budgets.first.categoryName;
    double amount = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Додати витрату'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: budgets.map((b) => DropdownMenuItem(value: b.categoryName, child: Text(b.categoryName))).toList(),
              onChanged: (v) => selectedCategory = v!,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Сума'),
              keyboardType: TextInputType.number,
              onChanged: (v) => amount = double.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          TextButton(
            onPressed: () {
              if (amount > 0) {
                ref.read(budgetProvider.notifier).addExpense(selectedCategory, amount);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
  }
}
