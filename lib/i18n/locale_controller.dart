import 'package:flutter/material.dart';

class LocaleController {
  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('en'));

  static void toggle() {
    final isEn = locale.value.languageCode == 'en';
    locale.value = Locale(isEn ? 'ar' : 'en');
  }
}
