// lib/features/shell/app_shell.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_app/features/dashboard/dashboard_page.dart';
import 'package:horse_auction_app/features/horses/horses_page.dart';
import 'package:horse_auction_app/features/services/services_page.dart';
import 'package:horse_auction_app/features/about/about_page.dart';
// reuse your working Lots page
import 'package:horse_auction_app/features/home/lots_home_tabs.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Horse Auctions'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
              Tab(icon: Icon(Icons.list_alt), text: 'Lots'),
              Tab(icon: Icon(Icons.horse), text: 'Horses'),
              Tab(
                  icon: Icon(Icons.miscellaneous_services_outlined),
                  text: 'Services'),
              Tab(icon: Icon(Icons.info_outline), text: 'About'),
              Tab(icon: Icon(Icons.mail_outline), text: 'Contact'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardPage(),
            LotsHomeTabs(),
            HorsesPage(),
            ServicesPage(),
            AboutPage(showContact: false),
            AboutPage(showContact: true),
          ],
        ),
      ),
    );
  }
}
