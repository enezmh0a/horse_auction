import 'package:flutter/foundation.dart';
import '../models/lot_model.dart';

/// Very simple in-memory service.
/// In production you’d back this with WebSocket/REST.
class LiveBidsService {
  LiveBidsService._();
  static final LiveBidsService instance = LiveBidsService._();

  final ValueNotifier<List<LotModel>> _lots =
      ValueNotifier<List<LotModel>>(buildDemoLots());
  ValueListenable<List<LotModel>> get lotsListenable => _lots;

  List<LotModel> get lots => _lots.value;

  /// Find a lot by id.
  LotModel? byId(String id) =>
      _lots.value.firstWhere((e) => e.id == id, orElse: () => null as LotModel);

  /// Place a bid with confirmation already done by the UI.
  /// Returns true if accepted.
  bool placeBid(String lotId, int amount) {
    final lot = _lots.value.firstWhere((e) => e.id == lotId,
        orElse: () => throw StateError('Lot not found'));
    if (lot.isClosed) return false;
    final requiredMin = lot.currentBid.value + lot.minIncrement;
    if (amount < requiredMin) return false;
    lot.currentBid.value = amount;
    // Notify list listeners (e.g., to repaint lists)
    _lots.value = List<LotModel>.from(_lots.value);
    return true;
  }

  /// Helpers
  List<LotModel> liveLots() => _lots.value
      .where((l) => l.status == LotStatus.live && !l.isClosed)
      .toList();
  List<LotModel> upcomingLots() =>
      _lots.value.where((l) => l.status == LotStatus.upcoming).toList();
  List<LotModel> resultsLots() => _lots.value
      .where((l) =>
          l.isClosed ||
          l.status == LotStatus.sold ||
          l.status == LotStatus.reserveNotMet)
      .toList();
}
