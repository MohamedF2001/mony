// lib/features/financial_profile/domain/usecases/calculate_profile.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/answer.dart';
import '../entities/financial_profile.dart';
import '../repositories/financial_profile_repository.dart';

class CalculateProfile {
  final FinancialProfileRepository repository;

  CalculateProfile(this.repository);

  Future<Either<Failure, FinancialProfile>> call(List<Answer> answers) async {
    // Validation
    if (answers.isEmpty) {
      return Left(ValidationFailure('Aucune réponse fournie'));
    }

    return await repository.calculateProfile(answers);
  }
}