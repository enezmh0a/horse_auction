import 'package:cloud_firestore/cloud_firestore.dart';

class Auction {
  final String id;
  final String name;
  final String status; // optional: 'upcoming' | 'live' | 'finished'
  final Timestamp? tsStart;
  final Timestamp? tsEnd;

  Auction({
    required this.id,
    required this.name,
    required this.status,
    this.tsStart,
    this.tsEnd,
  });

  factory Auction.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    Timestamp? _asTs(dynamic v) {
      if (v is Timestamp) return v;
      if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
      if (v is num) return Timestamp.fromMillisecondsSinceEpoch(v.toInt());
      return null;
    }

    return Auction(
      id: doc.id,
      name: (d['name'] as String?)?.trim() ?? '',
      status: (d['status'] as String?)?.trim() ?? '',
      tsStart: _asTs(d['tsStart']),
      tsEnd: _asTs(d['tsEnd']),
    );
  }
}
