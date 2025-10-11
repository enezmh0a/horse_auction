// lib/models/lot_model.dart
class Lot {
  final String id;
  final String name; // title/name shown to users
  final String description; // REQUIRED
  final String coverImage; // network image URL
  double currentBid; // mutable for demo bids
  final double minIncrement;
  DateTime? endsAt; // null => no timer

  Lot({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.currentBid,
    required this.minIncrement,
    required this.endsAt,
  });

  bool get isSold => timeLeft == Duration.zero;

  Duration get timeLeft {
    if (endsAt == null) return Duration.zero;
    final d = endsAt!.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }
}
