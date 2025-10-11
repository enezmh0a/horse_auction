// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Horse Auction';

  @override
  String get live => 'Live';

  @override
  String get lots => 'Lots';

  @override
  String get results => 'Results';

  @override
  String get current => 'Current';

  @override
  String get minIncrement => 'Min increment';

  @override
  String get timeLeft => 'Time left';

  @override
  String get yourBid => 'Your bid';

  @override
  String get placeBid => 'Place bid';

  @override
  String get liveTab => 'Live';

  @override
  String get lotsTab => 'Lots';

  @override
  String get resultsTab => 'Results';

  @override
  String get toggleLanguage => 'Toggle language';

  @override
  String get noLiveLots => 'No live lots right now.';

  @override
  String get noLotsAvailable => 'No lots available.';

  @override
  String get noResults => 'No results yet.';

  @override
  String bidPlaced(String amount) {
    return 'Bid placed: $amount';
  }

  @override
  String get bidTooLow => 'Your bid is too low';

  @override
  String get sold => 'Sold';

  @override
  String get finalPrice => 'Final';
}
