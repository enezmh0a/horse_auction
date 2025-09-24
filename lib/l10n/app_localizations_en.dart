// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get servicesTitle => 'Services';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get tierPlatinumDesc => 'Top exposure, concierge support, featured placement.';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierGoldDesc => 'High visibility listing and promo slots.';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierSilverDesc => 'Great starter package to get listed quickly.';
}
