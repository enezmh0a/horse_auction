import 'package:cloud_firestore/cloud_firestore.dart';

class Lot {
  final String id;
  final String name;
  final String status; // published | live | closed
  final int startPrice;
  final int? lastBidAmount;
  final int? minIncrement; // aka step
  final Timestamp? updatedAt;

  const Lot({
    required this.id,
    required this.name,
    required this.status,
    required this.startPrice,
    this.lastBidAmount,
    this.minIncrement,
    this.updatedAt,
  });

  int get step => (minIncrement ?? 100).clamp(1, 1000000000);

  int get current => lastBidAmount ?? startPrice;

  int get nextMin => current + step;

  factory Lot.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Lot(
      id: doc.id,
      name: (d['name'] ?? d['lotId'] ?? doc.id).toString(),
      status: (d['status'] ?? 'published').toString(),
      startPrice: (d['startPrice'] ?? d['startingBid'] ?? 0 as num).toInt(),
      lastBidAmount: (d['lastBidAmount'] as num?)?.toInt(),
      minIncrement: (d['minIncrement'] ?? d['customIncrement'] as num?)?.toInt(),
      updatedAt: d['updatedAt'] is Timestamp ? d['updatedAt'] as Timestamp : null,
    );
  }
}
