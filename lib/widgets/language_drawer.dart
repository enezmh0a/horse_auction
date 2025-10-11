import 'package:flutter/material.dart';

class LanguageDrawer extends StatelessWidget {
  const LanguageDrawer(
      {super.key, required this.onEnglish, required this.onArabic});
  final VoidCallback onEnglish;
  final VoidCallback onArabic;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ListTile(title: Text('Language')),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('English'),
              onTap: onEnglish,
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('العربية'),
              onTap: onArabic,
            ),
          ],
        ),
      ),
    );
  }
}
