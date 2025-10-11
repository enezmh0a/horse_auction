// lib/ui/lots_page.dart
import 'package:flutter/material.dart';
import '../models/lot_model.dart';
import '../services/live_bids_service.dart';
import 'lot_detail_page.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';
import '../utils/formatting.dart';

class LotsPage extends StatelessWidget {
  const LotsPage({super.key, required this.service});
  final LiveBidsService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lot>>(
      stream: service.lots$,
      initialData: service.lots,
      builder: (context, snap) {
        final items = snap.data ?? const <Lot>[];
        final l10n = AppLocalizations.of(context)!;
        final t = AppLocalizations.of(context)!;

        if (items.isEmpty) {
          return Center(child: Text(l10n.noLotsAvailable));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final lot = items[i];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => LotDetailPage(lotId: lot.id, service: service),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        lot.coverImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        lot.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bid: ${lot.currentBid.toStringAsFixed(0)}'),
                          Text(_fmt(lot.timeLeft)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
