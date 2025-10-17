import 'package:flutter/foundation.dart';
import '../models/lot_model.dart';
import 'live_bids_service.dart';

/// Shim/wrapper so old code that expected an AuctionService
/// can use the new LiveBidsService + LotModel.
class AuctionService {
  AuctionService._();
  static final AuctionService instance = AuctionService._();

  final LiveBidsService _svc = LiveBidsService.instance;

  ValueListenable<List<LotModel>> get lotsListenable => _svc.lotsListenable;
  List<LotModel> get lots => _svc.lots;

  List<LotModel> liveLots() => _svc.liveLots();
  List<LotModel> upcomingLots() => _svc.upcomingLots();
  List<LotModel> resultsLots() => _svc.resultsLots();

  bool placeBid({required String lotId, required int amount}) {
    return _svc.placeBid(lotId, amount);
  }

  LotModel? byId(String id) => _svc.byId(id);
}
