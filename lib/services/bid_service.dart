import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lot.dart';

class BidService {
  BidService._();
  static final BidService instance = BidService._();
  final _db = FirebaseFirestore.instance;

  /// Transactional bid placement with validation and duplicate-tap protection.
  Future<void> placeBidTx({required String lotId, required int amount}) async {
    final lotRef = _db.collection('lots').doc(lotId);
    final bidsRef = lotRef.collection('bids');

    await _db.runTransaction((tx) async {
      final snap = await tx.get(lotRef);
      if (!snap.exists) {
        throw StateError('MISSING_LOT');
      }
      final lot = Lot.fromDoc(snap as DocumentSnapshot<Map<String, dynamic>>);

      if (lot.state == AuctionState.closed) {
        throw StateError('CLOSED');
      }

      final min = lot.minBid;
      if (amount < min) {
        throw StateError('LOW_BID'); // handled in UI
      }
      if ((amount - min) % lot.step != 0) {
        throw StateError('BAD_STEP'); // handled in UI
      }

      // Double-tap protection: ignore if same as last accepted
      if (lot.lastBidAmount == amount) {
        return; // idempotent
      }

      final now = FieldValue.serverTimestamp();
      tx.update(lotRef, {
        'current': amount,
        'lastBidAmount': amount,
        'updatedAt': now,
      });

      final newBid = bidsRef.doc(); // auto id
      tx.set(newBid, {
        'amount': amount,
        'status': 'accepted',
        'createdAt': now,
        'by': 'demoUser',
      });
    });
  }
}
