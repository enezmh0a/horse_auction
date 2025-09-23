import 'package:flutter/material.dart';
import '../locale_controller.dart';
import '../l10n/app_localizations.dart';

class LanguageAction extends StatelessWidget {
  const LanguageAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      tooltip: l?.appTitle ?? 'Language',
      icon: const Icon(Icons.language),
      onSelected: (value) {
        if (value == 'en') {
          localeController.setEnglish();
        } else if (value == 'ar') {
          localeController.setArabic();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'en', child: Text(l?.langEnglish ?? 'English')),
        PopupMenuItem(value: 'ar', child: Text(l?.langArabic ?? 'العربية')),
      ],
    );
  }
}
