enum AuctionLotStatus { live, sold, upcoming }

class AuctionLot {
  AuctionLot({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.breed,
    required this.color,
    required this.heightCm,
    required this.ageYears,
    required this.currentBid,
    required this.minIncrement,
    required this.endsAt,
    required this.status,
  });

  final String id;
  final String name;
  final String imagePath;
  final String breed;
  final String color;
  final int heightCm;
  final int ageYears;

  int currentBid; // mutable
  final int minIncrement;
  DateTime endsAt; // mutable if you want to tick down
  AuctionLotStatus status;

  int nextMinBid() => currentBid + minIncrement;
  int next2xBid() => currentBid + (minIncrement * 2);
}
