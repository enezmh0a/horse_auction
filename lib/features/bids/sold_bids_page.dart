import 'package:flutter/material.dart';
import '../../services/lots_service.dart';

class SoldBidsPage extends StatelessWidget {
  const SoldBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final closed = LotsService.instance.lots.value
        .where((e) => !e.live)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Sold bids')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final lots = LotsService.instance.lots;
          final lot = closed[i];
          return ListTile(
            leading: _thumb(lot.images),
            title: Text(lot.title),
            subtitle: Text('City: ${lot.city}'),
            trailing: Text('Final: SAR ${lot.current}'),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: closed.length,
      ),
    );
  }

  Widget _thumb(List<String> imgs) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(
      imgs.isNotEmpty ? imgs.first : 'assets/horses/horse01.jpg',
      width: 56,
      height: 56,
      fit: BoxFit.cover,
    ),
  );
}
