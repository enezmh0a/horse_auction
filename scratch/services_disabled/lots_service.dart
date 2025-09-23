import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:horse_auction_app/models/lot.dart';

class LotsService {
  LotsService._();
  static final LotsService instance = LotsService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _lots => _db.collection('lots');

  /// Base query; pass status = null for "all"
  Query<Map<String, dynamic>> lotsQuery({String? status}) {
    Query<Map<String, dynamic>> q = _lots;

    if (status != null && status.isNotEmpty) {
      q = q.where('status', isEqualTo: status);
    }

    // Order if these fields exist. If they don't, Firestore still works.
    // Prefer tsStart desc, then title as a fallback.
    q = q.orderBy('tsStart', descending: true).orderBy('title');

    return q;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> lotsStreamAll() =>
      lotsQuery(status: null).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> lotsStreamLive() =>
      lotsQuery(status: 'live').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> lotsStreamClosed() =>
      lotsQuery(status: 'closed').snapshots();

  /// Helper for mapping snapshot → List<Lot>
  static List<Lot> mapLots(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map(Lot.fromDoc).toList(growable: false);
  }
}
