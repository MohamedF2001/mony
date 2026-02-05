// lib/features/financial_profile/presentation/providers/financial_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/usecases/generative_ai_feedback.dart';
import '../../domain/usecases/get_questions.dart';
import '../../domain/usecases/calculate_profile.dart';
import '../../domain/usecases/save_profile.dart';
import '../../data/datasources/financial_profile_local_datasource.dart';
import '../../data/datasources/gemini_profile_service.dart';
import '../../data/repositories/financial_profile_repository_impl.dart';

// ===== PROVIDERS DE DÉPENDANCES =====

final localDataSourceProvider = Provider((ref) {
  return FinancialProfileLocalDataSource();
});

final geminiServiceProvider = Provider((ref) {
  return GeminiProfileService();
});

final financialProfileRepositoryProvider = Provider((ref) {
  return FinancialProfileRepositoryImpl(
    localDataSource: ref.read(localDataSourceProvider),
    geminiService: ref.read(geminiServiceProvider),
  );
});

// ===== USE CASES PROVIDERS =====

final getQuestionsUseCaseProvider = Provider((ref) {
  return GetQuestions(ref.read(financialProfileRepositoryProvider));
});

final calculateProfileUseCaseProvider = Provider((ref) {
  return CalculateProfile(ref.read(financialProfileRepositoryProvider));
});

final generateAIFeedbackUseCaseProvider = Provider((ref) {
  return GenerateAIFeedback(ref.read(financialProfileRepositoryProvider));
});

final saveProfileUseCaseProvider = Provider((ref) {
  return SaveProfile(ref.read(financialProfileRepositoryProvider));
});

// ===== STATE CLASSES =====

/// État du questionnaire
class QuestionnaireState {
  final List<Question> questions;
  final Map<String, Answer> answers;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;
  final FinancialProfile? calculatedProfile;
  final String? aiFeedback;
  final bool isGeneratingFeedback;

  QuestionnaireState({
    this.questions = const [],
    this.answers = const {},
    this.currentQuestionIndex = 0,
    this.isLoading = false,
    this.error,
    this.calculatedProfile,
    this.aiFeedback,
    this.isGeneratingFeedback = false,
  });

  QuestionnaireState copyWith({
    List<Question>? questions,
    Map<String, Answer>? answers,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
    FinancialProfile? calculatedProfile,
    String? aiFeedback,
    bool? isGeneratingFeedback,
  }) {
    return QuestionnaireState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      calculatedProfile: calculatedProfile ?? this.calculatedProfile,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      isGeneratingFeedback: isGeneratingFeedback ?? this.isGeneratingFeedback,
    );
  }

  Question? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  bool get isComplete => currentQuestionIndex >= questions.length;

  double get progress {
    if (questions.isEmpty) return 0.0;
    return currentQuestionIndex / questions.length;
  }

  int get totalQuestions => questions.length;
  int get answeredCount => answers.length;
}

// ===== NOTIFIER =====

class QuestionnaireNotifier extends StateNotifier<QuestionnaireState> {
  final GetQuestions getQuestions;
  final CalculateProfile calculateProfile;
  final GenerateAIFeedback generateAIFeedback;
  final SaveProfile saveProfile;

  QuestionnaireNotifier({
    required this.getQuestions,
    required this.calculateProfile,
    required this.generateAIFeedback,
    required this.saveProfile,
  }) : super(QuestionnaireState());

  /// Charge les questions au démarrage
  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getQuestions();

    result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: 'Impossible de charger les questions',
        );
      },
          (questions) {
        state = state.copyWith(
          questions: questions,
          isLoading: false,
          currentQuestionIndex: 0,
        );
      },
    );
  }

  /// Soumet une réponse pour la question actuelle
  void submitAnswer({
    required String? selectedChoiceId,
    String? freeText,
  }) {
    final currentQ = state.currentQuestion;
    if (currentQ == null) return;

    // Validation
    if (currentQ.isRequired && selectedChoiceId == null) {
      state = state.copyWith(error: 'Veuillez sélectionner une réponse');
      return;
    }

    final answer = Answer(
      questionId: currentQ.id,
      selectedChoiceId: selectedChoiceId,
      freeText: freeText?.trim(),
      answeredAt: DateTime.now(),
    );

    final updatedAnswers = Map<String, Answer>.from(state.answers);
    updatedAnswers[currentQ.id] = answer;

    state = state.copyWith(
      answers: updatedAnswers,
      error: null,
    );
  }

  /// Passe à la question suivante
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// Revient à la question précédente
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// Finalise le questionnaire et calcule le profil
  Future<void> finalizeQuestionnaire() async {
    if (state.answers.isEmpty) {
      state = state.copyWith(error: 'Aucune réponse à analyser');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    // 1. Calculer le profil
    final profileResult = await calculateProfile(state.answers.values.toList());

    await profileResult.fold(
          (failure) async {
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur lors du calcul du profil',
        );
      },
          (profile) async {
        state = state.copyWith(
          calculatedProfile: profile,
          isLoading: false,
        );

        // 2. Générer le feedback IA (en parallèle)
        await _generateFeedback(profile);
      },
    );
  }

  /// Génère le feedback IA
  Future<void> _generateFeedback(FinancialProfile profile) async {
    state = state.copyWith(isGeneratingFeedback: true);

    final feedbackResult = await generateAIFeedback(
      profile: profile,
      answers: state.answers.values.toList(),
    );

    feedbackResult.fold(
          (failure) {
        // En cas d'erreur, on utilise le profil sans feedback IA
        state = state.copyWith(
          isGeneratingFeedback: false,
          aiFeedback: null,
        );
      },
          (feedback) {
        // Mise à jour du profil avec le feedback
        final updatedProfile = profile.copyWith(aiFeedback: feedback);
        state = state.copyWith(
          calculatedProfile: updatedProfile,
          aiFeedback: feedback,
          isGeneratingFeedback: false,
        );
      },
    );
  }

  /// Sauvegarde le profil final
  Future<bool> saveProfileToStorage() async {
    if (state.calculatedProfile == null) return false;

    final result = await saveProfile(state.calculatedProfile!);

    return result.fold(
          (failure) => false,
          (savedProfile) => true,
    );
  }

  /// Reset le questionnaire
  void reset() {
    state = QuestionnaireState();
  }
}

// ===== PROVIDER PRINCIPAL =====

final questionnaireProvider = StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
  return QuestionnaireNotifier(
    getQuestions: ref.read(getQuestionsUseCaseProvider),
    calculateProfile: ref.read(calculateProfileUseCaseProvider),
    generateAIFeedback: ref.read(generateAIFeedbackUseCaseProvider),
    saveProfile: ref.read(saveProfileUseCaseProvider),
  );
});