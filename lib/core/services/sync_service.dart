import 'package:hive/hive.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/budget/data/models/budget_model.dart';
import '../../features/financial_profile/data/models/profile_model.dart';
import 'api_client.dart';

class SyncService {
  final ApiClient _apiClient;

  SyncService(this._apiClient);

  Future<void> syncLocalDataToApi() async {
    // 1. Sync Categories
    if (Hive.isBoxOpen('categories')) {
      final categoryBox = Hive.box<CategoryModel>('categories');
      final categories = categoryBox.values.toList();
      for (var category in categories) {
        try {
          await _apiClient.dio.post('/api/categories', data: {
            'name': category.name,
            'type': category.type == 0 ? 'income' : 'expense',
            'color': '#${category.colorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
          });
        } catch (e) {
          print('Error syncing category ${category.name}: $e');
        }
      }
      await categoryBox.clear();
    }

    // 2. Sync Transactions
    if (Hive.isBoxOpen('transactions')) {
      final transactionBox = Hive.box<TransactionModel>('transactions');
      final transactions = transactionBox.values.toList();
      for (var transaction in transactions) {
        try {
          await _apiClient.dio.post('/api/transactions', data: {
            'title': transaction.description ?? 'Transaction',
            'amount': transaction.amount,
            'type': transaction.type == 0 ? 'income' : 'expense',
            'categoryName': transaction.category,
            'transactionDate': transaction.date.toIso8601String(),
            'description': transaction.description,
          });
        } catch (e) {
          print('Error syncing transaction ${transaction.id}: $e');
        }
      }
      await transactionBox.clear();
    }

    // 3. Sync Budgets
    if (Hive.isBoxOpen('budgets')) {
      final budgetBox = Hive.box<BudgetModel>('budgets');
      final budgets = budgetBox.values.toList();
      for (var budget in budgets) {
        try {
          await _apiClient.dio.post('/api/budgets', data: {
            'categoryName': budget.category,
            'amount': budget.amount,
            'period': 'monthly',
            'startDate': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Error syncing budget for ${budget.category}: $e');
        }
      }
      await budgetBox.clear();
    }

    // 4. Sync Financial Profile
    if (Hive.isBoxOpen('financial_profiles')) {
      final profileBox = Hive.box<FinancialProfileModel>('financial_profiles');
      if (profileBox.isNotEmpty) {
        final profile = profileBox.values.first;
        try {
          // Send what we have, API will process
          await _apiClient.dio.post('/api/financial-profile/calculate', data: {
            'profileType': profile.profileTypeIndex,
          });
        } catch (e) {
          print('Error syncing financial profile: $e');
        }
      }
      await profileBox.clear();
    }

    // Clear storage
    if (Hive.isBoxOpen('storage')) {
      await Hive.box('storage').clear();
    }
  }
}
