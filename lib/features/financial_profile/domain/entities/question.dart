// lib/features/financial_profile/domain/entities/question.dart

import 'package:equatable/equatable.dart';
import 'financial_trait.dart';

/// Type de question
enum QuestionType {
  multipleChoice,  // Choix multiples uniquement
  freeText,        // Réponse libre uniquement
  mixed,           // Choix multiples + option texte libre
}

/// Choix de réponse pour une question
class AnswerChoice extends Equatable {
  final String id;
  final String text;
  final Map<FinancialTraitType, int> scores; // Impact sur chaque trait

  const AnswerChoice({
    required this.id,
    required this.text,
    required this.scores,
  });

  @override
  List<Object?> get props => [id, text, scores];
}

/// Entité représentant une question du questionnaire
class Question extends Equatable {
  final String id;
  final int order; // Position dans le questionnaire
  final String text;
  final QuestionType type;
  final List<AnswerChoice> choices; // Vide si type == freeText
  final String? freeTextPrompt; // Prompt pour le texte libre (optionnel)
  final double weight; // Importance de la question (1.0 = normal, 1.5 = important)
  final bool isRequired;

  const Question({
    required this.id,
    required this.order,
    required this.text,
    required this.type,
    this.choices = const [],
    this.freeTextPrompt,
    this.weight = 1.0,
    this.isRequired = true,
  });

  /// Vérifie si la question a une option de texte libre
  bool get hasFreeTextOption {
    return type == QuestionType.freeText || type == QuestionType.mixed;
  }

  @override
  List<Object?> get props => [
    id,
    order,
    text,
    type,
    choices,
    freeTextPrompt,
    weight,
    isRequired,
  ];

  bool get hasChoices => choices.isNotEmpty;

}