// lib/features/ai_assistant/presentation/providers/ai_assistant_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/gemini_datasource.dart';
import '../../domain/entities/chat_message.dart';

final geminiDataSourceProvider = Provider<GeminiDataSource>((ref) {
  return GeminiDataSource();
});

class AiAssistantState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const AiAssistantState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AiAssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  final GeminiDataSource geminiDataSource;
  StreamSubscription<String>? _streamSubscription;

  AiAssistantNotifier(this.geminiDataSource) : super(const AiAssistantState()) {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Bonjour ! 👋 Je suis votre assistant financier personnel. '
          'Je peux vous aider à analyser vos finances, créer un budget, '
          'et vous donner des conseils pour mieux gérer votre argent. '
          'Comment puis-je vous aider aujourd\'hui ?',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [welcomeMessage]);
  }

  Future<void> sendMessage(String message, {String? financialContext}) async {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    final assistantMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMessage],
    );

    _streamSubscription = geminiDataSource
        .sendMessageStream(message, context: financialContext)
        .listen(
      (chunk) {
        final messages = [...state.messages];
        final lastIndex = messages.length - 1;
        messages[lastIndex] = messages[lastIndex].copyWith(content: chunk);
        state = state.copyWith(messages: messages);
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erreur: $e',
        );
      },
      onDone: () {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  Future<void> analyzeFinances({
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final assistantMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMessage],
    );

    _streamSubscription = geminiDataSource
        .analyzeFinancesStream(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categoryBreakdown: categoryBreakdown,
      currency: currency,
    )
        .listen(
      (chunk) {
        final messages = [...state.messages];
        final lastIndex = messages.length - 1;
        messages[lastIndex] = messages[lastIndex].copyWith(content: chunk);
        state = state.copyWith(messages: messages);
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erreur lors de l\'analyse: $e',
        );
      },
      onDone: () {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void clearMessages() {
    _streamSubscription?.cancel();
    state = const AiAssistantState();
    _addWelcomeMessage();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  final geminiDataSource = ref.watch(geminiDataSourceProvider);
  return AiAssistantNotifier(geminiDataSource);
});

extension on ChatMessage {
  ChatMessage copyWith({String? content}) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
    );
  }
}
