import 'package:flutter/material.dart';
import 'package:horse_auction_app/services/lots_service.dart'; // << Lot + LotsService
import 'package:horse_auction_app/widgets/bid_box.dart'; // << BidBox.show()

class HorsesPage extends StatelessWidget {
  const HorsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<Lot>>(
        valueListenable: LotsService.instance.lots,
        builder: (context, lots, _) {
          if (lots.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            itemCount: lots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _LotTile(lot: lots[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Seed lots'),
        onPressed: () {
          final res = LotsService.instance.seedLotsOnce();
          final msg = (res == 'already') ? 'Already seeded' : 'Seeded';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        },
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  final Lot lot;
  const _LotTile({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // <-- define theme once

    // choose first image (asset or http)
    final String? img = lot.images.isNotEmpty ? lot.images.first : null;

    Widget _thumbPlaceholder(ThemeData theme) {
      return Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.colorScheme.outline,
          size: 22,
        ),
      );
    }

    Widget thumb;
    if (img != null &&
        (img.startsWith('http://') || img.startsWith('https://'))) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          img,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbPlaceholder(theme),
        ),
      );
    } else if (img != null) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          img,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbPlaceholder(theme),
        ),
      );
    } else {
      thumb = _thumbPlaceholder(theme);
    }

    // ...use `thumb` in your row/list tile as before

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            thumb,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lot.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(context, lot.live ? 'Live' : 'Closed',
                          icon: lot.live ? Icons.play_arrow : Icons.lock_clock),
                      _chip(context, 'City: ${lot.city}'),
                      _chip(context, 'Step: SAR ${lot.step}'),
                      _chip(context, 'Current: SAR ${lot.current}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _BidButton(lot: lot),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String text, {IconData? icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 6),
          ],
          Text(text, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _thumbPlaceholder(ThemeData theme) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_not_supported_outlined, size: 22),
      );
}

class _BidButton extends StatelessWidget {
  const _BidButton({required this.lot});
  final Lot lot;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: lot.live ? () => BidBox.show(context, lot: lot) : null,
      icon: const Icon(Icons.gavel_rounded, size: 18),
      label: const Text('Bid'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 48, color: theme.colorScheme.onSurface),
            const SizedBox(height: 12),
            Text('No horses yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Add horse data or seed demo lots.',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
