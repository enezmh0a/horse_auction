import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:horse_auction_app/features/horses/horse_list_screen.dart';
import 'firebase_options.dart';

void main() async {
  // This is the crucial part. It ensures that the Flutter engine is initialized
  // before we try to initialize Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // This initializes Firebase for the specific platform (Windows in this case)
  // and waits for it to complete before running the app.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horse Auction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HorseListScreen(),
    );
  }
}