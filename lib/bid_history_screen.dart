import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/services/firestore_service.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

class BidHistoryScreen extends StatelessWidget {
  final String horseId;
  const BidHistoryScreen({super.key, required this.horseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bid History')),
      body: \<List<Lot>>(
  stream: LiveBidsService.instance.lots$,
  builder: (context, snapshot) {
    final lots = snapshot.data ?? const <Lot>[];
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final b = docs[i].data();
              final amount =
                  (b['amount'] is num) ? (b['amount'] as num).toInt() : 0;
              final ts = b['createdAt'];
              final when =
                  (ts is Timestamp) ? ts.toDate().toLocal().toString() : '—';
              final bidderId = (b['bidderId'] ?? '—') as String;
              return ListTile(
                leading: const Icon(Icons.gavel),
                title: Text('$amount SAR'),
                subtitle: Text('$when • $bidderId'),
              );
            },
          );
        },
      ),
    );
  }
}
