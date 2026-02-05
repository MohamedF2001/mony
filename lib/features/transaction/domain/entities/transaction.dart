// lib/features/transaction/domain/entities/transaction.dart

import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction extends Equatable {
  final String? id;
  final DateTime date;
  final String category;
  final double amount;
  final TransactionType type;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Transaction({
    this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Transaction copyWith({
    String? id,
    DateTime? date,
    String? category,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        category,
        amount,
        type,
        description,
        createdAt,
        updatedAt,
      ];
}
