import 'widgets/language_action.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_pages/dashboard_page.dart';
import 'admin_pages/auctions_page.dart';
import 'admin_pages/users_page.dart';
import 'admin_pages/services_page.dart';
import 'admin_pages/settings_page.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = <Widget>[
      const DashboardPage(),
      const AuctionsPage(),
      const UsersPage(),
      const ServicesPage(),
      const SettingsPage(),
    ];
    final List<String> labels = [
      l.navDashboard,
      l.navAuctions,
      l.navUsers,
      l.navServices,
      l.navSettings,
    ];
    final icons = const [
      Icons.space_dashboard_outlined,
      Icons.gavel_outlined,
      Icons.people_alt_outlined,
      Icons.build_outlined,
      Icons.settings_outlined,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).appTitle),
            actions: const [LanguageAction()], // 👈 add this
          ),
          drawer: wide ? null : _buildDrawer(labels, icons),
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (var i = 0; i < labels.length; i++)
                      NavigationRailDestination(
                        icon: Icon(icons[i]),
                        label: Text(labels[i]),
                      ),
                  ],
                ),
              Expanded(child: pages[_index]),
            ],
          ),
          bottomNavigationBar:
              wide
                  ? null
                  : NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: [
                      for (var i = 0; i < labels.length; i++)
                        NavigationDestination(
                          icon: Icon(icons[i]),
                          label: labels[i],
                        ),
                    ],
                  ),
          floatingActionButton: IconButton(
            tooltip: 'Ping',
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () async {
              await FirebaseFirestore.instance.settings;
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l.serviceDone ?? '')));
            },
          ),
        );
      },
    );
  }

  Widget _buildDrawer(List<String> labels, List<IconData> icons) {
    // drawer for narrow layouts
    return Drawer(
      child: SafeArea(
        child: ListView.builder(
          itemCount: labels.length,
          itemBuilder:
              (context, i) => ListTile(
                leading: Icon(icons[i]),
                title: Text(labels[i]),
                selected: i == _index,
                onTap: () {
                  setState(() => _index = i);
                  Navigator.pop(context);
                },
              ),
        ),
      ),
    );
  }
}
