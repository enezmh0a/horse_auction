import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:horse_auction_baseline/models/lot_model.dart';

final lotStreamProvider = StreamProvider.family<LotModel?, String>((
  ref,
  id,
) async* {
  yield null;
});

final bidsStreamProvider = StreamProvider.family<List<BidModel>, String>((
  ref,
  lotId,
) async* {
  yield <BidModel>[];
});

final bidsStreamProvider = StreamProvider.family<List<BidModel>, String>((
  ref,
  lotId,
) async* {
  yield <BidModel>[];
});
