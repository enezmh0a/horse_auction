<<<<<<< HEAD
// lib/widgets/lang_toggle_button.dart
import 'package:flutter/material.dart';

class LangToggleButton extends StatelessWidget {
  const LangToggleButton({
    super.key,
    required this.locale,
    required this.onToggle,
  });

  final Locale locale;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isAr = locale.languageCode == 'ar';
    final nextLabel = isAr ? 'EN' : 'AR';
    final tip = isAr ? 'Switch to English' : 'التبديل إلى العربية';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: onToggle,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: Text(
          nextLabel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
=======
import 'package:flutter/material.dart';
import '../i18n/locale_controller.dart';

class LangToggleButton extends StatelessWidget {
  const LangToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = LocaleController.locale.value.languageCode == 'ar';
    // Simple text icon so it’s obvious which language we’re switching TO.
    return IconButton(
      tooltip: isAr ? 'English' : 'العربية',
      onPressed: LocaleController.toggle,
      icon: Text(
        isAr ? 'EN' : 'ع',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
>>>>>>> origin/main
      ),
    );
  }
}
