// lib/features/financial_profile/domain/entities/answer.dart

import 'package:equatable/equatable.dart';

/// Réponse à une question
class Answer extends Equatable {
  final String questionId;
  final String? selectedChoiceId; // Pour questions à choix
  final String? freeText;         // Pour réponses libres
  final DateTime answeredAt;

  const Answer({
    required this.questionId,
    this.selectedChoiceId,
    this.freeText,
    required this.answeredAt,
  });

  bool get hasChoice => selectedChoiceId != null;
  bool get hasFreeText => freeText != null && freeText!.trim().isNotEmpty;

  @override
  List<Object?> get props => [questionId, selectedChoiceId, freeText, answeredAt];
}