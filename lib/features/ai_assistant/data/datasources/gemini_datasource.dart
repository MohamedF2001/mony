/*
// lib/features/ai_assistant/data/datasources/gemini_datasource.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/config/gemini_config.dart';

class GeminiDataSource {
  late final GenerativeModel _model;

  GeminiDataSource() {
    if (!GeminiConfig.isConfigured) {
      throw Exception(
        'Gemini API Key not configured. '
            'Please add your API key in lib/core/config/gemini_config.dart',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: GeminiConfig.apiKey,
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

  Future<String> sendMessage(String message, {String? context}) async {
    try {
      final prompt = context != null
          ? 'Contexte financier: $context\n\nQuestion: $message'
          : message;

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Désolé, je n\'ai pas pu générer de réponse.';
    } catch (e) {
      throw Exception('Erreur Gemini: $e');
    }
  }

  Future<String> analyzeFinances({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
  }) async {
    try {
      final context = '''
Analyse mes finances:
- Revenus totaux: $totalIncome F CFA
- Dépenses totales: $totalExpense F CFA
- Solde: ${totalIncome - totalExpense} F CFA

Répartition des dépenses par catégorie:
${categoryBreakdown.entries.map((e) => '- ${e.key}: ${e.value} F CFA').join('\n')}

Donne-moi une analyse détaillée et des conseils personnalisés pour améliorer ma gestion financière.
''';

      final content = [Content.text(context)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Impossible d\'analyser vos finances.';
    } catch (e) {
      throw Exception('Erreur lors de l\'analyse: $e');
    }
  }

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
}


*/


/*
// lib/features/ai_assistant/data/datasources/gemini_datasource.dart

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/config/gemini_config.dart';
import '../../domain/entities/chat_message.dart';
import 'package:uuid/uuid.dart';

class GeminiDataSource {
  late final GenerativeModel _model;
  final List<ChatMessage> _conversationMemory = [];

  GeminiDataSource() {
    if (!GeminiConfig.isConfigured) {
      throw Exception(
        'Gemini API Key not configured. '
            'Please add your API key in lib/core/config/gemini_config.dart',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        'Tu es un assistant financier personnel expert. '
            'Aide les utilisateurs à gérer leur argent, budgétiser, '
            'épargner et prendre de meilleures décisions financières. '
            'Réponds toujours en français, de manière claire, concise et amicale. '
            'Fournis des conseils pratiques et personnalisés basés sur leurs transactions.',
      ),
    );
  }

  void addToMemory(ChatMessage message) {
    _conversationMemory.add(message);
    // Limiter la mémoire à 50 messages pour éviter surcharge
    if (_conversationMemory.length > 50) {
      _conversationMemory.removeAt(0);
    }
  }

  /// Envoie un message à Gemini et reçoit la réponse complète
  Future<String> sendMessage(String message, {String? context}) async {
    final prompt = _buildPrompt(message, context);
    addToMemory(ChatMessage(
      id: const Uuid().v4(),
      content: message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final reply = response.text ?? 'Je n\'ai pas pu générer de réponse.';
      addToMemory(ChatMessage(
        id: const Uuid().v4(),
        content: reply,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
      return reply;
    } catch (e) {
      throw Exception('Erreur Gemini: $e');
    }
  }

  /// Streaming : reçoit les tokens en temps réel
  Stream<String> streamMessage(String message, {String? context}) async* {
    final prompt = _buildPrompt(message, context);
    addToMemory(ChatMessage(
      id: const Uuid().v4(),
      content: message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));

    try {
      await for (final chunk in _model.streamGenerateContent([Content.text(prompt)])) {
        final token = chunk.text ?? '';
        if (token.isNotEmpty) yield token;
      }
    } catch (e) {
      throw Exception('Erreur Gemini (stream): $e');
    }
  }

  /// Analyse financière optimisée
  Future<String> analyzeFinances({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
  }) async {
    final context = '''
Analyse mes finances:
- Revenus totaux: $totalIncome F CFA
- Dépenses totales: $totalExpense F CFA
- Solde: ${totalIncome - totalExpense} F CFA

Répartition des dépenses par catégorie:
${categoryBreakdown.entries.map((e) => '- ${e.key}: ${e.value} F CFA').join('\n')}

Donne-moi une analyse détaillée avec :
1. Conseils pour économiser
2. Conseils pour optimiser le budget
3. Astuces pour investir intelligemment
Réponds de manière claire, concise et en français.
''';

    return sendMessage(context);
  }

  /// Suggestions rapides
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

  String _buildPrompt(String message, String? context) {
    final buffer = StringBuffer();
    if (_conversationMemory.isNotEmpty) {
      buffer.writeln('Conversation précédente:');
      for (var msg in _conversationMemory) {
        final role = msg.isUser ? 'Utilisateur' : 'Assistant';
        buffer.writeln('$role: ${msg.content}');
      }
      buffer.writeln('---');
    }
    if (context != null) {
      buffer.writeln('Contexte financier: $context');
    }
    buffer.writeln('Question: $message');
    return buffer.toString();
  }

  void clearMemory() {
    _conversationMemory.clear();
  }

  List<ChatMessage> get memory => List.unmodifiable(_conversationMemory);
}
*/


