// lib/features/budget/data/repositories/budget_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      final models = await localDataSource.getBudgets();
      final budgets = models.map((model) => model.toEntity()).toList();
      return Right(budgets);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Budget>>> getActiveBudgets() async {
    try {
      final models = await localDataSource.getBudgets();
      final activeBudgets = models
          .where((model) => model.isActive)
          .map((model) => model.toEntity())
          .toList();
      return Right(activeBudgets);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> getBudgetByCategory(String category) async {
    try {
      final models = await localDataSource.getBudgets();
      final model = models.firstWhere(
        (model) => model.category == category && model.isActive,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Budget non trouvé pour cette catégorie'));
    }
  }

  @override
  Future<Either<Failure, Budget>> addBudget(Budget budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final addedModel = await localDataSource.addBudget(model);
      return Right(addedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final updatedModel = await localDataSource.updateBudget(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await localDataSource.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}