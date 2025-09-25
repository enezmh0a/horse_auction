import 'package:flutter/material.dart';

abstract class AppLocalizations {
  const AppLocalizations();

  // Accessor
  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  // Delegate + supported locales
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  // ====== Strings used across your UI ======
  String get title; // AppBar title
  String get language; // Language tooltip
  String get langEnglish; // English label
  String get langArabic; // Arabic label
  String get restartedApplied; // Shown after toggling language
  String get restartToApply; // (alias, used by older code)

  String get homeTitle;
  String get horsesTitle;
  String get servicesTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode.toLowerCase()) {
      case 'ar':
        return const _AppLocalizationsAr();
      case 'en':
      default:
        return const _AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English
class _AppLocalizationsEn extends AppLocalizations {
  const _AppLocalizationsEn();

  @override
  String get title => 'Horse Auctions';
  @override
  String get language => 'Language';
  @override
  String get langEnglish => 'English';
  @override
  String get langArabic => 'العربية';
  @override
  String get restartedApplied => 'Language changed.';
  @override
  String get restartToApply => 'Language changed.';

  @override
  String get homeTitle => 'Home';
  @override
  String get horsesTitle => 'Horses';
  @override
  String get servicesTitle => 'Services';
}

// Arabic
class _AppLocalizationsAr extends AppLocalizations {
  const _AppLocalizationsAr();

  @override
  String get title => 'مزادات الخيل';
  @override
  String get language => 'اللغة';
  @override
  String get langEnglish => 'English';
  @override
  String get langArabic => 'العربية';
  @override
  String get restartedApplied => 'تم تغيير اللغة.';
  @override
  String get restartToApply => 'تم تغيير اللغة.';

  @override
  String get homeTitle => 'الرئيسية';
  @override
  String get horsesTitle => 'الخيل';
  @override
  String get servicesTitle => 'الخدمات';
}
