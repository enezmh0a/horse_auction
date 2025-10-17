import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

/// Keep the class name the same so call sites don't break.
/// Accepts optional numbers so we don't depend on LotModel shape yet.
class BiddingControlsCard extends ConsumerStatefulWidget {
  const BiddingControlsCard({
    super.key,
    this.currentBid,
    this.minIncrement,
    this.onPlaceBid,
  });

  final int? currentBid;
  final int? minIncrement;
  final Future<void> Function(int amount)? onPlaceBid;

  @override
  ConsumerState<BiddingControlsCard> createState() =>
      _BiddingControlsCardState();
}

class _BiddingControlsCardState extends ConsumerState<BiddingControlsCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final start = (widget.currentBid ?? 0) + (widget.minIncrement ?? 0);
    _controller = TextEditingController(text: start.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Place a bid', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: widget.onPlaceBid == null
                      ? null
                      : () async {
                          final v = int.tryParse(_controller.text);
                          if (v == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter a number')),
                            );
                            return;
                          }
                          await widget.onPlaceBid!(v);
                        },
                  child: const Text('Bid'),
                ),
              ],
            ),
            if (widget.currentBid != null || widget.minIncrement != null) ...[
              const SizedBox(height: 8),
              Text(
                'Current: ${widget.currentBid ?? '-'}'
                '  •  Min inc: ${widget.minIncrement ?? '-'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
