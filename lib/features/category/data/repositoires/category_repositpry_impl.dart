// lib/features/category/data/repositories/category_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:mony/features/category/data/datasources/category_local_datasources.dart';
import '../../../../core/error/failures.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final models = await localDataSource.getCategories();
      final categories = models.map((model) => model.toEntity()).toList();
      return Right(categories);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategoriesByType(
    TransactionType type,
  ) async {
    try {
      final models = await localDataSource.getCategories();
      final filtered =
          models.where((model) => model.type == type.index).toList();
      final categories = filtered.map((model) => model.toEntity()).toList();
      return Right(categories);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final addedModel = await localDataSource.addCategory(model);
      return Right(addedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final updatedModel = await localDataSource.updateCategory(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories() async {
    try {
      await localDataSource.initializeDefaultCategories();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
