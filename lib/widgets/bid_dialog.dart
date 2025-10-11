import 'package:flutter/material.dart';

class BidDialog extends StatefulWidget {
  final double initial;
  final String currency;
  const BidDialog({super.key, required this.initial, required this.currency});

  @override
  State<BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initial.toStringAsFixed(0));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Place Bid'),
      content: TextField(
        controller: _c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(prefixText: '${widget.currency} '),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(_c.text);
            if (v == null) return;
            Navigator.pop(context, v);
          },
          child: const Text('Bid'),
        ),
      ],
    );
  }
}
