import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/user_providers.dart'; // <<< NEW IMPORT ADDED
import '../lots/lot_feed_page.dart'; // Placeholder for other admin pages
import 'admin_user_list_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is the line that required the import:
    final profileAsync = ref.watch(currentUserModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepOrange,
      ),
      body: profileAsync.when(
        data: (user) {
          if (user == null || !user.isAdmin) {
            return const Center(child: Text('Access Denied: Not an Admin.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              _buildCard(
                context,
                title: 'User Management',
                icon: Icons.people,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const AdminUserListScreen()),
                  );
                },
              ),
              _buildCard(
                context,
                title: 'Auction Lot Review',
                icon: Icons.gavel,
                onTap: () {
                  // Navigate to a dedicated lot review screen (LotFeedPage is a placeholder)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const LotFeedPage()),
                  );
                },
              ),
              _buildCard(
                context,
                title: 'System Settings',
                icon: Icons.settings,
                onTap: () {
                  // Implementation TBD
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings functionality TBD')),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.deepOrange),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }
}
