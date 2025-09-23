import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedArabicExamples() async {
  final db = FirebaseFirestore.instance;
  final lots = db.collection('lots');

  final docs = <Map<String, dynamic>>[
    {
      'id': 'lot_kadi_mix_filly_2022',
      'title': 'كادي',
      'tier': 'gold',
      'status': 'live',
      'start': 12000,
      'current': 12000,
      'step': 200,
      'city': 'الرياض',
      'images': [
        'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=1200&q=80',
      ],
      'horse': {
        'lang': 'ar',
        'type': 'mix',
        'sex': 'filly',
        'name': 'كادي',
        'sireName': 'يوروقرنت ابن عجمان منسيوني',
        'damName': 'ريم الشرقية',
        'birthDate': Timestamp.fromDate(DateTime(2022, 12, 28)),
        'heightCm': 147,
        'reproductiveStatus': 'فاضية تتشبى الموسم',
        'healthGeneral':
            'سليم وعلى الفحص في موقعه (يوجد تصوير فيما يخص حالة الفك والقوائم)',
        'jawAndLimbs': 'سليمه',
        'temperament': 'أديبه ولعوبه',
        'locationNotes': 'الرياض ديراب',
        'pedigreeImageUrl': null,
      },
    },
    {
      'id': 'lot_abdulrahman_mix_colt_2024',
      'title': 'عبدالرحمن',
      'tier': 'silver',
      'status': 'live',
      'start': 12000,
      'current': 12000,
      'step': 200,
      'city': 'الرياض',
      'images': [
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5e?w=1200&q=80',
      ],
      'horse': {
        'lang': 'ar',
        'type': 'mix',
        'sex': 'colt',
        'name': 'عبدالرحمن',
        'sireName': 'جاد ابن اليكساندر',
        'damName': 'ريم الشرقية',
        'birthDate': Timestamp.fromDate(DateTime(2024, 3, 1)),
        'heightCm': 143,
        'reproductiveStatus': 'مهر',
        'healthGeneral': 'سليمه شرط',
        'jawAndLimbs': 'سليم شرط',
        'temperament': '',
        'locationNotes': 'الرياض ديراب',
        'pedigreeImageUrl': null,
      },
    },
    {
      'id': 'lot_buyer_names_mix_filly_2024',
      'title': 'اسم المشتري لاحقًا',
      'tier': 'silver',
      'status': 'closed',
      'start': 12000,
      'current': 12000,
      'step': 200,
      'city': 'الرياض',
      'images': [
        'https://images.unsplash.com/photo-1501471984908-815b99686255?w=1200&q=80',
      ],
      'horse': {
        'lang': 'ar',
        'type': 'mix',
        'sex': 'filly',
        'name': 'يحق للمشتري التسميه',
        'sireName': 'سبيل الناصر',
        'damName': 'مونار',
        'birthDate': Timestamp.fromDate(DateTime(2024, 9, 1)),
        'heightCm': 140,
        'reproductiveStatus': 'مهره',
        'healthGeneral': 'سليمه شرط',
        'jawAndLimbs': 'تقدم بسيط',
        'temperament': '',
        'locationNotes': 'الرياض الرحمانيه',
        'pedigreeImageUrl': null,
      },
    },
  ];

  final batch = db.batch();
  for (final d in docs) {
    final step = (d['step'] as num).toInt();
    final current = (d['current'] as num).toInt();
    final docRef = lots.doc(d['id'] as String);
    batch.set(docRef, {
      ...d..remove('id'),
      'next': current + step,
      'tsUpdated': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
