// lib/admin_pages/admin_services_page.dart
import 'package:flutter/material.dart';

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services (Admin)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TierCard(
            title: 'Platinum',
            bullets: [
              'Homepage priority',
              'Pro photos & video',
              'Managed offers & bidding',
            ],
            icon: Icons.workspace_premium_outlined,
          ),
          SizedBox(height: 12),
          _TierCard(
            title: 'Gold',
            bullets: [
              'Featured card',
              'Basic analytics',
              'Business-hours support',
            ],
            icon: Icons.star_border_rounded,
          ),
          SizedBox(height: 12),
          _TierCard(
            title: 'Silver',
            bullets: [
              'Standard listing',
              'Basic photos',
              'Email Q&A',
            ],
            icon: Icons.grade_outlined,
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final List<String> bullets;
  final IconData icon;
  const _TierCard(
      {required this.title, required this.bullets, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final b in bullets)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 16),
                          const SizedBox(width: 6),
                          Expanded(child: Text(b)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
