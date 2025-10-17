import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/lot_model.dart';
import '../services/auction_service.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isAr = langCode == 'ar';
    final svc = AuctionService.instance;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'مباشر' : 'Live')),
        body: ValueListenableBuilder<List<LotModel>>(
          valueListenable: svc.lotsListenable,
          builder: (context, lots, _) {
            final live = lots
                .where((l) => l.status == LotStatus.live && !l.isClosed)
                .toList();
            if (live.isEmpty) {
              return Center(
                  child: Text(isAr
                      ? 'لا يوجد مزادات مباشرة الآن'
                      : 'No live lots right now'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: live.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final lot = live[i];
                return _LiveTile(lot: lot, isAr: isAr);
              },
            );
          },
        ),
      ),
    );
  }
}

class _LiveTile extends StatelessWidget {
  const _LiveTile({required this.lot, required this.isAr});
  final LotModel lot;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final minNext = lot.currentBid.value + lot.minIncrement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lot.titleForLocale(isAr ? 'ar' : 'en'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _Thumb(firstExistingAsset(lot.images)),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: lot.currentBid,
                    builder: (context, bid, _) {
                      final endsIn = lot.timeLeft;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((isAr ? 'العرض الحالي: ' : 'Current bid: ') +
                              bid.toString()),
                          const SizedBox(height: 4),
                          Text(
                            isAr
                                ? 'ينتهي خلال: ${_fmt(endsIn)}'
                                : 'Ends in: ${_fmt(endsIn)}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilledButton.tonal(
                                onPressed: lot.isClosed
                                    ? null
                                    : () async {
                                        final ok = await _confirm(
                                            context, isAr, minNext);
                                        if (!ok) return;
                                        final success = AuctionService.instance
                                            .placeBid(
                                                lotId: lot.id, amount: minNext);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(success
                                              ? (isAr
                                                  ? 'تم تقديم العرض'
                                                  : 'Bid placed')
                                              : (isAr
                                                  ? 'العرض منخفض'
                                                  : 'Bid too low')),
                                        ));
                                      },
                                child: Text(isAr ? '+ الحد الأدنى' : '+ Min'),
                              ),
                              FilledButton(
                                onPressed: lot.isClosed
                                    ? null
                                    : () async {
                                        final amount =
                                            minNext + lot.minIncrement;
                                        final ok = await _confirm(
                                            context, isAr, amount);
                                        if (!ok) return;
                                        final success = AuctionService.instance
                                            .placeBid(
                                                lotId: lot.id, amount: amount);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(success
                                              ? (isAr
                                                  ? 'تم تقديم العرض'
                                                  : 'Bid placed')
                                              : (isAr
                                                  ? 'العرض منخفض'
                                                  : 'Bid too low')),
                                        ));
                                      },
                                child: Text(
                                    isAr ? '+ 2× الحد الأدنى' : '+ 2× Min'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirm(BuildContext ctx, bool isAr, int amount) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (c) => AlertDialog(
            title: Text(isAr ? 'تأكيد المزايدة' : 'Confirm bid'),
            content: Text(isAr
                ? 'تأكيد تقديم عرض بقيمة $amount ؟'
                : 'Confirm placing a bid of $amount?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(isAr ? 'إلغاء' : 'Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(isAr ? 'تأكيد' : 'Confirm')),
            ],
          ),
        ) ??
        false;
  }

  String _fmt(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    final m = s ~/ 60;
    final remS = s % 60;
    return '${m}m ${remS}s';
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(this.asset);
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 112,
        height: 84,
        child: asset == null
            ? Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported))
            : Image.asset(asset!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported));
              }),
      ),
    );
  }
}

String? firstExistingAsset(List<String> assets) =>
    assets.isEmpty ? null : assets.first;
