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
  String get lotsTitle => 'Lots';

  @override
  String get language => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langArabic => 'Arabic';

  @override
  String get tabAll => 'All';

  @override
  String get tabLive => 'Live';

  @override
  String get tabClosed => 'Closed';

  @override
  String get errorLoadingLots => 'Error loading lots';

  @override
  String get noData => 'Nothing to show';

  @override
  String get current => 'Current';

  @override
  String get next => 'Next';

  @override
  String get step => 'Step';

  @override
  String get statusLive => 'Live';

  @override
  String get statusClosed => 'Closed';

  @override
  String get bid => 'Bid';

  @override
  String get bidPlaced => 'Bid placed';

  @override
  String get placeBid => 'Place bid';

  @override
  String get amount => 'Amount';

  @override
  String get min => 'Min';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get seedLots => 'Seed lots';
}
