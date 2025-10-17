import 'package:flutter/material.dart';

class ServicesHubPage extends StatelessWidget {
  const ServicesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Tile(
              title: 'Veterinarians',
              subtitle: 'Find certified vets and clinics'),
          _Tile(
              title: 'Transportation', subtitle: 'Horse transport & logistics'),
          _Tile(title: 'Boarding', subtitle: 'Stables and care services'),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.miscellaneous_services),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
