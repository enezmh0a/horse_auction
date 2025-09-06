// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bid _$BidFromJson(Map<String, dynamic> json) => Bid(
      id: json['id'] as String,
      lotId: json['lotId'] as String,
      bidderId: json['bidderId'] as String,
      amount: (json['amount'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$BidToJson(Bid instance) => <String, dynamic>{
      'id': instance.id,
      'lotId': instance.lotId,
      'bidderId': instance.bidderId,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
    };
