// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get servicesTitle => 'الخدمات';

  @override
  String get tierPlatinum => 'بلاتينيوم';

  @override
  String get tierPlatinumDesc => 'أعلى ظهور، دعم مخصص، إبراز مميز.';

  @override
  String get tierGold => 'ذهبي';

  @override
  String get tierGoldDesc => 'ظهور عالٍ ومساحات ترويجية.';

  @override
  String get tierSilver => 'فضي';

  @override
  String get tierSilverDesc => 'حزمة بداية ممتازة للإدراج بسرعة.';
}
