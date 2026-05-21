import '../../domain/entities/answer.dart';

class AnswerModel {
  final String questionId;
  final String? selectedChoiceId;
  final String? freeText;
  final DateTime answeredAt;

  AnswerModel({
    required this.questionId,
    this.selectedChoiceId,
    this.freeText,
    required this.answeredAt,
  });

  factory AnswerModel.fromEntity(Answer answer) {
    return AnswerModel(
      questionId: answer.questionId,
      selectedChoiceId: answer.selectedChoiceId,
      freeText: answer.freeText,
      answeredAt: answer.answeredAt,
    );
  }

  Answer toEntity() {
    return Answer(
      questionId: questionId,
      selectedChoiceId: selectedChoiceId,
      freeText: freeText,
      answeredAt: answeredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      // On remplace null par une chaîne vide pour éviter l'erreur de cast MongoDB
      'selectedChoiceId': selectedChoiceId ?? '',
      'freeText': freeText ?? '',
      'answeredAt': answeredAt.toUtc().toIso8601String(),
    };
  }
}
