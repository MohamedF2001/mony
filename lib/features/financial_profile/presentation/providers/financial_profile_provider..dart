// lib/features/financial_profile/presentation/providers/financial_profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/usecases/generative_ai_feedback.dart';
import '../../domain/usecases/get_questions.dart';
import '../../domain/usecases/calculate_profile.dart';
import '../../domain/usecases/save_profile.dart';
import '../../data/datasources/financial_profile_local_datasource.dart';
import '../../data/datasources/financial_profile_remote_datasource.dart';
import '../../data/datasources/gemini_profile_service.dart';
import '../../data/repositories/financial_profile_repository_impl.dart';

// ===== PROVIDERS DE DÉPENDANCES =====

final localDataSourceProvider = Provider((ref) {
  return FinancialProfileLocalDataSource();
});

final geminiServiceProvider = Provider((ref) {
  return GeminiProfileService();
});

final financialProfileRemoteDataSourceProvider = Provider((ref) {
  return FinancialProfileRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final financialProfileRepositoryProvider = Provider((ref) {
  return FinancialProfileRepositoryImpl(
    localDataSource: ref.read(localDataSourceProvider),
    remoteDataSource: ref.read(financialProfileRemoteDataSourceProvider),
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
  double get progress => questions.isEmpty ? 0.0 : currentQuestionIndex / questions.length;
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

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getQuestions();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: 'Impossible de charger les questions'),
      (questions) => state = state.copyWith(questions: questions, isLoading: false, currentQuestionIndex: 0),
    );
  }

  void submitAnswer({required String? selectedChoiceId, String? freeText}) {
    final currentQ = state.currentQuestion;
    if (currentQ == null) return;

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
    state = state.copyWith(answers: updatedAnswers, error: null);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  /// Finalise le questionnaire, calcule le profil, génère le feedback et SAUVEGARDE
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
        state = state.copyWith(isLoading: false, error: 'Erreur lors du calcul du profil');
      },
      (profile) async {
        state = state.copyWith(calculatedProfile: profile, isLoading: false);

        // 2. Générer le feedback IA
        await _generateFeedback(profile);
        
        // 3. SAUVEGARDE AUTOMATIQUE
        await saveProfileToStorage();
      },
    );
  }

  Future<void> _generateFeedback(FinancialProfile profile) async {
    state = state.copyWith(isGeneratingFeedback: true);
    final feedbackResult = await generateAIFeedback(
      profile: profile,
      answers: state.answers.values.toList(),
    );

    feedbackResult.fold(
      (failure) => state = state.copyWith(isGeneratingFeedback: false, aiFeedback: null),
      (feedback) {
        final updatedProfile = profile.copyWith(aiFeedback: feedback);
        state = state.copyWith(
          calculatedProfile: updatedProfile,
          aiFeedback: feedback,
          isGeneratingFeedback: false,
        );
      },
    );
  }

  Future<bool> saveProfileToStorage() async {
    final profileToSave = state.calculatedProfile;
    if (profileToSave == null) return false;

    final result = await saveProfile(
      profileToSave,
      answers: state.answers.values.toList(),
    );

    return result.fold((failure) => false, (savedProfile) => true);
  }

  void reset() => state = QuestionnaireState();
}

final questionnaireProvider = StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>((ref) {
  return QuestionnaireNotifier(
    getQuestions: ref.read(getQuestionsUseCaseProvider),
    calculateProfile: ref.read(calculateProfileUseCaseProvider),
    generateAIFeedback: ref.read(generateAIFeedbackUseCaseProvider),
    saveProfile: ref.read(saveProfileUseCaseProvider),
  );
});
