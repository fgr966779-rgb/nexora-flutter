import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/budget_model.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<CategoryBudget>>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<List<CategoryBudget>> {
  BudgetNotifier() : super(_defaultBudgets());

  static List<CategoryBudget> _defaultBudgets() {
    return [
      CategoryBudget(categoryName: 'Продукти', limitAmount: 5000, spentAmount: 1200, icon: Icons.shopping_basket_rounded, color: Colors.green),
      CategoryBudget(categoryName: 'Розваги', limitAmount: 2000, spentAmount: 1800, icon: Icons.movie_rounded, color: Colors.orange),
      CategoryBudget(categoryName: 'Транспорт', limitAmount: 1500, spentAmount: 450, icon: Icons.directions_bus_rounded, color: Colors.blue),
      CategoryBudget(categoryName: 'Кафе', limitAmount: 1000, spentAmount: 0, icon: Icons.restaurant_rounded, color: Colors.pink),
    ];
  }

  void addExpense(String categoryName, double amount) {
    state = [
      for (final budget in state)
        if (budget.categoryName == categoryName)
          budget.copyWith(spentAmount: budget.spentAmount + amount)
        else
          budget,
    ];
  }

  void updateLimit(String categoryName, double newLimit) {
    state = [
      for (final budget in state)
        if (budget.categoryName == categoryName)
          budget.copyWith(limitAmount: newLimit)
        else
          budget,
    ];
  }
}
