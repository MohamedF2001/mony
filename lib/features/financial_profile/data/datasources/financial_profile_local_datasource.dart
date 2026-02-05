// lib/features/financial_profile/data/datasources/financial_profile_local_datasource.dart

import 'package:hive/hive.dart';
import '../models/question_model.dart';
import '../models/profile_model.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/financial_trait.dart';

class FinancialProfileLocalDataSource {
  static const String _questionsBoxName = 'questions_box';
  static const String _profileBoxName = 'financial_profile_box';
  static const String _profileKey = 'user_financial_profile';

  /// Récupère toutes les questions (hardcodées pour v1)
  Future<List<QuestionModel>> getQuestions() async {
    // Pour v1, les questions sont hardcodées
    // Pour v2+, elles pourraient être stockées dans Hive ou Firebase
    return _getHardcodedQuestions();
  }

  /// Sauvegarde le profil financier
  Future<void> saveProfile(FinancialProfileModel profile) async {
    final box = await Hive.openBox<FinancialProfileModel>(_profileBoxName);
    await box.put(_profileKey, profile);
  }

  /// Récupère le profil sauvegardé
  Future<FinancialProfileModel?> getSavedProfile() async {
    final box = await Hive.openBox<FinancialProfileModel>(_profileBoxName);
    return box.get(_profileKey);
  }

  /// Supprime le profil (pour reset)
  Future<void> deleteProfile() async {
    final box = await Hive.openBox<FinancialProfileModel>(_profileBoxName);
    await box.delete(_profileKey);
  }

  /// Questions hardcodées (20 questions optimales)
  List<QuestionModel> _getHardcodedQuestions() {
    final questions = [
      // === QUESTION 1 : Argent inattendu ===
      QuestionModel(
        id: 'q1',
        text: 'Quand vous recevez de l\'argent inattendu (prime, cadeau...), vous :',
        typeIndex: QuestionType.mixed.index,
        choices: [
          AnswerChoiceModel(
            id: 'q1_a',
            text: 'Le dépensez rapidement pour vous faire plaisir',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 30,
              FinancialTraitType.savingCapacity.index: -20,
              FinancialTraitType.discipline.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q1_b',
            text: 'L\'épargnez immédiatement',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 30,
              FinancialTraitType.discipline.index: 25,
              FinancialTraitType.impulsivity.index: -20,
            },
          ),
          AnswerChoiceModel(
            id: 'q1_c',
            text: 'Prenez le temps de réfléchir à la meilleure utilisation',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: 20,
              FinancialTraitType.discipline.index: 15,
              FinancialTraitType.organizationLevel.index: 10,
            },
          ),
        ],
        freeTextPrompt: 'Pourquoi réagissez-vous ainsi ? (optionnel)',
        isRequired: true,
        weight: 1.5,
        order: 1,
      ),

