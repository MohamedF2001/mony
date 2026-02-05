// lib/features/financial_profile/domain/usecases/generate_ai_feedback.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/answer.dart';
import '../entities/financial_profile.dart';
import '../repositories/financial_profile_repository.dart';

class GenerateAIFeedback {
  final FinancialProfileRepository repository;

  GenerateAIFeedback(this.repository);

  Future<Either<Failure, String>> call({
    required FinancialProfile profile,
    required List<Answer> answers,
  }) async {
    return await repository.generateAIFeedback(
      profile: profile,
      answers: answers,
    );
  }
}