import 'package:flutter/material.dart';
import 'package:horse_auction_app/features/dashboard/dashboard_page.dart';
import 'package:horse_auction_app/features/horses/horses_page.dart';
import 'package:horse_auction_app/features/services/services_page.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart';
import 'package:horse_auction_app/l10n/locale_controller.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l?.appTitle ?? 'Horse Auctions'),
          actions: [
            IconButton(
              tooltip: l?.language ?? 'Language',
              icon: const Icon(Icons.language),
              onPressed: () async {
                final choice = await showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
                  items: [
                    PopupMenuItem(
                        value: 'en', child: Text(l?.langEnglish ?? 'English')),
                    PopupMenuItem(
                        value: 'ar', child: Text(l?.langArabic ?? 'العربية')),
                  ],
                );
                if (choice != null) {
                  LocaleController.instance.setLocale(Locale(choice));
                }
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              // reusing your existing tab strings for now
              Tab(
                  text: l?.tabAll ?? 'Dashboard',
                  icon: const Icon(Icons.dashboard)),
              Tab(text: l?.tabLive ?? 'Horses', icon: const Icon(Icons.pets)),
              Tab(
                  text: l?.tabClosed ?? 'Services',
                  icon: const Icon(Icons.miscellaneous_services)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardPage(),
            HorsesPage(),
            ServicesPage(),
          ],
        ),
      ),
    );
  }
}
