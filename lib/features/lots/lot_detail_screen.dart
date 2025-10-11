import 'package:flutter/material.dart';
import '../../services/lots_service.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

class LotDetailScreen extends StatefulWidget {
  final String lotId;
  const LotDetailScreen({super.key, required this.lotId});

  @override
  State<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends State<LotDetailScreen> {
  late LotModel? lot;

  @override
  void initState() {
    super.initState();
    lot = LotsService.instance.byId(widget.lotId);
  }

  @override
  Widget build(BuildContext context) {
    if (lot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lot')),
        body: const Center(child: Text('Lot not found')),
      );
    }

    final images = lot!.imageUrls;
    final title = lot!.displayTitle;
    final desc = lot!.description;
    final current = lot!.current;
    final minInc = lot!.minInc;
    final nextAllowed = lot!.nextAllowed;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  images.first,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const ColoredBox(
                        color: Color(0x11000000),
                        child: Center(child: Icon(Icons.image_not_supported)),
                      ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(desc),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _chip('Current', current.toStringAsFixed(0)),
              _chip('Min Inc', minInc.toStringAsFixed(0)),
              _chip('Next Allowed', nextAllowed.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.gavel),
            label: const Text('Place Bid'),
            onPressed: _placeBidDialog,
          ),
          const SizedBox(height: 12),
          const Text(
            'Bid History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...lot!.bids.reversed.map(
            (b) => ListTile(
              dense: true,
              leading: const Icon(Icons.person),
              title: Text('${b.amount.toStringAsFixed(0)}'),
              subtitle: Text(b.timestamp.toLocal().toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }

  Future<void> _placeBidDialog() async {
    final controller = TextEditingController(
      text: lot!.nextAllowed.toStringAsFixed(0),
    );
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Place Bid'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: 'SAR '),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(controller.text.trim());
                Navigator.pop(ctx, parsed);
              },
              child: const Text('Bid'),
            ),
          ],
        );
      },
    );

    if (amount == null) return;

    final ok = LotsService.instance.placeBid(
      lotId: lot!.id,
      userId: 'demo-user',
      amount: amount,
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be ≥ ${lot!.nextAllowed.toStringAsFixed(0)}'),
        ),
      );
      return;
    }

    setState(() {
      // lot updated in service; refresh local ref
      lot = LotsService.instance.byId(widget.lotId);
    });
  }
}
