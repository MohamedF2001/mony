// lib/features/budget/presentation/providers/budget_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../data/datasources/budget_local_datasource.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/add_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/update_budget.dart';

// Data Source Provider
final budgetBoxProvider = Provider<Box<BudgetModel>>((ref) {
  return Hive.box<BudgetModel>('budgets');
});

final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  final box = ref.watch(budgetBoxProvider);
  return BudgetLocalDataSourceImpl(box);
});

// Repository Provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dataSource = ref.watch(budgetLocalDataSourceProvider);
  return BudgetRepositoryImpl(dataSource);
});

// Use Cases Providers
final getBudgetsUseCaseProvider = Provider<GetBudgets>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return GetBudgets(repository);
});

final addBudgetUseCaseProvider = Provider<AddBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return AddBudget(repository);
});

final updateBudgetUseCaseProvider = Provider<UpdateBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return UpdateBudget(repository);
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudget>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return DeleteBudget(repository);
});

// State Management
class BudgetState {
  final List<Budget> budgets;
  final bool isLoading;
  final String? errorMessage;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BudgetState copyWith({
    List<Budget>? budgets,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Budget Notifier
class BudgetNotifier extends StateNotifier<BudgetState> {
  final GetBudgets getBudgetsUseCase;
  final AddBudget addBudgetUseCase;
  final UpdateBudget updateBudgetUseCase;
  final DeleteBudget deleteBudgetUseCase;

  BudgetNotifier({
    required this.getBudgetsUseCase,
    required this.addBudgetUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
  }) : super(const BudgetState()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getBudgetsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (budgets) {
        state = state.copyWith(
          budgets: budgets,
          isLoading: false,
        );
      },
    );
  }

  Future<bool> addBudget(Budget budget) async {
    final result = await addBudgetUseCase(budget);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (addedBudget) {
        final updatedList = [...state.budgets, addedBudget];
        state = state.copyWith(budgets: updatedList);
        return true;
      },
    );
  }

  Future<bool> updateBudget(Budget budget) async {
    final result = await updateBudgetUseCase(budget);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedBudget) {
        final updatedList = state.budgets.map((b) {
          return b.id == updatedBudget.id ? updatedBudget : b;
        }).toList();
        state = state.copyWith(budgets: updatedList);
        return true;
      },
    );
  }

  Future<bool> deleteBudget(String id) async {
    final result = await deleteBudgetUseCase(id);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList = state.budgets.where((b) => b.id != id).toList();
        state = state.copyWith(budgets: updatedList);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Budget Provider
final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier(
    getBudgetsUseCase: ref.watch(getBudgetsUseCaseProvider),
    addBudgetUseCase: ref.watch(addBudgetUseCaseProvider),
    updateBudgetUseCase: ref.watch(updateBudgetUseCaseProvider),
    deleteBudgetUseCase: ref.watch(deleteBudgetUseCaseProvider),
  );
});

// Computed Providers
final activeBudgetsProvider = Provider<List<Budget>>((ref) {
  final state = ref.watch(budgetProvider);
  return state.budgets.where((b) => b.isActive).toList();
});

// Budget with spending info
final budgetWithSpendingProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final budgets = ref.watch(activeBudgetsProvider);
  final transactions = ref.watch(filteredTransactionsProvider);

  return budgets.map((budget) {
    final spent = budget.getSpentAmount(transactions);
    final remaining = budget.getRemainingAmount(transactions);
    final percentage = budget.getPercentageUsed(transactions);
    final isOverBudget = budget.isOverBudget(transactions);

    return {
      'budget': budget,
      'spent': spent,
      'remaining': remaining,
      'percentage': percentage,
      'isOverBudget': isOverBudget,
    };
  }).toList();
});

