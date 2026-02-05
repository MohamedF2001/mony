// lib/features/budget/domain/usecases/delete_budget.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/budget_repository.dart';

class DeleteBudget {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return Left(ValidationFailure('ID de budget invalide'));
    }

    return await repository.deleteBudget(id);
  }
}