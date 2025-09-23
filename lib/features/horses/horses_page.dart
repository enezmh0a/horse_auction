import 'package:flutter/material.dart';
import 'package:horse_auction_app/features/home/lots_home_tabs.dart';

/// Reuse your working lots UI
class HorsesPage extends StatelessWidget {
  const HorsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LotsHomeTabs();
  }
}
