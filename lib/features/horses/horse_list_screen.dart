// at top:
import 'package:flutter/material.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart';
import '../../services/firestore_service.dart';

class HorseListScreen extends StatelessWidget {
  const HorseListScreen({super.key, this.onLocaleChange});
  final void Function(Locale?)? onLocaleChange;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t?.lotsTitle ?? 'Lots'),
        actions: [
          PopupMenuButton<String>(
            tooltip: t?.language ?? 'Language',
            onSelected: (v) {
              if (onLocaleChange == null) return;
              if (v == 'en') onLocaleChange!(const Locale('en'));
              if (v == 'ar') onLocaleChange!(const Locale('ar'));
              if (v == 'system') onLocaleChange!(null);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'en', child: Text(t?.english ?? 'English')),
              PopupMenuItem(value: 'ar', child: Text(t?.arabic ?? 'العربية')),
              PopupMenuItem(
                  value: 'system', child: Text(t?.systemLanguage ?? 'System')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.lotsStream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
                child: Text(t?.errorLoadingLots ?? 'Error loading lots'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lots = snap.data!;
          if (lots.isEmpty) {
            return Center(child: Text(t?.noLots ?? 'No lots'));
          }
          return ListView.separated(
            itemCount: lots.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final lot = lots[i];
              final id =
                  (lot['id'] as String?) ?? (lot['lotId'] as String?) ?? '';
              final name = (lot['name'] as String?) ?? id;
              final city = (lot['city'] as String?) ?? '';
              final highest = (lot['currentHighest'] is num)
                  ? (lot['currentHighest'] as num).toInt()
                  : 0;
              final images = (lot['images'] as List?)?.cast<String>() ??
                  (lot['imageUrls'] as List?)?.cast<String>() ??
                  const <String>[];

              return ListTile(
                leading: images.isNotEmpty
                    ? Image.network(images.first,
                        width: 64, height: 64, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                title: Text(name),
                subtitle: Text('${t?.cityLabel ?? "City"}: $city • '
                    '${t?.highestLabel ?? "Highest"}: $highest'),
                onTap: () {
                  if (id.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Missing lot id')),
                    );
                    return;
                  }
                  Navigator.of(context).pushNamed('/horse', arguments: id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
