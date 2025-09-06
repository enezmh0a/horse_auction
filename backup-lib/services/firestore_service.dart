import 'package:cloud_firestore/cloud_firestore.dart';

class BidTooLowException implements Exception {
  final num minAllowed;
  BidTooLowException(this.minAllowed);
  @override
  String toString() => 'Bid too low. Minimum allowed: $minAllowed';
}

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream lots ordered by createdAt desc
  static Stream<QuerySnapshot<Map<String, dynamic>>> lotsStream() {
    return _db.collection('lots')
      .orderBy('createdAt', descending: true)
      .snapshots();
  }

  /// Stream bids for a horse ordered by amount desc
  static Stream<QuerySnapshot<Map<String, dynamic>>> bidsStream(String horseId) {
    return _db.collection('lots')
      .doc(horseId)
      .collection('bids')
      .orderBy('amount', descending: true)
      .snapshots();
  }

  /// Add a horse/lot (integers only for numeric fields)
  static Future<void> addHorse({
    required String name,
    required String breed,
    required int age,
    required String owner,
    required num startingPrice, // Changed to num
    required num minIncrement,  // Changed to num
    String imageUrl = "",
  }) async {
    await _db.collection('lots').add({
      'name': name,
      'breed': breed,
      'age': age,
      'owner': owner,
      'startingPrice': startingPrice,
      'minIncrement': minIncrement,
      'currentHighest': 0,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Place a bid safely in a transaction.
  /// Validates min increment against currentHighest/startingPrice.
  static Future<void> placeBid({
    required String horseId,
    required num amount, // Changed to num
    required String userId,
  }) async {
    final lotRef = _db.collection('lots').doc(horseId);
    final newBidRef = lotRef.collection('bids').doc();

    await _db.runTransaction((tx) async {
      final lotSnap = await tx.get(lotRef);
      if (!lotSnap.exists) {
        throw StateError('Horse not found');
      }

      final data = lotSnap.data() as Map<String, dynamic>;

      // Helper to safely read numeric values from Firestore
      num _num(dynamic v, [num fallback = 0]) {
        if (v == null) return fallback;
        if (v is num) return v;
        if (v is String) return num.tryParse(v) ?? fallback;
        return fallback;
      }

      final num startingPrice = _num(data['startingPrice']);
      final num currentHighest = _num(data['currentHighest']);
      final num minIncrement = _num(data['minIncrement'], 50);

      final base = currentHighest > 0 ? currentHighest : startingPrice;
      final minAllowed = base + minIncrement;

      if (amount < minAllowed) {
        // Throw a Dart exception we can catch in UI (no native crash)
        throw BidTooLowException(minAllowed);
      }

      // Write the bid and update the lot atomically
      tx.set(newBidRef, {
        'amount': amount,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(lotRef, {
        'currentHighest': amount,
        'lastBidAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Added streamHorse for the detail screen
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamHorse(String horseId) {
    return _db.collection('lots').doc(horseId).snapshots();
  }
}