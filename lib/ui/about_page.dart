import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Horse Auction – demo build\n\n'
          'This is a simple baseline without backend.\n'
          '• Lots tab: list of horses\n'
          '• Live tab: simulated bid stream\n'
          '• Results tab: sold items\n'
          '• Tap a lot to place a bid',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
