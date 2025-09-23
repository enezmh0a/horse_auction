// lib/features/services/services_page.dart
import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        'Auction Hosting',
        Icons.gavel,
        'Full-service auction setup and management.'
      ),
      (
        'Photography',
        Icons.photo_camera_outlined,
        'Professional media for your horses.'
      ),
      (
        'Transport',
        Icons.local_shipping_outlined,
        'Trusted logistics across KSA.'
      ),
      (
        'Vet Check',
        Icons.health_and_safety_outlined,
        'On-site veterinary inspection.'
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map((e) => Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(e.$2),
                  title: Text(e.$1),
                  subtitle: Text(e.$3),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ))
          .toList(),
    );
  }
}
