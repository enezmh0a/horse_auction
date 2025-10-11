import 'dart:math';
import 'package:horse_auction_baseline/models/lot_model.dart';
import 'package:horse_auction_baseline/models/bid_model.dart';

class LotsService {
  LotsService._();
  static final LotsService instance = LotsService._();

  final List<Lot> lots = [
    Lot(
      id: 'h1',
      name: 'Desert Comet',
      coverImage: 'https://picsum.photos/seed/h1/1200/800',
      description: 'Fast chestnut mare, 6yo, great temperament.',
      currentBid: 25000,
      minIncrement: 500,
      endsAt: DateTime.now().add(const Duration(minutes: 8)),
    ),

    Lot(
      id: 'h2',
      name: 'Desert Comet',
      coverImage: 'https://picsum.photos/seed/h1/1200/800',
      description: 'Fast chestnut mare, 6yo, great temperament.',
      currentBid: 25000,
      minIncrement: 500,
      endsAt: DateTime.now().add(const Duration(minutes: 8)),
    ),

    Lot(
      id: 'h3',
      name: 'Midnight Echo',
      coverImage: 'https://picsum.photos/seed/h3/1200/800',
      description: 'Elegant black stallion with expressive movement.',
      imageUrls: [
        'https://images.unsplash.com/photo-1501686637-b7aa9c48a882?q=80&w=1200&auto=format&fit=crop',
      ],
      startingPrice: 9000,
      currentBid: 9000,
      minBidIncrement: 500,
    ),
  ];

  Lot? byId(String id) {
    for (final l in lots) {
      if (l.id == id) return l;
    }
    return null;
  }

  // ---------- Helper resolvers (accept Lot or id String) ----------
  Lot _resolve(Object lotOrId) {
    if (lotOrId is Lot) return lotOrId;
    final id = lotOrId.toString();
    return _lots.firstWhere(
      (l) => l.id == id,
      orElse: () => throw StateError('Lot $id not found'),
    );
  }

  String idOf(Object lotOrId) => _resolve(lotOrId).id;
  double currentBidOf(Object lotOrId) => _resolve(lotOrId).currentBid;

  bool isSold(Object lotOrId) => timeLeftOf(lotOrId) == Duration.zero;

  Duration timeLeftOf(Object lotOrId) {
    final lot = _resolve(lotOrId);
    final end = lot.endsAt;
    if (end == null) return Duration.zero;
    final d = end.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }
  // ------- Convenience helpers your UI is calling -------

  String idOf(Lot lot) {
    try {
      return (lot as dynamic).id as String;
    } catch (_) {}
    try {
      return (lot as dynamic).lotId as String;
    } catch (_) {}
    throw StateError('Lot has no id/lotId');
  }

  double currentBidOf(Lot lot) {
    try {
      return ((lot as dynamic).currentBid as num).toDouble();
    } catch (_) {}
    try {
      return ((lot as dynamic).current as num).toDouble();
    } catch (_) {}
    return 0.0;
  }

  double minIncrementOf(Lot lot) {
    try {
      return ((lot as dynamic).minIncrement as num).toDouble();
    } catch (_) {}
    try {
      return ((lot as dynamic).minInc as num).toDouble();
    } catch (_) {}
    return 50.0;
  }

  Duration timeLeftOf(Lot lot) {
    try {
      final end = (lot as dynamic).endsAt as DateTime?;
      if (end == null) return Duration.zero;
      final d = end.difference(DateTime.now());
      return d.isNegative ? Duration.zero : d;
    } catch (_) {}
    return Duration.zero;
  }
}
