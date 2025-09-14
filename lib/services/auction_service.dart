import 'package:cloud_firestore/cloud_firestore.dart';

final _db = FirebaseFirestore.instance;

class Lot {
  final String id;
  final String name;
  final String state;
  final int minIncrement;
  final int currentHighest;
  final Timestamp? startTime;
  final Timestamp? endTime;

  Lot({
    required this.id,
    required this.name,
    required this.state,
    required this.minIncrement,
    required this.currentHighest,
    this.startTime,
    this.endTime,
  });

  factory Lot.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Lot(
      id: doc.id,
      name: d['name'] ?? '',
      state: d['state'] ?? 'pending',
      minIncrement: (d['minIncrement'] ?? 0) as int,
      currentHighest: (d['currentHighest'] ?? 0) as int,
      startTime: d['startTime'],
      endTime: d['endTime'],
    );
  }
}

Stream<List<Lot>> watchLiveLots() => _db
    .collection('lots')
    .where('state', isEqualTo: 'live')
    .orderBy('currentHighest', descending: true)
    .snapshots()
    .map((s) => s.docs.map((d) => Lot.fromDoc(d)).toList());

Future<void> placeBid({
  required String lotId,
  required int amount,
  required String userId,
}) {
  return _db.collection('lots').doc(lotId).collection('bids').add({
    'amount': amount,
    'userId': userId,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  });
}
