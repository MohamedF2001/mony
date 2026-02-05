/*
// lib/features/budget/data/models/budget_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int period; // 0 = monthly, 1 = yearly

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime? endDate;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: budget.category,
      amount: budget.amount,
      period: budget.period.index,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
    );
  }

  Budget toEntity() {
    return Budget(
      id: id,
      category: category,
      amount: amount,
      period: period == 0 ? BudgetPeriod.monthly : BudgetPeriod.yearly,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period == 0 ? 'monthly' : 'yearly',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] == 'monthly' ? 0 : 1,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}*/


import '../../domain/entities/budget.dart';

class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final int period; // 0 = monthly, 1 = yearly
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: budget.category,
      amount: budget.amount,
      period: budget.period.index,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
    );
  }

  Budget toEntity() {
    return Budget(
      id: id,
      category: category,
      amount: amount,
      period: period == 0 ? BudgetPeriod.monthly : BudgetPeriod.yearly,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period == 0 ? 'monthly' : 'yearly',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] == 'monthly' ? 0 : 1,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
