import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../models/product.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Get all products with pagination and filters
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
    bool? isActive,
    String sortBy = 'name',
    String sortDirection = 'asc',
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (isActive != null) {
        queryParams['is_active'] = isActive ? '1' : '0';
      }

      queryParams['sort_by'] = sortBy;
      queryParams['sort_direction'] = sortDirection;

      // Make API request
      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParams: queryParams,
      );

      // Parse the response
      final responseData = response.data;
      final List<Product> products = [];

      // The products are in responseData['data']
      if (responseData != null && responseData['data'] != null) {
        for (var item in responseData['data']) {
          try {
            products.add(Product.fromJson(item));
          } catch (e) {
            debugPrint('Error parsing product: $e');
            // Skip products that fail to parse
          }
        }
      }

      // Extract pagination information
      final pagination = {
        'current_page': responseData?['current_page'] ?? page,
        'last_page': responseData?['last_page'] ?? 1,
        'total': responseData?['total'] ?? products.length,
        'per_page': responseData?['per_page'] ?? 10,
        'has_more': responseData != null &&
            (responseData['current_page'] < responseData['last_page']),
      };

      return {
        'products': products,
        'pagination': pagination,
      };
    } catch (e) {
      debugPrint('Error getting products: $e');
      return {
        'products': <Product>[],
        'pagination': {
          'current_page': page,
          'last_page': 1,
          'total': 0,
          'per_page': 10,
          'has_more': false,
        },
      };
    }
  }

  // Get a single product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.products}/$id');

      if (response.status && response.data != null) {
        return Product.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting product by ID: $e');
      rethrow;
    }
  }

  // Create a new product
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.products,
        body: product.toJson(),
      );

      if (response.status && response.data != null) {
        return Product.fromJson(response.data);
      }

      throw Exception('Failed to create product: ${response.message}');
    } catch (e) {
      debugPrint('Error creating product: $e');
      rethrow;
    }
  }

  // Update an existing product
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.products}/${product.id}',
        body: product.toJson(),
      );

      if (response.status && response.data != null) {
        return Product.fromJson(response.data);
      }

      throw Exception('Failed to update product: ${response.message}');
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.products}/$id');
      return response.status;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }
}
