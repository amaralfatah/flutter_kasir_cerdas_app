// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_kasir_cerdas_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_kasir_cerdas_app/features/auth/screens/login_screen.dart';
import 'package:flutter_kasir_cerdas_app/features/home/screens/home_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;

  const AppDrawer({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    // Get the auth provider to access user data
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? 'User Name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                Text(
                  user?.email ?? 'user@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            isSelected: currentPage == 'home',
            onTap: () {
              if (currentPage != 'home') {
                Navigator.pop(context); // Close drawer
                // If we're on another page, navigate back to home
                if (currentPage != 'home') {
                  // We are already on home page so just close drawer
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }
            },
          ),
          _buildNavItem(
            context: context,
            icon: Icons.person,
            title: 'Profile',
            isSelected: currentPage == 'profile',
            onTap: () {
              if (currentPage != 'profile') {
                Navigator.pop(context); // Close drawer

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
            },
          ),
          const Divider(),
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Settings page would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings page not implemented yet'),
                ),
              );
            },
          ),
          _buildNavItem(
            context: context,
            icon: Icons.help,
            title: 'Help',
            onTap: () {
              Navigator.pop(context);
              // Help page would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help page not implemented yet'),
                ),
              );
            },
          ),
          const Divider(),
          _buildNavItem(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pop(context); // Close drawer

              // Show a confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                        },
                        child: const Text('CANCEL'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog

                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          // Perform logout
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.logout();

                          // Close loading indicator
                          Navigator.pop(context);

                          // Navigate back to login screen and clear all routes
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('LOGOUT'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
