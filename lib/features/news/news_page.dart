import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/gen_l10n/app_localizations.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // You can replace this with a Firestore stream of "news" docs later.
    final demo = List.generate(
        6, (i) => 'Headline ${i + 1} – International & national events');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t.newsTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        for (final n in demo)
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign),
              title: Text(n),
              subtitle: const Text('Tap to read…'),
            ),
          )
      ],
    );
  }
}
