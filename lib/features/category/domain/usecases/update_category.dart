// lib/features/category/domain/usecases/update_category.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  Future<Either<Failure, Category>> call(Category category) async {
    if (category.id == null || category.id!.isEmpty) {
      return Left(ValidationFailure('ID de catégorie invalide'));
    }

    if (category.name.isEmpty) {
      return Left(ValidationFailure('Le nom de la catégorie est requis'));
    }

    return await repository.updateCategory(category);
  }
}
