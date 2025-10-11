import 'package:flutter/material.dart';
import '../services/auction_service.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LiveFeedPage extends StatelessWidget {
  const LiveFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = AuctionService.instance.liveFeed;
    return Scaffold(
      appBar: AppBar(title: const Text('Live Bids')),
      body: \<List<Lot>>(
  stream: LiveBidsService.instance.lots$,
  builder: (context, snapshot) {
    final lots = snapshot.data ?? const <Lot>[];
          return _LiveFeedStreamList(event: snap.data);
        },
      ),
    );
  }
}

class _LiveFeedStreamList extends StatefulWidget {
  final BidEvent? event;
  const _LiveFeedStreamList({required this.event});

  @override
  State<_LiveFeedStreamList> createState() => _LiveFeedStreamListState();
}

class _LiveFeedStreamListState extends State<_LiveFeedStreamList> {
  final List<BidEvent> _events = [];

  @override
  void didUpdateWidget(covariant _LiveFeedStreamList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final e = widget.event;
    if (e != null) {
      setState(() => _events.insert(0, e)); // newest on top
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_events.isEmpty) {
      return const Center(
          child: Text('No bids yet. Place one to get started!'));
    }
    return ListView.separated(
      itemCount: _events.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final e = _events[i];
        return ListTile(
          leading: const Icon(Icons.local_activity),
          title: Text('${e.lotName} • SAR ${e.bid.amount}'),
          subtitle: Text('${e.bid.user} • ${e.bid.ts}'),
        );
      },
    );
  }
}
