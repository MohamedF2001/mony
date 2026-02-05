// lib/features/financial_profile/presentation/widgets/question_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/question.dart';
import 'answer_choice_button.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final String? selectedChoiceId;
  final String? freeTextValue;
  final Function(String choiceId) onChoiceSelected;
  final Function(String text) onFreeTextChanged;

  const QuestionCard({
    Key? key,
    required this.question,
    this.selectedChoiceId,
    this.freeTextValue,
    required this.onChoiceSelected,
    required this.onFreeTextChanged,
  }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _textController.text = widget.freeTextValue ?? '';

    // Animation d'entrée
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Réinitialiser l'animation quand la question change
    if (oldWidget.question.id != widget.question.id) {
      _animController.reset();
      _animController.forward();
      _textController.text = widget.freeTextValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la question
              Text(
                widget.question.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Choix de réponses (si applicable)
              if (widget.question.hasChoices) ...[
                ...widget.question.choices.map((choice) {
                  return AnswerChoiceButton(
                    text: choice.text,
                    isSelected: widget.selectedChoiceId == choice.id,
                    onTap: () => widget.onChoiceSelected(choice.id),
                  );
                }).toList(),
              ],

              // Champ texte libre (si applicable)
              if (widget.question.hasFreeTextOption) ...[
                const SizedBox(height: 24),

                Text(
                  widget.question.freeTextPrompt ?? 'Votre réponse (optionnel)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _textController,
                  maxLines: 4,
                  onChanged: widget.onFreeTextChanged,
                  decoration: InputDecoration(
                    hintText: 'Partagez vos pensées...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}