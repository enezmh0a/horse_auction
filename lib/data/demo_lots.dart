import 'package:flutter/foundation.dart';
import '../models/auction_lot.dart';

List<AuctionLot> buildDemoLots() {
  final now = DateTime.now();
  return <AuctionLot>[
    AuctionLot(
      id: 'lot-1',
      name: 'Desert Comet',
      imagePath: 'assets/horses/white.jpg',
      breed: 'Arabian',
      color: 'White',
      heightCm: 150,
      ageYears: 4,
      currentBid: 12000,
      minIncrement: 500,
      endsAt: now.add(const Duration(minutes: 45)),
      status: AuctionLotStatus.live,
    ),
    AuctionLot(
      id: 'lot-2',
      name: 'Golden Mirage',
      imagePath: 'assets/horses/black.jpg',
      breed: 'Arabian',
      color: 'Black',
      heightCm: 155,
      ageYears: 5,
      currentBid: 8650,
      minIncrement: 250,
      endsAt: now.add(const Duration(minutes: 9)),
      status: AuctionLotStatus.live,
    ),
    AuctionLot(
      id: 'lot-3',
      name: 'Red Dunes',
      imagePath: 'assets/horses/bay.jpg',
      breed: 'Arabian',
      color: 'Bay',
      heightCm: 152,
      ageYears: 3,
      currentBid: 0,
      minIncrement: 200,
      endsAt: now.add(const Duration(hours: 2)),
      status: AuctionLotStatus.upcoming,
    ),
    AuctionLot(
      id: 'lot-4',
      name: 'Oasis Wind',
      imagePath: 'assets/horses/black2.jpg',
      breed: 'Arabian',
      color: 'Black',
      heightCm: 153,
      ageYears: 6,
      currentBid: 6000,
      minIncrement: 300,
      endsAt: now.subtract(const Duration(minutes: 10)),
      status: AuctionLotStatus.sold,
    ),
  ];
}
