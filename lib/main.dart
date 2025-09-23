import 'package:flutter/material.dart';
import 'package:horse_auction_app/locale_singleton.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart';
import 'package:horse_auction_app/lots_home_tabs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyRoot());
}

class MyRoot extends StatefulWidget {
  const MyRoot({super.key});

  @override
  State<MyRoot> createState() => _MyRootState();
}

class _MyRootState extends State<MyRoot> {
  @override
  Widget build(BuildContext context) {
    // Rebuild MaterialApp when locale changes
    return AnimatedBuilder(
      animation: AppLocale.instance,
      builder: (_, __) {
        return MaterialApp(
          title: 'Horse Auctions',
          debugShowCheckedModeBanner: false,
          locale: AppLocale.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFFF7F2F9),
          ),
          home: const LotsHomeTabs(),
          routes: {
            '/lots': (_) => const LotsHomeTabs(),
          },
        );
      },
    );
  }
}
