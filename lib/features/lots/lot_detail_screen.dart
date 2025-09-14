import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/auction_service.dart';

class LotDetailScreen extends StatefulWidget {
  final String lotId;
  const LotDetailScreen({super.key, required this.lotId});

  @override
  State<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends State<LotDetailScreen> {
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lotRef = FirebaseFirestore.instance.collection('lots').doc(widget.lotId);
    return Scaffold(
      appBar: AppBar(title: const Text('Lot details')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: lotRef.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!.data()!;
          final name = d['name'] ?? '';
          final state = d['state'] ?? 'pending';
          final currentHighest = (d['currentHighest'] ?? 0) as int;
          final minIncrement = (d['minIncrement'] ?? 0) as int;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('State: $state'),
                Text('Current highest: $currentHighest'),
                Text('Min increment: $minIncrement'),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Your bid amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: state != 'live'
                      ? null
                      : () async {
                          final amount = int.tryParse(_amountCtrl.text.trim());
                          if (amount == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter a valid number')),
                            );
                            return;
                          }
                          try {
                            await placeBid(
                              lotId: widget.lotId,
                              amount: amount,
                              userId: 'demoUser', // replace with real uid later
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bid placed. Waiting for server…')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                  child: const Text('Place Bid'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: lotRef
                        .collection('bids')
                        .orderBy('createdAt', descending: true)
                        .limit(30)
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();
                      final bids = snap.data!.docs;
                      return ListView.separated(
                        itemCount: bids.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final b = bids[i].data();
                          final amt = b['amount'];
                          final status = b['status'];
                          final reason = b['reason'];
                          return ListTile(
                            title: Text('Bid: $amt'),
                            subtitle: Text(
                              reason == null ? 'Status: $status' : 'Status: $status • $reason',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
