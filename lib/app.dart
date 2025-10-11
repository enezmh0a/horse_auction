// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

import 'l10n/app_localizations.dart';
import 'features/shell/app_shell.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Horse Auctions',
      debugShowCheckedModeBanner: false,

      // Explicit localization delegates (works even if your generated file
      // doesn’t define localizationsDelegates/supportedLocales).
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        // Add more if you have ARB files, e.g. Locale('ar'), Locale('fr'), …
      ],

      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7C4DFF),
        scaffoldBackgroundColor: const Color(0xFFF7EDF6),
        useMaterial3: true,
      ),

      home: const AppShell(),
    );
  }
}
