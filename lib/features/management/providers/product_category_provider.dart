// lib/providers/product_category_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_kasir_cerdas_app/core/api/api_client.dart';

import '../../../models/product_category.dart';
import '../services/product_category_service.dart';

class ProductCategoryProvider with ChangeNotifier {
  final ProductCategoryService _categoryService;

  List<ProductCategory> _categories = [];
  List<ProductCategory> _parentCategories = []; // Tambahkan ini kembali
  Map<int, ProductCategory> _categoriesMap = {}; // Cache untuk lookup cepat
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMorePages = false;
  int _totalItems = 0;
  int _perPage = 15;

  ProductCategoryProvider({ProductCategoryService? categoryService})
      : _categoryService = categoryService ?? ProductCategoryService();

  // Getters
  List<ProductCategory> get categories => _categories;
  List<ProductCategory> get parentCategories => _parentCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _hasMorePages;
  int get totalItems => _totalItems;

  // Load categories with pagination
  Future<void> loadCategories({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _categories = [];
      _categoriesMap = {};
    }

    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      final result = await _categoryService.getCategories(page: _currentPage);

      final List<ProductCategory> newCategories = result['categories'];
      final Map<String, dynamic> pagination = result['pagination'];

      if (refresh) {
        _categories = newCategories;
      } else {
        _categories = [..._categories, ...newCategories];
      }

      // Update lookup cache
      for (var category in newCategories) {
        _categoriesMap[category.id] = category;
      }

      // Update pagination info
      _currentPage = pagination['current_page'] ?? _currentPage;
      _totalPages = pagination['last_page'] ?? _totalPages;
      _totalItems = pagination['total'] ?? _totalItems;
      _perPage = pagination['per_page'] ?? _perPage;
      _hasMorePages = pagination['has_more'] ?? false;

      if (_hasMorePages) {
        _currentPage++;
      }

      // Jika kita melakukan refresh, maka perbarui juga parent categories
      if (refresh) {
        await loadParentCategories();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Load parent categories - menambahkan kembali metode ini
  Future<void> loadParentCategories() async {
    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      // Pertama coba filter dari list yang sudah ada
      final mainCategories =
          _categories.where((c) => c.parentId == null).toList();

      // Jika sudah ada parent categories, gunakan saja
      if (mainCategories.isNotEmpty) {
        _parentCategories = mainCategories;
        notifyListeners();
        _setLoading(false);
        return;
      }

      // Jika belum ada, fetch dari API
      final result = await _categoryService.getCategories();
      final List<ProductCategory> allCategories = result['categories'];

      _parentCategories =
          allCategories.where((category) => category.parentId == null).toList();

      // Update cache juga
      for (var category in allCategories) {
        _categoriesMap[category.id] = category;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading parent categories: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Get category by ID - efisien dengan cache
  Future<ProductCategory?> getCategoryById(int id) async {
    // Cek cache terlebih dahulu
    if (_categoriesMap.containsKey(id)) {
      return _categoriesMap[id];
    }

    // Cek di list yang sudah di-load
    final cachedCategory = _categories.where((c) => c.id == id).firstOrNull;
    if (cachedCategory != null) {
      _categoriesMap[id] = cachedCategory;
      return cachedCategory;
    }

    // Jika tidak ada di cache, baru fetch dari API
    try {
      final category = await _categoryService.getCategoryById(id);
      if (category != null) {
        _categoriesMap[id] = category;
      }
      return category;
    } catch (e) {
      debugPrint('Error getting category by id: $e');
      return null;
    }
  }

  // Get parent category - dengan handling null safety yang baik
  Future<ProductCategory?> getParentCategory(int? parentId) async {
    if (parentId == null) return null;
    return await getCategoryById(parentId);
  }

  // Create a new category
  Future<bool> createCategory(ProductCategory category) async {
    _setLoading(true);
    _error = null;

    try {
      final newCategory = await _categoryService.createCategory(category);
      _categories.add(newCategory);
      _categoriesMap[newCategory.id] = newCategory;

      // Jika category baru adalah parent category, tambahkan ke list parent
      if (newCategory.parentId == null) {
        _parentCategories.add(newCategory);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating category: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(ProductCategory category) async {
    _setLoading(true);
    _error = null;

    try {
      // Get the original category from our cache to track changes
      ProductCategory? originalCategory;
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        originalCategory = _categories[index];
      } else {
        originalCategory = _categoriesMap[category.id];
      }

      // Always send both the original (for comparison) and the updated category
      final updatedCategory = await _categoryService.updateCategory(category,
          original: originalCategory);

      // Update in categories list
      if (index != -1) {
        _categories[index] = updatedCategory;
      } else {
        // If not found in main list but exists in map, we need to add it to the list
        if (_categoriesMap.containsKey(updatedCategory.id)) {
          _categories.add(updatedCategory);
        }
      }

      // Update in cache
      _categoriesMap[updatedCategory.id] = updatedCategory;

      // Update in parent categories list if applicable
      if (updatedCategory.parentId == null) {
        final parentIndex =
            _parentCategories.indexWhere((c) => c.id == updatedCategory.id);
        if (parentIndex != -1) {
          _parentCategories[parentIndex] = updatedCategory;
        } else {
          _parentCategories.add(updatedCategory);
        }
      } else {
        // Remove from parent categories if it's no longer a parent
        _parentCategories.removeWhere((c) => c.id == updatedCategory.id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 422) {
        // For validation errors, provide a more user-friendly message
        _error = "Validation Error: Please check your category data";

        // Extract specific field errors if available
        if (e.data != null && e.data!.containsKey('errors')) {
          final errors = e.data!['errors'];
          if (errors is Map<String, dynamic>) {
            final messages = <String>[];
            errors.forEach((field, fieldErrors) {
              if (fieldErrors is List) {
                messages.add(
                    '${_formatFieldName(field)}: ${fieldErrors.join(', ')}');
              } else if (fieldErrors is String) {
                messages.add('${_formatFieldName(field)}: $fieldErrors');
              }
            });
            if (messages.isNotEmpty) {
              _error = messages.join('\n');
            }
          }
        }
      } else {
        _error = e.toString();
      }

      debugPrint('Error updating category: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

// Helper method to format field names for error messages
  String _formatFieldName(String field) {
    // Convert snake_case or camelCase to Title Case with spaces
    return field
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  // Delete a category
  Future<bool> deleteCategory(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _categoryService.deleteCategory(id);

      if (success) {
        _categories.removeWhere((category) => category.id == id);
        _parentCategories.removeWhere((category) => category.id == id);
        _categoriesMap.remove(id);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting category: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
