import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Query → Stream<List<T>>
Stream<List<T>> windowsSafeQueryStream<T>({
  required Query<Map<String, dynamic>> query,
  required T Function(DocumentSnapshot<Map<String, dynamic>> doc) mapDoc,
  Duration poll = const Duration(seconds: 5),
}) {
  if (!Platform.isWindows) {
    return query.snapshots().map((snap) => snap.docs.map(mapDoc).toList());
  }
  return Stream.periodic(poll)
      .asyncMap((_) => query.get())
      .map((snap) => snap.docs.map(mapDoc).toList());
}

/// Document → Stream<T?>
Stream<T?> windowsSafeDocStream<T>({
  required DocumentReference<Map<String, dynamic>> docRef,
  required T? Function(DocumentSnapshot<Map<String, dynamic>> doc) mapDoc,
  Duration poll = const Duration(seconds: 5),
}) {
  if (!Platform.isWindows) {
    return docRef.snapshots().map(mapDoc);
  }
  return Stream.periodic(poll).asyncMap((_) => docRef.get()).map(mapDoc);
}