      // === QUESTION 2 : Suivi des dépenses ===
      QuestionModel(
        id: 'q2',
        text: 'À quelle fréquence consultez-vous vos comptes bancaires ?',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q2_a',
            text: 'Plusieurs fois par jour',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 25,
              FinancialTraitType.emotionalControl.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q2_b',
            text: 'Une fois par jour',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 20,
              FinancialTraitType.discipline.index: 15,
            },
          ),
          AnswerChoiceModel(
            id: 'q2_c',
            text: 'Quelques fois par semaine',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q2_d',
            text: 'Rarement ou jamais',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: -30,
              FinancialTraitType.discipline.index: -20,
            },
          ),
        ],
        isRequired: true,
        weight: 1.2,
        order: 2,
      ),

      // === QUESTION 3 : Achat coup de coeur ===
      QuestionModel(
        id: 'q3',
        text: 'Face à un achat coup de cœur important, vous :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q3_a',
            text: 'Achetez immédiatement si vous en avez envie',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 35,
              FinancialTraitType.emotionalControl.index: -25,
            },
          ),
          AnswerChoiceModel(
            id: 'q3_b',
            text: 'Attendez 24-48h pour réfléchir',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: 25,
              FinancialTraitType.discipline.index: 20,
            },
          ),
          AnswerChoiceModel(
            id: 'q3_c',
            text: 'Comparez les prix et alternatives',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 20,
              FinancialTraitType.riskTolerance.index: -10,
            },
          ),
          AnswerChoiceModel(
            id: 'q3_d',
            text: 'Renoncez systématiquement',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 20,
              FinancialTraitType.emotionalControl.index: 15,
            },
          ),
        ],
        isRequired: true,
        weight: 1.8,
        order: 3,
      ),

      // === QUESTION 4 : Budget mensuel ===
      QuestionModel(
        id: 'q4',
        text: 'Avez-vous un budget mensuel défini ?',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q4_a',
            text: 'Oui, détaillé par catégorie que je suis rigoureusement',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 30,
              FinancialTraitType.discipline.index: 25,
            },
          ),
          AnswerChoiceModel(
            id: 'q4_b',
            text: 'Oui, mais je le respecte rarement',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 10,
              FinancialTraitType.discipline.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q4_c',
            text: 'J\'ai une idée générale de mes limites',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 5,
            },
          ),
          AnswerChoiceModel(
            id: 'q4_d',
            text: 'Non, je dépense selon mes besoins du moment',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: -25,
              FinancialTraitType.impulsivity.index: 20,
            },
          ),
        ],
        isRequired: true,
        weight: 1.5,
        order: 4,
      ),

      // === QUESTION 5 : Épargne mensuelle ===
      QuestionModel(
        id: 'q5',
        text: 'Épargnez-vous régulièrement chaque mois ?',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q5_a',
            text: 'Oui, un montant fixe automatiquement',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 35,
              FinancialTraitType.discipline.index: 30,
            },
          ),
          AnswerChoiceModel(
            id: 'q5_b',
            text: 'Oui, mais le montant varie',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 20,
              FinancialTraitType.discipline.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q5_c',
            text: 'J\'épargne ce qui reste en fin de mois',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 10,
              FinancialTraitType.organizationLevel.index: -10,
            },
          ),
          AnswerChoiceModel(
            id: 'q5_d',
            text: 'Non, je n\'arrive pas à épargner',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: -30,
              FinancialTraitType.discipline.index: -20,
            },
          ),
        ],
        isRequired: true,
        weight: 2.0,
        order: 5,
      ),

      // === QUESTION 6 : Réaction découvert ===
      QuestionModel(
        id: 'q6',
        text: 'Si votre compte est à découvert, comment réagissez-vous ?',
        typeIndex: QuestionType.mixed.index,
        choices: [
          AnswerChoiceModel(
            id: 'q6_a',
            text: 'Je panique et stresse énormément',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: -25,
              FinancialTraitType.organizationLevel.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q6_b',
            text: 'J\'analyse calmement et trouve des solutions',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: 25,
              FinancialTraitType.organizationLevel.index: 20,
            },
          ),
          AnswerChoiceModel(
            id: 'q6_c',
            text: 'Je ne m\'en rends compte qu\'après coup',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: -30,
              FinancialTraitType.discipline.index: -20,
            },
          ),
          AnswerChoiceModel(
            id: 'q6_d',
            text: 'Cela ne m\'arrive jamais',
            scoresMap: {
              FinancialTraitType.discipline.index: 25,
              FinancialTraitType.organizationLevel.index: 20,
            },
          ),
        ],
        freeTextPrompt: 'Que ressentez-vous face aux difficultés financières ?',
        isRequired: true,
        weight: 1.3,
        order: 6,
      ),

      // === QUESTION 7 : Objectifs financiers ===
      QuestionModel(
        id: 'q7',
        text: 'Avez-vous des objectifs financiers à moyen/long terme ?',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q7_a',
            text: 'Oui, précis et écrits avec plan d\'action',
            scoresMap: {
              FinancialTraitType.discipline.index: 30,
              FinancialTraitType.organizationLevel.index: 25,
            },
          ),
          AnswerChoiceModel(
            id: 'q7_b',
            text: 'Oui, mais vagues et non formalisés',
            scoresMap: {
              FinancialTraitType.discipline.index: 10,
              FinancialTraitType.organizationLevel.index: 5,
            },
          ),
          AnswerChoiceModel(
            id: 'q7_c',
            text: 'Non, je vis au jour le jour',
            scoresMap: {
              FinancialTraitType.discipline.index: -20,
              FinancialTraitType.impulsivity.index: 15,
            },
          ),
        ],
        isRequired: true,
        weight: 1.4,
        order: 7,
      ),

      // === QUESTION 8 : Achats en ligne ===
      QuestionModel(
        id: 'q8',
        text: 'Vos achats en ligne sont généralement :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q8_a',
            text: 'Planifiés et réfléchis',
            scoresMap: {
              FinancialTraitType.discipline.index: 20,
              FinancialTraitType.impulsivity.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q8_b',
            text: 'Spontanés, je craque facilement',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 30,
              FinancialTraitType.emotionalControl.index: -20,
            },
          ),
          AnswerChoiceModel(
            id: 'q8_c',
            text: 'Je n\'achète presque jamais en ligne',
            scoresMap: {
              FinancialTraitType.riskTolerance.index: -15,
            },
          ),
        ],
        isRequired: true,
        weight: 1.0,
        order: 8,
      ),

      // === QUESTION 9 : Promotions ===
      QuestionModel(
        id: 'q9',
        text: 'Face aux promotions et soldes :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q9_a',
            text: 'J\'achète même des choses dont je n\'ai pas besoin',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 35,
              FinancialTraitType.emotionalControl.index: -25,
            },
          ),
          AnswerChoiceModel(
            id: 'q9_b',
            text: 'Je profite uniquement pour ce qui était prévu',
            scoresMap: {
              FinancialTraitType.discipline.index: 25,
              FinancialTraitType.organizationLevel.index: 15,
            },
          ),
          AnswerChoiceModel(
            id: 'q9_c',
            text: 'Je me méfie, souvent ce n\'est pas une vraie affaire',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 15,
              FinancialTraitType.riskTolerance.index: -10,
            },
          ),
          AnswerChoiceModel(
            id: 'q9_d',
            text: 'Je ne suis jamais les promotions',
            scoresMap: {
              FinancialTraitType.discipline.index: 10,
            },
          ),
        ],
        isRequired: true,
        weight: 1.2,
        order: 9,
      ),

      // === QUESTION 10 : Relation à l'argent ===
      QuestionModel(
        id: 'q10',
        text: 'Votre relation à l\'argent est plutôt :',
        typeIndex: QuestionType.mixed.index,
        choices: [
          AnswerChoiceModel(
            id: 'q10_a',
            text: 'Source de stress permanent',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: -30,
              FinancialTraitType.organizationLevel.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q10_b',
            text: 'Neutre, c\'est juste un outil',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: 25,
            },
          ),
          AnswerChoiceModel(
            id: 'q10_c',
            text: 'Plaisir, j\'aime dépenser',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 20,
              FinancialTraitType.savingCapacity.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q10_d',
            text: 'Sécurité, j\'aime contrôler',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 25,
              FinancialTraitType.discipline.index: 20,
            },
          ),
        ],
        freeTextPrompt: 'Décrivez en quelques mots votre rapport à l\'argent',
        isRequired: true,
        weight: 2.0,
        order: 10,
      ),

      // === QUESTION 11 : Paiement carte/espèces ===
      QuestionModel(
        id: 'q11',
        text: 'Vous préférez payer :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q11_a',
            text: 'En espèces pour mieux contrôler',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 15,
              FinancialTraitType.discipline.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q11_b',
            text: 'Par carte, c\'est plus pratique',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q11_c',
            text: 'Peu importe le moyen',
            scoresMap: {},
          ),
        ],
        isRequired: true,
        weight: 0.8,
        order: 11,
      ),

      // === QUESTION 12 : Comparaison prix ===
      QuestionModel(
        id: 'q12',
        text: 'Avant un achat important, vous :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q12_a',
            text: 'Comparez systématiquement les prix pendant des jours',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 25,
              FinancialTraitType.riskTolerance.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q12_b',
            text: 'Regardez vite 2-3 options',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q12_c',
            text: 'Achetez au premier endroit qui vous plaît',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 25,
              FinancialTraitType.organizationLevel.index: -15,
            },
          ),
        ],
        isRequired: true,
        weight: 1.1,
        order: 12,
      ),

      // === QUESTION 13 : Fin de mois ===
      QuestionModel(
        id: 'q13',
        text: 'En fin de mois, vous êtes généralement :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q13_a',
            text: 'À découvert ou presque',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: -30,
              FinancialTraitType.discipline.index: -25,
            },
          ),
          AnswerChoiceModel(
            id: 'q13_b',
            text: 'Juste avec ce qu\'il faut',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 5,
            },
          ),
          AnswerChoiceModel(
            id: 'q13_c',
            text: 'Avec un bon reste disponible',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 25,
              FinancialTraitType.discipline.index: 20,
            },
          ),
        ],
        isRequired: true,
        weight: 1.6,
        order: 13,
      ),

      // === QUESTION 14 : Prêt à un proche ===
      QuestionModel(
        id: 'q14',
        text: 'Un proche vous demande de lui prêter de l\'argent :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q14_a',
            text: 'Vous acceptez facilement par générosité',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: -15,
              FinancialTraitType.impulsivity.index: 15,
            },
          ),
          AnswerChoiceModel(
            id: 'q14_b',
            text: 'Vous évaluez d\'abord votre situation',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: 20,
              FinancialTraitType.organizationLevel.index: 15,
            },
          ),
          AnswerChoiceModel(
            id: 'q14_c',
            text: 'Vous refusez systématiquement',
            scoresMap: {
              FinancialTraitType.discipline.index: 15,
              FinancialTraitType.savingCapacity.index: 10,
            },
          ),
        ],
        isRequired: true,
        weight: 1.0,
        order: 14,
      ),

      // === QUESTION 15 : Investissement ===
      QuestionModel(
        id: 'q15',
        text: 'Face à une opportunité d\'investissement :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q15_a',
            text: 'Vous vous lancez si ça semble intéressant',
            scoresMap: {
              FinancialTraitType.riskTolerance.index: 30,
              FinancialTraitType.impulsivity.index: 20,
            },
          ),
          AnswerChoiceModel(
            id: 'q15_b',
            text: 'Vous analysez longuement avant de décider',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 25,
              FinancialTraitType.riskTolerance.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q15_c',
            text: 'Vous évitez, c\'est trop risqué',
            scoresMap: {
              FinancialTraitType.riskTolerance.index: -25,
              FinancialTraitType.savingCapacity.index: 15,
            },
          ),
        ],
        isRequired: true,
        weight: 1.3,
        order: 15,
      ),

      // === QUESTION 16 : Factures ===
      QuestionModel(
        id: 'q16',
        text: 'Vos factures et abonnements sont :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q16_a',
            text: 'Tous automatisés et suivis',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 30,
              FinancialTraitType.discipline.index: 20,
            },
          ),
          AnswerChoiceModel(
            id: 'q16_b',
            text: 'Certains automatisés, d\'autres manuels',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 15,
            },
          ),
          AnswerChoiceModel(
            id: 'q16_c',
            text: 'Payés au dernier moment ou en retard',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: -25,
              FinancialTraitType.discipline.index: -20,
            },
          ),
        ],
        isRequired: true,
        weight: 1.2,
        order: 16,
      ),

      // === QUESTION 17 : Récompense après effort ===
      QuestionModel(
        id: 'q17',
        text: 'Après un gros effort ou succès, vous :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q17_a',
            text: 'Vous offrez une grosse récompense financière',
            scoresMap: {
              FinancialTraitType.impulsivity.index: 25,
              FinancialTraitType.emotionalControl.index: -15,
            },
          ),
          AnswerChoiceModel(
            id: 'q17_b',
            text: 'Un petit plaisir raisonnable',
            scoresMap: {
              FinancialTraitType.emotionalControl.index: 15,
              FinancialTraitType.discipline.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q17_c',
            text: 'Rien, vous préférez épargner',
            scoresMap: {
              FinancialTraitType.savingCapacity.index: 20,
              FinancialTraitType.discipline.index: 15,
            },
          ),
        ],
        isRequired: true,
        weight: 1.0,
        order: 17,
      ),

      // === QUESTION 18 : Applications bancaires ===
      QuestionModel(
        id: 'q18',
        text: 'Utilisez-vous des applications de gestion financière ?',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q18_a',
            text: 'Oui, quotidiennement',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 25,
              FinancialTraitType.discipline.index: 20,
            },
          ),
          AnswerChoiceModel(
            id: 'q18_b',
            text: 'Oui, mais rarement',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q18_c',
            text: 'Non, jamais',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: -15,
            },
          ),
        ],
        isRequired: true,
        weight: 0.9,
        order: 18,
      ),

      // === QUESTION 19 : Crédit/Découvert ===
      QuestionModel(
        id: 'q19',
        text: 'Votre position sur le crédit à la consommation :',
        typeIndex: QuestionType.multipleChoice.index,
        choices: [
          AnswerChoiceModel(
            id: 'q19_a',
            text: 'J\'y ai recours régulièrement',
            scoresMap: {
              FinancialTraitType.riskTolerance.index: 25,
              FinancialTraitType.discipline.index: -20,
            },
          ),
          AnswerChoiceModel(
            id: 'q19_b',
            text: 'Seulement pour gros achats nécessaires',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 15,
              FinancialTraitType.riskTolerance.index: 10,
            },
          ),
          AnswerChoiceModel(
            id: 'q19_c',
            text: 'Jamais, je préfère économiser d\'abord',
            scoresMap: {
              FinancialTraitType.discipline.index: 25,
              FinancialTraitType.savingCapacity.index: 20,
            },
          ),
        ],
        isRequired: true,
        weight: 1.4,
        order: 19,
      ),

      // === QUESTION 20 : Vision future ===
      QuestionModel(
        id: 'q20',
        text: 'Dans 5 ans, financièrement vous vous voyez :',
        typeIndex: QuestionType.mixed.index,
        choices: [
          AnswerChoiceModel(
            id: 'q20_a',
            text: 'Avec une belle épargne et patrimoine',
            scoresMap: {
              FinancialTraitType.discipline.index: 25,
              FinancialTraitType.savingCapacity.index: 25,
            },
          ),
          AnswerChoiceModel(
            id: 'q20_b',
            text: 'Stable, sans dette',
            scoresMap: {
              FinancialTraitType.organizationLevel.index: 15,
            },
          ),
          AnswerChoiceModel(
            id: 'q20_c',
            text: 'Je ne me projette pas vraiment',
            scoresMap: {
              FinancialTraitType.discipline.index: -20,
              FinancialTraitType.impulsivity.index: 15,
            },
          ),
        ],
        freeTextPrompt: 'Quel est votre rêve financier principal ?',
        isRequired: true,
        weight: 1.7,
        order: 20,
      ),
    ];

    return questions;
  }
}