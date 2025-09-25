// lib/admin_pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../features/services/lots_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lotsListenable = LotsService.instance.lots;
    return ValueListenableBuilder<List<Lot>>(
      valueListenable: lotsListenable,
      builder: (context, lots, _) {
        final total = lots.length;
        final live = lots.where((e) => e.live).length;
        final closed = total - live;
        final top = lots.isEmpty
            ? null
            : lots.reduce((a, b) => a.current >= b.current ? a : b);

        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _stat(context, 'Top current',
                        top == null ? '-' : 'SAR ${top.current}',
                        subtitle: top?.title ?? ''),
                    _stat(context, 'Closed', '$closed',
                        icon: Icons.lock_outline),
                    _stat(context, 'Live', '$live',
                        icon: Icons.play_arrow_rounded),
                    _stat(context, 'Total lots', '$total',
                        icon: Icons.list_alt),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent lots',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: lots.length.clamp(0, 10),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final lot = lots[i];
                      return _lotChip(context, lot);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(BuildContext context, String label, String value,
      {String? subtitle, IconData? icon}) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: Icon(icon),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Text(value,
                        style: Theme.of(context).textTheme.headlineSmall),
                    if ((subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lotChip(BuildContext context, Lot lot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Text(lot.title, style: Theme.of(context).textTheme.bodyLarge),
            _tag('Current: SAR ${lot.current}'),
            _tag('Step: SAR ${lot.step}'),
            _tag('City: ${lot.city}'),
            _tag(lot.live ? 'Live' : 'Closed'),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) => Chip(label: Text(text));
}
