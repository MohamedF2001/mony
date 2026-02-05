// lib/features/category/domain/entities/category.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../transaction/domain/entities/transaction.dart';

class Category extends Equatable {
  final String? id;
  final String name;
  final TransactionType type;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? name,
    TransactionType? type,
    IconData? icon,
    Color? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, type, icon, color, isDefault, createdAt];
}
