import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lot_model.dart';
import '../models/bid_model.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

class LotRepository {
  final FirebaseFirestore _db;
  LotRepository(this._db);

  Stream<List<LotModel>> lotsStream() {
    return _db
        .collection('lots')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) => LotModel.fromDoc(d)).toList());
  }

  Stream<LotModel?> lotStream(String id) {
    return _db
        .collection('lots')
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? LotModel.fromDoc(d) : null);
  }

  Stream<List<BidModel>> bidsStream(String lotId) {
    return _db
        .collection('lots')
        .doc(lotId)
        .collection('bids')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BidModel.fromDoc(d)).toList());
  }

  Future<void> seedDemoData() async {
    final col = _db.collection('lots');
    final exists = await col.limit(1).get();
    if (exists.docs.isNotEmpty) return;

    final items = <Map<String, dynamic>>[
      {
        'name': 'Desert Star',
        'description': '4yo Arabian, excellent endurance.',
        'startingPrice': 1000.0,
        'currentBid': 0.0,
        'minBidIncrement': 100.0,
        'imageUrls': [
          'https://images.unsplash.com/photo-1466825746891-30d1cd3a0478?q=80&w=1080&auto=format&fit=crop',
        ],
        'isFeatured': true,
      },
      {
        'name': 'Midnight Comet',
        'description': '3yo Thoroughbred, fast and agile.',
        'startingPrice': 1500.0,
        'currentBid': 0.0,
        'minBidIncrement': 150.0,
        'imageUrls': [
          'https://images.unsplash.com/photo-1466825746891-30d1cd3a0478?q=80&w=1080&auto=format&fit=crop',
        ],
        'isFeatured': false,
      },
    ];

    for (final m in items) {
      await col.add(m);
    }
  }

  Future<void> placeBid({
    required String lotId,
    required double amount,
    required String userId,
  }) async {
    await _db.runTransaction((tx) async {
      final lotRef = _db.collection('lots').doc(lotId);
      final lotSnap = await tx.get(lotRef);
      if (!lotSnap.exists) {
        throw StateError('Lot not found');
      }
      final lot = LotModel.fromDoc(lotSnap);

      final current = (lot.currentBid ?? 0).toDouble();
      final starting = (lot.startingPrice ?? 0).toDouble();
      final minInc = (lot.minBidIncrement ?? 0).toDouble();
      final base = current == 0 ? starting : current;
      final minAllowed = base + minInc;

      if (amount < minAllowed) {
        throw StateError(
          'Bid too low (min \$${minAllowed.toStringAsFixed(0)})',
        );
      }

      // write bid
      final bidsRef = lotRef.collection('bids').doc();
      tx.set(bidsRef, {
        'amount': amount,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // update lot
      tx.update(lotRef, {'currentBid': amount, 'currentHighBidderId': userId});
    });
  }
}
