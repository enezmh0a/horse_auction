import 'package:json_annotation/json_annotation.dart';
import 'lot.dart';

part 'auction.g.dart';

@JsonSerializable(explicitToJson: true)
class Auction {
  final String id;
  final String title;
  final List<Lot> lots;
  final DateTime startTime;
  final DateTime endTime;

  Auction({
    required this.id,
    required this.title,
    required this.lots,
    required this.startTime,
    required this.endTime,
  });

  factory Auction.fromJson(Map<String, dynamic> json) => _$AuctionFromJson(json);
  Map<String, dynamic> toJson() => _$AuctionToJson(this);
}
