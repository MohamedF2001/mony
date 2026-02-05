// lib/features/budget/domain/usecases/update_budget.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  Future<Either<Failure, Budget>> call(Budget budget) async {
    if (budget.id == null || budget.id!.isEmpty) {
      return Left(ValidationFailure('ID de budget invalide'));
    }

    if (budget.amount <= 0) {
      return Left(ValidationFailure('Le montant doit être supérieur à 0'));
    }

    return await repository.updateBudget(budget);
  }
}