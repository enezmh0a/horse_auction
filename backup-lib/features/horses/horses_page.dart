// lib/features/horses/horses_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_app/widgets/safe_network_image.dart';
import 'package:horse_auction_app/widgets/tier_badge.dart';
import 'package:horse_auction_app/tools/seed_tiers.dart';

class HorsesPage extends StatelessWidget {
  const HorsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lots = FirebaseFirestore.instance.collection('lots');
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: lots.orderBy('tsUpdated', descending: true).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No horses yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final title = (d['title'] ?? docs[i].id).toString();
              final tier = (d['tier'] ?? 'silver').toString();
              final city = (d['city'] ?? '').toString();
              final images =
                  (d['images'] is List ? (d['images'] as List) : const []);
              final first = images.isNotEmpty
                  ? images.first.toString()
                  : (d['image'] ?? '').toString();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            SafeNetworkImage(url: first, width: 90, height: 70),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              TierBadge(tier: tier),
                              if (city.isNotEmpty)
                                Chip(label: Text(city), side: BorderSide.none),
                            ]),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // Debug-only seeder
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                await seedDemoTiers(perTier: 5);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Seeded demo horses by tier')));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Seed demo'),
            )
          : null,
    );
  }
}
