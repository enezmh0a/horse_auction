// lib/ui/results_page.dart
import 'package:flutter/material.dart';
import '../models/lot_model.dart';
import '../services/live_bids_service.dart';
import 'lot_detail_page.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';
import '../utils/formatting.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.service});
  final LiveBidsService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lot>>(
      stream: service.results$,
      initialData: service.lots.where((l) => l.isSold).toList(),
      builder: (context, snap) {
        final items = snap.data ?? const <Lot>[];
        final l10n = AppLocalizations.of(context)!;
        final t = AppLocalizations.of(context)!;

        if (items.isEmpty) {
          return Center(child: Text(l10n.noResults));
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
                '${l10n.finalPrice}: ${lot.currentBid.toStringAsFixed(0)}',
              ),
              trailing: Text(l10n.sold),
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
}
