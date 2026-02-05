// lib/features/financial_profile/domain/usecases/save_profile.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/financial_profile.dart';
import '../repositories/financial_profile_repository.dart';

class SaveProfile {
  final FinancialProfileRepository repository;

  SaveProfile(this.repository);

  Future<Either<Failure, FinancialProfile>> call(
      FinancialProfile profile,
      ) async {
    return await repository.saveProfile(profile);
  }
}