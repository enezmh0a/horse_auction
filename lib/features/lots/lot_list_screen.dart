// lib/features/lots/screens/lot_list_screen.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';
import 'package:horse_auction_baseline/data/providers/lot_providers.dart';
import 'lot_detail_screen.dart';
import 'widgets/lot_list_item.dart';

class LotListScreen extends ConsumerWidget {
  const LotListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream of all live lots
    final liveLotsAsync = ref.watch(liveLotsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horse Auction'),
        actions: [
          // Placeholder for the Profile/Sign-in button
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to Auth/Profile Screen (Next step!)
            },
          ),
        ],
      ),
      body: liveLotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading auctions: $e')),
        data: (lots) {
          if (lots.isEmpty) {
            return const Center(
              child: Text('No active auctions are currently available.'),
            );
          }
          // lib/features/lots/lot_list_screen.dart

          return ListView.builder(
            itemCount: lots.length,
            itemBuilder: (context, index) {
              final lot =
                  lots[index] as LotModel; // or just: final lot = lots[index];
              return LotListItem(
                title: lot.displayTitle,
                subtitle: 'Current: ${lot.current}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LotDetailScreen(lotId: lot.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
