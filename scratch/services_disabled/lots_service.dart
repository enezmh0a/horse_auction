import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/horse.dart';
import '../models/lot.dart';

class LotsService {
  LotsService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _lots =>
      _db.collection('lots');

  /// Create or overwrite a lot
  Future<void> upsertLot(Lot lot) async {
    await _lots.doc(lot.id).set(lot.toJson());
  }

  /// Update partial fields
  Future<void> updateLot(String lotId, Map<String, dynamic> data) async {
    await _lots.doc(lotId).update(data);
  }

  /// Get a single lot
  Future<Lot?> getLot(String lotId) async {
    final snap = await _lots.doc(lotId).get();
    if (!snap.exists) return null;
    return Lot.fromJson(snap.data()!);
  }

  /// Stream approved/visible lots (customize filters as needed)
  Stream<List<Lot>> streamLots({bool onlyActive = true}) {
    Query<Map<String, dynamic>> q = _lots;
    if (onlyActive) {
      q = q.where('auctionEnd', isGreaterThan: Timestamp.now());
    }
    return q.orderBy('auctionEnd').snapshots().map((s) {
      return s.docs.map((d) => Lot.fromJson(d.data())).toList();
    });
  }

  /// Helper to generate new lot ids
  String newLotId() => _lots.doc().id;
}
