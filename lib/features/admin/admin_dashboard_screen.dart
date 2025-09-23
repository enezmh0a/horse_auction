import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _busy = false;
  String? _msg;

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    Stream<int> _countLots(String status, [String? tier]) {
      var q = db.collection('lots').where('status', isEqualTo: status);
      if (tier != null) q = q.where('priceTier', isEqualTo: tier);
      return q.snapshots().map((s) => s.size);
    }

    final latestBids = db.collectionGroup('bids')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();

    Widget _card(String title, Stream<int> s) => StreamBuilder<int>(
      stream: s,
      builder: (_, snap) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${snap.data ?? 0}', style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );

    Future<void> _run(String which) async {
      setState(() { _busy = true; _msg = null; });
      try {
        final svc = AdminService.instance;
        final res = which == 'tiers'
            ? await svc.backfillPriceTiers()
            : await svc.closeExpiredLotsNow();
        setState(() { _msg = '$which OK: $res'; });
      } catch (e) {
        setState(() { _msg = 'Error: $e'; });
      } finally {
        if (mounted) setState(() { _busy = false; });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _run('tiers'),
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Backfill price tiers'),
              ),
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _run('close'),
                icon: const Icon(Icons.lock_clock),
                label: const Text('Close expired now'),
              ),
              if (_busy) const Padding(
                padding: EdgeInsets.only(left: 8), child: CircularProgressIndicator(strokeWidth: 2)),
            ]),
            if (_msg != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_msg!, style: const TextStyle(color: Colors.blueGrey)),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                _card('Live auctions', _countLots('live')),
                _card('Bronze live', _countLots('live','bronze')),
                _card('Silver live', _countLots('live','silver')),
                _card('Gold live', _countLots('live','gold')),
                _card('Diamond live', _countLots('live','diamond')),
                _card('Platinum live', _countLots('live','platinum')),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Latest bids', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: latestBids,
                builder: (_, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final d = docs[i].data();
                      return ListTile(
                        title: Text('SAR ${d['amount'] ?? 0}'),
                        subtitle: Text('user: ${d['userId'] ?? ''}'),
                        trailing: Text((d['createdAt'] as Timestamp?)?.toDate().toLocal().toString().split('.').first ?? ''),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
