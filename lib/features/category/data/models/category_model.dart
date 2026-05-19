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
    // Gestion robuste de la couleur
    final rawColor = json['color'] ?? json['colorValue'];
    int finalColorValue = Colors.blue.value;
    
    if (rawColor is String && rawColor.startsWith('#')) {
      try {
        finalColorValue = int.parse(rawColor.replaceFirst('#', 'ff'), radix: 16);
      } catch (_) {}
    } else if (rawColor is num) {
      finalColorValue = rawColor.toInt();
    }

    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? 'Sans nom',
      type: json['type'] == 'income' ? 0 : 1,
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? Icons.category.codePoint,
      colorValue: finalColorValue,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
