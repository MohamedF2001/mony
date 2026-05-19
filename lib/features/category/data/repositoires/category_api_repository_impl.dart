import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryApiRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryApiRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final models = await remoteDataSource.getCategories();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategoriesByType(
    TransactionType type,
  ) async {
    final result = await getCategories();
    return result.map(
      (categories) => categories.where((category) => category.type == type).toList(),
    );
  }

  @override
  Future<Either<Failure, Category>> addCategory(Category category) async {
    try {
      final model = await remoteDataSource.addCategory(
        CategoryModel.fromEntity(category),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      final model = await remoteDataSource.updateCategory(
        CategoryModel.fromEntity(category),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories() async {
    return const Right(null);
  }
}
