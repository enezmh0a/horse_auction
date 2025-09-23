import 'package:cloud_functions/cloud_functions.dart';

class AdminService {
  AdminService._();
  static final instance = AdminService._();
  final _fns = FirebaseFunctions.instanceFor(region: 'me-central1');

  Future<Map<String, dynamic>> backfillPriceTiers() async {
    final res = await _fns.httpsCallable('backfillPriceTiers').call();
    return Map<String, dynamic>.from(res.data ?? {});
    }

  Future<Map<String, dynamic>> closeExpiredLotsNow() async {
    final res = await _fns.httpsCallable('closeExpiredLotsNow').call();
    return Map<String, dynamic>.from(res.data ?? {});
  }
}
