import 'package:cloud_functions/cloud_functions.dart';

class BidService {
  final _functions = FirebaseFunctions.instanceFor(region: 'me-central1');

  Future<Map<String, dynamic>> placeBid({
    required String lotId,
    required int amount,
  }) async {
    final callable = _functions.httpsCallable('placeBid');
    final result = await callable.call<Map<String, dynamic>>({
      'lotId': lotId,
      'bidAmount': amount,
    });
    final data = Map<String, dynamic>.from(result.data ?? {});
    return data;
  }
}
