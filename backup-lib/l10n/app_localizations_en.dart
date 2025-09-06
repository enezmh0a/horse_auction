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
  String get tabHome => 'Home';

  @override
  String get tabLots => 'Lots';

  @override
  String get tabBidding => 'Bidding';

  @override
  String get tabSeller => 'Seller';

  @override
  String get tabProfile => 'Profile';

  @override
  String get homeLive => 'Live Auctions';

  @override
  String get homeEnding => 'Ending Soon';

  @override
  String get homeSell => 'Sell a Horse';

  @override
  String get homeLiveSub => 'Join ongoing sales with anti-sniping timers.';

  @override
  String get homeEndingSub => 'Last few minutes — place your bid now.';

  @override
  String get homeSellSub => 'Create a lot, set reserve, upload documents.';

  @override
  String get lotReserveMet => 'Reserve Met';

  @override
  String get lotReserveNotMet => 'Reserve Not Met';

  @override
  String get registerToBid => 'Register to Bid';
}
