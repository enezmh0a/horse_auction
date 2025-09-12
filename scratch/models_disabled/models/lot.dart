import 'package:json_annotation/json_annotation.dart';
import 'horse.dart';

part 'lot.g.dart';

@JsonSerializable(explicitToJson: true)
class Lot {
  final String id;
  final Horse horse;

  /// Reserve price in SAR
  final int reservePrice;

  /// Current highest bid in SAR
  final int currentBid;

  final String sellerId;

  /// True when currentBid >= reservePrice
  final bool reserveMet;

  /// Auction end time (ISO8601)
  final DateTime auctionEnd;

  Lot({
    required this.id,
    required this.horse,
    required this.reservePrice,
    required this.currentBid,
    required this.sellerId,
    required this.reserveMet,
    required this.auctionEnd,
  });

  factory Lot.fromJson(Map<String, dynamic> json) => _$LotFromJson(json);
  Map<String, dynamic> toJson() => _$LotToJson(this);
}
