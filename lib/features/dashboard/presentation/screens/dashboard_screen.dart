// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:mony/l10n/app_localizations.dart';
import 'package:mony/features/transaction/domain/entities/transaction.dart';
import 'package:mony/features/transaction/presentation/screens/transaction_list_sreen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/money_card.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../financial_profile/presentation/utils/financial_profile_ui_utils.dart';
import '../../../profile/presentation/screens/user_profile_screen.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../../transaction/presentation/screens/add_transaction_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/spending_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);
    final balance = ref.watch(balanceProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: userAsync.when(
          data: (user) {
            final authUser = ref.watch(authProvider).user;
            final name = authUser != null ? '${authUser.firstName}' : (user?.name ?? "");
            return Text(AppLocalizations.of(context)!.hello(name));
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const Text('Mony'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UserProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(AppLocalizations.of(context)!.noUser));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(userProvider.notifier).loadUser();
              await ref.read(transactionProvider.notifier).loadTransactions();
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: AppColors.white,
                  automaticallyImplyLeading: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.financialProfile != null)
                        Text(
                          AppLocalizations.of(context)!.youAreA(
                            FinancialProfileUIUtils.getProfileLabel(user.financialProfile!.type, AppLocalizations.of(context)!)
                          ),
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: FinancialProfileUIUtils.getColorForProfileType(user.financialProfile!.type),
                          ),
                        )
                      else
                        Text(
                          "Profil non défini ${user.subscriptionType}" ,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BalanceCard(
                          balance: balance,
                          income: totalIncome,
                          expense: totalExpense,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: QuickActions(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: MoneyCard(
                                title: AppLocalizations.of(context)!.income,
                                amount: totalIncome,
                                icon: Icons.arrow_downward,
                                color: AppColors.income,
                                gradient: AppColors.incomeGradient,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MoneyCard(
                                title: AppLocalizations.of(context)!.expenses,
                                amount: totalExpense,
                                icon: Icons.arrow_upward,
                                color: AppColors.expense,
                                gradient: AppColors.expenseGradient,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SpendingChart(
                          transactions: recentTransactions,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recentTransactions,
                              style: AppTypography.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TransactionListScreen(),
                                  ),
                                );
                              },
                              child: Text(AppLocalizations.of(context)!.seeAll),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                if (transactionState.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (recentTransactions.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: AppLocalizations.of(context)!.noTransaction,
                      subtitle: AppLocalizations.of(context)!.startByAddingTransaction,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = recentTransactions[index];
                        return TransactionTile(
                          transaction: transaction,
                          onTap: () => _showTransactionDetails(context, transaction),
                          onDelete: () => _deleteTransaction(transaction.id!),
                          onEdit: () => _editTransaction(transaction),
                        );
                      },
                      childCount: recentTransactions.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text('${AppLocalizations.of(context)!.error}: $err'),
        ),
      ),
      floatingActionButton: OpenContainer(
        closedElevation: 6,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        closedColor: AppColors.primary,
        openColor: AppColors.background,
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedBuilder: (context, action) {
          return Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: const Icon(Icons.add, color: AppColors.white, size: 28),
          );
        },
        openBuilder: (context, action) {
          return const AddTransactionScreen();
        },
      ),
    );
  }

  void _showTransactionDetails(context, transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }

  void _editTransaction(transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(String id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.confirmDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionProvider.notifier).deleteTransaction(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.transactionDeleted)),
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

class _TransactionDetailsSheet extends StatelessWidget {
  final Transaction transaction;
  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            transaction.displayCategoryName,
            style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatMoney(transaction.amount),
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: transaction.type == TransactionType.income ? AppColors.income : AppColors.expense,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _DetailRow(label: AppLocalizations.of(context)!.date, value: Formatters.formatDate(transaction.date)),
          if (transaction.description != null && transaction.description!.isNotEmpty)
            _DetailRow(label: AppLocalizations.of(context)!.description, value: transaction.description!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.primaryLight)),
          Text(value, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
