import 'package:flutter/foundation.dart';

enum LotStatus { upcoming, live, sold, reserveNotMet }

class LotModel {
  LotModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.images,
    required this.reservePrice,
    required this.minIncrement,
    required this.currentBid,
    required this.endsAt,
    this.status = LotStatus.live,
    this.highestBidderUserId,
    this.details,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final List<String> images; // asset paths
  final int reservePrice;
  final int minIncrement;
  final ValueNotifier<int> currentBid;
  final DateTime endsAt;
  final Map<String, String>? details; // Name, Height, Sire, Dam, Breed...
  final String? highestBidderUserId;
  LotStatus status;

  bool get reserveMet => currentBid.value >= reservePrice;
  Duration get timeLeft => endsAt.difference(DateTime.now());
  bool get isClosed => timeLeft.isNegative || status == LotStatus.sold;
  String titleForLocale(String code) => code == 'ar' ? titleAr : titleEn;
  String descriptionForLocale(String code) =>
      code == 'ar' ? descriptionAr : descriptionEn;
}

/// Demo data using your assets: assets/horses/horse01.jpg .. horse06.jpg
List<LotModel> buildDemoLots() {
  List<String> pack(int n) {
    // Try up to 3 images per lot if you’ve placed them.
    return List<String>.generate(3, (i) {
      final idx = n.toString().padLeft(2, '0');
      final variant = i == 0 ? '' : '_${i + 1}';
      // e.g., assets/horses/horse01.jpg, horse01_2.jpg, horse01_3.jpg
      return 'assets/horses/horse$idx$variant.jpg';
    });
  }

  final now = DateTime.now();
  return [
    LotModel(
      id: 'L1',
      titleEn: 'Desert Comet',
      titleAr: 'المذنب الصحراوي',
      descriptionEn: 'Elegant Arabian gelding, well schooled.',
      descriptionAr: 'حصان عربي أنيق ومدرّب جيدًا.',
      images: pack(1),
      reservePrice: 8000,
      minIncrement: 250,
      currentBid: ValueNotifier<int>(7000),
      endsAt: now.add(const Duration(minutes: 45)),
      status: LotStatus.live,
      details: {
        'Name': 'Desert Comet',
        'Breed': 'Arabian',
        'Height': '15.1 hh',
        'Sire': 'Sahara Star',
        'Dam': 'Moonlight',
        'Age': '6',
      },
    ),
    LotModel(
      id: 'L2',
      titleEn: 'Golden Mirage',
      titleAr: 'السراب الذهبي',
      descriptionEn: 'Show ring ready, smooth canter.',
      descriptionAr: 'جاهز للمنافسات، كانتر سلس.',
      images: pack(2),
      reservePrice: 12000,
      minIncrement: 500,
      currentBid: ValueNotifier<int>(11500),
      endsAt: now.add(const Duration(minutes: 10)),
      status: LotStatus.live,
      details: {
        'Name': 'Golden Mirage',
        'Breed': 'Arabian',
        'Height': '15.0 hh',
        'Age': '7',
      },
    ),
    LotModel(
      id: 'L3',
      titleEn: 'Oasis Wind',
      titleAr: 'ريح الواحة',
      descriptionEn: 'Calm temperament, great for amateurs.',
      descriptionAr: 'مزاج هادئ ومناسب للهواة.',
      images: pack(3),
      reservePrice: 6000,
      minIncrement: 200,
      currentBid: ValueNotifier<int>(6000),
      endsAt: now.subtract(const Duration(minutes: 5)), // already ended
      status: LotStatus.sold,
    ),
    LotModel(
      id: 'L4',
      titleEn: 'Red Dunes',
      titleAr: 'الكثبان الحمراء',
      descriptionEn: 'Athletic, forward ride.',
      descriptionAr: 'حصان رياضي ذو حركة نشطة.',
      images: pack(4),
      reservePrice: 9000,
      minIncrement: 250,
      currentBid: ValueNotifier<int>(8500),
      endsAt: now.add(const Duration(minutes: 90)),
      status: LotStatus.live,
    ),
  ];
}
