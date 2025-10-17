// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Horse Auction Baseline';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get menuLive => 'Live';

  @override
  String get menuLots => 'Lots';

  @override
  String get menuResults => 'Results';

  @override
  String get menuDashboard => 'Dashboard';

  @override
  String get menuServices => 'Services';

  @override
  String get menuHistory => 'History';

  @override
  String get emptyLive => 'No live lots right now';

  @override
  String get emptyLots => 'No lots to show';

  @override
  String get emptyResults => 'No results yet';

  @override
  String get confirmBidTitle => 'Confirm your bid';

  @override
  String confirmBidBody(double amount, String lot) {
    return 'Place a bid of $amount SAR on $lot?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get placeBid => 'Place bid';

  @override
  String get bidPlaced => 'Bid placed!';

  @override
  String currentBidSar(int amount) {
    return 'Current: SAR $amount';
  }

  @override
  String minIncSar(int inc) {
    return 'Min +$inc';
  }

  @override
  String endsIn(String text) {
    return 'Ends in: $text';
  }

  @override
  String get ended => 'Ended';

  @override
  String get bidPlusMin => 'Bid + Min';

  @override
  String get bidPlus2x => 'Bid + 2×';

  @override
  String get bidTimes2 => 'Bid ×2';

  @override
  String ageLabel(String v) {
    return 'Age: $v';
  }

  @override
  String breedLabel(String v) {
    return 'Breed: $v';
  }

  @override
  String colorLabel(String v) {
    return 'Color: $v';
  }

  @override
  String heightLabel(String v) {
    return 'Height: $v';
  }

  @override
  String finalPriceSar(int amount) {
    return 'Final price: SAR $amount';
  }

  @override
  String get cardTotal => 'Total lots';

  @override
  String get cardLive => 'Live';

  @override
  String get cardSold => 'Sold';

  @override
  String get cardUpcoming => 'Upcoming';

  @override
  String get serviceVets => 'Veterinary check';

  @override
  String get serviceVetsDesc => 'Book a pre-purchase exam with licensed vets.';

  @override
  String get serviceTransport => 'Transport';

  @override
  String get serviceTransportDesc => 'Arrange national/international transport.';

  @override
  String get serviceBoarding => 'Boarding';

  @override
  String get serviceBoardingDesc => 'Find boarding and training after the auction.';

  @override
  String get hDesertComet => 'Desert Comet • Vet appointment';

  @override
  String get hGoldenMirage => 'Golden Mirage • Transport booking';

  @override
  String hAgo(String v) {
    return '$v ago';
  }

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPending => 'Pending';
}
