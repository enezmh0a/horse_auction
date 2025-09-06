import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all lots (horses)
  Stream<QuerySnapshot<Map<String, dynamic>>> lotsStream() {
    return _db.collection('lots').orderBy('createdAt', descending: true).snapshots();
  }

  // Stream a single lot
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamHorse(String horseId) {
    return _db.collection('lots').doc(horseId).snapshots();
  }

  // Add a horse (keeps defaults for bidding fields if missing)
  Future<void> addHorse({
    required String name,
    required String breed,
    required int age,
    required String owner,
    required int startingPrice,
    String imageUrl = '',
  }) async {
    final now = FieldValue.serverTimestamp();
    await _db.collection('lots').add({
      'name': name,
      'breed': breed,
      'age': age,
      'owner': owner,
      'startingPrice': startingPrice,
      'imageUrl': imageUrl,
      'createdAt': now,
      // bidding defaults
      'currentHighest': 0,
      'minIncrement': 50,
    });
  }

  // Simple place bid: client-side check + add bid + merge currentHighest if needed
  Future<void> placeBid({
    required String horseId,
    required int amount,
    required String userId,
  }) async {
    final lotRef = _db.collection('lots').doc(horseId);
    final bidRef = lotRef.collection('bids').doc();

    // Write the bid first
    await bidRef.set({
      'amount': amount,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Try to lift currentHighest if this bid is higher (simple, non-transactional)
    await lotRef.set(
      {
        'currentHighest': amount,
      },
      SetOptions(merge: true),
    );
  }

  // Optional: stream bids for a horse
  Stream<QuerySnapshot<Map<String, dynamic>>> bidsStream(String horseId) {
    return _db
        .collection('lots')
        .doc(horseId)
        .collection('bids')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
