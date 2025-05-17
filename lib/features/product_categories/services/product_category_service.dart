// lib/services/product_category_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_kasir_cerdas_app/core/api/api_client.dart';
import 'package:flutter_kasir_cerdas_app/core/api/api_endpoints.dart';
import 'package:flutter_kasir_cerdas_app/models/product_category.dart';

class ProductCategoryService {
  final ApiClient _apiClient;

  ProductCategoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Fetch all categories with pagination and search
  Future<Map<String, dynamic>> getCategories({
    int page = 1,
    String? search,
    int? parentId,
    bool? isActive,
    bool rootOnly = false,
    String sortBy = 'name',
    String sortDirection = 'asc',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
      };
      
      // Add optional parameters if provided
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (parentId != null) {
        queryParams['parent_id'] = parentId.toString();
      }
      
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }
      
      if (rootOnly) {
        queryParams['root_only'] = 'true';
      }
      
      queryParams['sort_by'] = sortBy;
      queryParams['sort_direction'] = sortDirection;
      
      final response = await _apiClient.get(
        ApiEndpoints.categories,
        queryParams: queryParams,
      );

      if (response.status && response.data != null) {
        return {
          'categories': (response.data['data'] as List<dynamic>)
              .map((json) => ProductCategory.fromJson(json))
              .toList(),
          'pagination': {
            'current_page': response.data['current_page'] ?? 1,
            'last_page': response.data['last_page'] ?? 1,
            'total': response.data['total'] ?? 0,
            'per_page': response.data['per_page'] ?? 15,
            'has_more': response.data['next_page_url'] != null,
          },
        };
      }

      return {'categories': <ProductCategory>[], 'pagination': {}};
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  // Get category by ID
  Future<ProductCategory?> getCategoryById(int id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.categories}/$id');
      
      if (response.status && response.data != null) {
        return ProductCategory.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching category by id: $e');
      return null;
    }
  }

  // Create a new category
  Future<ProductCategory> createCategory(ProductCategory category) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.categories,
        body: {
          'name': category.name,
          'parent_id': category.parentId,
          'is_active': category.isActive,
        },
      );

      if (response.status && response.data != null) {
        return ProductCategory.fromJson(response.data);
      } else {
        throw ApiException(message: 'Failed to create category: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error creating category: $e');
      rethrow;
    }
  }

  // Update an existing category
  Future<ProductCategory> updateCategory(ProductCategory category) async {
    try {
      final body = {
        'name': category.name,
        '_method': 'put',
        'is_active': category.isActive ? 1 : 0,
        'parent_id': category.parentId?.toString() ?? 'null',
      };

      final response = await _apiClient.post(
        '${ApiEndpoints.categories}/${category.id}',
        body: body,
        isFormData: true,
      );

      if (response.status && response.data != null) {
        return ProductCategory.fromJson(response.data);
      } else {
        throw ApiException(message: 'Failed to update category: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.categories}/$id');
      return response.status;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }
}