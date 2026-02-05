// lib/features/category/domain/usecases/delete_category.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return Left(ValidationFailure('ID de catégorie invalide'));
    }

    return await repository.deleteCategory(id);
  }
}
