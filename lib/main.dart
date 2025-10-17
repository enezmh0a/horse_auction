import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart'; // <-- add this line

// Shell
import 'features/shell/app_shell.dart';

void main() {
  // Keep main simple to avoid zone-related issues.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RootApp());
}

/// Minimal locale controller (works out-of-the-box).
/// If you already have lib/core/locale_controller.dart,
/// replace usages with your controller and remove this class.
class _SimpleLocaleController {
  _SimpleLocaleController({Locale initial = const Locale('en')})
      : _locale = ValueNotifier<Locale>(initial);

  final ValueNotifier<Locale> _locale;

  ValueListenable<Locale> get listenable => _locale;

  Locale get current => _locale.value;

  /// Toggle between English and Arabic.
  void toggle() {
    final isAr = _locale.value.languageCode.toLowerCase() == 'ar';
    _locale.value = Locale(isAr ? 'en' : 'ar');
  }

  /// Optional alias used by some shells.
  void switchLocale() => toggle();
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  late final _SimpleLocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = _SimpleLocaleController(
      // Pick your default locale here:
      initial: const Locale('en'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: _localeController.listenable,
      builder: (context, locale, _) {
        final isAr = locale.languageCode.toLowerCase() == 'ar';

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Basic built-in delegates (no flutter_gen).
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          locale: locale,
          // Title that adapts with locale (no gen).
          onGenerateTitle: (_) => isAr ? 'مزادات الخيول' : 'Horse Auctions',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.brown,
            brightness: Brightness.light,
            fontFamily: isAr ? null : null, // plug custom fonts if you have
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.brown,
            brightness: Brightness.dark,
            fontFamily: isAr ? null : null,
          ),
          // Home shell with tabs; we pass our controller so the AppBar toggle works.
          home: AppShell(localeController: _localeController),
        );
      },
    );
  }
}
