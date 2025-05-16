import 'package:flutter/material.dart';
import 'package:flutter_kasir_cerdas_app/widgets/app_drawer.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2, // Material 3 scrolled elevation
      ),
      drawer: const AppDrawer(currentPage: 'management'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Removed the redundant "Management" title here
                _buildManagementGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final List<ManagementMenuItem> menuItems = [
      ManagementMenuItem(
        title: 'Product or Service',
        icon: Icons.inventory,
        onTap: () {
          _handleMenuItemTap(context, 'Product or Service');
        },
      ),
      ManagementMenuItem(
        title: 'Product Category',
        icon: Icons.category,
        onTap: () {
          _handleMenuItemTap(context, 'Product Category');
        },
      ),
      ManagementMenuItem(
        title: 'Stock Management',
        icon: Icons.warehouse,
        onTap: () {
          _handleMenuItemTap(context, 'Stock Management');
        },
      ),
      ManagementMenuItem(
        title: 'Customer',
        icon: Icons.people,
        onTap: () {
          _handleMenuItemTap(context, 'Customer');
        },
      ),
      ManagementMenuItem(
        title: 'Credit',
        icon: Icons.credit_card,
        onTap: () {
          _handleMenuItemTap(context, 'Credit');
        },
      ),
      ManagementMenuItem(
        title: 'Purchase of Goods',
        icon: Icons.shopping_cart,
        onTap: () {
          _handleMenuItemTap(context, 'Purchase of Goods');
        },
      ),
      ManagementMenuItem(
        title: 'Discounts, Taxes and Fees',
        icon: Icons.savings,
        onTap: () {
          _handleMenuItemTap(context, 'Discounts, Taxes and Fees');
        },
      ),
      ManagementMenuItem(
        title: 'Stock Opname',
        icon: Icons.list_alt,
        onTap: () {
          _handleMenuItemTap(context, 'Stock Opname');
        },
      ),
      ManagementMenuItem(
        title: 'Supplier',
        icon: Icons.local_shipping,
        onTap: () {
          _handleMenuItemTap(context, 'Supplier');
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1, // Decreased to make cards taller
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildManagementCard(context, item);
      },
    );
  }

  Widget _buildManagementCard(BuildContext context, ManagementMenuItem item) {
    return Card(
      elevation: 2,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Material 3 uses more rounded corners
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
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

  void _handleMenuItemTap(BuildContext context, String itemName) {
    // For now, we'll just show a snackbar
    // In a real app, you would navigate to the respective screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName not implemented yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ManagementMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ManagementMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}