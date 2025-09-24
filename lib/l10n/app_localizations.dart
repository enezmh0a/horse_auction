import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _L();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  // Strings used in UI
  String get title => _t('Horse Auctions', 'مزادات الخيول');
  String get servicesTitle => _t('Services', 'الخدمات');
  String get horsesTitle => _t('Horses', 'الخيل');

  String get langEnglish => _t('English', 'الإنجليزية');
  String get langArabic => _t('Arabic', 'العربية');

  String get seedLots => _t('Seed lots', 'إنشاء بيانات تجريبية');
  String get alreadySeeded => _t('Already seeded', 'تم الإنشاء مسبقاً.');
  String get seedDone => _t('Seeded.', 'تم إنشاء البيانات.');
  String get working => _t('Working…', 'جاري التنفيذ…');

  String get placeBid => _t('Place bid', 'تقديم مزايدة');
  String get amount => _t('Amount', 'المبلغ');
  String get yourBidInteger =>
      _t('Your bid (integer)', 'مبلغ المزايدة (رقم صحيح)');
  String get min => _t('Min', 'الحد الأدنى');
  String get confirm => _t('Confirm', 'تأكيد');
  String get cancel => _t('Cancel', 'إلغاء');
  String get invalidNumber => _t('Invalid number', 'رقم غير صالح');
  String get badStep => _t('Amount is not aligned with bid step',
      'المبلغ غير مطابق لقيمة زيادة المزايدة');
  String get bidPlaced => _t('Bid placed!', 'تم تقديم المزايدة!');
  String get bid => _t('Bid', 'مزايدة');

  String get current => _t('Current', 'الحالي');
  String get step => _t('Step', 'الزيادة');
  String get stateLive => _t('Live', 'مباشر');
  String get stateClosed => _t('Closed', 'مغلق');

  String get error => _t('Error', 'خطأ');

  String get emptyLots => _t('No horses yet', 'لا توجد خيول بعد');
  String get emptyLotsHint => _t('Add horse data or wire a service later.',
      'أضف بيانات الخيول أو اربط خدمة لاحقاً.');

  String _t(String en, String ar) => locale.languageCode == 'ar' ? ar : en;
}

class _L extends LocalizationsDelegate<AppLocalizations> {
  const _L();
  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
