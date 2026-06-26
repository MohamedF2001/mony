import '../../../../core/entities/user.dart';
import '../../../academy/domain/entities/premium_content.dart';

abstract class PremiumRepository {
  Future<User> activatePremium(String type);
  Future<List<PremiumContent>> getPremiumContents({String? type, String? category});
  Future<List<PremiumContent>> getPdfs();
  Future<PremiumContent> getPdfById(String id);
  Future<PremiumContent> getContentById(String id);
}
