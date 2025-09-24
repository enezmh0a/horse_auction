import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _key = 'locale_code';
  static final LocaleController instance = LocaleController._();
  LocaleController._();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_key);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    if (code == _locale.languageCode) return;
    _locale = Locale(code);
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, code);
  }

  void toggle() {
    setLocale(_locale.languageCode == 'ar' ? 'en' : 'ar');
  }
}
