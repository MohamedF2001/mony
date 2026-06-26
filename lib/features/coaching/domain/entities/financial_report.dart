import 'package:equatable/equatable.dart';

enum ReportPeriod { weekly, monthly }

class FinancialReport extends Equatable {
  final String id;
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final String content;
  final ReportSummary summary;
  final int score;
  final List<AIAlert> alerts;
  final DateTime createdAt;

  const FinancialReport({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.content,
    required this.summary,
    required this.score,
    this.alerts = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, period, startDate, endDate, content, summary, score, alerts, createdAt];
}

class ReportSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double savingsRate;
  final List<CategorySummary> topCategories;

  const ReportSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.savingsRate,
    required this.topCategories,
  });

  @override
  List<Object?> get props => [totalIncome, totalExpense, savingsRate, topCategories];
}

class CategorySummary extends Equatable {
  final String name;
  final double amount;

  const CategorySummary({required this.name, required this.amount});

  @override
  List<Object?> get props => [name, amount];
}

class AIAlert extends Equatable {
  final String type;
  final String message;
  final String severity; // low, medium, high

  const AIAlert({required this.type, required this.message, required this.severity});

  @override
  List<Object?> get props => [type, message, severity];
}
