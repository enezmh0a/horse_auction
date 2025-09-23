import 'package:flutter/material.dart';
import '../l10n/locale_controller.dart';

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
      ),
    );
  }
}
