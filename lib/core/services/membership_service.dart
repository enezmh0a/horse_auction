import 'package:flutter/foundation.dart';

/// Minimal membership flag + notifier.
/// Gate member-only UI (e.g., History "Last" tab).
class MembershipService extends ChangeNotifier {
  MembershipService._();
  static final MembershipService instance = MembershipService._();

  bool _isMember = false;
  bool get isMember => _isMember;

  void setMember(bool v) {
    if (_isMember == v) return;
    _isMember = v;
    notifyListeners();
  }
}
