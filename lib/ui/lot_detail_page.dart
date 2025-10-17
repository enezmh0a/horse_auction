import 'package:flutter/material.dart';
import '../services/live_bids_service.dart';
import '../models/lot_model.dart';
import '../l10n/app_localizations.dart';

class LotDetailPage extends StatelessWidget {
  final LiveBidsService service;
  final Lot lot;
  const LotDetailPage({super.key, required this.service, required this.lot});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: service,
      builder: (_, __) {
        final fresh = service.lots.firstWhere(
          (l) => l.id == lot.id,
          orElse: () => lot,
        );
        final d = fresh.timeLeft;
        final h = d.inHours;
        final m = d.inMinutes.remainder(60);
        final s = d.inSeconds.remainder(60);
        final t = h > 0
            ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}'
            : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

        return Scaffold(
          appBar: AppBar(title: Text(fresh.title)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  fresh.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 36),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(fresh.description),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _kv(loc.current, '${fresh.currentBid} SAR'),
                    ),
                    Expanded(
                      child: _kv(loc.minIncrement, '${fresh.minIncrement} SAR'),
                    ),
                    Expanded(child: _kv(loc.timeLeft, t)),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: fresh.isLive
                        ? () => service.placeBid(fresh, steps: 1)
                        : null,
                    child: Text('${loc.placeBid}  ＋${fresh.minIncrement}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
