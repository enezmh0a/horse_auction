// lib/core/locale_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LocaleController {
  // App starts in English; change to 'ar' if you want Arabic by default
  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('en'),
  );

  Future<void> toggle() async {
    final current = locale.value.languageCode;
    final next = current == 'ar' ? const Locale('en') : const Locale('ar');
    locale.value = next;
  }
}
