// lib/features/product_categories/screens/product_category_screen.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:flutter_kasir_cerdas_app/features/product_categories/widgets/product_category_card.dart';
import 'package:flutter_kasir_cerdas_app/features/product_categories/widgets/product_category_form.dart';
import 'package:provider/provider.dart';

import '../../../models/product_category.dart';
import '../providers/product_category_provider.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isCreating = false;
  bool _isEditing = false;
  ProductCategory? _selectedProductCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ProductCategoryProvider>(context, listen: false);
      provider.loadProductCategories(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider =
          Provider.of<ProductCategoryProvider>(context, listen: false);
      if (provider.hasMorePages && !provider.isLoading) {
        provider.loadProductCategories();
      }
    }
  }

  // Method to handle search functionality
  void _handleSearch(String query) {
    final provider =
        Provider.of<ProductCategoryProvider>(context, listen: false);
    provider.searchProductCategories(query);
  }

  // Method to clear search
  void _clearSearch() {
    _searchController.clear();
    Provider.of<ProductCategoryProvider>(context, listen: false).resetFilters();
  }

  void _showCreateForm() {
    setState(() {
      _isCreating = true;
      _isEditing = false;
      _selectedProductCategory = null;
    });
    _showProductCategoryForm(context);
  }

  void _showEditForm(ProductCategory category) {
    setState(() {
      _isCreating = false;
      _isEditing = true;
      _selectedProductCategory = category;
    });
    _showProductCategoryForm(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ProductCategoryProvider>(context, listen: false)
                  .loadProductCategories(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer<ProductCategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.productCategories.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (provider.error != null && provider.productCategories.isEmpty) {
            return _buildErrorState(provider);
          }

          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadProductCategories(refresh: true);
                  },
                  child: provider.productCategories.isEmpty
                      ? _buildEmptyState()
                      : _buildCategoryList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateForm,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Cari kategori produk...',
        leading: const Icon(Icons.search),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onChanged: (value) {
          // Search happens as you type - original behavior
          _handleSearch(value);
        },
        trailing: _searchController.text.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ]
            : null,
        // MD3 styling
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHighest.withOpacity(0.3)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ProductCategoryProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error: ${provider.error}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              provider.loadProductCategories(refresh: true);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final provider =
        Provider.of<ProductCategoryProvider>(context, listen: false);
    final isSearching =
        provider.searchQuery != null && provider.searchQuery!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.category_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Tidak ada hasil pencarian'
                : 'Tidak ada kategori produk',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isSearching
                  ? 'Coba kata kunci lain atau hapus filter'
                  : 'Tambah kategori produk baru dengan menekan tombol + di bawah',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FilledButton.tonal(
                onPressed: _clearSearch,
                child: const Text('Hapus Pencarian'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final provider = Provider.of<ProductCategoryProvider>(context);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount:
          provider.productCategories.length + (provider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.productCategories.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final category = provider.productCategories[index];
        return ProductCategoryCard(
          category: category,
          onTap: () => _showEditForm(category),
          onDelete: () => _confirmDelete(context, category),
        );
      },
    );
  }

  void _showProductCategoryForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ProductCategoryForm(
              isCreating: _isCreating,
              isEditing: _isEditing,
              category: _selectedProductCategory,
              onSubmit: (category) {
                Navigator.pop(context);
                if (_isCreating) {
                  Provider.of<ProductCategoryProvider>(context, listen: false)
                      .createCategory(category);
                } else if (_isEditing && _selectedProductCategory != null) {
                  Provider.of<ProductCategoryProvider>(context, listen: false)
                      .updateCategory(category);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ProductCategory category) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori Produk'),
          content: Text('Yakin ingin menghapus kategori "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(context);
                Provider.of<ProductCategoryProvider>(context, listen: false)
                    .deleteCategory(category.id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
