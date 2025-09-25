import 'package:flutter/material.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.servicesTitle ?? 'Services')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TierTile(
            icon: Icons.verified,
            titleKey: 'tierPlatinum',
            descKey: 'tierPlatinumDesc',
          ),
          SizedBox(height: 12),
          _TierTile(
            icon: Icons.emoji_events,
            titleKey: 'tierGold',
            descKey: 'tierGoldDesc',
          ),
          SizedBox(height: 12),
          _TierTile(
            icon: Icons.military_tech,
            titleKey: 'tierSilver',
            descKey: 'tierSilverDesc',
          ),
        ],
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String descKey;

  const _TierTile({
    required this.icon,
    required this.titleKey,
    required this.descKey,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(_t(l, titleKey)),
        subtitle: Text(_t(l, descKey)),
        onTap: () {},
      ),
    );
  }

  String _t(AppLocalizations? l, String key) {
    // tiny helper to resolve by key name without switch
    final map = <String, String?>{
      'tierPlatinum': l?.tierPlatinum,
      'tierPlatinumDesc': l?.tierPlatinumDesc,
      'tierGold': l?.tierGold,
      'tierGoldDesc': l?.tierGoldDesc,
      'tierSilver': l?.tierSilver,
      'tierSilverDesc': l?.tierSilverDesc,
    };
    return map[key] ?? key;
  }
}
