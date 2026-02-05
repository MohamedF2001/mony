// lib/features/financial_profile/domain/repositories/financial_profile_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/question.dart';
import '../entities/answer.dart';
import '../entities/financial_profile.dart';
import '../entities/profile_validation_result.dart';

abstract class FinancialProfileRepository {
  /// Récupère toutes les questions du questionnaire
  Future<Either<Failure, List<Question>>> getQuestions();

  /// Calcule le profil financier à partir des réponses
  Future<Either<Failure, FinancialProfile>> calculateProfile(
      List<Answer> answers,
      );

  /// Génère un feedback IA personnalisé
  Future<Either<Failure, String>> generateAIFeedback({
    required FinancialProfile profile,
    required List<Answer> answers,
  });

  /// Valide la cohérence du profil avec l'IA
  Future<Either<Failure, ProfileValidationResult>> validateProfile({
    required FinancialProfile profile,
    required List<Answer> answers,
  });

  /// Sauvegarde le profil finalisé
  Future<Either<Failure, FinancialProfile>> saveProfile(
      FinancialProfile profile,
      );

  /// Récupère le profil sauvegardé de l'utilisateur
  Future<Either<Failure, FinancialProfile?>> getSavedProfile();
}