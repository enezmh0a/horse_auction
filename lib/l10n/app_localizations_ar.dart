// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مزادات الخيل';

  @override
  String get lots => 'الدفعات';

  @override
  String get all => 'الكل';

  @override
  String get live => 'مباشر';

  @override
  String get closed => 'مغلق';

  @override
  String get bid => 'مزاد';

  @override
  String get current => 'الحالي';

  @override
  String get next => 'التالي';

  @override
  String get step => 'الزيادة';

  @override
  String get noData => 'لا يوجد شيء للعرض';

  @override
  String get errorLoadingLots => 'حدث خطأ أثناء تحميل الدُفعات';

  @override
  String get seedLots => 'إضافة بيانات تجريبية';

  @override
  String get seeded => 'تمت إضافة عينات';

  @override
  String get seedFailed => 'فشل في إضافة العينات';
}
