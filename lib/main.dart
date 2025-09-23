// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// NEW
import 'features/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horse Auctions',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6B5AE0),
      ),
      debugShowCheckedModeBanner: false,
      home: const AppShell(), // <-- HERE
    );
  }

  @override
  void initState() {
    super.initState();
    // Rebuild MaterialApp when locale changes.
    _locale.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleControllerProvider(
      controller: _locale,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Horse Auctions',
        locale: _locale.locale, // null => system locale
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B5AE0)),
          useMaterial3: true,
        ),
        home: const LotsHomeTabs(),
      ),
    );
  }
}
