import '../../../../core/services/api_client.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<BudgetModel> addBudget(BudgetModel budget);
  Future<BudgetModel> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final ApiClient apiClient;

  BudgetRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final response = await apiClient.dio.get('/api/budgets');
    final items = response.data['data']['budgets'] as List;
    return items
        .map((item) => BudgetModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<BudgetModel> addBudget(BudgetModel budget) async {
    final response = await apiClient.dio.post('/api/budgets', data: {
      'category': budget.category, // Correction : clé 'category' attendue par le backend
      'amount': budget.amount,
      'period': budget.period == 0 ? 'monthly' : 'yearly',
      'startDate': budget.startDate.toIso8601String(),
      'endDate': budget.endDate?.toIso8601String(),
      'isActive': budget.isActive,
    });
    return BudgetModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['budget'] as Map),
    );
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    final response = await apiClient.dio.put('/api/budgets/${budget.id}', data: {
      'category': budget.category, // Correction : clé 'category' attendue par le backend
      'amount': budget.amount,
      'period': budget.period == 0 ? 'monthly' : 'yearly',
      'startDate': budget.startDate.toIso8601String(),
      'endDate': budget.endDate?.toIso8601String(),
      'isActive': budget.isActive,
    });
    return BudgetModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['budget'] as Map),
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    await apiClient.dio.delete('/api/budgets/$id');
  }
}
