// lib/services/live_bids_service.dart
import 'dart:async';
import '../models/lot_model.dart';

/// Single source of truth for demo/live bidding.
/// - Singleton
/// - In-memory lots + periodic ticker
/// - Streams for UI
class LiveBidsService {
  LiveBidsService._internal() {
    _seedLots(); // one-time seed
    _startTicker(); // emits every second so timeLeft updates
  }
  static final LiveBidsService instance = LiveBidsService._internal();

  final _controller = StreamController<List<Lot>>.broadcast();
  Stream<List<Lot>> get lots$ => _controller.stream;

  /// Convenience filtered streams
  Stream<List<Lot>> get live$ =>
      lots$.map((all) => all.where((l) => !l.isSold).toList());
  Stream<List<Lot>> get results$ =>
      lots$.map((all) => all.where((l) => l.isSold).toList());

  final List<Lot> _lots = [];

  // -------------------- Public helpers (single definitions) --------------------
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
  Duration timeLeftOf(Object lotOrId) => _resolve(lotOrId).timeLeft;
  bool isSold(Object lotOrId) => _resolve(lotOrId).isSold;

  List<Lot> get lots => List.unmodifiable(_lots);

  // -------------------- Mutations --------------------
  /// Place a bid on a lot (by id or Lot).
  /// Returns the new bid amount.
  double placeBid(Object lotOrId, double amount) {
    final lot = _resolve(lotOrId);
    // simple validation: must be >= current + minIncrement and not sold
    if (lot.isSold) return lot.currentBid;
    final minAllowed = lot.currentBid + lot.minIncrement;
    if (amount < minAllowed) return lot.currentBid;

    lot.currentBid = amount;
    // keep lot open a little longer on every valid bid (demo UX)
    if (lot.endsAt != null) {
      lot.endsAt = lot.endsAt!.add(const Duration(seconds: 20));
    }
    _emit();
    return lot.currentBid;
  }

  // -------------------- Internals --------------------
  void _emit() => _controller.add(List.unmodifiable(_lots));

  void _startTicker() {
    // tick every 1s so UI gets timeLeft updates
    Timer.periodic(const Duration(seconds: 1), (_) => _emit());
  }

  void _seedLots() {
    // Clear and add consistent sample data (with description!)
    _lots
      ..clear()
      ..addAll([
        Lot(
          id: 'h1',
          name: 'Desert Comet',
          description:
              'Fast chestnut mare (6yo) with excellent temperament and endurance.',
          coverImage: 'https://picsum.photos/seed/h1/1200/800',
          currentBid: 25000,
          minIncrement: 500,
          endsAt: DateTime.now().add(const Duration(minutes: 6, seconds: 20)),
        ),
        Lot(
          id: 'h2',
          name: 'Midnight Star',
          description:
              'Elegant black stallion (5yo), responsive and sure-footed, show potential.',
          coverImage: 'https://picsum.photos/seed/h2/1200/800',
          currentBid: 32000,
          minIncrement: 1000,
          endsAt: DateTime.now().add(const Duration(minutes: 4, seconds: 30)),
        ),
        Lot(
          id: 'h3',
          name: 'Golden Mirage',
          description:
              'Palomino gelding (8yo), calm under saddle, great for beginners.',
          coverImage: 'https://picsum.photos/seed/h3/1200/800',
          currentBid: 18000,
          minIncrement: 500,
          endsAt: DateTime.now().add(const Duration(minutes: 1, seconds: 50)),
        ),
        Lot(
          id: 'h4',
          name: 'Sirocco Wind',
          description:
              'Grey Arabian (7yo), forward and brave, excellent desert gait.',
          coverImage: 'https://picsum.photos/seed/h4/1200/800',
          currentBid: 41000,
          minIncrement: 1000,
          endsAt: DateTime.now().add(const Duration(minutes: 8)),
        ),
        Lot(
          id: 'h5',
          name: 'Copper Sky',
          description:
              'Chestnut (9yo), reliable with smooth canter; solid trail record.',
          coverImage: 'https://picsum.photos/seed/h5/1200/800',
          currentBid: 15000,
          minIncrement: 500,
          endsAt: DateTime.now().add(const Duration(minutes: 12)),
        ),
        Lot(
          id: 'h6',
          name: 'White Oasis',
          description:
              'White mare (6yo), agile and responsive; potential for dressage.',
          coverImage: 'https://picsum.photos/seed/h6/1200/800',
          currentBid: 28000,
          minIncrement: 500,
          endsAt: DateTime.now().add(const Duration(minutes: 2, seconds: 15)),
        ),
      ]);
    _emit();
  }
}
