import 'package:flutter/material.dart';
import '../../services/lots_service.dart';

class UpcomingBidsPage extends StatelessWidget {
  const UpcomingBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final live = LotsService.instance.lots.value.where((e) => e.live).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming / Live')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final lot = live[i];
          return ListTile(
            leading: _thumb(lot.images),
            title: Text(lot.title),
            subtitle: Text('City: ${lot.city} • Step: SAR ${lot.step}'),
            trailing: Text('Current: SAR ${lot.current}'),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: live.length,
      ),
    );
  }

  Widget _thumb(List<String> imgs) => ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
          imgs.isNotEmpty ? imgs.first : 'assets/horses/horse01.jpg',
          width: 56,
          height: 56,
          fit: BoxFit.cover));
}
