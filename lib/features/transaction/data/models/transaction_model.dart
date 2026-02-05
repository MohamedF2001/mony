/*
// lib/features/transaction/data/models/transaction_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final int type; // 0 = income, 1 = expense

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.date,
    required this.category,
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
      'amount': amount,
      'type': type == 0 ? 'income' : 'expense',
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From JSON (for import)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? 0 : 1,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
*/

import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final DateTime date;
  final String category;
  final double amount;
  final int type; // 0 = income, 1 = expense
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.date,
    required this.category,
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
      'amount': amount,
      'type': type == 0 ? 'income' : 'expense',
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // From JSON (for import)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income' ? 0 : 1,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}


