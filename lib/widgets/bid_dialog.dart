import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/auction_lot.dart';
import '../store/auction_store.dart';

Future<void> showBidDialog(
    BuildContext context, AuctionLot lot, int bidAmount) async {
  final loc = AppLocalizations.of(context)!;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(loc.confirmBidTitle),
        content: Text(loc.confirmBidBody(
          amount: bidAmount,
          lot: lot.name,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.placeBid),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    context.read<AuctionStore>().placeBid(lot.id, bidAmount);
    // Optional: your existing snackbar/toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.bidPlaced)),
    );
  }
}
