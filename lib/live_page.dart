import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auction_lot.dart';
import '../../widgets/bid_dialog.dart';
import '../../widgets/chips.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final store = context.watch<AuctionStore>();
    final lots = store.liveLots;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: lots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          final lot = lots[i];
          return _LotTile(lot: lot, t: t, store: store);
        },
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot, required this.t, required this.store});
  final AuctionLot lot;
  final AppLocalizations t;
  final AuctionStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withOpacity(.6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                lot.imagePath,
                width: 140,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lot.titleForLocale(Localizations.localeOf(context)),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChipText(t.currentBidSar(lot.currentBid.value)),
                      ChipText(t.minIncSar(lot.minIncrement)),
                      _CountdownChip(listenable: lot.timeLeft),
                      ChipText(
                        '${lot.breed} • ${lot.sex} • ${lot.heightCm}cm • ${lot.color}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.tonalIcon(
                        onPressed:
                            () => showBidDialog(
                              context,
                              t,
                              lot,
                              store,
                              lot.minIncrement,
                            ),
                        icon: const Icon(Icons.gavel),
                        label: Text(t.bidPlusMin),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonal(
                        onPressed:
                            () => showBidDialog(
                              context,
                              t,
                              lot,
                              store,
                              lot.minIncrement * 2,
                            ),
                        child: Text(t.bidPlus2x),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.listenable});
  final ValueNotifier<Duration> listenable;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ValueListenableBuilder<Duration>(
      valueListenable: listenable,
      builder: (_, d, __) => ChipText(t.endsIn(formatDuration(d))),
    );
  }
}
