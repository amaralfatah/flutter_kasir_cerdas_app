// lib/services/product_category_service.dart
import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/api_response.dart';
import '../../../models/product_category.dart';

class ProductCategoryService {
  final ApiClient _apiClient;

  ProductCategoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Fetch all categories with pagination
  Future<Map<String, dynamic>> getCategories({int page = 1}) async {
    try {
      final queryParams = {'page': page.toString()};
      final ApiResponse response = await _apiClient.get(
        ApiEndpoints.categories,
        queryParams: queryParams,
      );

      if (response.status && response.data != null) {
        final result = {
          'categories': <ProductCategory>[],
          'pagination': <String, dynamic>{},
        };

        // Process paginated data format from API response
        if (response.data['data'] != null) {
          final List<dynamic> categoriesData = response.data['data'];
          result['categories'] = categoriesData
              .map((json) => ProductCategory.fromJson(json))
              .toList();
        }

        // Extract pagination info
        result['pagination'] = {
          'current_page': response.data['current_page'] ?? 1,
          'last_page': response.data['last_page'] ?? 1,
          'total': response.data['total'] ?? 0,
          'per_page': response.data['per_page'] ?? 15,
          'has_more': response.data['next_page_url'] != null,
        };

        return result;
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
      final ApiResponse response =
          await _apiClient.get('${ApiEndpoints.categories}/$id');

      if (response.status && response.data != null) {
        return ProductCategory.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching category by id: $e');
      return null; // Return null instead of rethrowing for graceful error handling
    }
  }

  // Create a new category
  Future<ProductCategory> createCategory(ProductCategory category) async {
    try {
      final Map<String, dynamic> body = {
        'name': category.name,
        'parent_id': category.parentId,
        'is_active': category.isActive,
      };

      final ApiResponse response = await _apiClient.post(
        ApiEndpoints.categories,
        body: body,
      );

      if (response.status && response.data != null) {
        return ProductCategory.fromJson(response.data);
      } else {
        throw ApiException(
            message: 'Failed to create category: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error creating category: $e');
      rethrow;
    }
  }

  // Update an existing category
  Future<ProductCategory> updateCategory(ProductCategory category,
      {ProductCategory? original}) async {
    try {
      // First, get the current category data if original not provided
      ProductCategory? currentCategory = original;
      if (currentCategory == null) {
        try {
          currentCategory = await getCategoryById(category.id);
        } catch (e) {
          debugPrint('Error fetching original category: $e');
          // Continue even if we can't get the original
        }
      }

      // According to API docs, update requires _method=PUT
      // We must include all fields, not just changed ones
      final Map<String, dynamic> body = {
        'name': category.name,
        '_method': 'put',
        'is_active': category.isActive ? 1 : 0,
      };

      // Always include parent_id field (null or value)
      // This is crucial when only updating parent_id
      // Convert to string 'null' if it's null (API might expect this format)
      body['parent_id'] = category.parentId?.toString() ?? 'null';

      debugPrint('Update request body: $body');

      // Check what's changing (for debugging)
      if (currentCategory != null) {
        final changes = <String>[];
        if (currentCategory.name != category.name) changes.add('name');
        if (currentCategory.parentId != category.parentId) {
          changes.add('parent_id');
        }
        if (currentCategory.isActive != category.isActive) {
          changes.add('is_active');
        }

        debugPrint('Changing fields: ${changes.join(', ')}');
      }

      final ApiResponse response = await _apiClient.post(
        '${ApiEndpoints.categories}/${category.id}',
        body: body,
        isFormData: true, // Important for _method handling
      );

      if (response.status && response.data != null) {
        return ProductCategory.fromJson(response.data);
      } else {
        throw ApiException(
            message: 'Failed to update category: ${response.message}');
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 422) {
        // This is a validation error, provide more helpful information
        String validationErrors = '';
        if (e.data != null && e.data!.containsKey('errors')) {
          final errors = e.data!['errors'] as Map<String, dynamic>;
          errors.forEach((field, messages) {
            if (messages is List) {
              validationErrors += '$field: ${messages.join(', ')}\n';
            }
          });
        }
        throw ApiException(
            message:
                'Validation failed: ${validationErrors.isNotEmpty ? validationErrors : e.message}',
            statusCode: e.statusCode,
            data: e.data);
      }
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int id) async {
    try {
      final ApiResponse response =
          await _apiClient.delete('${ApiEndpoints.categories}/$id');
      return response.status;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }
}
