import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../models/answer_model.dart';
import '../models/profile_model.dart';

abstract class FinancialProfileRemoteDataSource {
  Future<FinancialProfileModel> saveProfile({
    required FinancialProfileModel profile,
    required List<AnswerModel> answers,
  });

  Future<FinancialProfileModel?> getSavedProfile();
}

class FinancialProfileRemoteDataSourceImpl
    implements FinancialProfileRemoteDataSource {
  final ApiClient apiClient;

  FinancialProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<FinancialProfileModel> saveProfile({
    required FinancialProfileModel profile,
    required List<AnswerModel> answers,
  }) async {
    try {
      final data = profile.toApiJson(
        answers: answers.map((answer) => answer.toJson()).toList(),
      );

      developer.log('Envoi du profil au serveur: $data', name: 'FinancialProfile');

      final response = await apiClient.dio.post(
        '/api/financial-profile',
        data: data,
      );

      if (response.data['success'] == true) {
        return FinancialProfileModel.fromJson(
          Map<String, dynamic>.from(response.data['data']['profile'] as Map),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Erreur lors de la sauvegarde');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      developer.log('Erreur Dio lors de la sauvegarde: $errorMessage', 
        name: 'FinancialProfile', 
        error: e.response?.data
      );
      throw Exception('Erreur serveur: $errorMessage');
    } catch (e) {
      developer.log('Erreur inconnue: $e', name: 'FinancialProfile');
      rethrow;
    }
  }

  @override
  Future<FinancialProfileModel?> getSavedProfile() async {
    try {
      final response = await apiClient.dio.get('/api/financial-profile');
      
      final profileData = response.data['data']?['profile'];
      if (profileData == null) return null;

      return FinancialProfileModel.fromJson(
        Map<String, dynamic>.from(profileData as Map),
      );
    } catch (e) {
      // On ne log pas l'erreur 404 car c'est un comportement attendu si pas de profil
      return null;
    }
  }
}
