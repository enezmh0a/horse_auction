import 'package:flutter/material.dart';
import 'package:horse_auction_app/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: Text(l.homeLive),
              subtitle: Text(l.homeLiveSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/lots'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: Text(l.homeEnding),
              subtitle: Text(l.homeEndingSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/lots'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront),
              title: Text(l.homeSell),
              subtitle: Text(l.homeSellSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/seller'),
            ),
          ),
        ],
      ),
    );
  }
}
