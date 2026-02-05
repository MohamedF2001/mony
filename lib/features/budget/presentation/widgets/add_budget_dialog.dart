// lib/features/budget/presentation/widgets/add_budget_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final Budget? budget;

  const AddBudgetDialog({super.key, this.budget});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _selectedCategory = widget.budget!.category;
      _selectedPeriod = widget.budget!.period;
      _amountController.text = widget.budget!.amount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.budget != null;
    final categories = ref.watch(expenseCategoriesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'Modifier le budget' : 'Nouveau budget',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Category Selection
                Text(
                  'Catégorie',
                  style: AppTypography.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    hintText: 'Sélectionnez',
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 12),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sélectionnez une catégorie';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Amount Input
                Text(
                  'Montant du budget',
                  style: AppTypography.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'F CFA',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez un montant';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Montant invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Period Selection
                Text(
                  'Période',
                  style: AppTypography.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PeriodButton(
                        label: 'Mensuel',
                        isSelected: _selectedPeriod == BudgetPeriod.monthly,
                        onTap: () {
                          setState(() => _selectedPeriod = BudgetPeriod.monthly);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PeriodButton(
                        label: 'Annuel',
                        isSelected: _selectedPeriod == BudgetPeriod.yearly,
                        onTap: () {
                          setState(() => _selectedPeriod = BudgetPeriod.yearly);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        label: isEdit ? 'Mettre à jour' : 'Créer',
                        onPressed: _saveBudget,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final startDate = _selectedPeriod == BudgetPeriod.monthly
        ? DateTime(now.year, now.month, 1)
        : DateTime(now.year, 1, 1);

    final budget = Budget(
      id: widget.budget?.id,
      category: _selectedCategory!,
      amount: double.parse(_amountController.text),
      period: _selectedPeriod,
      startDate: startDate,
      createdAt: widget.budget?.createdAt ?? DateTime.now(),
    );

    final notifier = ref.read(budgetProvider.notifier);
    final success = widget.budget != null
        ? await notifier.updateBudget(budget)
        : await notifier.addBudget(budget);

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? widget.budget != null
                  ? 'Budget mis à jour'
                  : 'Budget créé'
              : 'Une erreur s\'est produite',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: isSelected ? AppColors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}