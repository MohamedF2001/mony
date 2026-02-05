/*
// lib/features/category/data/models/category_model.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:poche/features/category/domain/entities/category.dart';
import 'package:poche/features/transaction/domain/entities/transaction.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int type; // 0 = income, 1 = expense

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final bool isDefault;

  @HiveField(6)
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
    required this.createdAt,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: category.name,
      type: category.type.index,
      iconCodePoint: category.icon.codePoint,
      colorValue: category.color.value,
      isDefault: category.isDefault,
      createdAt: category.createdAt,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      type: type == 0 ? TransactionType.income : TransactionType.expense,
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      color: Color(colorValue),
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type == 0 ? 'income' : 'expense',
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] == 'income' ? 0 : 1,
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Pour Hive, ajoutez ces méthodes si nécessaire
  CategoryModel copyWith({
    String? id,
    String? name,
    int? type,
    int? iconCodePoint,
    int? colorValue,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:mony/features/category/domain/entities/category.dart';
import 'package:mony/features/transaction/domain/entities/transaction.dart';

class CategoryModel {
  final String id;
  final String name;
  final int type; // 0 = income, 1 = expense
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
    required this.createdAt,
  });

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: category.name,
      type: category.type.index,
      iconCodePoint: category.icon.codePoint,
      colorValue: category.color.value,
      isDefault: category.isDefault,
      createdAt: category.createdAt,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      type: type == 0 ? TransactionType.income : TransactionType.expense,
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      color: Color(colorValue),
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type == 0 ? 'income' : 'expense',
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] == 'income' ? 0 : 1,
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    int? type,
    int? iconCodePoint,
    int? colorValue,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

