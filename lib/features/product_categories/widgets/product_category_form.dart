// lib/features/product_categories/widgets/category_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product_category.dart';
import '../providers/product_category_provider.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Header with drag handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.isCreating
                  ? 'Tambah Kategori Produk'
                  : 'Edit Kategori Produk',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_outlined),
                floatingLabelStyle: TextStyle(color: colorScheme.primary),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama kategori produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Parent Category Dropdown
            Consumer<ProductCategoryProvider>(
              builder: (context, provider, child) {
                // Prepare unique dropdown items
                final parentItems = [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tidak Ada (Kategori Utama)'),
                  ),
                ];

                final addedIds = <int>{};
                for (var category in provider.parentProductCategories) {
                  // Skip if category is itself or id already in list
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
                  decoration: InputDecoration(
                    labelText: 'Kategori Induk',
                    hintText: 'Pilih Kategori Induk',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.account_tree_outlined),
                    floatingLabelStyle: TextStyle(color: colorScheme.primary),
                  ),
                  value: _parentId,
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

            // Active Status Switch
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Status Aktif'),
                subtitle: Text(
                  _isActive
                      ? 'Kategori produk aktif dan dapat digunakan'
                      : 'Kategori produk tidak aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: _isActive ? colorScheme.primary : colorScheme.error,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Warning if no changes detected
            if (widget.isEditing && !_hasChanges())
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  'Anda belum melakukan perubahan pada kategori produk ini',
                  style: TextStyle(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _hasChanges()
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              final category = ProductCategory(
                                id: widget.category?.id ?? 0,
                                name: _nameController.text.trim(),
                                parentId: _parentId,
                                isActive: _isActive,
                              );
                              widget.onSubmit(category);
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
