import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  void toggle() {
    _locale =
        _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }

  void set(Locale loc) {
    _locale = loc;
    notifyListeners();
  }
}
