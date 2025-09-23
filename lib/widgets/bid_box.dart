import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BidBox extends StatefulWidget {
  final String lotId;
  const BidBox({super.key, required this.lotId});

  @override
  State<BidBox> createState() => _BidBoxState();
}

class _BidBoxState extends State<BidBox> {
  final _amountController = TextEditingController();
  late final DocumentReference<Map<String, dynamic>> _lotRef;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  FirebaseFunctions get _fx =>
      FirebaseFunctions.instanceFor(region: 'me-central1');

  @override
  void initState() {
    super.initState();
    _lotRef = FirebaseFirestore.instance.collection('lots').doc(widget.lotId);
    _sub = _lotRef.snapshots().listen(_onLotChanged, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _onLotChanged(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists) return;

    final lot = snap.data()!;
    final start = [
      lot['lastBidAmount'],
      lot['startPrice'],
      lot['startingBid']
    ].map((v) => (v is num) ? v.toInt() : 0).fold<int>(0, (a, b) => a > b ? a : b);

    final inc = (lot['minIncrement'] is num && (lot['minIncrement'] as num) > 0)
        ? (lot['minIncrement'] as num).toInt()
        : 100;

    final nextBid =
        (lot['nextBid'] is num && (lot['nextBid'] as num) > 0) ? (lot['nextBid'] as num).toInt() : 0;

    final minAllowed = [start + inc, nextBid].fold<int>(0, (a, b) => a > b ? a : b);

    // Only bump the field forward; don't overwrite if user typed a higher number.
    final currentText = int.tryParse(_amountController.text);
    if (currentText == null || currentText < minAllowed) {
      _amountController.text = minAllowed.toString();
    }
    setState(() {}); // to redraw if you want to show computed values later
  }

  Future<void> _placeBid() async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    try {
      // Ensure we have a UID (anonymous is fine)
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      final result = await _fx.httpsCallable('placeBid').call<Map<String, dynamic>>({
        'lotId': widget.lotId,
        'bidAmount': amount,
      });

      final data = result.data;
      if (data['ok'] == true) {
        final next = (data['nextMin'] as num?)?.toInt();
        if (next != null) _amountController.text = next.toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bid placed. Next min: ${next ?? '—'}')),
        );
      } else {
        final reason = data['reason'] ?? 'Rejected';
        final min = (data['minAllowed'] as num?)?.toInt();
        if (min != null) _amountController.text = min.toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$reason${min != null ? ' (min $min)' : ''}')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${e.code}: ${e.message ?? 'error'}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your bid', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _placeBid,
                child: const Text('Bid'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
