// lib/features/products/providers/product_provider.dart
import 'package:flutter/foundation.dart';

import '../../../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  int? _filterCategoryId;
  bool? _filterIsActive;
  String _sortBy = 'name';
  String _sortDirection = 'asc';

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMorePages = false;
  final int _totalItems = 0;

  ProductProvider({ProductService? productService})
      : _productService = productService ?? ProductService();

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  int? get filterCategoryId => _filterCategoryId;
  bool? get filterIsActive => _filterIsActive;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _hasMorePages;
  int get totalItems => _totalItems;
  String get sortBy => _sortBy;
  String get sortDirection => _sortDirection;

  // Set search query and reload products
  Future<void> searchProducts(String query) async {
    _searchQuery = query.isNotEmpty ? query : null;
    await loadProducts(refresh: true);
  }

  // Filter products by category
  Future<void> filterByCategory(int? categoryId) async {
    _filterCategoryId = categoryId;
    await loadProducts(refresh: true);
  }

  // Filter products by active status
  Future<void> filterByActiveStatus(bool? isActive) async {
    _filterIsActive = isActive;
    await loadProducts(refresh: true);
  }

  // Reset all filters and search
  Future<void> resetFilters() async {
    _searchQuery = null;
    _filterCategoryId = null;
    _filterIsActive = null;
    _sortBy = 'name';
    _sortDirection = 'asc';
    await loadProducts(refresh: true);
  }

  // Sort products
  Future<void> sortProducts(
      {required String sortBy, String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadProducts(refresh: true);
  }

  // Load products with pagination
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
    }

    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final result = await _productService.getProducts(page: _currentPage);

      final List<Product> newProducts = result['products'];
      final Map<String, dynamic> pagination = result['pagination'];

      if (refresh) {
        _products = newProducts;
      } else {
        _products = [..._products, ...newProducts];
      }

      // Update pagination info
      _currentPage = pagination['current_page'];
      _totalPages = pagination['last_page'];
      _hasMorePages = pagination['has_more'];

      if (_hasMorePages) {
        _currentPage++;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading products: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get product by ID
  Future<Product?> getProductById(int id) async {
    // Check if product is already in the loaded list
    final cachedProduct = _products.where((p) => p.id == id).firstOrNull;
    if (cachedProduct != null) {
      return cachedProduct;
    }

    // If not in cache, fetch from API
    try {
      return await _productService.getProductById(id);
    } catch (e) {
      debugPrint('Error getting product by id: $e');
      return null;
    }
  }

  // Create a new product
  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    _error = null;

    try {
      final newProduct = await _productService.createProduct(product);
      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating product: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing product
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedProduct = await _productService.updateProduct(product);

      // Update in products list
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      } else {
        _products.add(updatedProduct);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating product: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a product
  Future<bool> deleteProduct(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _productService.deleteProduct(id);

      if (success) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting product: $_error');
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
