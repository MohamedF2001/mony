import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';

abstract class ReportRemoteDataSource {
  Future<Map<String, dynamic>> generateMonthlyReport(int month, int year);
  Future<Map<String, dynamic>> getMyReports();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> generateMonthlyReport(int month, int year) async {
    try {
      final response = await apiClient.dio.post('/api/reports/generate', queryParameters: {
        'month': month,
        'year': year,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la génération du rapport');
    }
  }

  @override
  Future<Map<String, dynamic>> getMyReports() async {
    try {
      final response = await apiClient.dio.get('/api/reports');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération des rapports');
    }
  }
}
