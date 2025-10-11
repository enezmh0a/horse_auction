import 'package:flutter/material.dart';
import 'package:horse_auction_app/l10n/generated/app_localizations.dart';

class LotDetailScreen extends StatelessWidget {
  final String lotId;
  const LotDetailScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lot $lotId • Arabian Stallion', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: const [
              Chip(label: Text('Vet Report')),
              SizedBox(width: 8),
              Chip(label: Text('Passport Verified')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Gallery Placeholder')),
          ),
          const SizedBox(height: 16),
          const Text('Quick facts: Age 4 • Bay • Microchip • Studbook ID'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.gavel),
            label: Text(l.registerToBid),
          ),
        ],
      ),
    );
  }
}
