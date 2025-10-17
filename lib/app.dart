// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

import 'l10n/app_localizations.dart';
import 'features/shell/app_shell.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horse Auctions',
      locale: appLocale.value, // if you keep a ValueNotifier for RTL toggle
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(), // your delegate class from l10n/
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7C4DFF),
        scaffoldBackgroundColor: const Color(0xFFF7EDF6),
        useMaterial3: true,
      ),

      home: const AppShell(),
    );
  }
}
