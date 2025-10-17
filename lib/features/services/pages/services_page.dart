// lib/features/services/pages/services_page.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    Widget tile(IconData icon, String title, String subtitle) => Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        tile(Icons.verified, l.serviceVets, l.serviceVetsDesc),
        tile(Icons.local_shipping, l.serviceTransport, l.serviceTransportDesc),
        tile(
            Icons.home_work_outlined, l.serviceBoarding, l.serviceBoardingDesc),
      ],
    );
  }
}
