import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wire this to your real repository later.
/// Keeping it `dynamic` avoids method-mismatch analyzer errors for now.
final lotRepositoryProvider = Provider<dynamic>((ref) => Object());
