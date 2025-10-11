import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biddingRepositoryProvider = Provider<BiddingRepository>((ref) {
  return BiddingRepository(FirebaseFirestore.instance);
});

class BiddingRepository {
  BiddingRepository(this._db);
  final FirebaseFirestore _db;

  /// Places a bid atomically. Throws a String on failure (for easy UI).
  Future<void> placeBid({
    required String lotId,
    required double amount,
    required String userId,
  }) async {
    final lots = _db.collection('lots');
    await _db.runTransaction((tx) async {
      final lotRef = lots.doc(lotId);
      final snap = await tx.get(lotRef);
      if (!snap.exists) throw Exception('Lot not found');

      final data = snap.data() as Map<String, dynamic>;
      final currentBid = (data['currentBid'] as num?)?.toDouble() ?? 0;
      final minInc = (data['minBidIncrement'] as num?)?.toDouble() ?? 0;
      final startingPrice = (data['startingPrice'] as num?)?.toDouble() ?? 0;

      final base = currentBid == 0 ? startingPrice : currentBid;
      final nextAllowed = base + minInc;
      if (amount < nextAllowed) {
        throw Exception(
            'Bid must be at least \$${nextAllowed.toStringAsFixed(0)}');
      }

      final bidsRef = lotRef.collection('bids').doc();
      tx.set(bidsRef, {
        'lotId': lotId,
        'userId': userId,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      tx.update(lotRef, {
        'currentBid': amount,
        'currentHighBidderId': userId,
        'bidCount': FieldValue.increment(1),
      });
    });
  }
}
