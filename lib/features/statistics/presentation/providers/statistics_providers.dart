/*
// lib/features/statistics/presentation/providers/statistics_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';

enum StatisticsPeriod {
  week,
  month,
  year,
}

class StatisticsState {
  final StatisticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  StatisticsState({
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  StatisticsState copyWith({
    StatisticsPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StatisticsState(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  StatisticsNotifier()
      : super(StatisticsState(
          period: StatisticsPeriod.month,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ));

  void setPeriod(StatisticsPeriod period) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case StatisticsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case StatisticsPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case StatisticsPeriod.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
    }

    state = state.copyWith(
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
    );
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier();
});

// Category Statistics Provider
final categoryStatisticsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  
  final Map<String, double> categoryTotals = {};
  
  for (var transaction in transactions) {
    if (transaction.isExpense) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
  }
  
  // Sort by amount descending
  final sortedEntries = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final sortedMap = Map<String, double>.fromEntries(sortedEntries);
  
  return AsyncValue.data(sortedMap);
});

*/




// lib/features/statistics/presentation/providers/statistics_providers.dart

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';

enum StatisticsPeriod {
  week,
  month,
  year,
}

class StatisticsState {
  final StatisticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  StatisticsState({
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  StatisticsState copyWith({
    StatisticsPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StatisticsState(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  StatisticsNotifier()
      : super(StatisticsState(
    period: StatisticsPeriod.month,
    startDate: _getStartDate(StatisticsPeriod.month),
    endDate: DateTime.now(),
  ));

  static DateTime _getStartDate(StatisticsPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case StatisticsPeriod.week:
      // Derniers 7 jours
        return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

      case StatisticsPeriod.month:
      // Premier jour du mois actuel
        return DateTime(now.year, now.month, 1);

      case StatisticsPeriod.year:
      // Premier jour de l'année actuelle
        return DateTime(now.year, 1, 1);
    }
  }

  void setPeriod(StatisticsPeriod period) {
    final now = DateTime.now();
    final startDate = _getStartDate(period);

    state = state.copyWith(
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
    );
  }
}

final statisticsProvider =
StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier();
});

// Provider pour filtrer les transactions selon la période sélectionnée
final periodFilteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final allTransactions = ref.watch(transactionsProvider).when(
    data: (transactions) => transactions,
    loading: () => <Transaction>[],
    error: (_, __) => <Transaction>[],
  );

  final statisticsState = ref.watch(statisticsProvider);

  // Filtrer les transactions dans la période sélectionnée
  return allTransactions.where((transaction) {
    final transactionDate = transaction.date;
    return transactionDate.isAfter(statisticsState.startDate.subtract(const Duration(days: 1))) &&
        transactionDate.isBefore(statisticsState.endDate.add(const Duration(days: 1)));
  }).toList();
});

// Category Statistics Provider - utilise les transactions filtrées par période
final categoryStatisticsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);

  if (transactions.isEmpty) {
    return const AsyncValue.data({});
  }

  final Map<String, double> categoryTotals = {};

  for (var transaction in transactions) {
    if (transaction.isExpense) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
  }

  // Sort by amount descending
  final sortedEntries = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final sortedMap = Map<String, double>.fromEntries(sortedEntries);

  return AsyncValue.data(sortedMap);
});

// Trend Data Provider - Données pour le graphique de tendances
class TrendDataPoint {
  final DateTime date;
  final double income;
  final double expense;
  final double balance;

  TrendDataPoint({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });
}

