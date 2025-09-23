// lib/widgets/language_drawer.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';

class LanguageDrawer extends StatelessWidget {
  const LanguageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!; // non-null
    final code = Localizations.localeOf(context).languageCode;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(l.langEnglish),
              trailing: code == 'en' ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(context);
                localeController.setEnglish();
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(l.langArabic),
              trailing: code == 'ar' ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(context);
                localeController.setArabic();
              },
            ),
          ],
        ),
      ),
    );
  }
}
