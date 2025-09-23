import 'package:cloud_firestore/cloud_firestore.dart';

class Lot {
  final String id;
  final String title;
  final String status; // e.g., 'published' | 'live' | 'closed'
  final int startPrice;
  final int lastBid;
  final String exhibitor;
  final Timestamp? tsStart;
  final Timestamp? tsEnd;
  final String? horseId;
  final String? auctionId;

  Lot({
    required this.id,
    required this.title,
    required this.status,
    required this.startPrice,
    required this.lastBid,
    required this.exhibitor,
    this.tsStart,
    this.tsEnd,
    this.horseId,
    this.auctionId,
  });

  /// Safe mapping: tolerant of missing/typed fields
  factory Lot.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    Timestamp? _asTs(dynamic v) {
      if (v is Timestamp) return v;
      if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
      if (v is num) return Timestamp.fromMillisecondsSinceEpoch(v.toInt());
      return null;
    }

    int _asInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    return Lot(
      id: doc.id,
      title: (d['title'] as String?)?.trim() ?? '',
      status: (d['status'] as String?)?.trim() ?? '',
      startPrice: _asInt(d['startPrice']),
      lastBid: _asInt(d['lastBid']),
      exhibitor: (d['exhibitor'] as String?)?.trim() ?? '',
      tsStart: _asTs(d['tsStart']),
      tsEnd: _asTs(d['tsEnd']),
      horseId: (d['horseId'] as String?)?.trim(),
      auctionId: (d['auctionId'] as String?)?.trim(),
    );
  }
}
