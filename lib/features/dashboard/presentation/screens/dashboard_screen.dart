// lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:mony/features/transaction/domain/entities/transaction.dart';
import 'package:mony/features/transaction/presentation/screens/transaction_list_sreen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/money_card.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../../core/widgets/empty_state.dart';
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
          data: (user) => Text('Bonjour ${user?.name ?? ""}'), // ✨ NOUVEAU
          loading: () => const Text('Chargement...'),
          error: (_, __) => const Text('Mony'),
        ),
        actions: [
          // Bouton profil
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
          if (user == null) return const Text('Aucun utilisateur');

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: AppColors.white,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Text(
                      'Bonjour 👋',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Bienvenue',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),*/
                    Text('Vous etes un : ${user.financialProfile?.label ?? "Non défini"}',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),),
                  ],
                ),
                /*actions: [
              IconButton(
                onPressed: () {
                  // Navigate to notifications
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButton(
                onPressed: () {
                  // Navigate to profile
                },
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],*/
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Balance Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BalanceCard(
                        balance: balance,
                        income: totalIncome,
                        expense: totalExpense,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: QuickActions(),
                    ),

                    const SizedBox(height: 24),

                    // Statistics Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: MoneyCard(
                              title: 'Revenus',
                              amount: totalIncome,
                              icon: Icons.arrow_downward,
                              color: AppColors.income,
                              gradient: AppColors.incomeGradient,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MoneyCard(
                              title: 'Dépenses',
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

                    // Spending Chart
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SpendingChart(
                        transactions: recentTransactions,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions récentes',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const TransactionListScreen(),
                                ),
                              );
                            },
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Recent Transactions List
              if (transactionState.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (recentTransactions.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aucune transaction',
                    subtitle: 'Commencez par ajouter votre première transaction',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final transaction = recentTransactions[index];
                      return TransactionTile(
                        transaction: transaction,
                        onTap: () {
                          _showTransactionDetails(context, transaction);
                        },
                        onDelete: () {
                          _deleteTransaction(transaction.id!);
                        },
                        onEdit: () {
                          _editTransaction(transaction);
                        },
                      );
                    },
                    childCount: recentTransactions.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );

            /*Column(
            children: [
              Text('Profil: ${user.financialProfile?.label ?? "Non défini"}'),
              // Votre contenu...
            ],
          );*/
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, _) => Text('Erreur: $err'),
      ),





      // Floating Action Button
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
            child: const Icon(
              Icons.add,
              color: AppColors.white,
              size: 28,
            ),
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
        builder: (context) => AddTransactionScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la transaction'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette transaction ?',
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
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionProvider.notifier).deleteTransaction(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction supprimée'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Transaction Details Bottom Sheet
class _TransactionDetailsSheet extends StatelessWidget {
  final Transaction transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (transaction.isIncome
                                ? AppColors.income
                                : AppColors.expense)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        transaction.isIncome
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.isIncome
                            ? AppColors.income
                            : AppColors.expense,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.category,
                            style: AppTypography.textTheme.titleLarge,
                          ),
                          Text(
                            transaction.date.toFormattedDateLong(),
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                _DetailRow(
                  label: 'Montant',
                  value: transaction.amount.toFormattedMoney(),
                  valueColor: transaction.isIncome
                      ? AppColors.income
                      : AppColors.expense,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Type',
                  value: transaction.isIncome ? 'Revenu' : 'Dépense',
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Date',
                  value: transaction.date.toFormattedDateLong(),
                ),
                if (transaction.description != null &&
                    transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Description',
                    value: transaction.description!,
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
