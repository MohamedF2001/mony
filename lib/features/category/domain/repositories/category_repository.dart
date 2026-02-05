// lib/features/category/domain/repositories/category_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Category>>> getCategoriesByType(
      TransactionType type);
  Future<Either<Failure, Category>> addCategory(Category category);
  Future<Either<Failure, Category>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, void>> initializeDefaultCategories();
}
