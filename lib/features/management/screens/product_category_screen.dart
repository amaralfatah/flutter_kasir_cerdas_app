import 'package:flutter/material.dart';
import 'package:flutter_kasir_cerdas_app/models/product_category.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk'),
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
            return const Center(child: CircularProgressIndicator());
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
                      : _buildProductCategoryList(provider),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCreating = true;
            _isEditing = false;
            _selectedProductCategory = null;
          });
          _showProductCategoryForm(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
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
          // Implement debounce if needed for better performance
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
      ),
    );
  }

  Widget _buildErrorState(ProductCategoryProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${provider.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
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
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Tidak ada hasil pencarian'
                : 'Tidak ada kategori produk',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Coba kata kunci lain atau hapus filter'
                : 'Tambah kategori produk baru dengan menekan tombol + di bawah',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.outline.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
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

  Widget _buildProductCategoryList(ProductCategoryProvider provider) {
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

        final productCategory = provider.productCategories[index];
        return _buildProductCategoryItem(productCategory, provider);
      },
    );
  }

  Widget _buildProductCategoryItem(
      ProductCategory productCategory, ProductCategoryProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0, // Tanpa elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isCreating = false;
            _isEditing = true;
            _selectedProductCategory = productCategory;
          });
          _showProductCategoryForm(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: productCategory.isActive
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.category,
                color: productCategory.isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              productCategory.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: productCategory.parentId != null
                ? _buildParentInfo(productCategory, provider)
                : const Text('Kategori Utama'),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () => _confirmDelete(context, productCategory),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentInfo(
      ProductCategory productCategory, ProductCategoryProvider provider) {
    // First try to find the parent in the already loaded categories
    final parentInList = provider.productCategories
        .where((c) => c.id == productCategory.parentId)
        .firstOrNull;

    if (parentInList != null) {
      return Text('Parent: ${parentInList.name}');
    }

    // If not found, fetch it
    return FutureBuilder<ProductCategory?>(
      future: provider.getParentCategory(productCategory.parentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading parent...');
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Text('Parent: ${snapshot.data!.name}');
        }

        return Text('Parent ID: ${productCategory.parentId}');
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
              onSubmit: (productCategory) {
                Navigator.pop(context);
                if (_isCreating) {
                  Provider.of<ProductCategoryProvider>(context, listen: false)
                      .createCategory(productCategory);
                } else if (_isEditing && _selectedProductCategory != null) {
                  Provider.of<ProductCategoryProvider>(context, listen: false)
                      .updateCategory(productCategory);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ProductCategory productCategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori Produk'),
          content:
              Text('Yakin ingin menghapus kategori "${productCategory.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(context);
                Provider.of<ProductCategoryProvider>(context, listen: false)
                    .deleteCategory(productCategory.id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class ProductCategoryForm extends StatefulWidget {
  final bool isCreating;
  final bool isEditing;
  final ProductCategory? category;
  final Function(ProductCategory) onSubmit;

  const ProductCategoryForm({
    super.key,
    required this.isCreating,
    required this.isEditing,
    this.category,
    required this.onSubmit,
  });

  @override
  State<ProductCategoryForm> createState() => _ProductCategoryFormState();
}

class _ProductCategoryFormState extends State<ProductCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int? _parentId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _parentId = widget.category?.parentId;
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    if (widget.isCreating) return true;

    if (widget.category != null) {
      return _nameController.text != widget.category!.name ||
          _parentId != widget.category!.parentId ||
          _isActive != widget.category!.isActive;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isCreating
                  ? 'Tambah Kategori Produk'
                  : 'Edit Kategori Produk',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori Produk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kategori produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Consumer<ProductCategoryProvider>(
              builder: (context, provider, child) {
                // Prepare unique dropdown items
                final parentItems = [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tidak Ada'),
                  ),
                ];

                final addedIds = <int>{};
                for (var productCategory in provider.parentProductCategories) {
                  // Skip if category is itself or id already in list
                  if ((widget.category != null &&
                          productCategory.id == widget.category!.id) ||
                      addedIds.contains(productCategory.id)) {
                    continue;
                  }

                  addedIds.add(productCategory.id);
                  parentItems.add(
                    DropdownMenuItem<int?>(
                      value: productCategory.id,
                      child: Text(productCategory.name),
                    ),
                  );
                }

                // If parent_id not in valid list, still show it
                if (_parentId != null &&
                    !addedIds.contains(_parentId) &&
                    _parentId != 0) {
                  String parentName = 'Parent ID: $_parentId';
                  final parentInList = provider.productCategories
                      .where((c) => c.id == _parentId)
                      .firstOrNull;
                  if (parentInList != null) {
                    parentName = parentInList.name;
                  }

                  parentItems.add(
                    DropdownMenuItem<int?>(
                      value: _parentId,
                      child: Text(parentName),
                    ),
                  );
                }

                return DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori Induk (Opsional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  value: _parentId,
                  hint: const Text('Pilih Kategori Induk'),
                  items: parentItems,
                  onChanged: (value) {
                    setState(() {
                      _parentId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Status Aktif'),
              subtitle: Text(
                _isActive
                    ? 'Kategori produk aktif dan dapat digunakan'
                    : 'Kategori produk tidak aktif',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: Icon(
                _isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: _isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.isEditing && !_hasChanges())
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Anda belum melakukan perubahan pada kategori produk ini',
                  style: TextStyle(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final productCategory = ProductCategory(
                          id: widget.category?.id ?? 0,
                          name: _nameController.text.trim(),
                          parentId: _parentId,
                          isActive: _isActive,
                        );
                        widget.onSubmit(productCategory);
                      }
                    },
                    child: Text(widget.isCreating ? 'Tambah' : 'Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
