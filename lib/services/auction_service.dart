import 'dart:async';
import 'dart:math';

class Bid {
  final String user;
  final int amount;
  final DateTime ts;
  Bid(this.user, this.amount, this.ts);
}

class Lot {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int startingPrice;
  final int minIncrement;
  final List<Bid> bids;

  Lot({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.startingPrice,
    required this.minIncrement,
    List<Bid>? bids,
  }) : bids = bids ?? [];

  int get current => bids.isEmpty ? startingPrice : bids.last.amount;
  int get nextAllowed => current + minIncrement;
}

class BidEvent {
  final String lotId;
  final String lotName;
  final Bid bid;
  BidEvent({required this.lotId, required this.lotName, required this.bid});
}

class AuctionService {
  AuctionService._();
  static final AuctionService instance = AuctionService._();

  final List<Lot> _lots = [
    Lot(
      id: '1',
      name: 'Desert Comet',
      description: 'Athletic mare with strong sprint pedigree.',
      imageUrl:
          'https://images.unsplash.com/photo-1525253013412-55c1a69a5738?q=80&w=1600&auto=format&fit=crop',
      startingPrice: 5000,
      minIncrement: 250,
    ),
    Lot(
      id: '2',
      name: 'River Dancer',
      description: 'Fluid mover, nice temperament.',
      imageUrl:
          'https://images.unsplash.com/photo-1532634726-8b9fb99825c7?q=80&w=1600&auto=format&fit=crop',
      startingPrice: 3500,
      minIncrement: 250,
    ),
    Lot(
      id: '3',
      name: 'Midnight Echo',
      description: 'Powerful build, proven stamina.',
      imageUrl:
          'https://images.unsplash.com/photo-1485302391453-37b4bd349d10?q=80&w=1600&auto=format&fit=crop',
      startingPrice: 9000,
      minIncrement: 250,
    ),
  ];

  List<Lot> get lots => List.unmodifiable(_lots);

  // Live feed
  final _feedCtrl = StreamController<BidEvent>.broadcast();
  Stream<BidEvent> get liveFeed => _feedCtrl.stream;

  // Place bid + push into feed
  bool placeBid(
      {required String lotId, required int amount, String user = 'You'}) {
    final lot = _lots.firstWhere((l) => l.id == lotId,
        orElse: () => throw ArgumentError('Lot not found'));
    if (amount < lot.nextAllowed) return false;
    final bid = Bid(user, amount, DateTime.now());
    lot.bids.add(bid);
    _feedCtrl.add(BidEvent(lotId: lot.id, lotName: lot.name, bid: bid));
    return true;
  }

  // Results (sold == any lot that has >= 3 bids, tweak as you like)
  List<Lot> get soldLots => _lots.where((l) => l.bids.length >= 3).toList();

  // Simple “bot bidders” to make the live tab exciting (optional)
  Timer? _botTimer;
  void startBots({Duration every = const Duration(seconds: 8)}) {
    _botTimer?.cancel();
    final rnd = Random();
    _botTimer = Timer.periodic(every, (_) {
      if (_lots.isEmpty) return;
      final lot = _lots[rnd.nextInt(_lots.length)];
      final next = lot.nextAllowed +
          (rnd.nextInt(2) * lot.minIncrement); // next or +1 step
      placeBid(
          lotId: lot.id,
          amount: next,
          user: ['Bidder A', 'Bidder B', 'Bidder C'][rnd.nextInt(3)]);
    });
  }

  void stopBots() => _botTimer?.cancel();
}
