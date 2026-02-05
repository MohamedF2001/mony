/*
// lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../../presentation/providers/ai_assistant_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final assistantState = ref.watch(aiAssistantProvider);
    final geminiDataSource = ref.watch(geminiDataSourceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assistant IA'),
                  Text(
                    'Propulsé par Gemini',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAnalyzeDialog,
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analyser mes finances',
          ),
          IconButton(
            onPressed: () {
              ref.read(aiAssistantProvider.notifier).clearMessages();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Nouvelle conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: assistantState.messages.length +
                  (assistantState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == assistantState.messages.length &&
                    assistantState.isLoading) {
                  return _buildTypingIndicator();
                }

                final message = assistantState.messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // Error Message
          if (assistantState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      assistantState.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(aiAssistantProvider.notifier).clearError();
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),

          // Suggestions
          FutureBuilder<List<String>>(
            future: geminiDataSource.getSuggestions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || assistantState.messages.length > 1) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: snapshot.data!.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            _sendMessage(suggestion);
                          },
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: AppTypography.textTheme.labelSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    icon: const Icon(Icons.send, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Get financial context
    final transactions = ref.read(filteredTransactionsProvider);
    final totalIncome = ref.read(totalIncomeProvider);
    final totalExpense = ref.read(totalExpenseProvider);

    final context = 'Total revenus: $totalIncome F CFA, '
        'Total dépenses: $totalExpense F CFA, '
        'Nombre de transactions: ${transactions.length}';

    ref.read(aiAssistantProvider.notifier).sendMessage(
      message,
      financialContext: context,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _showAnalyzeDialog() {
    final totalIncome = ref.read(totalIncomeProvider);
    final totalExpense = ref.read(totalExpenseProvider);
    final transactions = ref.read(filteredTransactionsProvider);

    // Category breakdown
    final Map<String, double> categoryBreakdown = {};
    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categoryBreakdown[transaction.category] =
            (categoryBreakdown[transaction.category] ?? 0) + transaction.amount;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analyser mes finances'),
        content: const Text(
          'Voulez-vous que l\'assistant IA analyse vos finances et vous donne des conseils personnalisés ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(aiAssistantProvider.notifier).analyzeFinances(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                categoryBreakdown: categoryBreakdown,
              );
              _scrollToBottom();
            },
            child: const Text('Analyser'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 200),
                const SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: isUser ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.timestamp.toFormattedDate(),
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: isUser
                          ? AppColors.white.withOpacity(0.7)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}*/


// lib/features/ai_assistant/presentation/screens/ai_assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../../presentation/providers/ai_assistant_provider.dart';
import '../../data/datasources/gemini_datasource.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final assistantState = ref.watch(aiAssistantProvider);
    final geminiDataSource = ref.watch(geminiDataSourceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assistant IA'),
                  Text(
                    'Propulsé par Gemini',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAnalyzeDialog,
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analyser mes finances',
          ),
          IconButton(
            onPressed: () {
              ref.read(aiAssistantProvider.notifier).clearMessages();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Nouvelle conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: assistantState.messages.length + (assistantState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == assistantState.messages.length && assistantState.isLoading) {
                  return _buildTypingIndicator();
                }
                final message = assistantState.messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // Error Message
          if (assistantState.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      assistantState.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(aiAssistantProvider.notifier).clearError();
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),

          // Suggestions
          FutureBuilder<List<String>>(
            future: geminiDataSource.getSuggestions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || assistantState.messages.length > 1) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: snapshot.data!.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            _sendMessage(suggestion);
                          },
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: AppTypography.textTheme.labelSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_messageController.text),
                    icon: const Icon(Icons.send, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Contexte financier
    final transactions = ref.read(filteredTransactionsProvider);
    final totalIncome = ref.read(totalIncomeProvider);
    final totalExpense = ref.read(totalExpenseProvider);

    final context =
        'Total revenus: $totalIncome F CFA, Total dépenses: $totalExpense F CFA, Nombre de transactions: ${transactions.length}';

    ref.read(aiAssistantProvider.notifier).sendMessage(
      message,
      financialContext: context,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _showAnalyzeDialog() {
    final totalIncome = ref.read(totalIncomeProvider);
    final totalExpense = ref.read(totalExpenseProvider);
    final transactions = ref.read(filteredTransactionsProvider);

    // Répartition par catégorie
    final Map<String, double> categoryBreakdown = {};
    for (var t in transactions) {
      if (t.isExpense) {
        categoryBreakdown[t.category] = (categoryBreakdown[t.category] ?? 0) + t.amount;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Analyser mes finances'),
        content: const Text(
          'Voulez-vous que l\'assistant IA analyse vos finances et vous donne des conseils personnalisés ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(aiAssistantProvider.notifier).analyzeFinances(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                categoryBreakdown: categoryBreakdown,
              );
              _scrollToBottom();
            },
            child: const Text('Analyser'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _TypingDot(delay: 0),
                SizedBox(width: 4),
                _TypingDot(delay: 200),
                SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
            ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: isUser ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.timestamp.toFormattedDate(),
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: isUser
                          ? AppColors.white.withOpacity(0.7)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            ...[
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.white, size: 20),
              ),
            ],
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

