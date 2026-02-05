// lib/features/financial_profile/presentation/screens/questionnaire_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/financial_profile_provider..dart';
import '../widgets/questionnaire_progress_bar.dart';
import '../widgets/question_card.dart';
import 'result_animation_screen.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  String? _selectedChoiceId;
  String? _freeTextValue;

  @override
  void initState() {
    super.initState();
    // Charger les questions au démarrage
    Future.microtask(() {
      ref.read(questionnaireProvider.notifier).loadQuestions();
    });
  }

  void _handleNext() {
    final notifier = ref.read(questionnaireProvider.notifier);
    final state = ref.read(questionnaireProvider);

    // Soumettre la réponse actuelle
    notifier.submitAnswer(
      selectedChoiceId: _selectedChoiceId,
      freeText: _freeTextValue,
    );

    // Vérifier s'il y a une erreur
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Réinitialiser la sélection pour la prochaine question
    setState(() {
      _selectedChoiceId = null;
      _freeTextValue = null;
    });

    // Passer à la suivante ou finaliser
    if (state.currentQuestionIndex + 1 < state.totalQuestions) {
      notifier.nextQuestion();
    } else {
      _finalizeQuestionnaire();
    }
  }

  void _handlePrevious() {
    final notifier = ref.read(questionnaireProvider.notifier);
    notifier.previousQuestion();

    // Récupérer la réponse précédente si elle existe
    final state = ref.read(questionnaireProvider);
    final prevQuestion = state.currentQuestion;
    if (prevQuestion != null) {
      final prevAnswer = state.answers[prevQuestion.id];
      setState(() {
        _selectedChoiceId = prevAnswer?.selectedChoiceId;
        _freeTextValue = prevAnswer?.freeText;
      });
    }
  }

  Future<void> _finalizeQuestionnaire() async {
    final notifier = ref.read(questionnaireProvider.notifier);

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await notifier.finalizeQuestionnaire();

    if (!mounted) return;
    Navigator.of(context).pop(); // Fermer le loader

    // Naviguer vers l'écran d'animation de résultat
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ResultAnimationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionnaireProvider);

    if (state.isLoading && state.questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.error != null && state.questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(questionnaireProvider.notifier).loadQuestions();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = state.currentQuestion;
    if (currentQ == null) {
      return const Scaffold(
        body: Center(
          child: Text('Aucune question disponible'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: state.currentQuestionIndex > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _handlePrevious,
        )
            : null,
        title: Text(
          'Profil Financier',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de progression
            QuestionnaireProgressBar(
              currentQuestion: state.currentQuestionIndex + 1,
              totalQuestions: state.totalQuestions,
              progress: state.progress,
            ),

            const SizedBox(height: 24),

            // Question actuelle
            Expanded(
              child: SingleChildScrollView(
                child: QuestionCard(
                  key: ValueKey(currentQ.id), // Force rebuild
                  question: currentQ,
                  selectedChoiceId: _selectedChoiceId,
                  freeTextValue: _freeTextValue,
                  onChoiceSelected: (choiceId) {
                    setState(() {
                      _selectedChoiceId = choiceId;
                    });
                  },
                  onFreeTextChanged: (text) {
                    setState(() {
                      _freeTextValue = text;
                    });
                  },
                ),
              ),
            ),

            // Bouton suivant
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: currentQ.hasChoices && _selectedChoiceId == null
                      ? null
                      : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    state.currentQuestionIndex + 1 < state.totalQuestions
                        ? 'Suivant'
                        : 'Terminer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}