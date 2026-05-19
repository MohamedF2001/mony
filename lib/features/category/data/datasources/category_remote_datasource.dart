import '../../../../core/services/api_client.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiClient.dio.get('/api/categories');
    final items = response.data['data']['categories'] as List;
    return items
        .map((item) => CategoryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final response = await apiClient.dio.post('/api/categories', data: {
      'name': category.name,
      'type': category.type == 0 ? 'income' : 'expense',
      'color': '#${category.colorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
      'iconCodePoint': category.iconCodePoint,
      'isDefault': category.isDefault,
    });
    return CategoryModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['category'] as Map),
    );
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final response = await apiClient.dio.put('/api/categories/${category.id}', data: {
      'name': category.name,
      'type': category.type == 0 ? 'income' : 'expense',
      'color': '#${category.colorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
      'iconCodePoint': category.iconCodePoint,
      'isDefault': category.isDefault,
    });
    return CategoryModel.fromJson(
      Map<String, dynamic>.from(response.data['data']['category'] as Map),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await apiClient.dio.delete('/api/categories/$id');
  }
}
