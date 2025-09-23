import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AuctionsPage extends StatelessWidget {
  const AuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(child: Text(l.noData));
  }
}
