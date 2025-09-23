import 'package:flutter/material.dart';

class AdminDebugScreen extends StatelessWidget {
  const AdminDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            // Add more widgets here as needed
          ],
        ),
      ),
    );
  }
}
