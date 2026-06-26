import '../../../../core/entities/user.dart';
import '../../../academy/domain/entities/premium_content.dart';
import '../../../financial_profile/data/models/profile_model.dart';
import '../../../financial_profile/domain/entities/financial_profile.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_remote_datasource.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumRemoteDataSource remoteDataSource;

  PremiumRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> activatePremium(String type) async {
    final response = await remoteDataSource.activatePremium(type);
    final userData = response['data']['user'];
    
    // Extraire le profil financier s'il est présent dans la réponse
    FinancialProfile? financialProfile;
    if (userData['financialProfile'] != null && userData['financialProfile'] is Map) {
      financialProfile = FinancialProfileModel.fromJson(
        Map<String, dynamic>.from(userData['financialProfile']),
      ).toEntity();
    }
    
    return User(
      id: userData['_id'],
      name: '${userData['firstName']} ${userData['lastName']}',
      isPremium: userData['isPremium'] ?? false,
      subscriptionType: userData['subscriptionType'] ?? 'none',
      financialProfile: financialProfile, // On garde le profil !
      premiumUntil: userData['premiumUntil'] != null 
          ? DateTime.parse(userData['premiumUntil']) 
          : null,
      createdAt: DateTime.parse(userData['createdAt']),
    );
  }

  @override
  Future<List<PremiumContent>> getPremiumContents({String? type, String? category}) async {
    final response = await remoteDataSource.getPremiumContents(type: type, category: category);
    final List list = response['data']['contents'];
    
    return list.map((item) => PremiumContent(
      id: item['_id'],
      title: item['title'],
      description: item['description'],
      type: _parseContentType(item['type']),
      category: item['category'],
      url: item['url'],
      thumbnailUrl: item['thumbnailUrl'] ?? '',
      isPremium: item['isPremium'] ?? true,
      duration: item['duration'] ?? '',
    )).toList();
  }

  @override
  Future<List<PremiumContent>> getPdfs() async {
    final response = await remoteDataSource.getPdfs();
    final List list = response['data']['pdfs'];
    
    return list.map((item) => PremiumContent(
      id: item['_id'],
      title: item['title'],
      description: '',
      type: ContentType.ebook,
      category: 'Ebooks',
      url: item['pdfUrl'],
      thumbnailUrl: '',
      isPremium: true,
      duration: '',
    )).toList();
  }

  @override
  Future<PremiumContent> getPdfById(String id) async {
    final response = await remoteDataSource.getPdfById(id);
    final item = response['data']['pdf'];
    
    return PremiumContent(
      id: item['_id'],
      title: item['title'],
      description: '',
      type: ContentType.ebook,
      category: 'Ebooks',
      url: item['pdfUrl'],
      thumbnailUrl: '',
      isPremium: true,
      duration: '',
    );
  }

  @override
  Future<PremiumContent> getContentById(String id) async {
    final response = await remoteDataSource.getContentById(id);
    final item = response['data']['content'];
    
    return PremiumContent(
      id: item['_id'],
      title: item['title'],
      description: item['description'],
      type: _parseContentType(item['type']),
      category: item['category'],
      url: item['url'],
      thumbnailUrl: item['thumbnailUrl'] ?? '',
      isPremium: item['isPremium'] ?? true,
      duration: item['duration'] ?? '',
    );
  }

  ContentType _parseContentType(String type) {
    switch (type) {
      case 'ebook': return ContentType.ebook;
      case 'course': return ContentType.course;
      case 'template': return ContentType.template;
      default: return ContentType.ebook;
    }
  }
}
