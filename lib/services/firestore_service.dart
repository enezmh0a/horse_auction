// lib/services/firestore_service.dart
import 'dart:async';
import '../models/bid_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  /// Old code calls FirestoreService().bidsStream(userId)
  Stream<List<BidModel>> bidsStream(String userId) async* {
    yield const <BidModel>[];
  }
}
