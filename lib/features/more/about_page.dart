import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Who we are')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'We run curated horse auctions across the region. '
          'Our mission is transparent bidding, verified horses, and a smooth buyer experience.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
