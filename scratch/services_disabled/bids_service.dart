import 'package:cloud_firestore/cloud_firestore.dart';

class BidsService {
  BidsService._();
  static final BidsService instance = BidsService._();

  final _db = FirebaseFirestore.instance;

  /// Bids live under /lots/{lotId}/bids (adjust if your schema differs)
  Query<Map<String, dynamic>> bidsQuery(String lotId) {
    return _db
        .collection('lots')
        .doc(lotId)
        .collection('bids')
        .orderBy('ts', descending: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> bidsStream(String lotId) =>
      bidsQuery(lotId).snapshots();
}
