import 'package:flutter/material.dart';

class LanguageAction extends StatelessWidget {
  const LanguageAction(
      {super.key, required this.onEnglish, required this.onArabic});
  final VoidCallback onEnglish;
  final VoidCallback onArabic;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate),
      onSelected: (v) => v == 'en' ? onEnglish() : onArabic(),
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 'en', child: Text('English')),
        PopupMenuItem(value: 'ar', child: Text('العربية')),
      ],
    );
  }
}
