// lib/data/providers/locale_provider.dart
import 'package:flutter/widgets.dart' show Locale;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleController, Locale?>(
    (ref) => LocaleController());

class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(const Locale('en'));

  void setLocale(Locale? locale) => state = locale;

  /// Simple en/ar toggle so existing UI calls to `.toggle()` work.
  void toggle() => state =
      (state?.languageCode == 'ar') ? const Locale('en') : const Locale('ar');
}
