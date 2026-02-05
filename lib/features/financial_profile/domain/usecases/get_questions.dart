// lib/features/financial_profile/domain/usecases/get_questions.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/question.dart';
import '../repositories/financial_profile_repository.dart';

class GetQuestions {
  final FinancialProfileRepository repository;

  GetQuestions(this.repository);

  Future<Either<Failure, List<Question>>> call() async {
    return await repository.getQuestions();
  }
}