import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  Locale? _locale;
  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
