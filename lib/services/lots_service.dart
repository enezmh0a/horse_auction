import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lot.dart';

class LotsService {
  LotsService._();
  static final LotsService instance = LotsService._();
  final _col = FirebaseFirestore.instance.collection('lots');

  Stream<List<Lot>> streamLots() {
    return _col
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Lot.fromDoc(d)).toList());
  }

  Future<Lot?> getLot(String id) async {
    final d = await _col.doc(id).get();
    if (!d.exists) return null;
    return Lot.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>);
  }
}
