import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mohammed Al-Anazi'),
            subtitle: Text('Buyer • Seller'),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language / اللغة'),
            subtitle: Text('Change from the top bar (EN/العربية)'),
          ),
        ],
      ),
    );
  }
}
