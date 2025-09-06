import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_app/services/firestore_service.dart';

class HorseDetailScreen extends StatefulWidget {
  final String horseId;
  const HorseDetailScreen({super.key, required this.horseId});

  @override
  State<HorseDetailScreen> createState() => _HorseDetailScreenState();
}

class _HorseDetailScreenState extends State<HorseDetailScreen> {
  final _bidCtrl = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _bidCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeBid(Map<String, dynamic> lot) async {
    if (_placing) return;
    setState(() => _placing = true);
    try {
      final amount = int.tryParse(_bidCtrl.text.trim()) ?? -1;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid integer amount')));
        return;
      }

      final currentHighest = (lot['currentHighest'] ?? 0) as num;
      final startingPrice = (lot['startingPrice'] ?? 0) as num;
      final minIncrement = (lot['minIncrement'] ?? 50) as num;

      final base = (currentHighest > 0 ? currentHighest : startingPrice).toInt();
      final requiredMin = base + minIncrement.toInt();
      if (amount < requiredMin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bid must be ≥ $requiredMin (base $base + +${minIncrement.toInt()})')),
        );
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
      await FirestoreService.instance.placeBid(
        horseId: widget.horseId,
        amount: amount,
        userId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid placed')));
        _bidCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bid failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horse details')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.instance.streamHorse(widget.horseId),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!.data();
          if (data == null) return const Center(child: Text('Not found'));

          final name = (data['name'] ?? 'Horse') as String;
          final breed = (data['breed'] ?? '') as String;
          final age = (data['age'] ?? 0) as num;
          final owner = (data['owner'] ?? '') as String;
          final startingPrice = (data['startingPrice'] ?? 0) as num;
          final currentHighest = (data['currentHighest'] ?? 0) as num;
          final minIncrement = (data['minIncrement'] ?? 50) as num;

          final base = (currentHighest > 0 ? currentHighest : startingPrice).toInt();
          final requiredMin = base + minIncrement.toInt();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('$breed • Age ${age.toInt()} • Owner $owner'),
                const SizedBox(height: 16),
                Text('Starting price: ${startingPrice.toInt()}'),
                Text('Current highest: ${currentHighest.toInt()}'),
                Text('Min increment: +${minIncrement.toInt()}'),
                const Divider(height: 32),
                Text('Next bid must be ≥ $requiredMin', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bidCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Your bid (SAR)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _placing ? null : () => _placeBid(data),
                      child: _placing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Place'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirestoreService.instance.bidsStream(widget.horseId),
                    builder: (context, s2) {
                      if (s2.hasError) return Center(child: Text('Bids error: ${s2.error}'));
                      if (!s2.hasData) return const Center(child: CircularProgressIndicator());
                      final bids = s2.data!.docs;
                      if (bids.isEmpty) return const Center(child: Text('No bids yet'));
                      return ListView.builder(
                        itemCount: bids.length,
                        itemBuilder: (context, i) {
                          final b = bids[i].data();
                          final amt = (b['amount'] ?? 0) as num;
                          final uid = (b['userId'] ?? '') as String;
                          final ts = (b['createdAt'] as Timestamp?)?.toDate().toLocal().toString().split('.').first ?? '';
                          return ListTile(
                            leading: const Icon(Icons.gavel),
                            title: Text('SAR ${amt.toInt()}'),
                            subtitle: Text(uid.isEmpty ? ts : '$uid • $ts'),
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
