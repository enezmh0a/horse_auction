class BidModel {
  final String id;
  final String lotId;
  final String userId;
  final double amount;
  final DateTime timestamp;

  const BidModel({
    required this.id,
    required this.lotId,
    required this.userId,
    required this.amount,
    required this.timestamp,
  });
}
