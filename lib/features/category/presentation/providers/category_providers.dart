// lib/features/category/presentation/providers/category_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mony/features/category/data/datasources/category_local_datasources.dart';
import 'package:mony/features/category/data/repositoires/category_repositpry_impl.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../data/models/category_model.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';

// Data Source Provider
final categoryBoxProvider = Provider<Box<CategoryModel>>((ref) {
  return Hive.box<CategoryModel>('categories');
});

final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  final box = ref.watch(categoryBoxProvider);
  return CategoryLocalDataSourceImpl(box);
});

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

// Use Cases Providers
final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategories(repository);
});

final getCategoriesByTypeUseCaseProvider = Provider<GetCategoriesByType>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesByType(repository);
});

final addCategoryUseCaseProvider = Provider<AddCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return AddCategory(repository);
});

final updateCategoryUseCaseProvider = Provider<UpdateCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return UpdateCategory(repository);
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategory>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return DeleteCategory(repository);
});

// State Management
class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// Category Notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  final GetCategories getCategoriesUseCase;
  final AddCategory addCategoryUseCase;
  final UpdateCategory updateCategoryUseCase;
  final DeleteCategory deleteCategoryUseCase;
  final CategoryRepository repository;

  CategoryNotifier({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.repository,
  }) : super(const CategoryState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize default categories if needed
    await repository.initializeDefaultCategories();
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getCategoriesUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (categories) {
        state = state.copyWith(
          categories: categories,
          isLoading: false,
        );
      },
    );
  }

  Future<bool> addCategory(Category category) async {
    final result = await addCategoryUseCase(category);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (addedCategory) {
        final updatedList = [...state.categories, addedCategory];
        state = state.copyWith(categories: updatedList);
        return true;
      },
    );
  }

  Future<bool> updateCategory(Category category) async {
    final result = await updateCategoryUseCase(category);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedCategory) {
        final updatedList = state.categories.map((c) {
          return c.id == updatedCategory.id ? updatedCategory : c;
        }).toList();
        state = state.copyWith(categories: updatedList);
        return true;
      },
    );
  }

  Future<bool> deleteCategory(String id) async {
    final result = await deleteCategoryUseCase(id);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedList = state.categories.where((c) => c.id != id).toList();
        state = state.copyWith(categories: updatedList);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Category Provider
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(
    getCategoriesUseCase: ref.watch(getCategoriesUseCaseProvider),
    addCategoryUseCase: ref.watch(addCategoryUseCaseProvider),
    updateCategoryUseCase: ref.watch(updateCategoryUseCaseProvider),
    deleteCategoryUseCase: ref.watch(deleteCategoryUseCaseProvider),
    repository: ref.watch(categoryRepositoryProvider),
  );
});

// Computed Providers
final categoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final state = ref.watch(categoryProvider);

  if (state.isLoading) {
    return const AsyncValue.loading();
  }

  if (state.errorMessage != null) {
    return AsyncValue.error(state.errorMessage!, StackTrace.current);
  }

  return AsyncValue.data(state.categories);
});

final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoryProvider);
  return state.categories
      .where((c) => c.type == TransactionType.income)
      .toList();
});

final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final state = ref.watch(categoryProvider);
  return state.categories
      .where((c) => c.type == TransactionType.expense)
      .toList();
});
