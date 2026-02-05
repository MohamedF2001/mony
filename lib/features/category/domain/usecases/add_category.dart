// lib/features/category/domain/usecases/add_category.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository repository;

  AddCategory(this.repository);

  Future<Either<Failure, Category>> call(Category category) async {
    if (category.name.isEmpty) {
      return Left(ValidationFailure('Le nom de la catégorie est requis'));
    }

    if (category.name.length > 20) {
      return Left(
          ValidationFailure('Le nom ne doit pas dépasser 20 caractères'));
    }

    return await repository.addCategory(category);
  }
}
