// lib/features/management/screens/management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_kasir_cerdas_app/features/product_categories/screens/product_category_screen.dart';
import 'package:flutter_kasir_cerdas_app/features/products/screens/product_screen.dart';
import 'package:flutter_kasir_cerdas_app/widgets/app_drawer.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  // Definisikan menu items langsung di dalam class
  final List<ManagementMenuItem> _menuItems = const [
    ManagementMenuItem(
      title: 'Product or Service',
      icon: Icons.inventory,
      route: 'product',
    ),
    ManagementMenuItem(
      title: 'Product Category',
      icon: Icons.category,
      route: 'product_category',
    ),
    ManagementMenuItem(
      title: 'Stock Management',
      icon: Icons.warehouse,
      route: 'stock',
    ),
    ManagementMenuItem(
      title: 'Customer',
      icon: Icons.people,
      route: 'customer',
    ),
    ManagementMenuItem(
      title: 'Credit',
      icon: Icons.credit_card,
      route: 'credit',
    ),
    ManagementMenuItem(
      title: 'Purchase of Goods',
      icon: Icons.shopping_cart,
      route: 'purchase',
    ),
    ManagementMenuItem(
      title: 'Discounts, Taxes and Fees',
      icon: Icons.savings,
      route: 'discounts',
    ),
    ManagementMenuItem(
      title: 'Stock Opname',
      icon: Icons.list_alt,
      route: 'stock_opname',
    ),
    ManagementMenuItem(
      title: 'Supplier',
      icon: Icons.local_shipping,
      route: 'supplier',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Management'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      drawer: const AppDrawer(currentPage: 'management'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional section title
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'Menu Manajemen',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildManagementGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildManagementCard(context, item.title, item.icon,
            () => _handleMenuItemTap(context, item.route));
      },
    );
  }

  Widget _buildManagementCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    const borderRadius = 16.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, String route) {
    // Navigate based on route identifier
    switch (route) {
      case 'product':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductScreen()),
        );
        break;
      case 'product_category':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ProductCategoryScreen()),
        );
        break;
      default:
        // For unimplemented menu items
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$route not implemented yet'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
    }
  }
}

// Class untuk menu item
class ManagementMenuItem {
  final String title;
  final IconData icon;
  final String route;

  const ManagementMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}
