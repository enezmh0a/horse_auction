<<<<<<< HEAD
// lib/services/firestore_service.dart
import 'dart:async';
import '../models/bid_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  /// Old code calls FirestoreService().bidsStream(userId)
  Stream<List<BidModel>> bidsStream(String userId) async* {
    yield const <BidModel>[];
=======
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;
Future<int> countLotsOnce() async {
  final snap = await _db.collection('lots').get();
  return snap.docs.length;
}

  /// Stream lots (list page)
  Stream<List<Map<String, dynamic>>> lotsStream() {
    return _db
        .collection('lots')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Stream single lot (detail page)
  Stream<Map<String, dynamic>?> streamLot(String lotId) {
    return _db.collection('lots').doc(lotId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    });
  }

  /// Stream bids for a lot
  Stream<List<Map<String, dynamic>>> bidsStream(String lotId) {
    return _db
        .collection('lots')
        .doc(lotId)
        .collection('bids')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  /// Place a bid
  Future<bool> placeBid({
    required String lotId,
    required int amount,
    required String userId,
  }) async {
    try {
      final lotRef = _db.collection('lots').doc(lotId);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(lotRef);
        if (!snap.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Lot does not exist',
          );
        }
        final data = snap.data() as Map<String, dynamic>;
        final current = (data['currentHighest'] ?? 0) as int;
        final minInc = (data['minIncrement'] ?? 0) as int;

        if (amount < current + minInc) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Bid too low',
          );
        }

        final bidsCol = lotRef.collection('bids');
        tx.set(bidsCol.doc(), {
          'amount': amount,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.update(lotRef, <String, dynamic>{
          'currentHighest': amount,
          'bidsCount': (data['bidsCount'] ?? 0) + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } on FirebaseException catch (e) {
      // Handle as normal Dart exception on every platform (including web)
      // You can log e.code / e.message if you want
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Update lot status
  Future<void> setLotStatus({
    required String lotId,
    required String status, // 'open' | 'closed' | 'published'
  }) async {
    await _db.collection('lots').doc(lotId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
>>>>>>> origin/main
  }
}
