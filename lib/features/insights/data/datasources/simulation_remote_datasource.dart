import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';

abstract class SimulationRemoteDataSource {
  Future<Map<String, dynamic>> createSimulation(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getMySimulations();
  Future<Map<String, dynamic>> deleteSimulation(String id);
}

class SimulationRemoteDataSourceImpl implements SimulationRemoteDataSource {
  final ApiClient apiClient;

  SimulationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> createSimulation(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/api/simulations', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la création de la simulation');
    }
  }

  @override
  Future<Map<String, dynamic>> getMySimulations() async {
    try {
      final response = await apiClient.dio.get('/api/simulations');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération des simulations');
    }
  }

  @override
  Future<Map<String, dynamic>> deleteSimulation(String id) async {
    try {
      final response = await apiClient.dio.delete('/api/simulations/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la suppression de la simulation');
    }
  }
}
