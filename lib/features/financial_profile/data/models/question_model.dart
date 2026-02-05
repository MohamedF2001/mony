/*
// lib/features/financial_profile/data/models/question_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/financial_trait.dart';

part 'question_model.g.dart';

@HiveType(typeId: 10)
class QuestionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int typeIndex; // QuestionType.index

  @HiveField(3)
  final List<AnswerChoiceModel> choices;

  @HiveField(4)
  final String? freeTextPrompt;

  @HiveField(5)
  final bool isRequired;

  @HiveField(6)
  final double weight;

  @HiveField(7)
  final int order;

  QuestionModel({
    required this.id,
    required this.text,
    required this.typeIndex,
    required this.choices,
    this.freeTextPrompt,
    required this.isRequired,
    required this.weight,
    required this.order,
  });

  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      text: question.text,
      typeIndex: question.type.index,
      choices: question.choices
          .map((choice) => AnswerChoiceModel.fromEntity(choice))
          .toList(),
      freeTextPrompt: question.freeTextPrompt,
      isRequired: question.isRequired,
      weight: question.weight,
      order: question.order,
    );
  }

  Question toEntity() {
    return Question(
      id: id,
      text: text,
      type: QuestionType.values[typeIndex],
      choices: choices.map((choice) => choice.toEntity()).toList(),
      freeTextPrompt: freeTextPrompt,
      isRequired: isRequired,
      weight: weight,
      order: order,
    );
  }
}

@HiveType(typeId: 11)
class AnswerChoiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final Map<int, int> scoresMap; // FinancialTraitType.index -> score

  AnswerChoiceModel({
    required this.id,
    required this.text,
    required this.scoresMap,
  });

  factory AnswerChoiceModel.fromEntity(AnswerChoice choice) {
    final scoresMap = <int, int>{};
    choice.scores.forEach((trait, score) {
      scoresMap[trait.index] = score;
    });

    return AnswerChoiceModel(
      id: choice.id,
      text: choice.text,
      scoresMap: scoresMap,
    );
  }

  AnswerChoice toEntity() {
    final scores = <FinancialTraitType, int>{};
    scoresMap.forEach((traitIndex, score) {
      scores[FinancialTraitType.values[traitIndex]] = score;
    });

    return AnswerChoice(
      id: id,
      text: text,
      scores: scores,
    );
  }
}*/


import '../../domain/entities/question.dart';
import '../../domain/entities/financial_trait.dart';

class QuestionModel {
  final String id;
  final String text;
  final int typeIndex; // QuestionType.index
  final List<AnswerChoiceModel> choices;
  final String? freeTextPrompt;
  final bool isRequired;
  final double weight;
  final int order;

  QuestionModel({
    required this.id,
    required this.text,
    required this.typeIndex,
    required this.choices,
    this.freeTextPrompt,
    required this.isRequired,
    required this.weight,
    required this.order,
  });

  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      text: question.text,
      typeIndex: question.type.index,
      choices: question.choices
          .map((choice) => AnswerChoiceModel.fromEntity(choice))
          .toList(),
      freeTextPrompt: question.freeTextPrompt,
      isRequired: question.isRequired,
      weight: question.weight,
      order: question.order,
    );
  }

  Question toEntity() {
    return Question(
      id: id,
      text: text,
      type: QuestionType.values[typeIndex],
      choices: choices.map((choice) => choice.toEntity()).toList(),
      freeTextPrompt: freeTextPrompt,
      isRequired: isRequired,
      weight: weight,
      order: order,
    );
  }
}

class AnswerChoiceModel {
  final String id;
  final String text;
  final Map<int, int> scoresMap; // FinancialTraitType.index -> score

  AnswerChoiceModel({
    required this.id,
    required this.text,
    required this.scoresMap,
  });

  factory AnswerChoiceModel.fromEntity(AnswerChoice choice) {
    final scoresMap = <int, int>{};
    choice.scores.forEach((trait, score) {
      scoresMap[trait.index] = score;
    });

    return AnswerChoiceModel(
      id: choice.id,
      text: choice.text,
      scoresMap: scoresMap,
    );
  }

  AnswerChoice toEntity() {
    final scores = <FinancialTraitType, int>{};
    scoresMap.forEach((traitIndex, score) {
      scores[FinancialTraitType.values[traitIndex]] = score;
    });

    return AnswerChoice(
      id: id,
      text: text,
      scores: scores,
    );
  }
}
