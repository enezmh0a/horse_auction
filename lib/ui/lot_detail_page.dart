// lib/ui/lot_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lot_model.dart';
import '../services/live_bids_service.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';
import '../utils/formatting.dart';

class LotDetailPage extends StatefulWidget {
  const LotDetailPage({super.key, required this.lotId, required this.service});
  final String lotId;
  final LiveBidsService service;

  @override
  State<LotDetailPage> createState() => _LotDetailPageState();
}

class _LotDetailPageState extends State<LotDetailPage> {
  double? _proposed; // temp value to bid with plus/minus

  NumberFormat get _currency {
    final isAr =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    return NumberFormat.currency(
      locale: isAr ? 'ar_SA' : 'en_SA',
      symbol: isAr ? 'ر.س' : 'SAR',
      decimalDigits: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lot>>(
      stream: widget.service.lots$,
      initialData: widget.service.lots,
      builder: (context, snap) {
        final lots = snap.data ?? const <Lot>[];
        final lot = lots.firstWhere((e) => e.id == widget.lotId);
        final l10n = AppLocalizations.of(context)!;
        final t = AppLocalizations.of(context)!;

        _proposed ??= lot.currentBid + lot.minIncrement;

        return Scaffold(
          appBar: AppBar(title: Text(lot.name)),
          body: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(lot.coverImage, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(lot.description),
                    const SizedBox(height: 12),
                    _tile(l10n.current, _currency.format(lot.currentBid)),
                    _tile(
                      l10n.minIncrement,
                      _currency.format(lot.minIncrement),
                    ),
                    _tile(l10n.timeLeft, _fmt(lot.timeLeft)),
                    const Divider(height: 28),
                    Text(
                      l10n.yourBid,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              lot.isSold
                                  ? null
                                  : () => setState(() {
                                    final next =
                                        (_proposed ?? lot.currentBid) -
                                        lot.minIncrement;
                                    _proposed =
                                        next <= lot.currentBid
                                            ? lot.currentBid + lot.minIncrement
                                            : next;
                                  }),
                          icon: const Icon(Icons.remove),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              _currency.format(_proposed ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              lot.isSold
                                  ? null
                                  : () => setState(() {
                                    _proposed =
                                        (_proposed ?? lot.currentBid) +
                                        lot.minIncrement;
                                  }),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            lot.isSold
                                ? null
                                : () {
                                  final want =
                                      _proposed ??
                                      (lot.currentBid + lot.minIncrement);
                                  final minAllowed =
                                      lot.currentBid + lot.minIncrement;
                                  if (want < minAllowed) {
                                    _toast(context, 'Bid too low.');
                                    return;
                                  }
                                  final newBid = widget.service.placeBid(
                                    lot.id,
                                    want,
                                  );
                                  setState(() {
                                    _proposed = newBid + lot.minIncrement;
                                  });
                                  _toast(
                                    context,
                                    'Bid placed: ${_currency.format(newBid)}',
                                  );
                                },
                        child: Text(lot.isSold ? 'SOLD' : 'Place bid'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _fmt(Duration d) {
    final s = d.isNegative ? Duration.zero : d;
    final mm = s.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = s.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = s.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
