import 'package:flutter/foundation.dart';
import '../models/auction_lot.dart';

class AuctionStore extends ChangeNotifier {
  AuctionStore(this.lots);

  final List<AuctionLot> lots;

  // Counters used by your dashboard cards
  int get totalCount => lots.length;
  int get liveCount =>
      lots.where((l) => l.status == AuctionLotStatus.live).length;
  int get soldCount =>
      lots.where((l) => l.status == AuctionLotStatus.sold).length;
  int get upcomingCount =>
      lots.where((l) => l.status == AuctionLotStatus.upcoming).length;

  void placeBid(String lotId, int amount) {
    final lot = lots.firstWhere((l) => l.id == lotId,
        orElse: () => throw ArgumentError('Lot not found'));
    // Only allow if live and amount >= current + minIncrement
    final minAllowed = lot.currentBid + lot.minIncrement;
    if (lot.status == AuctionLotStatus.live && amount >= minAllowed) {
      lot.currentBid = amount;
      notifyListeners();
    }
  }
}
