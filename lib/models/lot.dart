import 'package:cloud_firestore/cloud_firestore.dart';

enum AuctionState { live, closed }

class Lot {
  final String id;
  final String title;
  final String city;
  final int current;
  final int step;
  final int start;
  final AuctionState state;
  final List<String> images;
  final int lastBidAmount; // for duplicate-press protection
  final Timestamp updatedAt;

  Lot({
    required this.id,
    required this.title,
    required this.city,
    required this.current,
    required this.step,
    required this.start,
    required this.state,
    required this.images,
    required this.lastBidAmount,
    required this.updatedAt,
  });

  int get minBid => (current + step);

  factory Lot.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Lot(
      id: doc.id,
      title: (d['title'] ?? '') as String,
      city: (d['city'] ?? '') as String,
      current: (d['current'] ?? 0) as int,
      step: (d['step'] ?? 100) as int,
      start: (d['start'] ?? 0) as int,
      state: ((d['state'] ?? 'live') == 'closed')
          ? AuctionState.closed
          : AuctionState.live,
      images:
          (d['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      lastBidAmount: (d['lastBidAmount'] ?? 0) as int,
      updatedAt: (d['updatedAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'city': city,
        'current': current,
        'step': step,
        'start': start,
        'state': state == AuctionState.closed ? 'closed' : 'live',
        'images': images,
        'lastBidAmount': lastBidAmount,
        'updatedAt': updatedAt,
      };
}
