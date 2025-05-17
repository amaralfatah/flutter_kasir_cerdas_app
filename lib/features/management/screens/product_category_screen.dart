import 'package:flutter/material.dart';
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
  ProductCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ProductCategoryProvider>(context, listen: false);
      provider.loadCategories(refresh: true);
      provider.loadParentCategories();
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
        provider.loadCategories();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              final provider =
                  Provider.of<ProductCategoryProvider>(context, listen: false);
              provider.loadCategories(refresh: true);
              provider.loadParentCategories();
            },
          ),
        ],
      ),
      body: Consumer<ProductCategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.categories.isEmpty) {
            return _buildErrorState(provider);
          }

          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadCategories(refresh: true);
                    await provider.loadParentCategories();
                  },
                  child: provider.categories.isEmpty
                      ? _buildEmptyState()
                      : _buildCategoryList(provider),
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
            _selectedCategory = null;
          });
          _showCategoryForm(context);
        },
        tooltip: 'Tambah Kategori',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Cari kategori...',
        leading: const Icon(Icons.search),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onChanged: (value) {
          // Implementasi pencarian di sini
        },
        trailing: _searchController.text.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    // Reset hasil pencarian di sini
                  },
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
              provider.loadCategories(refresh: true);
              provider.loadParentCategories();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada kategori',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah kategori baru dengan menekan tombol + di bawah',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.outline.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ProductCategoryProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: provider.categories.length + (provider.hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.categories.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final category = provider.categories[index];
        return _buildCategoryItem(category, provider);
      },
    );
  }

  Widget _buildCategoryItem(
      ProductCategory category, ProductCategoryProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isCreating = false;
            _isEditing = true;
            _selectedCategory = category;
          });
          _showCategoryForm(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.isActive
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.category,
                color: category.isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: category.parentId != null
                ? _buildParentInfo(category, provider)
                : const Text('Kategori Utama'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'Hapus',
                  onPressed: () => _confirmDelete(context, category),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentInfo(
      ProductCategory category, ProductCategoryProvider provider) {
    // Cari dari daftar kategori yang sudah dimuat
    final parentInList =
        provider.categories.where((c) => c.id == category.parentId).firstOrNull;

    if (parentInList != null) {
      return Text('Parent: ${parentInList.name}');
    }

    // Jika tidak ditemukan, lakukan fetch
    return FutureBuilder<ProductCategory?>(
      future: provider.getParentCategory(category.parentId),
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

        return Text('Parent ID: ${category.parentId}');
      },
    );
  }

  void _showCategoryForm(BuildContext context) {
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
            child: _CategoryForm(
              isCreating: _isCreating,
              isEditing: _isEditing,
              category: _selectedCategory,
              onSubmit: (category) {
                Navigator.pop(context);
                if (_isCreating) {
                  Provider.of<ProductCategoryProvider>(context, listen: false)
                      .createCategory(category);
                } else if (_isEditing && _selectedCategory != null) {
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
          title: const Text('Hapus Kategori'),
          content: Text('Yakin ingin menghapus kategori "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<ProductCategoryProvider>(context, listen: false)
                    .deleteCategory(category.id);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryForm extends StatefulWidget {
  final bool isCreating;
  final bool isEditing;
  final ProductCategory? category;
  final Function(ProductCategory) onSubmit;

  const _CategoryForm({
    required this.isCreating,
    required this.isEditing,
    this.category,
    required this.onSubmit,
  });

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int? _parentId;
  bool _isActive = true;
  ProductCategory? _originalCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _parentId = widget.category?.parentId;
    _isActive = widget.category?.isActive ?? true;
    _originalCategory = widget.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    // If creating a new category, always return true
    if (widget.isCreating) return true;

    // If editing, check if anything changed
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
              widget.isCreating ? 'Tambah Kategori' : 'Edit Kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Consumer<ProductCategoryProvider>(
              builder: (context, provider, child) {
                // Siapkan list unik yang tidak memiliki id duplikat
                final parentItems = [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tidak Ada'),
                  ),
                ];

                // Pastikan tidak ada id duplikat di dropdown items
                final addedIds = <int>{};
                for (var category in provider.parentCategories) {
                  // Skip jika category adalah dirinya sendiri atau id sudah ada dalam list
                  if ((widget.category != null &&
                          category.id == widget.category!.id) ||
                      addedIds.contains(category.id)) {
                    continue;
                  }

                  addedIds.add(category.id);
                  parentItems.add(
                    DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  );
                }

                // Jika _parentId tidak ada dalam list valid, masih tetap tampilkan
                // untuk memastikan bahwa user dapat mengubah parent saja
                if (_parentId != null &&
                    !addedIds.contains(_parentId) &&
                    _parentId != 0) {
                  // Tambahkan parent_id ke dropdown dengan nilai placeholder
                  // Coba dapatkan nama parent dari cache jika ada
                  String parentName = 'Parent ID: $_parentId';
                  final parentInMap = provider.categories
                      .where((c) => c.id == _parentId)
                      .firstOrNull;
                  if (parentInMap != null) {
                    parentName = parentInMap.name;
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
                    ? 'Kategori aktif dan dapat digunakan'
                    : 'Kategori tidak aktif',
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
                  'Anda belum melakukan perubahan pada kategori ini',
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
                        // Important: Always include parentId whether it's null or has value
                        final category = ProductCategory(
                          id: widget.category?.id ?? 0,
                          name: _nameController.text.trim(),
                          parentId: _parentId, // Always include, even if null
                          isActive: _isActive,
                        );

                        // Log what's changing for debugging
                        if (widget.isEditing && widget.category != null) {
                          final changes = <String>[];
                          if (widget.category!.name != category.name)
                            changes.add('name');
                          if (widget.category!.parentId != category.parentId)
                            changes.add('parent_id');
                          if (widget.category!.isActive != category.isActive)
                            changes.add('is_active');

                          debugPrint('Changing fields: ${changes.join(', ')}');
                        }

                        widget.onSubmit(category);
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
