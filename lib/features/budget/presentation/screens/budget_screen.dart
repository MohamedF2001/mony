// lib/features/budget/presentation/screens/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/budget_providers.dart';
import '../widgets/add_budget_dialog.dart';
import '../widgets/budget_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final budgetState = ref.watch(budgetProvider);
    final budgetsWithSpending = ref.watch(budgetWithSpendingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.budgets),
        /*actions: [
          IconButton(
            onPressed: () {
              // Show budget insights
            },
            icon: const Icon(Icons.insights),
          ),
        ],*/
      ),
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        onPressed: () => _showAddBudgetDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.newBudget),
      ),
      body: budgetState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : budgetsWithSpending.isEmpty
              ? EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.noDataAvailable, // Assuming this for empty budget
                  subtitle: l10n.startByAddingTransaction, // Or similar
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary Card
                    _BudgetSummaryCard(budgets: budgetsWithSpending),

                    const SizedBox(height: 24),

                    // Budgets List
                    Text(
                      l10n.budgets,
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...budgetsWithSpending.map((budgetData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BudgetCard(
                          budgetData: budgetData,
                          onEdit: () =>
                              _editBudget(context, budgetData['budget']),
                          onDelete: () =>
                              _deleteBudget(context, ref, budgetData['budget']),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }

  void _editBudget(BuildContext context, budget) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(budget: budget),
    );
  }

  void _deleteBudget(BuildContext context, WidgetRef ref, budget) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(
          '${l10n.confirmDelete} "${budget.category}" ?',
        ),
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
              await ref.read(budgetProvider.notifier).deleteBudget(budget.id!);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.budgetDeleted),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> budgets;

  const _BudgetSummaryCard({required this.budgets});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b['budget'].amount);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b['spent']);
    final totalRemaining = totalBudget - totalSpent;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total ${l10n.budgets}',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalBudget.toFormattedMoney(),
            style: AppTypography.moneyLarge.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.expenses,
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalSpent.toDouble().toCompactMoney(),
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Text(
                    //   totalSpent.toCompactMoney(),
                    //   style: AppTypography.textTheme.titleMedium?.copyWith(
                    //     color: AppColors.white,
                    //     fontWeight: FontWeight.w700,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.white.withOpacity(0.2),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restant',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalRemaining.toDouble().toCompactMoney(),
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Text(
                      //   totalRemaining.toCompactMoney(),
                      //   style: AppTypography.textTheme.titleMedium?.copyWith(
                      //     color: AppColors.white,
                      //     fontWeight: FontWeight.w700,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
