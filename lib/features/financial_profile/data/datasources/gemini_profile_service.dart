// lib/features/financial_profile/data/datasources/gemini_profile_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/financial_trait.dart';

class GeminiProfileService {
  late final GenerativeModel _model;

  GeminiProfileService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 10024,
      ),
    );
  }

  /// Génère un feedback personnalisé pour le profil
  Future<String> generateProfileFeedback({
    required FinancialProfile profile,
    required List<Answer> answers,
  }) async {
    try {
      // Extraction des réponses libres
      final freeTexts = answers
          .where((a) => a.hasFreeText)
          .map((a) => a.freeText!)
          .join('\n• ');

      // Construction des scores
      /*final scoresText = profile.traitScores.entries
          .map((e) => '${FinancialTrait.getLabelFor(e.key)}: ${e.value.toStringAsFixed(0)}/100')
          .join('\n• ');*/
      final scoresText = profile.traitScores.entries
          .map((e) => '${e.key.label}: ${e.value.toStringAsFixed(0)}/100')
          .join('\n• ');


      // Prompt structuré
      final prompt = _buildFeedbackPrompt(
        profileType: profile.type,
        scores: scoresText,
        freeTexts: freeTexts,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? _getDefaultFeedback(profile.type);
    } catch (e) {
      print('❌ Erreur Gemini: $e');
      return _getDefaultFeedback(profile.type);
    }
  }

  /// Valide la cohérence du profil avec les réponses libres
  Future<Map<String, dynamic>> validateProfileCoherence({
    required FinancialProfile profile,
    required List<Answer> answers,
  }) async {
    try {
      final freeTexts = answers
          .where((a) => a.hasFreeText)
          .map((a) => a.freeText!)
          .join('\n• ');

      if (freeTexts.isEmpty) {
        return {
          'isCoherent': true,
          'confidence': profile.confidenceScore,
          'hasConflict': false,
        };
      }

      final prompt = _buildValidationPrompt(
        profileType: profile.type,
        freeTexts: freeTexts,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseValidationResponse(response.text ?? '');
    } catch (e) {
      print('❌ Erreur validation Gemini: $e');
      return {
        'isCoherent': true,
        'confidence': profile.confidenceScore,
        'hasConflict': false,
      };
    }
  }

  /// Construit le prompt de génération de feedback
  String _buildFeedbackPrompt({
    required ProfileType profileType,
    required String scores,
    required String freeTexts,
  }) {
    return '''
Tu es un conseiller financier bienveillant et pédagogue.

CONTEXTE :
- Profil détecté : ${profileType.label}
- Description : ${profileType.description}

SCORES DES TRAITS :
$scores

${freeTexts.isNotEmpty ? 'RÉPONSES LIBRES DE L\'UTILISATEUR :\n• $freeTexts' : ''}

CONSIGNES :
1. Génère un feedback personnalisé en 3 parties courtes :
   a) Points forts (2-3 phrases max)
   b) Points de vigilance (2-3 phrases max)
   c) Premier conseil actionnable immédiat (1-2 phrases)

2. STYLE IMPÉRATIF :
   - Ton empathique et encourageant
   - Vocabulaire accessible (pas de jargon)
   - Concret et actionnable
   - MAXIMUM 120 mots AU TOTAL

3. INTERDICTIONS :
   - Jamais de score brut (ex: "votre score de 75")
   - Jamais de terme "algorithme" ou "test"
   - Jamais de généralités vides
   - Jamais de jugement négatif

GÉNÈRE UNIQUEMENT LE FEEDBACK (sans intro ni conclusion) :
''';
  }

  /// Construit le prompt de validation
  String _buildValidationPrompt({
    required ProfileType profileType,
    required String freeTexts,
  }) {
    return '''
Tu es un expert en analyse de cohérence.

PROFIL DÉTECTÉ : ${profileType.label}
DESCRIPTION : ${profileType.description}

RÉPONSES LIBRES :
$freeTexts

MISSION :
Analyse si les réponses libres sont cohérentes avec le profil détecté.

RÉPONDS UNIQUEMENT avec ce format JSON strict :
{
  "isCoherent": true ou false,
  "confidence": nombre entre 0 et 100,
  "hasConflict": true ou false,
  "reason": "explication courte si conflit"
}

RÈGLES :
- isCoherent = true si les réponses supportent le profil
- hasConflict = true si contradiction majeure
- confidence = ton degré de certitude
''';
  }

  /// Parse la réponse de validation
  Map<String, dynamic> _parseValidationResponse(String response) {
    try {
      // Nettoyage de la réponse
      final cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Extraction manuelle des valeurs (plus fiable que JSON.parse avec Gemini)
      final isCoherent = cleaned.contains('"isCoherent": true');
      final hasConflict = cleaned.contains('"hasConflict": true');

      // Extraction du confidence
      final confMatch = RegExp(r'"confidence":\s*(\d+)').firstMatch(cleaned);
      final confidence = confMatch != null
          ? double.parse(confMatch.group(1)!)
          : 75.0;

      return {
        'isCoherent': isCoherent,
        'confidence': confidence,
        'hasConflict': hasConflict,
      };
    } catch (e) {
      print('❌ Erreur parsing validation: $e');
      return {
        'isCoherent': true,
        'confidence': 70.0,
        'hasConflict': false,
      };
    }
  }

  /// Feedback par défaut (fallback)
  String _getDefaultFeedback(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender:
        return '''**Points forts** : Vous profitez du moment présent et êtes généreux avec vos proches.

**Vigilances** : Attention aux achats coup de cœur qui peuvent impacter votre épargne.

**Conseil** : Instaurez une règle des 24h : avant tout achat non essentiel >50€, attendez 24h pour décider.''';

      case ProfileType.balancedAware:
        return '''**Points forts** : Excellent équilibre entre plaisir et raison financière.

**Vigilances** : Maintenez cette discipline même en période de stress ou de bonheur intense.

**Conseil** : Automatisez 10% de vos revenus vers l'épargne pour sécuriser cet équilibre.''';

      case ProfileType.strategicSaver:
        return '''**Points forts** : Discipline remarquable et vision long terme impressionnante.

**Vigilances** : N'oubliez pas de vous faire plaisir occasionnellement.

**Conseil** : Allouez 5% de votre budget mensuel à des "plaisirs sans culpabilité".''';

      case ProfileType.overController:
        return '''**Points forts** : Organisation exemplaire et sécurité financière assurée.

**Vigilances** : Le contrôle excessif peut nuire à votre qualité de vie.

**Conseil** : Définissez un budget "liberté" mensuel sans contrôle ni justification.''';

      case ProfileType.financiallyDisorganized:
        return '''**Points forts** : Flexibilité et absence de stress excessif.

**Vigilances** : Le manque de suivi peut créer des surprises désagréables.

**Conseil** : Commencez par noter uniquement vos 3 plus grosses dépenses chaque semaine.''';

      case ProfileType.cautiousOptimizer:
        return '''**Points forts** : Recherche de valeur et décisions informées.

**Vigilances** : L'analyse excessive peut faire perdre de bonnes opportunités.

**Conseil** : Fixez-vous un délai maximum de réflexion selon le montant (ex: 2h pour <100€).''';
    }
  }
}