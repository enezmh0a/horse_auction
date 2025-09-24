import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  AdminService._();
  static final _db = FirebaseFirestore.instance;
  static bool _busy = false; // prevents double taps

  /// Create the demo lots/bids only if they don't already exist.
  static Future<void> seedLotsOnce() async {
    if (_busy) return;
    _busy = true;
    try {
      for (final s in _seedLots) {
        final lotRef = _db.collection('lots').doc(s.id);

        // Create lot only if it doesn't exist
        final lotSnap = await lotRef.get();
        if (!lotSnap.exists) {
          await lotRef.set({
            'title': s.title,
            'city': s.city,
            'tier': s.tier, // platinum/gold/silver
            'images': s.images,
            'start': s.start,
            'current': s.current,
            'step': s.step,
            'state': 'live',
            'seed': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Add a few sample bids only if there are none yet
        final hasBids = await lotRef.collection('bids').limit(1).get();
        if (hasBids.docs.isEmpty) {
          final amounts = [
            s.start,
            s.start + s.step,
            s.start + s.step * 2,
          ];

          final batch = _db.batch();
          for (var i = 0; i < amounts.length; i++) {
            final amt = amounts[i];
            final bidRef = lotRef.collection('bids').doc('seed_$i');
            batch.set(bidRef, {
              'amount': amt,
              'status': i == amounts.length - 1 ? 'accepted' : 'rejected',
              'by': i == amounts.length - 1 ? 'demoUser' : 'demo',
              'ts': FieldValue.serverTimestamp(),
              'seed': true,
            });
          }
          batch.update(lotRef, {
            'current': amounts.last,
            'updatedAt': FieldValue.serverTimestamp()
          });
          await batch.commit();
        }
      }
    } finally {
      _busy = false;
    }
  }
}

class _SeedLot {
  final String id, title, city, tier;
  final List<String> images;
  final int start, step, current;
  const _SeedLot({
    required this.id,
    required this.title,
    required this.city,
    required this.tier,
    required this.images,
    required this.start,
    required this.step,
    required this.current,
  });
}

const _seedLots = <_SeedLot>[
  _SeedLot(
    id: 'seed_platinum_1',
    title: 'Platinum Stallion',
    city: 'Riyadh',
    tier: 'platinum',
    images: [
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200'
    ],
    start: 20000,
    step: 500,
    current: 20000,
  ),
  _SeedLot(
    id: 'seed_gold_1',
    title: 'Gold Mare',
    city: 'Jeddah',
    tier: 'gold',
    images: [
      'https://images.unsplash.com/photo-1517849845537-4d257902454a?w=1200'
    ],
    start: 15000,
    step: 250,
    current: 15000,
  ),
  _SeedLot(
    id: 'seed_silver_1',
    title: 'Silver Gelding',
    city: 'Dammam',
    tier: 'silver',
    images: [
      'https://images.unsplash.com/photo-1517423440428-a5a00ad493e8?w=1200'
    ],
    start: 12000,
    step: 200,
    current: 12000,
  ),
];
