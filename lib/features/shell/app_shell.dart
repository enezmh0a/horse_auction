import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/locale_controller.dart';
import '../../l10n/app_localizations.dart';

import '../home/home_page.dart';
import '../horses/horses_page.dart';
import '../services/services_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final pages = const [
      HomePage(),
      HorsesPage(),
      ServicesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.title),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: l.language,
            icon: const Icon(Icons.public),
            onSelected: (locale) {
              LocaleController.of(context).setLocale(locale);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.restartedApplied)),
              );
            },
            itemBuilder: (context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem(
                  value: const Locale('en'), child: Text(l.langEnglish)),
              PopupMenuItem(
                  value: const Locale('ar'), child: Text(l.langArabic)),
            ],
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: const Icon(Icons.pets),
            label: l.horsesTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.servicesTitle,
          ),
        ],
      ),
    );
  }
}
