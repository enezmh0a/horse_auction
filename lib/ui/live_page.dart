// lib/ui/live_page.dart
import 'package:flutter/material.dart';
import '../models/lot_model.dart';
import '../services/live_bids_service.dart';
import 'lot_detail_page.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';
import '../utils/formatting.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key, required this.service});
  final LiveBidsService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lot>>(
      stream: service.live$,
      initialData: service.lots.where((l) => !l.isSold).toList(),
      builder: (context, snap) {
        final items = snap.data ?? const <Lot>[];
        final l10n = AppLocalizations.of(context)!;
        final t = AppLocalizations.of(context)!;

        if (items.isEmpty) {
          return Center(child: Text(l10n.noLiveLots));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (_, i) {
            final lot = items[i];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  lot.coverImage,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(lot.name),
              subtitle: Text(
                'Current bid: ${lot.currentBid.toStringAsFixed(0)}',
              ),
              trailing: Text(_fmt(lot.timeLeft)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => LotDetailPage(lotId: lot.id, service: service),
                  ),
                );
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        );
      },
    );
  }

  String _fmt(Duration d) {
    final s = d.isNegative ? Duration.zero : d;
    final mm = s.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = s.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = s.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}
