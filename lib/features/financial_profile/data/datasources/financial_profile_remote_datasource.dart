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
    final response = await apiClient.dio.post(
      '/api/financial-profile/calculate',
      data: profile.toApiJson(
        answers: answers.map((answer) => answer.toJson()).toList(),
      ),
    );

    return FinancialProfileModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['profile'] as Map),
    );
  }

  @override
  Future<FinancialProfileModel?> getSavedProfile() async {
    try {
      final response = await apiClient.dio.get('/api/financial-profile');
      return FinancialProfileModel.fromJson(
        Map<String, dynamic>.from(response.data['data']['profile'] as Map),
      );
    } catch (_) {
      return null;
    }
  }
}
