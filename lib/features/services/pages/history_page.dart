// lib/features/services/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    Widget item(String initials, String title, String when, bool confirmed) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(child: Text(initials)),
          title: Text(title),
          subtitle: Text(when),
          trailing: Chip(
            label: Text(confirmed ? l.statusConfirmed : l.statusPending),
            backgroundColor:
                confirmed ? Colors.blue.shade50 : Colors.orange.shade50,
            side: BorderSide(color: confirmed ? Colors.blue : Colors.orange),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        item('D', l.hDesertComet, l.hAgo('20m'), true),
        item('G', l.hGoldenMirage, l.hAgo('2h'), false),
      ],
    );
  }
}
