import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'features/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyRoot());
}

class MyRoot extends StatefulWidget {
  const MyRoot({super.key});

  @override
  State<MyRoot> createState() => _MyRootState();
}

class _MyRootState extends State<MyRoot> {
  final _localeController = LocaleController();

  @override
  Widget build(BuildContext context) {
    return LocaleControllerScope(
      controller: _localeController,
      child: Builder(
        builder: (context) {
          final locale = LocaleController.of(context).locale;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Horse Auctions',
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
