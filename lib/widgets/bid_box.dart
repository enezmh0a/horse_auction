import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horse_auction_app/services/bid_service.dart';
import 'package:horse_auction_app/services/lots_service.dart';

class BidBox {
  static Future<void> show(BuildContext context, {required Lot lot}) async {
    final min = lot.current + lot.step;
    final controller = TextEditingController(text: '$min');
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Place bid'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      helperText: 'Min: $min',
                      errorText: error,
                    ),
                    onFieldSubmitted: (_) => _confirm(ctx, context, lot,
                        controller, setState, (e) => error = e),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _confirm(ctx, context, lot, controller,
                      setState, (e) => error = e),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _confirm(
    BuildContext dialogCtx,
    BuildContext scaffoldCtx,
    Lot lot,
    TextEditingController controller,
    void Function(void Function()) setState,
    void Function(String?) setError,
  ) {
    final value = int.tryParse(controller.text.trim());
    if (value == null) {
      setState(() => setError('Enter a valid number'));
      return;
    }

    final result = BidService.instance.placeBid(lot: lot, amount: value);
    if (!result.ok) {
      setState(() {
        switch (result.code) {
          case 'closed':
            setError('Lot is closed');
            break;
          case 'min':
            setError('Minimum is ${result.min}');
            break;
          case 'step':
            setError('Step must be ${lot.step}');
            break;
          default:
            setError('Could not place bid');
        }
      });
      return;
    }

    Navigator.of(dialogCtx).pop(); // close dialog
    ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
      const SnackBar(content: Text('Bid placed')),
    );
  }
}
