import 'package:flutter/material.dart';
import 'package:horse_auction_app/features/home/home_page.dart';
import 'package:horse_auction_app/features/horses/horses_page.dart';
import 'package:horse_auction_app/features/services/services_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_index) {
      case 0:
        body = const HomePage();
        break;
      case 1:
        body = const HorsesPage();
        break;
      case 2:
      default:
        body = const ServicesPage();
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Horses',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Services',
          ),
        ],
      ),
      // Simple language button that just tells user to restart (no LocaleController needed).
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 8, right: 8),
        child: IconButton.filledTonal(
          tooltip: 'Language',
          icon: const Icon(Icons.language),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Restart the app to apply language'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
