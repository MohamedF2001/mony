import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/transaction_providers.dart';
import '../../domain/entities/transaction.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // SOLUTION 1: Utiliser un listener qui met à jour AVANT le changement de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;  // Changé: indexIsChanging au lieu de !indexIsChanging

      final notifier = ref.read(transactionProvider.notifier);
      switch (_tabController.index) {
        case 0:
          notifier.clearFilters();
          break;
        case 1:
          notifier.setTypeFilter(TransactionType.income);
          break;
        case 2:
          notifier.setTypeFilter(TransactionType.expense);
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showSearchScreen,
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.textTheme.labelLarge,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Revenus'),
            Tab(text: 'Dépenses'),
          ],
        ),
      ),
      body: transactionState.isLoading
          ? _buildLoadingWidget()
          : TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // SOLUTION 2: Désactiver le swipe
        children: [
          // SOLUTION 3: Utiliser directement filteredTransactions
          // Le filtrage est géré par le provider
          _buildTransactionList(filteredTransactions),
          _buildTransactionList(filteredTransactions),
          _buildTransactionList(filteredTransactions),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des transactions...',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune transaction',
        subtitle: 'Les transactions apparaîtront ici',
      );
    }

    final groupedTransactions = _groupTransactionsByDate(transactions);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final date = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date.toRelativeString(),
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _getDayTotal(dayTransactions).toFormattedMoney(),
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: _getDayTotal(dayTransactions) >= 0
                          ? AppColors.income
                          : AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            ...dayTransactions.map(
                  (transaction) => TransactionTile(
                transaction: transaction,
                onTap: () => _showTransactionDetails(transaction),
                onDelete: () => _deleteTransaction(transaction),
                onEdit: () => _editTransaction(transaction),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions,
      ) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    return grouped;
  }

  double _getDayTotal(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + (t.isIncome ? t.amount : -t.amount);
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterOptionsSheet(
        onApplyFilter: (startDate, endDate) {
          if (startDate != null && endDate != null) {
            ref.read(transactionProvider.notifier).setDateFilter(
              startDate,
              endDate,
            );
          }
        },
        onClearFilter: () {
          ref.read(transactionProvider.notifier).clearFilters();
          _tabController.animateTo(0);
        },
      ),
    );
  }

  void _showSearchScreen() {
    // Implement search functionality
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TransactionDetailsSheet(
        transaction: transaction,
        onEdit: () {
          Navigator.pop(context);
          _editTransaction(transaction);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTransaction(transaction);
        },
      ),
    );
  }

  void _editTransaction(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EditTransactionSheet(
        transaction: transaction,
        onSave: (updatedTransaction) async {
          final success = await ref
              .read(transactionProvider.notifier)
              .updateTransaction(updatedTransaction);

          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction modifiée avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la modification'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: const Text('Supprimer la transaction',
              style: TextStyle(fontSize: 18,),),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cette transaction ?',
              style: AppTypography.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.category,
                        style: AppTypography.textTheme.titleSmall,
                      ),
                      Text(
                        transaction.amount.toFormattedMoney(),
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: transaction.isIncome
                              ? AppColors.income
                              : AppColors.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.date.toFormattedDate(),
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cette action est irréversible.',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(transactionProvider.notifier)
                  .deleteTransaction(transaction.id!);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction supprimée avec succès'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la suppression'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Transaction Tile with Action Buttons
class _TransactionTileWithActions extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTileWithActions({
    required this.transaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmer la suppression'),
              content: const Text(
                  'Voulez-vous vraiment supprimer cette transaction ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Supprimer'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.white,
          size: 28,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: transaction.isIncome
                        ? AppColors.income.withOpacity(0.1)
                        : AppColors.expense.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    transaction.isIncome
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: transaction.isIncome
                        ? AppColors.income
                        : AppColors.expense,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.category,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (transaction.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 2),
                        Text(
                          transaction.description!,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction.amount.toFormattedMoney(),
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: transaction.isIncome
                            ? AppColors.income
                            : AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.date.toFormattedDate(),
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Action Button
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('Supprimer',
                              style: TextStyle(color: AppColors.error)),
                        ],
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
}

// Transaction Details Sheet
class _TransactionDetailsSheet extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionDetailsSheet({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
                children: [
                  // Icon and Amount
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: transaction.isIncome
                          ? AppColors.income.withOpacity(0.1)
                          : AppColors.expense.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction.isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.isIncome
                          ? AppColors.income
                          : AppColors.expense,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.amount.toFormattedMoney(),
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: transaction.isIncome
                          ? AppColors.income
                          : AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.isIncome ? 'Revenu' : 'Dépense',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Details
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Catégorie',
                    value: transaction.category,
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: transaction.date.toFormattedDate(),
                  ),
                  if (transaction.description?.isNotEmpty ?? false)
                    _DetailRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: transaction.description!,
                    ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Supprimer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// Edit Transaction Sheet
class _EditTransactionSheet extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction) onSave;

  const _EditTransactionSheet({
    required this.transaction,
    required this.onSave,
  });

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _categoryController =
        TextEditingController(text: widget.transaction.category);
    _descriptionController =
        TextEditingController(text: widget.transaction.description ?? '');
    _selectedDate = widget.transaction.date;
    _selectedType = widget.transaction.type;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Modifier la transaction',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              // Type Selection
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Revenu',
                      icon: Icons.arrow_downward,
                      isSelected: _selectedType == TransactionType.income,
                      color: AppColors.income,
                      onTap: () {
                        setState(() {
                          _selectedType = TransactionType.income;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TypeButton(
                      label: 'Dépense',
                      icon: Icons.arrow_upward,
                      isSelected: _selectedType == TransactionType.expense,
                      color: AppColors.expense,
                      onTap: () {
                        setState(() {
                          _selectedType = TransactionType.expense;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Category
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_selectedDate.toFormattedDate()),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optionnel)',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer les modifications'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une catégorie'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updatedTransaction = widget.transaction.copyWith(
      amount: amount,
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      date: _selectedDate,
      type: _selectedType,
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedTransaction);
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.background,
          border: Border.all(
            color: isSelected ? color : AppColors.textTertiary.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*// Filter Options Bottom Sheet (reste inchangé)
class _FilterOptionsSheet extends StatefulWidget {
  final Function(DateTime?, DateTime?) onApplyFilter;
  final VoidCallback onClearFilter;

  const _FilterOptionsSheet({
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  @override
  State<_FilterOptionsSheet> createState() => _FilterOptionsSheetState();
}*/

// Filter Options Sheet (kept from original)
class _FilterOptionsSheet extends StatefulWidget {
  final Function(DateTime?, DateTime?) onApplyFilter;
  final VoidCallback onClearFilter;

  const _FilterOptionsSheet({
    required this.onApplyFilter,
    required this.onClearFilter,
  });

  @override
  State<_FilterOptionsSheet> createState() => _FilterOptionsSheetState();
}

class _FilterOptionsSheetState extends State<_FilterOptionsSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
                  Text(
                    'Filtres',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Aujourd\'hui',
                        onTap: () => _setQuickFilter(0),
                      ),
                      _FilterChip(
                        label: 'Cette semaine',
                        onTap: () => _setQuickFilter(7),
                      ),
                      _FilterChip(
                        label: 'Ce mois',
                        onTap: () => _setQuickFilter(30),
                      ),
                      _FilterChip(
                        label: 'Cette année',
                        onTap: () => _setQuickFilter(365),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Période personnalisée',
                    style: AppTypography.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Date début',
                          date: _startDate,
                          onTap: () => _selectDate(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DateButton(
                          label: 'Date fin',
                          date: _endDate,
                          onTap: () => _selectDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onClearFilter();
                            Navigator.pop(context);
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onApplyFilter(_startDate, _endDate);
                            Navigator.pop(context);
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setQuickFilter(int days) {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(Duration(days: days));
      _endDate = now;
    });
    widget.onApplyFilter(_startDate, _endDate);
    Navigator.pop(context);
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}

/*class _FilterOptionsSheetState extends State<_FilterOptionsSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
                  Text(
                    'Filtres',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Aujourd\'hui',
                        onTap: () => _setQuickFilter(0),
                      ),
                      _FilterChip(
                        label: 'Cette semaine',
                        onTap: () => _setQuickFilter(7),
                      ),
                      _FilterChip(
                        label: 'Ce mois',
                        onTap: () => _setQuickFilter(30),
                      ),
                      _FilterChip(
                        label: 'Cette année',
                        onTap: () => _setQuickFilter(365),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Période personnalisée',
                    style: AppTypography.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DateButton(
                          label: 'Date début',
                          date: _startDate,
                          onTap: () => _selectDate(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DateButton(
                          label: 'Date fin',
                          date: _endDate,
                          onTap: () => _selectDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onClearFilter();
                            Navigator.pop(context);
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onApplyFilter(_startDate, _endDate);
                            Navigator.pop(context);
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setQuickFilter(int days) {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(Duration(days: days));
      _endDate = now;
    });
    widget.onApplyFilter(_startDate, _endDate);
    Navigator.pop(context);
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}*/

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.primary,
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        date != null ? date!.toFormattedDate() : label,
        style: AppTypography.textTheme.labelMedium,
      ),
    );
  }
}