import 'package:flutter/material.dart';

/// Global locale holder (super light).
class AppLocale extends ChangeNotifier {
  AppLocale._();
  static final AppLocale instance = AppLocale._();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void setLocale(Locale? value) {
    if (value == null) return;
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }

  void toggleEnAr() {
    setLocale(
        _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }
}
