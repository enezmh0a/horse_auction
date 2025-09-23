// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Horse Auctions';

  @override
  String get lots => 'Lots';

  @override
  String get all => 'All';

  @override
  String get live => 'Live';

  @override
  String get closed => 'Closed';

  @override
  String get bid => 'Bid';

  @override
  String get current => 'Current';

  @override
  String get next => 'Next';

  @override
  String get step => 'Step';

  @override
  String get noData => 'Nothing to show';

  @override
  String get errorLoadingLots => 'Error loading lots';

  @override
  String get seedLots => 'Seed lots';

  @override
  String get seeded => 'Seeded a few lots';

  @override
  String get seedFailed => 'Failed to seed lots';
}
