// lib/features/transaction/presentation/providers/transaction_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mony/features/transaction/data/datasources/transaction_local_datasources.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';

// Data Source Provider
final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('transactions');
});

final transactionLocalDataSourceProvider =
    Provider<TransactionLocalDataSource>((ref) {
  final box = ref.watch(transactionBoxProvider);
  return TransactionLocalDataSourceImpl(box);
});

// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dataSource = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(dataSource);
});

// Use Cases Providers
final getTransactionsUseCaseProvider = Provider<GetTransactions>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactions(repository);
});

final addTransactionUseCaseProvider = Provider<AddTransaction>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return AddTransaction(repository);
});

final updateTransactionUseCaseProvider = Provider<UpdateTransaction>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return UpdateTransaction(repository);
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return DeleteTransaction(repository);
});

// State Management
class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final TransactionType? filterType;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterStartDate,
    this.filterEndDate,
    this.filterType,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? errorMessage,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    TransactionType? filterType,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      filterStartDate:
          clearFilters ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearFilters ? null : (filterEndDate ?? this.filterEndDate),
      filterType: clearFilters ? null : (filterType ?? this.filterType),
    );
  }

  List<Transaction> get filteredTransactions {
    var filtered = transactions;

    // Filter by date range
    if (filterStartDate != null && filterEndDate != null) {
      filtered = filtered.where((t) {
        return (t.date.isAfter(filterStartDate!) ||
                t.date.isAtSameMomentAs(filterStartDate!)) &&
            t.date.isBefore(filterEndDate!);
      }).toList();
    }

    // Filter by type
    if (filterType != null) {
      filtered = filtered.where((t) => t.type == filterType).toList();
    }

    return filtered;
  }

  double get totalIncome {
    return filteredTransactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;
}

// Transaction Notifier
class TransactionNotifier extends StateNotifier<TransactionState> {
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateTransaction updateTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;

  TransactionNotifier({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(const TransactionState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getTransactionsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (transactions) {
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
        );
      },
    );
  }

  Future<bool> addTransaction(Transaction transaction) async {
    final result = await addTransactionUseCase(transaction);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (addedTransaction) {
        final updatedList = [...state.transactions, addedTransaction];
        updatedList.sort((a, b) => b.date.compareTo(a.date));
        state = state.copyWith(transactions: updatedList);
        return true;
      },
    );
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    final result = await updateTransactionUseCase(transaction);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedTransaction) {
        final updatedList = state.transactions.map((t) {
          return t.id == updatedTransaction.id ? updatedTransaction : t;
        }).toList();
        updatedList.sort((a, b) => b.date.compareTo(a.date));
        state = state.copyWith(transactions: updatedList);
        return true;
      },
    );
  }

  Future<bool> deleteTransaction(String id) async {
    final result = await deleteTransactionUseCase(id);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList =
            state.transactions.where((t) => t.id != id).toList();
        state = state.copyWith(transactions: updatedList);
        return true;
      },
    );
  }

  void setDateFilter(DateTime startDate, DateTime endDate) {
    state = state.copyWith(
      filterStartDate: startDate,
      filterEndDate: endDate,
    );
  }

  void setTypeFilter(TransactionType? type) {
    state = state.copyWith(filterType: type);
  }

  void clearFilters() {
    state = state.copyWith(clearFilters: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Transaction Provider
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(
    getTransactionsUseCase: ref.watch(getTransactionsUseCaseProvider),
    addTransactionUseCase: ref.watch(addTransactionUseCaseProvider),
    updateTransactionUseCase: ref.watch(updateTransactionUseCaseProvider),
    deleteTransactionUseCase: ref.watch(deleteTransactionUseCaseProvider),
  );
});

// Computed Providers
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final state = ref.watch(transactionProvider);
  return state.filteredTransactions;
});

final totalIncomeProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  return state.totalIncome;
});

final totalExpenseProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  return state.totalExpense;
});

final balanceProvider = Provider<double>((ref) {
  final state = ref.watch(transactionProvider);
  return state.balance;
});

// Recent Transactions Provider (last 5)
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.take(5).toList();
});
