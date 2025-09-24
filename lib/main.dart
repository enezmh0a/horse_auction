import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/locale_controller.dart';
import 'features/shell/app_shell.dart';
import 'firebase_options.dart'; // your existing FlutterFire file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocaleController.instance.load();
  runApp(const MyRoot());
}

class MyRoot extends StatefulWidget {
  const MyRoot({super.key});
  @override
  State<MyRoot> createState() => _MyRootState();
}

class _MyRootState extends State<MyRoot> {
  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocale);
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocale);
    super.dispose();
  }

  void _onLocale() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleController.instance.locale;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D5BA4)),
        useMaterial3: true,
        fontFamily: locale.languageCode == 'ar' ? 'NotoNaskhArabic' : null,
      ),
      home: const AppShell(),
    );
  }
}
