// lib/features/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';
import 'package:horse_auction_baseline/core/locale_controller.dart';
import 'package:horse_auction_baseline/services/live_bids_service.dart';

import 'package:horse_auction_baseline/ui/live_page.dart';
import 'package:horse_auction_baseline/ui/lots_page.dart';
import 'package:horse_auction_baseline/ui/results_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.service,
    required this.localeController,
  });

  final LiveBidsService service;
  final LocaleController localeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 1; // default to Lots

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final pages = <Widget>[
      LivePage(service: widget.service),
      LotsPage(service: widget.service),
      ResultsPage(service: widget.service),
    ];

    final titles = <String>[t.liveTab, t.lotsTab, t.resultsTab];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: t.toggleLanguage,
            onPressed: () async {
              await widget.localeController.toggle();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        // IMPORTANT: use a block; don’t try to use the value of setState
        onDestinationSelected: (i) {
          setState(() {
            _index = i;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.podcasts_outlined),
            selectedIcon: const Icon(Icons.podcasts),
            label: t.liveTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: t.lotsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: t.resultsTab,
          ),
        ],
      ),
    );
  }
}
