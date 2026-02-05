// lib/features/budget/domain/repositories/budget_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();
  Future<Either<Failure, List<Budget>>> getActiveBudgets();
  Future<Either<Failure, Budget>> getBudgetByCategory(String category);
  Future<Either<Failure, Budget>> addBudget(Budget budget);
  Future<Either<Failure, Budget>> updateBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(String id);
}