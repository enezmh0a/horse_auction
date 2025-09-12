import 'package:flutter/material.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seller Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Create a lot, set reserve, upload documents.'),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New Lot')),
          const SizedBox(height: 24),
          const Text('Your recent lots:'),
          const SizedBox(height: 8),
          const Expanded(child: Center(child: Text('No lots yet'))),
        ],
      ),
    );
  }
}
