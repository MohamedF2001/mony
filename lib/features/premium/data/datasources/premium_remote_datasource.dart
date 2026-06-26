import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';

abstract class PremiumRemoteDataSource {
  Future<Map<String, dynamic>> activatePremium(String type);
  Future<Map<String, dynamic>> getPremiumContents({String? type, String? category});
  Future<Map<String, dynamic>> getPdfs();
  Future<Map<String, dynamic>> getPdfById(String id);
  Future<Map<String, dynamic>> getContentById(String id);
}

class PremiumRemoteDataSourceImpl implements PremiumRemoteDataSource {
  final ApiClient apiClient;

  PremiumRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> activatePremium(String type) async {
    try {
      final response = await apiClient.dio.post('/api/premium/activate', data: {
        'type': type,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'activation Premium');
    }
  }

  @override
  Future<Map<String, dynamic>> getPremiumContents({String? type, String? category}) async {
    try {
      final response = await apiClient.dio.get('/api/premium/contents', queryParameters: {
        if (type != null) 'type': type,
        if (category != null) 'category': category,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération du contenu');
    }
  }

  @override
  Future<Map<String, dynamic>> getPdfs() async {
    try {
      final response = await apiClient.dio.get('/api/pdfs');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération des PDFs');
    }
  }

  @override
  Future<Map<String, dynamic>> getPdfById(String id) async {
    try {
      final response = await apiClient.dio.get('/api/pdfs/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération du PDF');
    }
  }

  @override
  Future<Map<String, dynamic>> getContentById(String id) async {
    try {
      final response = await apiClient.dio.get('/api/premium/contents/$id');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la récupération du détail');
    }
  }
}
