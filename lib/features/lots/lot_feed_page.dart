import 'package:flutter/material.dart';
import '../../services/lots_service.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';
import 'lot_detail_screen.dart';

class LotFeedPage extends StatelessWidget {
  const LotFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lots = LotsService.instance.lots;
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Lots')),
      body: ListView.separated(
        itemCount: lots.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final LotModel lot = lots[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                lot.imageUrls.isNotEmpty ? lot.imageUrls.first : '',
              ),
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(lot.displayTitle),
            subtitle: Text('Current: ${lot.current} • Start: ${lot.starting}'),
            trailing: const Icon(Icons.chevron_right),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LotDetailScreen(lotId: lot.id),
                  ),
                ),
          );
        },
      ),
    );
  }
}
