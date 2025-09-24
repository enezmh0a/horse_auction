import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore bid logic kept intentionally simple/safe for Windows desktop.
/// - Only writes primitives and Timestamp
/// - No FieldValue.serverTimestamp / increment
class BidService {
  BidService._();
  static final instance = BidService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Places a bid inside a Firestore transaction.
  /// Throws StateError with codes: LOT_MISSING, CLOSED, LOW_BID, BAD_STEP
  Future<void> placeBidTx({
    required String lotId,
    required int amount,
    String userId = 'demo',
    String userName = 'demoUser',
  }) async {
    final lotRef = _db.collection('lots').doc(lotId);
    final bidsRef = lotRef.collection('bids');

    await _db.runTransaction((tx) async {
      final lotSnap = await tx.get(lotRef);
      if (!lotSnap.exists) throw StateError('LOT_MISSING');

      final data = (lotSnap.data() as Map<String, dynamic>)
        ..removeWhere((k, v) => v == null);

      final int current = (data['current'] as num?)?.toInt() ?? 0;
      final int step = (data['step'] as num?)?.toInt() ?? 100;
      final int start = (data['start'] as num?)?.toInt() ?? 0;
      final String state = (data['state'] as String?) ?? 'live';

      if (state != 'live') throw StateError('CLOSED');

      final int min = current == 0 ? start : current + step;
      if (amount < min) throw StateError('LOW_BID');

      // Amount must align with step from the base (current or start)
      final base = current == 0 ? start : current;
      if ((amount - base) % step != 0) throw StateError('BAD_STEP');

      final now = Timestamp.now();

      // Update lot
      tx.update(lotRef, <String, dynamic>{
        'current': amount,
        'updatedAt': now,
      });

      // Write bid (unique id to avoid accidental dupes)
      final bidId =
          '${now.seconds}-${now.nanoseconds}-${Random().nextInt(10000)}';

      tx.set(bidsRef.doc(bidId), <String, dynamic>{
        'amount': amount,
        'createdAt': now,
        'status': 'accepted',
        'userId': userId,
        'userName': userName,
      });
    });
  }
}
