// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مزادات الخيول';

  @override
  String get lotsTitle => 'اللوتات';

  @override
  String get language => 'اللغة';

  @override
  String get langEnglish => 'الإنجليزية';

  @override
  String get langArabic => 'العربية';

  @override
  String get tabAll => 'الكل';

  @override
  String get tabLive => 'مباشر';

  @override
  String get tabClosed => 'مغلق';

  @override
  String get errorLoadingLots => 'حدث خطأ عند تحميل اللوتات';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get current => 'الحالي';

  @override
  String get next => 'التالي';

  @override
  String get step => 'الزيادة';

  @override
  String get statusLive => 'مباشر';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get bid => 'مزايدة';

  @override
  String get bidPlaced => 'تم تقديم المزايدة';

  @override
  String get placeBid => 'تقديم مزايدة';

  @override
  String get amount => 'المبلغ';

  @override
  String get min => 'الحد الأدنى';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get seedLots => 'تعبئة لوتات';
}
