import 'package:json_annotation/json_annotation.dart';

part 'bid.g.dart';

@JsonSerializable()
class Bid {
  final String id;
  final String lotId;
  final String bidderId;

  /// Amount in SAR
  final int amount;

  final DateTime timestamp;

  Bid({
    required this.id,
    required this.lotId,
    required this.bidderId,
    required this.amount,
    required this.timestamp,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
  Map<String, dynamic> toJson() => _$BidToJson(this);
}
