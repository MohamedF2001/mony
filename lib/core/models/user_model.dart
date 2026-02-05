/*
// lib/core/models/user_model.dart

import 'package:hive/hive.dart';
import '../entities/user.dart';
import '../../features/financial_profile/data/models/profile_model.dart';

part 'user_model.g.dart';

@HiveType(typeId: 14)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final FinancialProfileModel? financialProfile;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    this.financialProfile,
    required this.createdAt,
    this.updatedAt,
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
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      financialProfile: financialProfile?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}*/

import '../../features/financial_profile/data/models/profile_model.dart';
import '../entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final FinancialProfileModel? financialProfile;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    this.financialProfile,
    required this.createdAt,
    this.updatedAt,
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
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      financialProfile: financialProfile?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
