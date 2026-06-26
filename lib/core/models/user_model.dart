import '../../features/financial_profile/data/models/profile_model.dart';
import '../entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final FinancialProfileModel? financialProfile;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPremium;
  final DateTime? premiumUntil;
  final String subscriptionType;

  UserModel({
    required this.id,
    required this.name,
    this.financialProfile,
    required this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.premiumUntil,
    this.subscriptionType = 'none',
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: user.name,
      financialProfile: user.financialProfile != null
          ? FinancialProfileModel.fromEntity(user.financialProfile!)
          : null,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isPremium: user.isPremium,
      premiumUntil: user.premiumUntil,
      subscriptionType: user.subscriptionType,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      financialProfile: financialProfile?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPremium: isPremium,
      premiumUntil: premiumUntil,
      subscriptionType: subscriptionType,
    );
  }
}
