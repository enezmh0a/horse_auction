import 'package:flutter/foundation.dart';
import 'package:horse_auction_app/services/lots_service.dart';

/// Result of attempting to place a bid.
class BidResult {
  final String code; // 'ok' | 'closed' | 'min' | 'step' | 'invalid'
  final String message;
  final int min;
  final Lot lot;
  bool get ok => code == 'ok';
  const BidResult(this.code, this.message, this.min, this.lot);
}

class BidService {
  BidService._();
  static final BidService instance = BidService._();

  /// Validates then updates the lot’s current price.
  BidResult placeBid({required Lot lot, required int amount}) {
    final min = lot.current + lot.step;

    if (!lot.live) {
      return BidResult('closed', 'Lot is closed', min, lot);
    }
    if (amount < min) {
      return BidResult('min', 'Minimum is $min', min, lot);
    }
    if ((amount - lot.current) % lot.step != 0) {
      return BidResult('step', 'Bid must be in steps of ${lot.step}', min, lot);
    }

    final updated = lot.copyWith(current: amount);
    LotsService.instance.upsert(updated);
    return BidResult('ok', 'Bid placed', min, updated);
  }
}
