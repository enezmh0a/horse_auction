import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

/// Minimal stub so pages compile. Replace with your real impl later.
/// Use your repository or Firestore here if you want real data.
class _LotModelFake {}

final liveLotsStreamProvider = StreamProvider<List<_LotModelFake>>((
  ref,
) async* {
  yield <_LotModelFake>[]; // empty list keeps UI happy for now
});

// Older pages reference this alias name.
final lotsStreamProvider = liveLotsStreamProvider;
