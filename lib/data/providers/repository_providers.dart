import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/auth_repository.dart';
import '../repositories/bidding_repository.dart';
import '../repositories/user_repository.dart';

// Firebase
final firebaseAuthProvider = Provider<FirebaseFirestore>(
    (_) => FirebaseFirestore.instance); // (if you need Firestore provider)

// Repositories
final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository(ref));
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return AuthRepository(ref, userRepo);
});
final biddingRepositoryProvider = Provider<BiddingRepository>(
    (ref) => BiddingRepository(FirebaseFirestore.instance));
