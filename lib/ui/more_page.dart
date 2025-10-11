import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('About'),
            subtitle: Text('Simple demo auction with in-memory data.'),
          ),
          ListTile(
            title: const Text('Contact'),
            subtitle: const Text('support@example.com'),
            leading: const Icon(Icons.email_outlined),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
