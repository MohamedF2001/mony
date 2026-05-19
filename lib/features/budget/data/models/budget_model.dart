import '../../domain/entities/budget.dart';

class BudgetModel {
  final String id;
  final String category; // ID de la catégorie
  final String? categoryName; // Nom de la catégorie pour l'affichage
  final double amount;
  final int period; // 0 = monthly, 1 = yearly
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    this.categoryName,
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
      categoryName: budget.categoryName,
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
      categoryName: categoryName,
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
    final categoryData = json['category'];
    String categoryId = '';
    String? categoryName;

    if (categoryData is Map) {
      categoryId = (categoryData['_id'] ?? categoryData['id'] ?? '').toString();
      categoryName = categoryData['name']?.toString();
    } else {
      categoryId = categoryData?.toString() ?? '';
    }

    return BudgetModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      category: categoryId,
      categoryName: categoryName ?? json['categoryName']?.toString(),
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] == 'monthly' ? 0 : 1,
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
