// lib/ui/live_page.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';
import 'package:horse_auction_baseline/services/live_bids_service.dart';
import 'package:horse_auction_baseline/utils/lot_image.dart';
import 'package:horse_auction_baseline/ui/lot_detail_page.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key, required this.service});
  final LiveBidsService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lot>>(
      stream: service.lotsStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lots = snap.data!;
        // Show only lots that are not sold
        final liveLots =
            lots.where((l) => !service.isSold(service.idOf(l))).toList();

        if (liveLots.isEmpty) {
          return const Center(child: Text('No live lots right now'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: liveLots.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final lot = liveLots[i];
            final id = service.idOf(lot);
            final bid = service.currentBidOf(id);
            final left = service.timeLeftOf(id);

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => LotDetailPage(lotId: id, service: service),
                      ),
                    ),
                child: Row(
                  children: [
                    // image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageForLot(lot),
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleOf(lot),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Current: \$${bid.toStringAsFixed(0)}'),
                            Text('Left: ${_fmt(left)}'),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.chevron_right),
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

  String _titleOf(Lot lot) {
    final d = lot as dynamic;
    return (d.name ?? d.title ?? d.id ?? 'Lot').toString();
  }

  String _fmt(Duration d) {
    final s = d.isNegative ? Duration.zero : d;
    final mm = s.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = s.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = s.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}
