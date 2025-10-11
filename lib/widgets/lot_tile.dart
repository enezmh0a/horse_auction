import 'package:flutter/material.dart';
import '../models/lot_model.dart';
import '../services/live_bids_service.dart';
import '../ui/lot_detail_page.dart';

class LotTile extends StatelessWidget {
  const LotTile({super.key, required this.lot, LiveBidsService? service})
    : service = service ?? LiveBidsService.instance;

  final Lot lot;
  final LiveBidsService service;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          lot.coverImage,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
        ),
      ),
      title: Text(lot.name),
      subtitle: Text('\$${lot.currentBid.toStringAsFixed(0)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LotDetailPage(lotId: lot.id, service: service),
          ),
        );
      },
    );
  }
}
