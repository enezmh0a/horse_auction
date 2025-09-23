import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void toggle() {
    if (_locale?.languageCode == 'ar') {
      setEnglish();
    } else {
      setArabic();
    }
  }
}

final localeController = LocaleController();
