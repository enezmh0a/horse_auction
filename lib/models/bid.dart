import 'package:horse_auction_baseline/models/lot_model.dart';
import 'package:horse_auction_baseline/models/bid_model.dart';

class Bid {
  final String id;
  final String bidderId;
  final String? bidderName;
  final double amount;
  final DateTime ts;

  Bid({
    required this.id,
    required this.bidderId,
    required this.amount,
    required this.ts,
    this.bidderName,
  });

  static double _d(dynamic v) {
    if (v is int) return v.toDouble();
    if (v is double) return v;
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime _t(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  factory Bid.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const <String, dynamic>{};
    return Bid(
      id: d.id,
      bidderId: m['bidderId'] as String? ?? '',
      bidderName: m['bidderName'] as String?,
      amount: _d(m['amount']),
      ts: _t(m['ts']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'ts': FieldValue.serverTimestamp(),
    };
  }
}
