import 'lots_service.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  Future<String> seedLotsOnce() async {
    return LotsService.instance.seedLotsOnce();
  }
}
