/*
// lib/features/financial_profile/data/models/answer_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/answer.dart';

part 'answer_model.g.dart';

@HiveType(typeId: 12)
class AnswerModel extends HiveObject {
  @HiveField(0)
  final String questionId;

  @HiveField(1)
  final String? selectedChoiceId;

  @HiveField(2)
  final String? freeText;

  @HiveField(3)
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
}*/

import 'package:hive/hive.dart';
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
}
