// lib/features/budget/domain/usecases/add_budget.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../repositories/budget_repository.dart';

class AddBudget {
  final BudgetRepository repository;

  AddBudget(this.repository);

  Future<Either<Failure, Budget>> call(Budget budget) async {
    if (budget.amount <= 0) {
      return Left(ValidationFailure('Le montant doit être supérieur à 0'));
    }

    if (budget.category.isEmpty) {
      return Left(ValidationFailure('La catégorie est requise'));
    }

    return await repository.addBudget(budget);
  }
}





