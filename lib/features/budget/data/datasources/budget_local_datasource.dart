// lib/features/budget/data/datasources/budget_local_datasource.dart

import 'package:hive/hive.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets(); 
  Future<BudgetModel> addBudget(BudgetModel budget);
  Future<BudgetModel> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Box<BudgetModel> box;

  BudgetLocalDataSourceImpl(this.box);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des budgets: $e');
    }
  }

  @override
  Future<BudgetModel> addBudget(BudgetModel budget) async {
    try {
      await box.put(budget.id, budget);
      return budget;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du budget: $e');
    }
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    try {
      await box.put(budget.id, budget);
      return budget;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du budget: $e');
    }
  }
}
