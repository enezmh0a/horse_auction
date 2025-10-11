import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  UserRepository(this._ref);
  final Ref _ref;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Create/merge a user profile document at `users/{userId}`.
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await _users.doc(userId).set({
      'email': email,
      'displayName': displayName ?? '',
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
