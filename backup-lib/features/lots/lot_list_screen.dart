import 'package:flutter/material.dart';
import 'package:horse_auction_app/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LotListScreen extends StatelessWidget {
  const LotListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final demoLots = List.generate(8, (i) => {
          'id': (i + 1).toString(),
          'name': 'حصان عربي رقم ${i + 1}',
          'currentBid': 5000 * (i + 1),
          'reserveMet': i % 2 == 0,
        });

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: demoLots.length,
      itemBuilder: (context, i) {
        final lot = demoLots[i];
        final reserve =
            (lot['reserveMet'] as bool) ? l.lotReserveMet : l.lotReserveNotMet;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(lot['id'] as String)),
            title: Text(lot['name'] as String),
            subtitle: Text('SAR ${(lot['currentBid'] as int)} • $reserve'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/lots/${lot['id']}'),
          ),
        );
      },
    );
  }
}
