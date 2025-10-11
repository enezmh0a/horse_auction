// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مزاد الخيل';

  @override
  String get live => 'البث المباشر';

  @override
  String get lots => 'الخيل';

  @override
  String get results => 'النتائج';

  @override
  String get current => 'الحالي';

  @override
  String get minIncrement => 'أقل زيادة';

  @override
  String get timeLeft => 'الوقت المتبقي';

  @override
  String get yourBid => 'مزايدتك';

  @override
  String get placeBid => 'تأكيد المزايدة';

  @override
  String get liveTab => 'البث المباشر';

  @override
  String get lotsTab => 'الخيول';

  @override
  String get resultsTab => 'النتائج';

  @override
  String get toggleLanguage => 'تبديل اللغة';

  @override
  String get noLiveLots => 'لا توجد خيول مباشرة حالياً.';

  @override
  String get noLotsAvailable => 'لا توجد خيول متاحة.';

  @override
  String get noResults => 'لا توجد نتائج بعد.';

  @override
  String bidPlaced(String amount) {
    return 'تمت المزايدة: $amount';
  }

  @override
  String get bidTooLow => 'عرضك أقل من المسموح';

  @override
  String get sold => 'مباع';

  @override
  String get finalPrice => 'النهائي';
}
