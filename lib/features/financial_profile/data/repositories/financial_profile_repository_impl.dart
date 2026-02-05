// lib/features/financial_profile/data/repositories/financial_profile_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/entities/financial_trait.dart';
import '../../domain/entities/profile_validation_result.dart';
import '../../domain/repositories/financial_profile_repository.dart';
import '../datasources/financial_profile_local_datasource.dart';
import '../datasources/gemini_profile_service.dart';
import '../models/profile_model.dart';

class FinancialProfileRepositoryImpl implements FinancialProfileRepository {
  final FinancialProfileLocalDataSource localDataSource;
  final GeminiProfileService geminiService;

  FinancialProfileRepositoryImpl({
    required this.localDataSource,
    required this.geminiService,
  });

  @override
  Future<Either<Failure, List<Question>>> getQuestions() async {
    try {
      final questionsModels = await localDataSource.getQuestions();
      final questions = questionsModels.map((model) => model.toEntity()).toList();

      // Trier par ordre
      questions.sort((a, b) => a.order.compareTo(b.order));

      return Right(questions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialProfile>> calculateProfile(
      List<Answer> answers,
      ) async {
    try {
      final questionsEither = await getQuestions();
      if (questionsEither.isLeft()) {
        return Left(ServerFailure('Impossible de charger les questions'));
      }

      final questions = questionsEither.getOrElse(() => []);

      // 1. Calculer les scores pour chaque trait
      //final traitScores = _calculateTraitScores(answers);
      final traitScores = _calculateTraitScores(
        answers,
        questions,
      );


      // 2. Déterminer le profil dominant
      final profileType = _determineProfileType(traitScores);

      // 3. Calculer le score de confiance
      final confidenceScore = _calculateConfidenceScore(answers, traitScores);

      // 4. Créer le profil
      final profile = FinancialProfile(
        type: profileType,
        traitScores: traitScores,
        confidenceScore: confidenceScore,
        createdAt: DateTime.now(),
      );

      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateAIFeedback({
    required FinancialProfile profile,
    required List<Answer> answers,
  }) async {
    try {
      final feedback = await geminiService.generateProfileFeedback(
        profile: profile,
        answers: answers,
      );
      return Right(feedback);
    } catch (e) {
      return Left(ServerFailure('Erreur génération feedback IA: $e'));
    }
  }

  @override
  Future<Either<Failure, ProfileValidationResult>> validateProfile({
    required FinancialProfile profile,
    required List<Answer> answers,
  }) async {
    try {
      final validationData = await geminiService.validateProfileCoherence(
        profile: profile,
        answers: answers,
      );

      if (validationData['hasConflict'] == true) {
        // En cas de conflit, suggérer un profil alternatif
        final suggestedProfile = _getSuggestedAlternativeProfile(
          profile.type,
          validationData['reason'] as String?,
        );

        return Right(ProfileValidationResult.needsReview(
          detected: profile.type,
          suggested: suggestedProfile,
          reason: validationData['reason'] as String? ?? 'Incohérence détectée',
          confidence: validationData['confidence'] as double,
        ));
      }

      return Right(ProfileValidationResult.confirmed(
        profile.type,
        validationData['confidence'] as double,
      ));
    } catch (e) {
      // En cas d'erreur, on confirme le profil calculé
      return Right(ProfileValidationResult.confirmed(
        profile.type,
        profile.confidenceScore,
      ));
    }
  }

  @override
  Future<Either<Failure, FinancialProfile>> saveProfile(
      FinancialProfile profile,
      ) async {
    try {
      final profileModel = FinancialProfileModel.fromEntity(profile);
      await localDataSource.saveProfile(profileModel);
      return Right(profileModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinancialProfile?>> getSavedProfile() async {
    try {
      final profileModel = await localDataSource.getSavedProfile();
      if (profileModel == null) {
        return const Right(null);
      }
      return Right(profileModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // ===== MÉTHODES PRIVÉES - LOGIQUE MÉTIER =====

  /// Calcule les scores pour chaque trait financier
  /*Map<FinancialTraitType, double> _calculateTraitScores(List<Answer> answers) {
    // Initialiser les scores à 50 (neutre)
    final scores = <FinancialTraitType, double>{
      FinancialTraitType.impulsivity: 50.0,
      FinancialTraitType.discipline: 50.0,
      FinancialTraitType.savingCapacity: 50.0,
      FinancialTraitType.emotionalControl: 50.0,
      FinancialTraitType.organizationLevel: 50.0,
      FinancialTraitType.riskTolerance: 50.0,
    };

    // Récupérer les questions pour accéder aux poids
    final questions = localDataSource.getQuestions();

    for (final answer in answers) {
      if (answer.selectedChoiceId == null) continue;

      // Trouver la question correspondante (synchrone car hardcodé)
      final question = questions.then((q) =>
          q.firstWhere((q) => q.id == answer.questionId)
      );

      question.then((q) {
        final choice = q.choices.firstWhere(
              (c) => c.id == answer.selectedChoiceId,
        );

        // Appliquer les scores avec le poids de la question
        choice.scores.forEach((trait, scoreImpact) {
          scores[trait] = (scores[trait]! + (scoreImpact * q.weight)).clamp(0.0, 100.0);
        });
      });
    }

    return scores;
  }*/

  Map<FinancialTraitType, double> _calculateTraitScores(
      List<Answer> answers,
      List<Question> questions,
      ) {
    final scores = <FinancialTraitType, double>{
      FinancialTraitType.impulsivity: 50.0,
      FinancialTraitType.discipline: 50.0,
      FinancialTraitType.savingCapacity: 50.0,
      FinancialTraitType.emotionalControl: 50.0,
      FinancialTraitType.organizationLevel: 50.0,
      FinancialTraitType.riskTolerance: 50.0,
    };

    for (final answer in answers) {
      if (answer.selectedChoiceId == null) continue;

      final question = questions.firstWhere(
            (q) => q.id == answer.questionId,
        orElse: () => throw Exception('Question introuvable'),
      );

      final choice = question.choices.firstWhere(
            (c) => c.id == answer.selectedChoiceId,
        orElse: () => throw Exception('Choix introuvable'),
      );

      choice.scores.forEach((trait, impact) {
        scores[trait] =
            (scores[trait]! + (impact * question.weight)).clamp(0.0, 100.0);
      });
    }

    return scores;
  }


  /// Détermine le type de profil dominant basé sur les scores
  ProfileType _determineProfileType(Map<FinancialTraitType, double> scores) {
    final impulsivity = scores[FinancialTraitType.impulsivity]!;
    final discipline = scores[FinancialTraitType.discipline]!;
    final savingCapacity = scores[FinancialTraitType.savingCapacity]!;
    final emotionalControl = scores[FinancialTraitType.emotionalControl]!;
    final organization = scores[FinancialTraitType.organizationLevel]!;

    // Logique de détermination du profil (priorités)

    // 1. Dépensier impulsif : impulsivité élevée + faible discipline
    if (impulsivity > 65 && discipline < 45 && savingCapacity < 45) {
      return ProfileType.impulsiveSpender;
    }

    // 2. Désorganisé financier : organisation très faible
    if (organization < 35 && discipline < 40) {
      return ProfileType.financiallyDisorganized;
    }

    // 3. Économe stratégique : épargne élevée + discipline élevée
    if (savingCapacity > 70 && discipline > 65) {
      return ProfileType.strategicSaver;
    }

    // 4. Sur-contrôleur : contrôle émotionnel faible malgré discipline élevée
    if (discipline > 70 && emotionalControl < 40 && organization > 70) {
      return ProfileType.overController;
    }

    // 5. Prudent optimisateur : équilibre avec organisation élevée
    if (organization > 60 && discipline > 55 && savingCapacity > 55) {
      return ProfileType.cautiousOptimizer;
    }

    // 6. Par défaut : Équilibré conscient
    return ProfileType.balancedAware;
  }

  /// Calcule le score de confiance du profil (0-100)
  double _calculateConfidenceScore(
      List<Answer> answers,
      Map<FinancialTraitType, double> scores,
      ) {
    // Facteurs de confiance :
    // 1. Nombre de réponses (20 questions max)
    final answerCompleteness = (answers.length / 20.0) * 40;

    // 2. Présence de réponses libres (bonus de contexte)
    final freeTextBonus = answers.where((a) => a.hasFreeText).length * 3.0;

    // 3. Cohérence des scores (variance faible = profil clair)
    final scoreValues = scores.values.toList();
    final mean = scoreValues.reduce((a, b) => a + b) / scoreValues.length;
    final variance = scoreValues
        .map((s) => (s - mean) * (s - mean))
        .reduce((a, b) => a + b) / scoreValues.length;
    final coherenceScore = (100 - variance).clamp(0.0, 30.0);

    final totalConfidence = (answerCompleteness + freeTextBonus + coherenceScore)
        .clamp(0.0, 100.0);

    return totalConfidence;
  }

  /// Suggère un profil alternatif en cas d'incohérence
  ProfileType _getSuggestedAlternativeProfile(
      ProfileType detected,
      String? conflictReason,
      ) {
    // Logique simple : suggérer un profil adjacent
    switch (detected) {
      case ProfileType.impulsiveSpender:
        return ProfileType.balancedAware;
      case ProfileType.strategicSaver:
        return ProfileType.cautiousOptimizer;
      case ProfileType.overController:
        return ProfileType.strategicSaver;
      case ProfileType.financiallyDisorganized:
        return ProfileType.balancedAware;
      case ProfileType.cautiousOptimizer:
        return ProfileType.balancedAware;
      case ProfileType.balancedAware:
        return ProfileType.cautiousOptimizer;
    }
  }
}