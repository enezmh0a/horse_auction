// lib/tools/seed_tiers.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Call from debug FAB in HorsesPage
Future<void> seedDemoTiers({int perTier = 5}) async {
  final tiers = ['silver', 'gold', 'platinum', 'diamond'];
  final now = DateTime.now();
  final rnd = Random();

  // royalty-free horse images (replace with your CDN later)
  const images = [
    'https://images.unsplash.com/photo-1612119276757-0e2b1c9c79a0?w=1200&q=80',
    'https://images.unsplash.com/photo-1501471984908-815b99686255?w=1200&q=80',
    'https://images.unsplash.com/photo-1553284965-83fd3e82fa5e?w=1200&q=80',
    'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=1200&q=80',
  ];

  final lots = FirebaseFirestore.instance.collection('lots');
  final batch = FirebaseFirestore.instance.batch();

  for (final tier in tiers) {
    for (int i = 0; i < perTier; i++) {
      final id = '${tier}_${now.millisecondsSinceEpoch}_$i';
      final start = 12000 + rnd.nextInt(4000);
      final step = [200, 250, 500][rnd.nextInt(3)];
      final inc = ((rnd.nextInt(5) + 1) * step);
      final current = start + inc;
      final status = rnd.nextBool() ? 'live' : 'closed';
      final city = ['Riyadh', 'Jeddah', 'Dammam'][rnd.nextInt(3)];
      final breed =
          ['Arabian', 'Thoroughbred', 'Quarter Horse'][rnd.nextInt(3)];
      final color = ['Bay', 'Chestnut', 'Grey', 'Black'][rnd.nextInt(4)];
      final height = 145 + rnd.nextInt(20); // cm

      final doc = lots.doc(id);
      batch.set(doc, {
        'title': '$tier ${i + 1}'.toLowerCase(),
        'tier': tier,
        'city': city,
        'breed': breed,
        'color': color,
        'height': height,
        'start': start,
        'current': current,
        'next': current + step,
        'step': step,
        'status': status,
        'images': images..shuffle(),
        'tsUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
  await batch.commit();
}