final trendDataProvider = Provider<AsyncValue<List<TrendDataPoint>>>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  final statisticsState = ref.watch(statisticsProvider);

  if (transactions.isEmpty) {
    return const AsyncValue.data([]);
  }

  // Grouper les transactions par période
  final Map<String, TrendDataPoint> dataPoints = {};

  switch (statisticsState.period) {
    case StatisticsPeriod.week:
    // Grouper par jour
      for (var transaction in transactions) {
        final dateKey = _formatDateKey(transaction.date, isDaily: true);

        if (!dataPoints.containsKey(dateKey)) {
          dataPoints[dateKey] = TrendDataPoint(
            date: DateTime(transaction.date.year, transaction.date.month, transaction.date.day),
            income: 0,
            expense: 0,
            balance: 0,
          );
        }

        final current = dataPoints[dateKey]!;
        if (transaction.isExpense) {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income,
            expense: current.expense + transaction.amount,
            balance: current.balance - transaction.amount,
          );
        } else {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income + transaction.amount,
            expense: current.expense,
            balance: current.balance + transaction.amount,
          );
        }
      }
      break;

    case StatisticsPeriod.month:
    // Grouper par semaine
      for (var transaction in transactions) {
        final weekNumber = _getWeekNumber(transaction.date);
        final dateKey = 'Week$weekNumber';

        if (!dataPoints.containsKey(dateKey)) {
          dataPoints[dateKey] = TrendDataPoint(
            date: _getStartOfWeek(transaction.date),
            income: 0,
            expense: 0,
            balance: 0,
          );
        }

        final current = dataPoints[dateKey]!;
        if (transaction.isExpense) {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income,
            expense: current.expense + transaction.amount,
            balance: current.balance - transaction.amount,
          );
        } else {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income + transaction.amount,
            expense: current.expense,
            balance: current.balance + transaction.amount,
          );
        }
      }
      break;

    case StatisticsPeriod.year:
    // Grouper par mois
      for (var transaction in transactions) {
        final dateKey = _formatDateKey(transaction.date, isMonthly: true);

        if (!dataPoints.containsKey(dateKey)) {
          dataPoints[dateKey] = TrendDataPoint(
            date: DateTime(transaction.date.year, transaction.date.month, 1),
            income: 0,
            expense: 0,
            balance: 0,
          );
        }

        final current = dataPoints[dateKey]!;
        if (transaction.isExpense) {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income,
            expense: current.expense + transaction.amount,
            balance: current.balance - transaction.amount,
          );
        } else {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income + transaction.amount,
            expense: current.expense,
            balance: current.balance + transaction.amount,
          );
        }
      }
      break;
  }

  // Trier par date
  final sortedData = dataPoints.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return AsyncValue.data(sortedData);
});

// Helpers
String _formatDateKey(DateTime date, {bool isDaily = false, bool isMonthly = false}) {
  if (isDaily) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  } else if (isMonthly) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
  return date.toIso8601String();
}

int _getWeekNumber(DateTime date) {
  final startOfMonth = DateTime(date.year, date.month, 1);
  final daysDifference = date.difference(startOfMonth).inDays;
  return (daysDifference / 7).floor() + 1;
}

DateTime _getStartOfWeek(DateTime date) {
  final daysToSubtract = date.weekday - 1; // Lundi = 1
  return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
}

// Providers pour les totaux filtrés par période
final periodTotalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  return transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final periodTotalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  return transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final periodBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(periodTotalIncomeProvider);
  final expense = ref.watch(periodTotalExpenseProvider);
  return income - expense;
});

// Provider pour les insights intelligents
class InsightData {
  final String message;
  final IconData icon;
  final Color color;

  InsightData({
    required this.message,
    required this.icon,
    required this.color,
  });
}

final insightsProvider = Provider<List<InsightData>>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  final categoryStats = ref.watch(categoryStatisticsProvider).value ?? {};
  final income = ref.watch(periodTotalIncomeProvider);
  final expense = ref.watch(periodTotalExpenseProvider);
  final period = ref.watch(statisticsProvider).period;

  final insights = <InsightData>[];

  if (transactions.isEmpty) {
    return insights;
  }

  // Insight 1: Taux d'épargne
  if (income > 0) {
    final savingsRate = ((income - expense) / income * 100);
    if (savingsRate > 0) {
      insights.add(InsightData(
        message: 'Vous avez économisé ${savingsRate.toStringAsFixed(1)}% de vos revenus',
        icon: Icons.savings,
        color: AppColors.success,
      ));
    } else {
      insights.add(InsightData(
        message: 'Attention: vos dépenses dépassent vos revenus',
        icon: Icons.warning,
        color: AppColors.error,
      ));
    }
  }

  // Insight 2: Plus grosse catégorie de dépense
  if (categoryStats.isNotEmpty) {
    final topCategory = categoryStats.entries.first;
    final percentage = (topCategory.value / expense * 100);
    insights.add(InsightData(
      message: '${topCategory.key} représente ${percentage.toStringAsFixed(0)}% de vos dépenses',
      icon: Icons.pie_chart,
      color: AppColors.primary,
    ));
  }

  // Insight 3: Moyenne de dépenses
  final periodDays = period == StatisticsPeriod.week ? 7
      : period == StatisticsPeriod.month ? 30
      : 365;
  final dailyAverage = expense / periodDays;

  insights.add(InsightData(
    message: 'Dépense moyenne: ${dailyAverage.toStringAsFixed(0)} F CFA/jour',
    icon: Icons.trending_up,
    color: AppColors.error,
  ));

  return insights;
});
*/



