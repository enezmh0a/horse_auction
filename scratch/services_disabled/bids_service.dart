import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid.dart';
import '../models/lot.dart';

class BidsService {
  BidsService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _lots =>
      _db.collection('lots');
  CollectionReference<Map<String, dynamic>> _bids(String lotId) =>
      _lots.doc(lotId).collection('bids');

  /// Place a bid atomically:
  /// - Validates min increment & time
  /// - Updates lot.currentBid and reserveMet
  /// - Appends Bid in subcollection
  /// - Anti-sniping: extend end by [extension] if within [extensionWindow]
  Future<void> placeBid({
    required String lotId,
    required String bidderId,
    required int amount,               // SAR
    Duration minIncrement = const Duration(minutes: 0),
    int minIncrementValue = 1000,      // SAR
    Duration extensionWindow = const Duration(seconds: 30),
    Duration extension = const Duration(seconds: 30),
  }) async {
    await _db.runTransaction((tx) async {
      final lotRef = _lots.doc(lotId);
      final lotSnap = await tx.get(lotRef);
      if (!lotSnap.exists) {
        throw StateError('Lot not found');
      }
      final lot = Lot.fromJson(lotSnap.data()!);

      final now = DateTime.now().toUtc();
      if (now.isAfter(lot.auctionEnd.toUtc())) {
        throw StateError('Auction ended');
      }

      // Enforce min increment
      final needed = lot.currentBid + minIncrementValue;
      if (amount < needed) {
        throw StateError('Bid too low. Next bid must be ≥ SAR $needed');
      }

      // Write Bid
      final bidRef = _bids(lotId).doc();
      final bid = Bid(
        id: bidRef.id,
        lotId: lotId,
        bidderId: bidderId,
        amount: amount,
        timestamp: now,
      );

      // Anti-sniping extension
      DateTime newEnd = lot.auctionEnd;
      final timeLeft = lot.auctionEnd.toUtc().difference(now);
      if (timeLeft <= extensionWindow) {
        newEnd = now.add(extension);
      }

      final reserveMet = amount >= lot.reservePrice;

      // Update Lot + add Bid atomically
      tx.set(bidRef, bid.toJson());
      tx.update(lotRef, {
        'currentBid': amount,
        'reserveMet': reserveMet,
        'auctionEnd': Timestamp.fromDate(newEnd),
      });
    });
  }

  /// Stream recent bids for a lot (descending)
  Stream<List<Bid>> streamBids(String lotId, {int limit = 50}) {
    return _bids(lotId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Bid.fromJson(d.data())).toList());
  }
}
