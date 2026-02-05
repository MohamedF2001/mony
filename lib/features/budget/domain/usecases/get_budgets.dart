// lib/features/budget/domain/usecases/get_budgets.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  Future<Either<Failure, List<Budget>>> call() async {
    return await repository.getBudgets();
  }
}

class GetActiveBudgets {
  final BudgetRepository repository;

  GetActiveBudgets(this.repository);

  Future<Either<Failure, List<Budget>>> call() async {
    return await repository.getActiveBudgets();
  }
}