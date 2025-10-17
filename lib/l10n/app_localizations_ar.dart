// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منصة مزاد الخيول';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get menuLive => 'مباشر';

  @override
  String get menuLots => 'الخيول';

  @override
  String get menuResults => 'النتائج';

  @override
  String get menuDashboard => 'لوحة التحكم';

  @override
  String get menuServices => 'الخدمات';

  @override
  String get menuHistory => 'السجل';

  @override
  String get emptyLive => 'لا توجد خيول مباشرة الآن';

  @override
  String get emptyLots => 'لا توجد خيول للعرض';

  @override
  String get emptyResults => 'لا توجد نتائج بعد';

  @override
  String get confirmBidTitle => 'تأكيد المزايدة';

  @override
  String confirmBidBody(double amount, String lot) {
    return 'هل ترغب بمزايدة بقيمة $amount SAR على \"$lot\"؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get placeBid => 'تأكيد المزايدة';

  @override
  String get bidPlaced => 'تم تسجيل المزايدة!';

  @override
  String currentBidSar(int amount) {
    return 'SAR $amount :الحالي';
  }

  @override
  String minIncSar(int inc) {
    return '$inc+ :الزيادة الدنيا';
  }

  @override
  String endsIn(String text) {
    return 'ينتهي خلال: $text';
  }

  @override
  String get ended => 'انتهى';

  @override
  String get bidPlusMin => 'المزايدة + الدنيا';

  @override
  String get bidPlus2x => 'المزايدة ×2';

  @override
  String get bidTimes2 => '×2 مزايدة';

  @override
  String ageLabel(String v) {
    return '$v :العمر';
  }

  @override
  String breedLabel(String v) {
    return '$v :السلالة';
  }

  @override
  String colorLabel(String v) {
    return '$v :اللون';
  }

  @override
  String heightLabel(String v) {
    return '$v :الارتفاع';
  }

  @override
  String finalPriceSar(int amount) {
    return 'السعر النهائي: SAR $amount';
  }

  @override
  String get cardTotal => 'إجمالي الخيول';

  @override
  String get cardLive => 'مباشر';

  @override
  String get cardSold => 'مباع';

  @override
  String get cardUpcoming => 'قادِم';

  @override
  String get serviceVets => 'فحص بيطري';

  @override
  String get serviceVetsDesc => 'احجز فحص ما قبل الشراء مع أطباء مرخّصين.';

  @override
  String get serviceTransport => 'نقل';

  @override
  String get serviceTransportDesc => 'رتّب نقلاً داخليًا/دوليًا آمنًا.';

  @override
  String get serviceBoarding => 'إيواء';

  @override
  String get serviceBoardingDesc => 'اعثر على الإيواء والتدريب بعد المزاد.';

  @override
  String get hDesertComet => 'Desert Comet • موعد بيطري';

  @override
  String get hGoldenMirage => 'Golden Mirage • حجز نقل';

  @override
  String hAgo(String v) {
    return 'قبل $v';
  }

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusPending => 'قيد الانتظار';
}
