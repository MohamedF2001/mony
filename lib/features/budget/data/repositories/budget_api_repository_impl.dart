import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_datasource.dart';
import '../models/budget_model.dart';

class BudgetApiRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetApiRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      final models = await remoteDataSource.getBudgets();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Budget>>> getActiveBudgets() async {
    final result = await getBudgets();
    return result.map((budgets) => budgets.where((budget) => budget.isActive).toList());
  }

  @override
  Future<Either<Failure, Budget>> getBudgetByCategory(String category) async {
    final result = await getBudgets();
    return result.fold(
      (failure) => Left(failure),
      (budgets) {
        try {
          return Right(budgets.firstWhere(
            (budget) => budget.category.toLowerCase() == category.toLowerCase(),
          ));
        } catch (_) {
          return Left(ServerFailure('Budget introuvable pour cette categorie'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, Budget>> addBudget(Budget budget) async {
    try {
      final model = await remoteDataSource.addBudget(BudgetModel.fromEntity(budget));
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      final model =
          await remoteDataSource.updateBudget(BudgetModel.fromEntity(budget));
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await remoteDataSource.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
