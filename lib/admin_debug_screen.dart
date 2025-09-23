// lib/admin_debug_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/bid_box.dart';        // adjust path if needed
import 'admin_debug_panel.dart';      // adjust/remove if your panel is elsewhere

class AdminDebugScreen extends StatelessWidget {
  const AdminDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user == null ? 'Not signed in' : 'UID: ${user.uid}'),
            const SizedBox(height: 16),

            // Your debug panel (no const to avoid "not a constant expression" issues)
            AdminDebugPanel(),

            const SizedBox(height: 24),
            const Divider(),

            const Text('Test bidding (lot01)'),
            const SizedBox(height: 8),

            // Bid box (remove const if your constructor isn't const)
            BidBox(lotId: 'lot01'),
          ],
        ),
      ),
    );
  }
}
