// lib/features/ai_assistant/data/datasources/gemini_datasource.dart

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/config/gemini_config.dart';
import '../../domain/entities/chat_message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiDataSource {
  late final GenerativeModel _model;

  // Mémoire de conversation
  final List<ChatMessage> _conversationMemory = [];

  GeminiDataSource() {
    if (!GeminiConfig.isConfigured) {
      throw Exception(
        'Gemini API Key not configured. '
            'Please add your API key in lib/core/config/gemini_config.dart',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Utilisation d'un modèle stable pour éviter les erreurs 503
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        'Tu es un assistant financier personnel expert. '
            'Tu aides les utilisateurs à gérer leur argent, à budgétiser, '
            'à épargner et à prendre de meilleures décisions financières. '
            'Réponds toujours en français de manière claire, concise et amicale. '
            'Fournis des conseils pratiques et personnalisés basés sur leurs transactions.',
      ),
    );
  }

  /// Envoie un message et simule un streaming de la réponse
  Stream<String> sendMessageStream(String message, {String? context}) async* {
    // Ajout du message utilisateur à la mémoire
    _conversationMemory.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));

    final prompt = _buildPrompt(message, context);

    try {
      // Génération de la réponse complète
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? 'Désolé, je n\'ai pas pu générer de réponse.';

      // Simuler le streaming en renvoyant par morceaux
      int chunkSize = 20;
      String currentText = "";
      for (int start = 0; start < text.length; start += chunkSize) {
        final end = (start + chunkSize < text.length) ? start + chunkSize : text.length;
        currentText = text.substring(0, end);
        yield currentText;
        await Future.delayed(const Duration(milliseconds: 30));
      }

      // Ajouter la réponse à la mémoire
      _conversationMemory.add(ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: text,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      yield 'Erreur Gemini: $e';
    }
  }

  /// Analyse des finances avec streaming
  Stream<String> analyzeFinancesStream({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
    String currency = 'F CFA',
  }) async* {
    final context = '''
Analyse mes finances:
- Revenus totaux: $totalIncome $currency
- Dépenses totales: $totalExpense $currency
- Solde: ${totalIncome - totalExpense} $currency

Répartition des dépenses par catégorie:
${categoryBreakdown.entries.map((e) => '- ${e.key}: ${e.value} $currency').join('\n')}

Donne-moi une analyse détaillée et des conseils personnalisés pour améliorer ma gestion financière.
''';

    await for (final chunk in sendMessageStream('Analyse financière:\n$context')) {
      yield chunk;
    }
  }

  /// Suggestions prédéfinies
  Future<List<String>> getSuggestions() async {
    return [
      'Comment puis-je économiser plus d\'argent ?',
      'Analyse mes dépenses ce mois-ci',
      'Comment créer un budget efficace ?',
      'Conseils pour réduire mes dépenses',
      'Quelle est la règle 50/30/20 ?',
      'Comment investir intelligemment ?',
    ];
  }

  /// Crée le prompt en incluant la mémoire de conversation
  String _buildPrompt(String message, String? context) {
    final buffer = StringBuffer();

    // On limite l'historique pour ne pas saturer le prompt
    final history = _conversationMemory.length > 10 
        ? _conversationMemory.sublist(_conversationMemory.length - 10) 
        : _conversationMemory;

    for (var msg in history) {
      final role = msg.isUser ? 'Utilisateur' : 'Assistant';
      buffer.writeln('$role: ${msg.content}');
    }

    if (context != null && context.isNotEmpty) {
      buffer.writeln('\nContexte financier: $context');
    }

    buffer.writeln('\nUtilisateur: $message\nAssistant:');

    return buffer.toString();
  }
  
  void clearMemory() {
    _conversationMemory.clear();
  }
}