// lib/features/statistics/presentation/providers/statistics_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';

enum StatisticsPeriod {
  week,
  month,
  year,
}

class StatisticsState {
  final StatisticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  StatisticsState({
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  StatisticsState copyWith({
    StatisticsPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return StatisticsState(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  StatisticsNotifier()
      : super(StatisticsState(
    period: StatisticsPeriod.month,
    startDate: _getStartDate(StatisticsPeriod.month),
    endDate: DateTime.now(),
  ));

  static DateTime _getStartDate(StatisticsPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case StatisticsPeriod.week:
      // Derniers 7 jours
        return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

      case StatisticsPeriod.month:
      // Premier jour du mois actuel
        return DateTime(now.year, now.month, 1);

      case StatisticsPeriod.year:
      // Premier jour de l'année actuelle
        return DateTime(now.year, 1, 1);
    }
  }

  void setPeriod(StatisticsPeriod period) {
    final now = DateTime.now();
    final startDate = _getStartDate(period);

    state = state.copyWith(
      period: period,
      startDate: startDate,
      endDate: now,
    );
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
    );
  }
}

final statisticsProvider =
StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier();
});

// Provider pour filtrer les transactions selon la période sélectionnée
final periodFilteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactionState = ref.watch(transactionProvider);
  final allTransactions = transactionState.transactions;

  final statisticsState = ref.watch(statisticsProvider);

  // Filtrer les transactions dans la période sélectionnée
  return allTransactions.where((transaction) {
    final transactionDate = transaction.date;
    return transactionDate.isAfter(statisticsState.startDate.subtract(const Duration(days: 1))) &&
        transactionDate.isBefore(statisticsState.endDate.add(const Duration(days: 1)));
  }).toList();
});

// Category Statistics Provider - utilise les transactions filtrées par période
final categoryStatisticsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);

  if (transactions.isEmpty) {
    return const AsyncValue.data({});
  }

  final Map<String, double> categoryTotals = {};

  for (var transaction in transactions) {
    if (transaction.isExpense) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
  }

  // Sort by amount descending
  final sortedEntries = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final sortedMap = Map<String, double>.fromEntries(sortedEntries);

  return AsyncValue.data(sortedMap);
});

// Trend Data Provider - Données pour le graphique de tendances
class TrendDataPoint {
  final DateTime date;
  final double income;
  final double expense;
  final double balance;

  TrendDataPoint({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });
}

final trendDataProvider = Provider<AsyncValue<List<TrendDataPoint>>>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  final statisticsState = ref.watch(statisticsProvider);

  if (transactions.isEmpty) {
    return const AsyncValue.data([]);
  }

  // Grouper les transactions par période
  final Map<String, TrendDataPoint> dataPoints = {};

  switch (statisticsState.period) {
    case StatisticsPeriod.week:
    // Grouper par jour
      for (var transaction in transactions) {
        final dateKey = _formatDateKey(transaction.date, isDaily: true);

        if (!dataPoints.containsKey(dateKey)) {
          dataPoints[dateKey] = TrendDataPoint(
            date: DateTime(transaction.date.year, transaction.date.month, transaction.date.day),
            income: 0,
            expense: 0,
            balance: 0,
          );
        }

        final current = dataPoints[dateKey]!;
        if (transaction.isExpense) {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income,
            expense: current.expense + transaction.amount,
            balance: current.balance - transaction.amount,
          );
        } else {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income + transaction.amount,
            expense: current.expense,
            balance: current.balance + transaction.amount,
          );
        }
      }
      break;

    case StatisticsPeriod.month:
    // Grouper par semaine
      for (var transaction in transactions) {
        final weekNumber = _getWeekNumber(transaction.date);
        final dateKey = 'Week$weekNumber';

        if (!dataPoints.containsKey(dateKey)) {
          dataPoints[dateKey] = TrendDataPoint(
            date: _getStartOfWeek(transaction.date),
            income: 0,
            expense: 0,
            balance: 0,
          );
        }

        final current = dataPoints[dateKey]!;
        if (transaction.isExpense) {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income,
            expense: current.expense + transaction.amount,
            balance: current.balance - transaction.amount,
          );
        } else {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income + transaction.amount,
            expense: current.expense,
            balance: current.balance + transaction.amount,
          );
        }
      }
      break;

    case StatisticsPeriod.year:
    // Grouper par mois
      for (var transaction in transactions) {
        final dateKey = _formatDateKey(transaction.date, isMonthly: true);

        if (!dataPoints.containsKey(dateKey)) {
          dataPoints[dateKey] = TrendDataPoint(
            date: DateTime(transaction.date.year, transaction.date.month, 1),
            income: 0,
            expense: 0,
            balance: 0,
          );
        }

        final current = dataPoints[dateKey]!;
        if (transaction.isExpense) {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income,
            expense: current.expense + transaction.amount,
            balance: current.balance - transaction.amount,
          );
        } else {
          dataPoints[dateKey] = TrendDataPoint(
            date: current.date,
            income: current.income + transaction.amount,
            expense: current.expense,
            balance: current.balance + transaction.amount,
          );
        }
      }
      break;
  }

  // Trier par date
  final sortedData = dataPoints.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return AsyncValue.data(sortedData);
});

