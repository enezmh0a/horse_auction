import 'package:cloud_firestore/cloud_firestore.dart';
import 'lots_service.dart';
import 'bids_service.dart';

class Services {
  Services._();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final lots = LotsService(_db);
  static final bids = BidsService(_db);
}
