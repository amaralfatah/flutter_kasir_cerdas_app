// lib/providers/product_category_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_kasir_cerdas_app/models/product_category.dart';
import '../services/product_category_service.dart';

class ProductCategoryProvider with ChangeNotifier {
  final ProductCategoryService _categoryService;

  List<ProductCategory> _categories = [];
  List<ProductCategory> _parentCategories = [];
  Map<int, ProductCategory> _categoriesMap = {}; // Cache for quick lookups
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  int? _filterParentId;
  bool? _filterIsActive;
  bool _rootOnly = false;
  String _sortBy = 'name';
  String _sortDirection = 'asc';
  
  // Adding the missing pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMorePages = false;
  int _totalItems = 0;

  ProductCategoryProvider({ProductCategoryService? categoryService})
      : _categoryService = categoryService ?? ProductCategoryService();

  // Getters
  List<ProductCategory> get productCategories => _categories;
  List<ProductCategory> get parentProductCategories => _parentCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _hasMorePages;
  int get totalItems => _totalItems;

  // Set search query and reload categories
  Future<void> searchProductCategories(String query) async {
    _searchQuery = query.isNotEmpty ? query : null;
    await loadProductCategories(refresh: true);
  }

  // Reset all filters and search
  Future<void> resetFilters() async {
    _searchQuery = null;
    _filterParentId = null;
    _filterIsActive = null;
    _rootOnly = false;
    _sortBy = 'name';
    _sortDirection = 'asc';
    await loadProductCategories(refresh: true);
  }

  // Load categories with pagination
  Future<void> loadProductCategories({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _categories = [];
      _categoriesMap = {};
    }

    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      final result = await _categoryService.getCategories(
        page: _currentPage,
        search: _searchQuery,
        parentId: _filterParentId,
        isActive: _filterIsActive,
        rootOnly: _rootOnly,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

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
      _hasMorePages = pagination['has_more'] ?? false;

      if (_hasMorePages) {
        _currentPage++;
      }

      // If refreshing, also update parent categories
      if (refresh) {
        await loadParentProductCategories();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Load parent categories
  Future<void> loadParentProductCategories() async {
    if (_isLoading) return;

    try {
      // First try filtering from the existing list
      final mainCategories = _categories.where((c) => c.parentId == null).toList();

      // If we already have parent categories, use them
      if (mainCategories.isNotEmpty) {
        _parentCategories = mainCategories;
        notifyListeners();
        return;
      }

      // If we don't have any, fetch from the API
      _setLoading(true);
      final result = await _categoryService.getCategories(rootOnly: true);
      final List<ProductCategory> allCategories = result['categories'];

      _parentCategories = allCategories.where((c) => c.parentId == null).toList();

      // Update cache
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

  // Get category by ID (efficiently using cache)
  Future<ProductCategory?> getCategoryById(int id) async {
    // Check cache first
    if (_categoriesMap.containsKey(id)) {
      return _categoriesMap[id];
    }

    // Check loaded list
    final cachedCategory = _categories.where((c) => c.id == id).firstOrNull;
    if (cachedCategory != null) {
      _categoriesMap[id] = cachedCategory;
      return cachedCategory;
    }

    // If not in cache, fetch from API
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

  // Get parent category
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

      // If the new category is a parent category, add it to the parent list
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

  // Update an existing category
  Future<bool> updateCategory(ProductCategory category) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedCategory = await _categoryService.updateCategory(category);

      // Update in categories list
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      } else {
        _categories.add(updatedCategory);
      }

      // Update in cache
      _categoriesMap[updatedCategory.id] = updatedCategory;

      // Update in parent categories if applicable
      if (updatedCategory.parentId == null) {
        final parentIndex = _parentCategories.indexWhere((c) => c.id == updatedCategory.id);
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
      _error = e.toString();
      debugPrint('Error updating category: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _categoryService.deleteCategory(id);

      if (success) {
        _categories.removeWhere((c) => c.id == id);
        _parentCategories.removeWhere((c) => c.id == id);
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