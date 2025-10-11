// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'core/locale_controller.dart';
import 'services/live_bids_service.dart';
import 'features/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT: your LiveBidsService is a singleton — use .instance
  final service = LiveBidsService.instance;

  // Locale controller drives the language toggle (EN/AR)
  final localeController = LocaleController();

  runApp(MyApp(service: service, localeController: localeController));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.service,
    required this.localeController,
  });

  final LiveBidsService service;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    // LocaleController exposes a ValueNotifier<Locale> named `locale`
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController.locale,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Horse Auction',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B5E3C),
            ),
          ),

          // Localization wiring
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Root shell gets BOTH service and locale controller
          home: AppShell(service: service, localeController: localeController),
        );
      },
    );
  }
}
