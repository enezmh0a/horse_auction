import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horse_auction_baseline/data/providers/lot_providers.dart';
import 'package:horse_auction_baseline/data/models/lot_model.dart';
import '../lots/lot_detail_screen.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(lotsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Horse Auctions')),
      body: lotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (List<LotModel> lots) =>
            _buildHomeBody(context, lots),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context, List<LotModel> lots) {
    final highest = lots.isEmpty
        ? 0.0
        : lots
            .map((l) => (l.currentBid ?? 0).toDouble())
            .fold<double>(0, (a, b) => b > a ? b : a);

    // Your model has no `isFeatured`; just show the first item as “featured”
    final featured = lots.isEmpty ? <LotModel>[] : [lots.first];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Welcome!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        const _StatCard(label: 'Total active lots', valueBuilder: _totalLots),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Highest bid',
          valueBuilder: (lots) => '\$${highest.toStringAsFixed(0)}',
        ),
        const SizedBox(height: 24),
        Text('Featured auctions',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (featured.isEmpty)
          const Text('None yet')
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: featured.map((lot) => _LotTile(lot: lot)).toList(),
          ),
      ],
    );
  }

  static String _totalLots(List<LotModel> lots) => '${lots.length}';
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.valueBuilder});
  final String label;
  final String Function(List<LotModel> lots) valueBuilder;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final lots = ref.watch(lotsStreamProvider).maybeWhen(
              data: (data) => data as List<LotModel>,
              orElse: () => const <LotModel>[],
            );
        final value = valueBuilder(lots);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({required this.lot});
  final LotModel lot;

  @override
  Widget build(BuildContext context) {
    final price = (lot.currentBid ?? 0).toDouble();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LotDetailScreen(lotId: lot.id!)),
        );
      },
      child: SizedBox(
        width: 180,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lot.name ?? '—',
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('\$${price.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
