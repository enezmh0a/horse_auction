import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

<<<<<<< HEAD
  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Horse Auction Baseline'**
  String get appTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @menuLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get menuLive;

  /// No description provided for @menuLots.
  ///
  /// In en, this message translates to:
  /// **'Lots'**
  String get menuLots;

  /// No description provided for @menuResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get menuResults;

  /// No description provided for @menuDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get menuDashboard;

  /// No description provided for @menuServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get menuServices;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menuHistory;

  /// No description provided for @emptyLive.
  ///
  /// In en, this message translates to:
  /// **'No live lots right now'**
  String get emptyLive;

  /// No description provided for @emptyLots.
  ///
  /// In en, this message translates to:
  /// **'No lots to show'**
  String get emptyLots;

  /// No description provided for @emptyResults.
  ///
  /// In en, this message translates to:
  /// **'No results yet'**
  String get emptyResults;

  /// No description provided for @confirmBidTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your bid'**
  String get confirmBidTitle;

  /// No description provided for @confirmBidBody.
  ///
  /// In en, this message translates to:
  /// **'Place a bid of {amount} SAR on {lot}?'**
  String confirmBidBody(double amount, String lot);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @placeBid.
  ///
  /// In en, this message translates to:
  /// **'Place bid'**
  String get placeBid;

  /// No description provided for @bidPlaced.
  ///
  /// In en, this message translates to:
  /// **'Bid placed!'**
  String get bidPlaced;

  /// No description provided for @currentBidSar.
  ///
  /// In en, this message translates to:
  /// **'Current: SAR {amount}'**
  String currentBidSar(int amount);

  /// No description provided for @minIncSar.
  ///
  /// In en, this message translates to:
  /// **'Min +{inc}'**
  String minIncSar(int inc);

  /// No description provided for @endsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in: {text}'**
  String endsIn(String text);

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @bidPlusMin.
  ///
  /// In en, this message translates to:
  /// **'Bid + Min'**
  String get bidPlusMin;

  /// No description provided for @bidPlus2x.
  ///
  /// In en, this message translates to:
  /// **'Bid + 2×'**
  String get bidPlus2x;

  /// No description provided for @bidTimes2.
  ///
  /// In en, this message translates to:
  /// **'Bid ×2'**
  String get bidTimes2;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age: {v}'**
  String ageLabel(String v);

  /// No description provided for @breedLabel.
  ///
  /// In en, this message translates to:
  /// **'Breed: {v}'**
  String breedLabel(String v);

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color: {v}'**
  String colorLabel(String v);

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height: {v}'**
  String heightLabel(String v);

  /// No description provided for @finalPriceSar.
  ///
  /// In en, this message translates to:
  /// **'Final price: SAR {amount}'**
  String finalPriceSar(int amount);

  /// No description provided for @cardTotal.
  ///
  /// In en, this message translates to:
  /// **'Total lots'**
  String get cardTotal;

  /// No description provided for @cardLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get cardLive;

  /// No description provided for @cardSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get cardSold;

  /// No description provided for @cardUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get cardUpcoming;

  /// No description provided for @serviceVets.
  ///
  /// In en, this message translates to:
  /// **'Veterinary check'**
  String get serviceVets;

  /// No description provided for @serviceVetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Book a pre-purchase exam with licensed vets.'**
  String get serviceVetsDesc;

  /// No description provided for @serviceTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get serviceTransport;

  /// No description provided for @serviceTransportDesc.
  ///
  /// In en, this message translates to:
  /// **'Arrange national/international transport.'**
  String get serviceTransportDesc;

  /// No description provided for @serviceBoarding.
  ///
  /// In en, this message translates to:
  /// **'Boarding'**
  String get serviceBoarding;

  /// No description provided for @serviceBoardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Find boarding and training after the auction.'**
  String get serviceBoardingDesc;

  /// No description provided for @hDesertComet.
  ///
  /// In en, this message translates to:
  /// **'Desert Comet • Vet appointment'**
  String get hDesertComet;

  /// No description provided for @hGoldenMirage.
  ///
  /// In en, this message translates to:
  /// **'Golden Mirage • Transport booking'**
  String get hGoldenMirage;

  /// No description provided for @hAgo.
  ///
  /// In en, this message translates to:
  /// **'{v} ago'**
  String hAgo(String v);

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;
=======
  /// No description provided for @lotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lots'**
  String get lotsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @errorLoadingLots.
  ///
  /// In en, this message translates to:
  /// **'Error loading lots'**
  String get errorLoadingLots;

  /// No description provided for @noLots.
  ///
  /// In en, this message translates to:
  /// **'No lots yet'**
  String get noLots;

  /// No description provided for @horseDetails.
  ///
  /// In en, this message translates to:
  /// **'Horse details'**
  String get horseDetails;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @highestLabel.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highestLabel;

  /// No description provided for @startingLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get startingLabel;

  /// No description provided for @currentHighestLabel.
  ///
  /// In en, this message translates to:
  /// **'Current highest'**
  String get currentHighestLabel;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min step'**
  String get minLabel;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @decrement.
  ///
  /// In en, this message translates to:
  /// **'Decrement'**
  String get decrement;

  /// No description provided for @increment.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get increment;

  /// No description provided for @placeBid.
  ///
  /// In en, this message translates to:
  /// **'Place bid'**
  String get placeBid;

  /// No description provided for @bidPlaced.
  ///
  /// In en, this message translates to:
  /// **'Bid placed'**
  String get bidPlaced;

  /// No description provided for @bidFailed.
  ///
  /// In en, this message translates to:
  /// **'Bid failed'**
  String get bidFailed;

  /// No description provided for @recentBids.
  ///
  /// In en, this message translates to:
  /// **'Recent bids'**
  String get recentBids;

  /// No description provided for @noBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No bids yet'**
  String get noBidsYet;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currency;

  /// No description provided for @byUser.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get byUser;

  /// No description provided for @closeAuction.
  ///
  /// In en, this message translates to:
  /// **'Close auction'**
  String get closeAuction;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;
>>>>>>> origin/main
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
