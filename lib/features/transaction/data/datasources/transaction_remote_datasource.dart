import '../../../../core/services/api_client.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<Map<String, double>> getStats();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final response = await apiClient.dio.get('/api/transactions', queryParameters: {
      'limit': 1000,
    });
    final items = response.data['data']['transactions'] as List;
    return items
        .map((item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final response = await apiClient.dio.post('/api/transactions', data: {
      'title': transaction.description?.isNotEmpty == true
          ? transaction.description
          : transaction.category,
      'amount': transaction.amount,
      'type': transaction.type == 0 ? 'income' : 'expense',
      'categoryName': transaction.category,
      'transactionDate': transaction.date.toIso8601String(),
      'description': transaction.description,
    });
    return TransactionModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['transaction'] as Map),
    );
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    final response = await apiClient.dio.put('/api/transactions/${transaction.id}', data: {
      'title': transaction.description?.isNotEmpty == true
          ? transaction.description
          : transaction.category,
      'amount': transaction.amount,
      'type': transaction.type == 0 ? 'income' : 'expense',
      'categoryName': transaction.category,
      'transactionDate': transaction.date.toIso8601String(),
      'description': transaction.description,
    });
    return TransactionModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['transaction'] as Map),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await apiClient.dio.delete('/api/transactions/$id');
  }

  @override
  Future<Map<String, double>> getStats() async {
    final response = await apiClient.dio.get('/api/transactions/stats');
    final data = response.data['data'] as Map;
    return {
      'income': (data['totalIncome'] as num? ?? 0).toDouble(),
      'expense': (data['totalExpense'] as num? ?? 0).toDouble(),
      'balance': (data['balance'] as num? ?? 0).toDouble(),
    };
  }
}
