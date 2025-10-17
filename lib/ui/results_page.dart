import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/lot_model.dart';
import '../services/auction_service.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isAr = langCode == 'ar';
    final svc = AuctionService.instance;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'النتائج' : 'Results')),
        body: ValueListenableBuilder<List<LotModel>>(
          valueListenable: svc.lotsListenable,
          builder: (context, lots, _) {
            final done = svc.resultsLots();
            if (done.isEmpty) {
              return Center(
                  child: Text(isAr ? 'لا توجد نتائج بعد' : 'No results yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: done.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final lot = done[i];
                return ListTile(
                  leading: _Thumb(firstExistingAsset(lot.images)),
                  title: Text(lot.titleForLocale(isAr ? 'ar' : 'en')),
                  subtitle: ValueListenableBuilder<int>(
                    valueListenable: lot.currentBid,
                    builder: (context, bid, _) => Text(
                      (isAr ? 'السعر النهائي: ' : 'Final price: ') +
                          bid.toString(),
                    ),
                  ),
                  trailing: Chip(
                    label: Text(
                      lot.reserveMet
                          ? (isAr ? 'مباع' : 'Sold')
                          : (isAr ? 'لم يبلغ الحد الأدنى' : 'Reserve not met'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(this.asset);
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 64,
        height: 48,
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
