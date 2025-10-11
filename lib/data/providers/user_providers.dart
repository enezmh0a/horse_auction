import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/windows_firestore_safe.dart';

/// Returns the raw map for flexibility (avoids model churn)
final currentUserProfileStreamProvider =
    StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final auth = FirebaseFirestore
      .instance; // replace with your firebaseAuthProvider if you have one
  // If you have an auth provider, grab the uid from there:
  // final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  final uid = FirebaseFirestore.instance.app.options.projectId.isNotEmpty
      ? null
      : null; // <— replace with your actual UID source

  if (uid == null) {
    // No user signed in: emit null
    return Stream.value(null);
  }

  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  return windowsSafeDocStream<Map<String, dynamic>?>(
    docRef: docRef,
    mapDoc: (snap) => snap.data(),
  );
});
