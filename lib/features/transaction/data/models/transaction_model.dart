import '../../domain/entities/transaction.dart';
import '../../../category/data/models/category_model.dart';

class TransactionModel {
  final String id;
  final DateTime date;
  final String category;
  final CategoryModel? categoryModel;
  final String? categoryName;
  final double amount;
  final int type; // 0 = income, 1 = expense
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.date,
    required this.category,
    this.categoryModel,
    this.categoryName,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  // From Entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: transaction.date,
      category: transaction.category,
      categoryModel: transaction.categoryObject != null 
          ? CategoryModel.fromEntity(transaction.categoryObject!) 
          : null,
      categoryName: transaction.categoryName,
      amount: transaction.amount,
      type: transaction.type.index,
      description: transaction.description,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  // To Entity
  Transaction toEntity() {
    return Transaction(
      id: id,
      date: date,
      category: category,
      categoryObject: categoryModel?.toEntity(),
      categoryName: categoryName ?? categoryModel?.name,
      amount: amount,
      type: type == 0 ? TransactionType.income : TransactionType.expense,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // To JSON (for export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'categoryModel': categoryModel?.toJson(),
      'categoryName': categoryName,
      'amount': amount,
      'type': type == 0 ? 'income' : 'expense',
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'];
    String categoryId = '';
    CategoryModel? categoryModel;
    String? categoryName;

    if (categoryData != null) {
      if (categoryData is Map) {
        categoryId = (categoryData['_id'] ?? categoryData['id'] ?? '').toString();
        categoryModel = CategoryModel.fromJson(Map<String, dynamic>.from(categoryData));
        categoryName = categoryData['name']?.toString();
      } else {
        categoryId = categoryData.toString();
      }
    }

    return TransactionModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      date: DateTime.parse((json['date'] ?? json['transactionDate']).toString()),
      category: categoryId,
      categoryModel: categoryModel,
      categoryName: categoryName ?? json['categoryName']?.toString(),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? 0 : 1,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }
}
