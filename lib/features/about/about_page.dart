// lib/features/about/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.showContact});
  final bool showContact;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'We are a modern horse auction platform with transparent bidding, '
              'tiered visibility (Silver, Gold, Platinum, Diamond), and easy management.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        if (showContact)
          const Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text('contact@horseauctions.example'),
              subtitle: Text('Riyadh • +966-555-000-000'),
            ),
          ),
      ],
    );
  }
}
