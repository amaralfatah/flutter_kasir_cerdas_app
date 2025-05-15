import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/routes.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/dialogs.dart';
import '../../../config/theme.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      appBar: KasirAppBar(
        title: 'Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ConfirmationDialog(
                  title: 'Logout',
                  message: 'Are you sure you want to logout?',
                  confirmText: 'Logout',
                  onConfirm: () async {
                    Navigator.of(context).pop();
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User greeting
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.name ?? 'User',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.shop?.name ?? 'Shop',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Dashboard cards title
            Text(
              'Business Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dashboard cards - placeholder data
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DashboardCard(
                  title: 'Today\'s Sales',
                  value: 'Rp. 2,500,000',
                  icon: Icons.point_of_sale,
                ),
                DashboardCard(
                  title: 'Items Sold',
                  value: '48',
                  icon: Icons.shopping_bag,
                ),
                DashboardCard(
                  title: 'Profit',
                  value: 'Rp. 850,000',
                  icon: Icons.money,
                  iconColor: AppColors.success,
                ),
                DashboardCard(
                  title: 'Customers',
                  value: '12',
                  icon: Icons.people,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick actions title
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick actions
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickActionCard(
                  context,
                  title: 'New Sale',
                  icon: Icons.add_shopping_cart,
                  color: AppColors.primary,
                  onTap: () {
                    // Navigate to new sale screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Products',
                  icon: Icons.inventory,
                  color: AppColors.accent,
                  onTap: () {
                    // Navigate to products screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Customers',
                  icon: Icons.people,
                  color: Colors.green,
                  onTap: () {
                    // Navigate to customers screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Inventory',
                  icon: Icons.store,
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to inventory screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Reports',
                  icon: Icons.bar_chart,
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to reports screen
                  },
                ),
                _buildQuickActionCard(
                  context,
                  title: 'Settings',
                  icon: Icons.settings,
                  color: Colors.grey,
                  onTap: () {
                    // Navigate to settings screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}