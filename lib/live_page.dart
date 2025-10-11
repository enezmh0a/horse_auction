// lib/ui/live_page.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';
import 'package:horse_auction_baseline/services/live_bids_service.dart';
import '../widgets/lot_tile.dart';
import 'C:\horse-auction-baseline\lib\ui\lot_detail_page.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lot>>(
      stream: LiveBidsService.instance.lots$,
      builder: (context, snap) {
        final lots =
            (snap.data ?? const <Lot>[]).where((e) => !e.isSold).toList()
              ..sort((a, b) => a.endsAt.compareTo(b.endsAt));

        if (lots.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noLiveLots));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: lots.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final lot = lots[i];
            return LotTile(
              lot: lot,
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LotDetailPage(lotId: lot.id),
                    ),
                  ),
            );
          },
        );
      },
    );
  }
}
