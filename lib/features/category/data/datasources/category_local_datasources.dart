// lib/features/category/data/datasources/category_local_datasource.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> initializeDefaultCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box<CategoryModel> box;

  CategoryLocalDataSourceImpl(this.box);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      await box.put(category.id, category);
      return category;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la catégorie: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      await box.put(category.id, category);
      return category;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la catégorie: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la catégorie: $e');
    }
  }

  @override
  Future<void> initializeDefaultCategories() async {
    if (box.isNotEmpty) return;

    final defaultCategories = [
      // Income Categories
      CategoryModel(
        id: 'cat_income_salary',
        name: 'Salaire',
        type: 0,
        iconCodePoint: Icons.attach_money.codePoint,
        colorValue: AppColors.categoryColors[0].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_income_investment',
        name: 'Investissement',
        type: 0,
        iconCodePoint: Icons.trending_up.codePoint,
        colorValue: AppColors.categoryColors[1].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_income_freelance',
        name: 'Freelance',
        type: 0,
        iconCodePoint: Icons.work.codePoint,
        colorValue: AppColors.categoryColors[2].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),

      // Expense Categories
      CategoryModel(
        id: 'cat_expense_food',
        name: 'Alimentation',
        type: 1,
        iconCodePoint: Icons.restaurant.codePoint,
        colorValue: AppColors.categoryColors[3].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_expense_transport',
        name: 'Transport',
        type: 1,
        iconCodePoint: Icons.directions_car.codePoint,
        colorValue: AppColors.categoryColors[4].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_expense_shopping',
        name: 'Shopping',
        type: 1,
        iconCodePoint: Icons.shopping_bag.codePoint,
        colorValue: AppColors.categoryColors[5].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_expense_bills',
        name: 'Factures',
        type: 1,
        iconCodePoint: Icons.receipt_long.codePoint,
        colorValue: AppColors.categoryColors[6].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_expense_entertainment',
        name: 'Divertissement',
        type: 1,
        iconCodePoint: Icons.movie.codePoint,
        colorValue: AppColors.categoryColors[7].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_expense_health',
        name: 'Santé',
        type: 1,
        iconCodePoint: Icons.medical_services.codePoint,
        colorValue: AppColors.categoryColors[8].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_expense_education',
        name: 'Éducation',
        type: 1,
        iconCodePoint: Icons.school.codePoint,
        colorValue: AppColors.categoryColors[9].value,
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    ];

    for (var category in defaultCategories) {
      await box.put(category.id, category);
    }
  }
}
