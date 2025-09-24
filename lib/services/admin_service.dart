import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();
  final _db = FirebaseFirestore.instance;

  /// Seeds only once using a guard doc.
  Future<String> seedLotsOnce() async {
    final guardRef = _db.collection('internal').doc('seed_v1');
    final g = await guardRef.get();
    if (g.exists) return 'already';

    final lots = _db.collection('lots');
    final now = FieldValue.serverTimestamp();

    Future<void> add(
      String title,
      String city,
      int start,
      int step,
      int current,
      String state,
      List<String> images,
    ) async {
      await lots.add({
        'title': title,
        'city': city,
        'start': start,
        'step': step,
        'current': current,
        'state': state,
        'images': images,
        'lastBidAmount': 0,
        'updatedAt': now,
      });
    }

    await add(
        'عبدالرحمن – مهر مكس', 'Riyadh', 20000, 100, 20000, 'live', const [
      'https://images.unsplash.com/photo-1548199973-03cce0bbc87b',
    ]);

    await add('مهرة – يحق للمشتري التسمية', 'Riyadh', 3200, 100, 3200,
        'closed', const [
      'https://images.unsplash.com/photo-1517849845537-4d257902454a',
    ]);

    await add('كادي – مهرة مكس', 'Jeddah', 2500, 100, 2500, 'live', const [
      'https://images.unsplash.com/photo-1508471608744-72f0e3fd943f',
    ]);

    await guardRef.set({'seededAt': now});
    return 'done';
  }
}
