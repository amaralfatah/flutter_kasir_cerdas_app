// lib/features/products/screens/product_screen.dart - Fixed redundant search
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    // Load products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .loadProducts(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Filter options would go here'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Product'),
        centerTitle: true,
        leading: BackButton(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
            },
            color: colorScheme.onSurface,
          ),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surface,
            child: SearchBar(
              controller: _searchController,
              leading: Icon(
                _isSearchActive ? Icons.arrow_back : Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              hintText: 'Find name or code of product',
              trailing: [
                if (_isSearchActive && _searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      // Reset search results
                      final provider =
                          Provider.of<ProductProvider>(context, listen: false);
                      provider.searchProducts('');
                    },
                    tooltip: 'Clear',
                  ),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _showFilterBottomSheet,
                  tooltip: 'Filter',
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    // Show sort options
                  },
                  tooltip: 'Sort',
                ),
              ],
              onTap: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
              onSubmitted: (value) {
                // Process search
                final provider =
                    Provider.of<ProductProvider>(context, listen: false);
                provider.searchProducts(value);
              },
              onChanged: (value) {
                // For real-time filtering if desired
                if (value.isEmpty && _isSearchActive) {
                  final provider =
                      Provider.of<ProductProvider>(context, listen: false);
                  provider.searchProducts('');
                }
              },
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                  colorScheme.surfaceContainerHighest.withOpacity(0.3)),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              side: const WidgetStatePropertyAll(BorderSide.none),
            ),
          ),

          // Product list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                if (provider.error != null && provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => provider.loadProducts(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        // Navigate to product detail
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        child: const Icon(Icons.add),
      ),
    );
  }
}