/*// lib/features/ai_assistant/data/datasources/gemini_datasource.dart

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/config/gemini_config.dart';
import '../../domain/entities/chat_message.dart';

class GeminiDataSource {
  late final GenerativeModel _model;
  final List<ChatMessage> _conversationHistory = [];

  GeminiDataSource() {
    if (!GeminiConfig.isConfigured) {
      throw Exception(
        'Gemini API Key not configured. '
            'Veuillez ajouter votre clé API dans lib/core/config/gemini_config.dart',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        'Tu es un assistant financier expert. '
            'Aide les utilisateurs à gérer leur argent, budgétiser, épargner et prendre de meilleures décisions financières. '
            'Réponds toujours en français, de manière claire, concise et amicale. '
            'Fournis des conseils pratiques et personnalisés basés sur leurs transactions.',
      ),
    );
  }

  /// Envoi de message simple
  Future<String> sendMessage(String message, {String? context}) async {
    try {
      final prompt = _buildPrompt(message, context);
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);

      final text = response.text ?? 'Désolé, je n\'ai pas pu générer de réponse.';
      _addToHistory(message, text);

      return text;
    } catch (e) {
      throw Exception('Erreur Gemini: $e');
    }
  }

  /// Envoi de message en streaming
  Stream<String> streamMessage(String message, {String? context}) async* {
    final prompt = _buildPrompt(message, context);
    final content = [Content.text(prompt)];

    try {
      final stream = _model.streamGenerateContent(content);

      String fullResponse = '';

      await for (final partial in stream) {
        if (partial.text != null) {
          fullResponse += partial.text!;
          yield fullResponse; // renvoie la réponse partielle en temps réel
        }
      }

      _addToHistory(message, fullResponse);
    } catch (e) {
      throw Exception('Erreur Gemini streaming: $e');
    }
  }

  /// Analyse financière détaillée
  Future<String> analyzeFinances({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
  }) async {
    final prompt = '''
Analyse mes finances :
- Revenus totaux: $totalIncome F CFA
- Dépenses totales: $totalExpense F CFA
- Solde: ${totalIncome - totalExpense} F CFA

Répartition des dépenses par catégorie:
${categoryBreakdown.entries.map((e) => '- ${e.key}: ${e.value} F CFA').join('\n')}

Donne-moi une analyse détaillée avec conseils personnalisés pour améliorer ma gestion financière.
''';

    return await sendMessage(prompt);
  }

  /// Suggestions initiales
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

  /// Historique de conversation
  List<ChatMessage> get conversationHistory => List.unmodifiable(_conversationHistory);

  void _addToHistory(String userMessage, String assistantMessage) {
    _conversationHistory.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));

    _conversationHistory.add(ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: assistantMessage,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    ));
  }

  /// Construction du prompt avec historique pour contexte
  String _buildPrompt(String message, String? context) {
    final buffer = StringBuffer();

    // Ajout du contexte financier si disponible
    if (context != null) {
      buffer.writeln('Contexte financier: $context\n');
    }

    // Historique des messages
    for (var msg in _conversationHistory) {
      final role = msg.isUser ? 'Utilisateur' : 'Assistant';
      buffer.writeln('$role: ${msg.content}');
    }

    // Message actuel
    buffer.writeln('Utilisateur: $message');

    return buffer.toString();
  }

  /// Réinitialiser l'historique
  void clearHistory() => _conversationHistory.clear();
}*/


// lib/features/ai_assistant/data/datasources/gemini_datasource.dart

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
//import 'package:poche/test_list_model.dart';
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
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
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
      for (int start = 0; start < text.length; start += chunkSize) {
        final end = (start + chunkSize < text.length) ? start + chunkSize : text.length;
        yield text.substring(0, end); // yield cumulatif pour effet typing
        await Future.delayed(const Duration(milliseconds: 50));
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
      print('Erreur Gemini: $e');
    }
  }

  /// Analyse des finances avec streaming
  Stream<String> analyzeFinancesStream({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
  }) async* {
    final context = '''
Analyse mes finances:
- Revenus totaux: $totalIncome F CFA
- Dépenses totales: $totalExpense F CFA
- Solde: ${totalIncome - totalExpense} F CFA

Répartition des dépenses par catégorie:
${categoryBreakdown.entries.map((e) => '- ${e.key}: ${e.value} F CFA').join('\n')}

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

    for (var msg in _conversationMemory) {
      final role = msg.isUser ? 'Utilisateur' : 'Assistant';
      buffer.writeln('$role: ${msg.content}');
    }

    if (context != null && context.isNotEmpty) {
      buffer.writeln('\nContexte financier: $context');
    }

    buffer.writeln('\nUtilisateur: $message\nAssistant:');

    return buffer.toString();
  }
}
