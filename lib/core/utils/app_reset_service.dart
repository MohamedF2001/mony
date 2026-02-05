import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/budget/data/models/budget_model.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/transaction/data/models/transaction_model.dart';

class AppResetService {
  Future<void> resetAll() async {
    await Hive.box<TransactionModel>('transactions').clear();
    await Hive.box<CategoryModel>('categories').clear();
    await Hive.box<BudgetModel>('budgets').clear();
    await Hive.box('storage').clear();

    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

