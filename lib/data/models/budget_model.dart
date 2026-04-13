import 'package:flutter/material.dart';

/// Модель бюджету для певної категорії витрат.
class CategoryBudget {
  final String categoryName;
  final double limitAmount;
  final double spentAmount;
  final IconData icon;
  final Color color;

  CategoryBudget({
    required this.categoryName,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.icon,
    required this.color,
  });

  double get progress => (spentAmount / limitAmount).clamp(0.0, 1.0);
  double get remaining => limitAmount - spentAmount;
  bool get isExceeded => spentAmount > limitAmount;

  CategoryBudget copyWith({
    double? spentAmount,
    double? limitAmount,
  }) {
    return CategoryBudget(
      categoryName: categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      icon: icon,
      color: color,
    );
  }
}

/// Модель витрати.
class Expense {
  final String id;
  final String categoryName;
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.categoryName,
    required this.amount,
    required this.description,
    required this.date,
  });
}
