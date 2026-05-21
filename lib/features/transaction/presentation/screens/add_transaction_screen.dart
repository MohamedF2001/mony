// lib/features/transaction/presentation/screens/add_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mony/l10n/app_localizations.dart';
import 'package:mony/features/category/presentation/widgets/add_category_dialog.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/formatters.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory; // Stocke l'ID de la catégorie (ObjectId)
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _selectedType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category; // Reçoit l'ID
      _selectedDate = widget.transaction!.date;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.transaction != null
            ? AppLocalizations.of(context)!.edit
            : AppLocalizations.of(context)!.newTransaction),
        actions: [
          if (widget.transaction != null)
            IconButton(
              onPressed: _deleteTransaction,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type Selector
            _TypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                  _selectedCategory = null; // Reset category when type changes
                });
              },
            ),

            const SizedBox(height: 24),

            // Amount Input
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.amount,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: AppTypography.moneyLarge.copyWith(
                      color: _selectedType == TransactionType.income
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTypography.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.normal),
                      suffixText: '${ref.watch(appSettingsProvider).currency} ',
                      suffixStyle: AppTypography.textTheme.titleLarge,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterAmount;
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return AppLocalizations.of(context)!.invalidAmount;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Selection
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.category,
                          style: AppTypography.textTheme.titleSmall,
                        ),
                        TextButton(
                          onPressed: _showAddCategoryDialog,
                          child: Text(
                              AppLocalizations.of(context)!.newCategoryShort),
                        ),
                      ],
                    ),
                  ),
                  categories.when(
                    data: (categoryList) {
                      final filteredCategories = categoryList
                          .where((c) => c.type == _selectedType)
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredCategories.map((category) {
                            final isSelected =
                                _selectedCategory == category.id; // Correction: comparaison par ID
                            return _CategoryChip(
                              label: category.name,
                              icon: category.icon,
                              color: category.color,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category.id; // Correction: stocke l'ID
                                });
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('${AppLocalizations.of(context)!.error}: $error'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date Selection
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(AppLocalizations.of(context)!.date),
                subtitle: Text(_selectedDate.toFormattedDateLong()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
              ),
            ),

            const SizedBox(height: 16),

            // Description Input
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.description} (${AppLocalizations.of(context)!.optional})',
                    style: AppTypography.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.addNote,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              label: widget.transaction != null
                  ? AppLocalizations.of(context)!.update
                  : AppLocalizations.of(context)!.save,
              onPressed: _saveTransaction,
              isLoading: _isLoading,
              icon: Icons.check,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectCategory),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaction = Transaction(
      id: widget.transaction?.id,
      date: _selectedDate,
      category: _selectedCategory!, // Contient l'ID
      amount: double.parse(_amountController.text),
      type: _selectedType,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(transactionProvider.notifier);
    final success = widget.transaction != null
        ? await notifier.updateTransaction(transaction)
        : await notifier.addTransaction(transaction);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction != null
                ? AppLocalizations.of(context)!.transactionUpdated
                : AppLocalizations.of(context)!.transactionAdded,
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.somethingWentWrong),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteTransaction() {
    if (widget.transaction?.id == null) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDeleteTransaction),
        actions: [
          TextButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(transactionProvider.notifier)
                  .deleteTransaction(widget.transaction!.id!);
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(type: _selectedType),
    );
  }
}

// Type Selector Widget
class _TypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: l10n.income,
              icon: Icons.arrow_downward,
              isSelected: selectedType == TransactionType.income,
              color: AppColors.income,
              onTap: () => onTypeChanged(TransactionType.income),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: l10n.expenses,
              icon: Icons.arrow_upward,
              isSelected: selectedType == TransactionType.expense,
              color: AppColors.expense,
              onTap: () => onTypeChanged(TransactionType.expense),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
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
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.color,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.white : color,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppColors.white : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
