// lib/features/product_categories/widgets/category_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product_category.dart';
import '../providers/product_category_provider.dart';

class ProductCategoryCard extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProductCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get initials for avatar
    String initials = category.name.isNotEmpty
        ? category.name.substring(0, min(2, category.name.length)).toUpperCase()
        : '?';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left: Category initial/avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: category.isActive
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Middle: Category name and parent info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildParentInfo(context, category),
                  ],
                ),
              ),

              // Right: Status badge and delete button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Delete button
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            colorScheme.errorContainer.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentInfo(BuildContext context, ProductCategory category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider =
        Provider.of<ProductCategoryProvider>(context, listen: false);

    if (category.parentId == null) {
      return Text(
        'Kategori Utama',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    // First try to find the parent in the already loaded categories
    final parentInList = provider.productCategories
        .where((c) => c.id == category.parentId)
        .firstOrNull;

    if (parentInList != null) {
      return Text(
        'Parent: ${parentInList.name}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // If not found, fetch it
    return FutureBuilder<ProductCategory?>(
      future: provider.getParentCategory(category.parentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading parent...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            'Parent: ${snapshot.data!.name}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return Text(
          'Parent ID: ${category.parentId}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }

  // Helper to get minimum of two values
  int min(int a, int b) => a < b ? a : b;
}