// Helpers
String _formatDateKey(DateTime date, {bool isDaily = false, bool isMonthly = false}) {
  if (isDaily) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  } else if (isMonthly) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
  return date.toIso8601String();
}

int _getWeekNumber(DateTime date) {
  final startOfMonth = DateTime(date.year, date.month, 1);
  final daysDifference = date.difference(startOfMonth).inDays;
  return (daysDifference / 7).floor() + 1;
}

DateTime _getStartOfWeek(DateTime date) {
  final daysToSubtract = date.weekday - 1; // Lundi = 1
  return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
}

// Providers pour les totaux filtrés par période
final periodTotalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  return transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final periodTotalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  return transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final periodBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(periodTotalIncomeProvider);
  final expense = ref.watch(periodTotalExpenseProvider);
  return income - expense;
});

// Provider pour les insights intelligents
class InsightData {
  final String message;
  final IconData icon;
  final Color color;

  InsightData({
    required this.message,
    required this.icon,
    required this.color,
  });
}

final insightsProvider = Provider<List<InsightData>>((ref) {
  final transactions = ref.watch(periodFilteredTransactionsProvider);
  final categoryStats = ref.watch(categoryStatisticsProvider).value ?? {};
  final income = ref.watch(periodTotalIncomeProvider);
  final expense = ref.watch(periodTotalExpenseProvider);
  final period = ref.watch(statisticsProvider).period;

  final insights = <InsightData>[];

  if (transactions.isEmpty) {
    return insights;
  }

  // Insight 1: Taux d'épargne
  if (income > 0) {
    final savingsRate = ((income - expense) / income * 100);
    if (savingsRate > 0) {
      insights.add(InsightData(
        message: 'Vous avez économisé ${savingsRate.toStringAsFixed(1)}% de vos revenus',
        icon: Icons.savings,
        color: AppColors.success,
      ));
    } else {
      insights.add(InsightData(
        message: 'Attention: vos dépenses dépassent vos revenus',
        icon: Icons.warning,
        color: AppColors.error,
      ));
    }
  }

  // Insight 2: Plus grosse catégorie de dépense
  if (categoryStats.isNotEmpty) {
    final topCategory = categoryStats.entries.first;
    final percentage = (topCategory.value / expense * 100);
    insights.add(InsightData(
      message: '${topCategory.key} représente ${percentage.toStringAsFixed(0)}% de vos dépenses',
      icon: Icons.pie_chart,
      color: AppColors.primary,
    ));
  }

  // Insight 3: Moyenne de dépenses
  final periodDays = period == StatisticsPeriod.week ? 7
      : period == StatisticsPeriod.month ? 30
      : 365;
  final dailyAverage = expense / periodDays;

  insights.add(InsightData(
    message: 'Dépense moyenne: ${dailyAverage.toStringAsFixed(0)} F CFA/jour',
    icon: Icons.trending_up,
    color: AppColors.error,
  ));

  return insights;
});



