import 'package:flutter/material.dart';

class BidBox extends StatelessWidget {
  const BidBox({super.key, required this.onBid, this.initial});
  final Future<void> Function(int amount) onBid;
  final int? initial;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: (initial ?? 0).toString());

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () async {
            final v = int.tryParse(controller.text);
            if (v == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a number')),
              );
              return;
            }
            await onBid(v);
          },
          child: const Text('Bid'),
        ),
      ],
    );
  }
}
