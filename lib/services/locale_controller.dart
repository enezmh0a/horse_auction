import 'package:flutter/material.dart';

/// Simple global controller to switch app locale at runtime.
class LocaleController {
  LocaleController._();
  static final instance = LocaleController._();

  /// null = follow system, or set to Locale('en') / Locale('ar')
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  void toggle() {
    final cur = locale.value?.languageCode;
    if (cur == 'ar') {
      locale.value = const Locale('en');
    } else {
      locale.value = const Locale('ar');
    }
  }
}
