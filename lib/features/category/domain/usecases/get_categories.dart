// lib/features/category/domain/usecases/get_categories.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<Category>>> call() async {
    return await repository.getCategories();
  }
}

class GetCategoriesByType {
  final CategoryRepository repository;

  GetCategoriesByType(this.repository);

  Future<Either<Failure, List<Category>>> call(TransactionType type) async {
    return await repository.getCategoriesByType(type);
  }
}
