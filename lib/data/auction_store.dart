import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class AuctionLot {
  final int id;
  final String title;
  int currentBid;
  final int minInc;
  DateTime endAt;
  bool reserveMet;
  bool isUserWinning;
  final List<String> imageAssets;

  AuctionLot({
    required this.id,
    required this.title,
    required this.currentBid,
    required this.minInc,
    required this.endAt,
    required this.reserveMet,
    required this.isUserWinning,
    required this.imageAssets,
  });

  bool get isEnded => DateTime.now().isAfter(endAt);

  void bumpBy(int amount, {required bool byUser}) {
    currentBid += amount;
    isUserWinning = byUser;
    // shift end time slightly to simulate anti-sniping
    endAt = endAt.add(const Duration(seconds: 5));
    if (currentBid >= 4000) {
      reserveMet = true;
    }
  }
}

class BidEvent {
  final DateTime at;
  final int lotId;
  final int amount;
  final bool byUser;

  BidEvent({
    required this.at,
    required this.lotId,
    required this.amount,
    required this.byUser,
  });
}

class AuctionStore extends ChangeNotifier {
  AuctionStore._() {
    _seed();
    _startLiveFeed();
  }
  static final AuctionStore I = AuctionStore._();

  final List<AuctionLot> _lots = [];
  int _selectedLotId = 1;

  final _events = StreamController<BidEvent>.broadcast();
  Stream<BidEvent> get eventsStream => _events.stream;

  List<AuctionLot> get lots => List.unmodifiable(_lots);
  int get selectedLotId => _selectedLotId;
  AuctionLot get selected => _lots.firstWhere((e) => e.id == _selectedLotId);

  void select(int lotId) {
    _selectedLotId = lotId;
    notifyListeners();
  }

  void bidMinInc({required int lotId}) {
    final lot = _lots.firstWhere((e) => e.id == lotId);
    lot.bumpBy(lot.minInc, byUser: true);
    _events.add(
      BidEvent(
        at: DateTime.now(),
        lotId: lotId,
        amount: lot.minInc,
        byUser: true,
      ),
    );
    notifyListeners();
  }

  void bidX2({required int lotId}) {
    final lot = _lots.firstWhere((e) => e.id == lotId);
    final amount = lot.minInc * 2;
    lot.bumpBy(amount, byUser: true);
    _events.add(
      BidEvent(at: DateTime.now(), lotId: lotId, amount: amount, byUser: true),
    );
    notifyListeners();
  }

  // ——— Dashboard helpers ———
  int get totalLots => _lots.length;
  int get liveLots => _lots.where((e) => !e.isEnded).length;
  int get soldLots => _lots.where((e) => e.isEnded).length;
  int get reserveMetLots => _lots.where((e) => e.reserveMet).length;

  // ——— Internals ———
  void _seed() {
    final now = DateTime.now();
    _lots
      ..add(
        AuctionLot(
          id: 1,
          title: "Horse #1",
          currentBid: 2700,
          minInc: 100,
          endAt: now.add(const Duration(minutes: 4, seconds: 10)),
          reserveMet: false,
          isUserWinning: false,
          imageAssets: const [
            'assets/horses/horse_1.jpg',
            'assets/horses/horse_1b.jpg',
          ],
        ),
      )
      ..add(
        AuctionLot(
          id: 2,
          title: "Horse #2",
          currentBid: 2900,
          minInc: 100,
          endAt: now.add(const Duration(minutes: 6, seconds: 50)),
          reserveMet: false,
          isUserWinning: false,
          imageAssets: const [
            'assets/horses/horse_2.jpg',
            'assets/horses/horse_2b.jpg',
          ],
        ),
      )
      ..add(
        AuctionLot(
          id: 3,
          title: "Horse #3",
          currentBid: 3200,
          minInc: 100,
          endAt: now.add(const Duration(minutes: 11, seconds: 30)),
          reserveMet: false,
          isUserWinning: false,
          imageAssets: const [
            'assets/horses/horse_3.jpg',
            'assets/horses/horse_3b.jpg',
          ],
        ),
      )
      ..add(
        AuctionLot(
          id: 4,
          title: "Horse #4",
          currentBid: 3600,
          minInc: 100,
          endAt: now.add(const Duration(minutes: 16, seconds: 10)),
          reserveMet: false,
          isUserWinning: false,
          imageAssets: const [
            'assets/horses/horse_4.jpg',
            'assets/horses/horse_4b.jpg',
          ],
        ),
      );
  }

  Timer? _ticker;

  void _startLiveFeed() {
    final rng = Random();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lots.isEmpty) return;
      final active = _lots.where((e) => !e.isEnded).toList();
      if (active.isEmpty) return;

      final lot = active[rng.nextInt(active.length)];
      // Simulate other bidder outbidding the user randomly
      final amount = lot.minInc * (rng.nextBool() ? 1 : 2);
      lot.bumpBy(amount, byUser: false);
      _events.add(
        BidEvent(
          at: DateTime.now(),
          lotId: lot.id,
          amount: amount,
          byUser: false,
        ),
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _events.close();
    super.dispose();
  }
}
