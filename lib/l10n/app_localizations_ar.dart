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
  String get tabHome => 'الرئيسية';

  @override
  String get tabLots => 'العروض';

  @override
  String get tabBidding => 'المزايدة';

  @override
  String get tabSeller => 'البائع';

  @override
  String get tabProfile => 'حسابي';

  @override
  String get homeLive => 'المزادات المباشرة';

  @override
  String get homeEnding => 'تنتهي قريباً';

  @override
  String get homeSell => 'بيع حصان';

  @override
  String get homeLiveSub => 'انضم للمزادات الجارية مع تمديد مضاد للقنص.';

  @override
  String get homeEndingSub => 'الدقائق الأخيرة — قدّم مزايدتك الآن.';

  @override
  String get homeSellSub => 'أنشئ عرضاً وحدد الحد الأدنى وارفع المستندات.';

  @override
  String get lotReserveMet => 'تم بلوغ الحد الأدنى';

  @override
  String get lotReserveNotMet => 'لم يُبلغ الحد الأدنى';

  @override
  String get registerToBid => 'التسجيل للمزايدة';
}
