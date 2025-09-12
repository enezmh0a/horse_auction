import 'package:flutter/material.dart';

class BiddingScreen extends StatefulWidget {
  const BiddingScreen({super.key});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  int _price = 10000; // demo current bid

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Bidding Room',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('Current bid: SAR $_price'),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => setState(() => _price += 1000),
                  child: const Text('+1,000'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => setState(() => _price += 5000),
                  child: const Text('+5,000'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
