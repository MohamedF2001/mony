// lib/features/budget/domain/entities/budget.dart

import 'package:equatable/equatable.dart';

enum BudgetPeriod {
  monthly,
  yearly,
}

class Budget extends Equatable {
  final String? id;
  final String category;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  const Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  double getSpentAmount(List transactions) {
    return transactions
        .where((t) => t.category == category && t.date.isAfter(startDate))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getRemainingAmount(List transactions) {
    return amount - getSpentAmount(transactions);
  }

  double getPercentageUsed(List transactions) {
    if (amount == 0) return 0;
    return (getSpentAmount(transactions) / amount * 100).clamp(0, 100);
  }

  bool isOverBudget(List transactions) {
    return getSpentAmount(transactions) > amount;
  }

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        amount,
        period,
        startDate,
        endDate,
        isActive,
        createdAt,
      ];
}