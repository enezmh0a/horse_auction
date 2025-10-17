import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../models/lot_model.dart';
import '../../services/auction_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isAr = langCode == 'ar';
    final svc = AuctionService.instance;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'لوحة المعلومات' : 'Dashboard')),
        body: ValueListenableBuilder<List<LotModel>>(
          valueListenable: svc.lotsListenable,
          builder: (context, lots, _) {
            final total = lots.length;
            final live = lots
                .where((l) => l.status == LotStatus.live && !l.isClosed)
                .length;
            final sold = lots.where((l) => l.status == LotStatus.sold).length;
            final upcoming =
                lots.where((l) => l.status == LotStatus.upcoming).length;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _StatCard(
                      label: isAr ? 'إجمالي الخيول' : 'Total lots',
                      value: total.toString(),
                      color: Colors.blue),
                  _StatCard(
                      label: isAr ? 'مباشر' : 'Live',
                      value: live.toString(),
                      color: Colors.orange),
                  _StatCard(
                      label: isAr ? 'مباع' : 'Sold',
                      value: sold.toString(),
                      color: Colors.green),
                  _StatCard(
                      label: isAr ? 'قادمة' : 'Upcoming',
                      value: upcoming.toString(),
                      color: Colors.purple),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: color, height: 1)),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
