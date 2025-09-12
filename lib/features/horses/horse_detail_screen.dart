import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/firestore_service.dart';
import '../../widgets/gallery_banner.dart';
import '../../l10n/generated/app_localizations.dart';

class HorseDetailScreen extends StatefulWidget {
  const HorseDetailScreen({super.key, required this.lotId});
  final String lotId;

  @override
  State<HorseDetailScreen> createState() => _HorseDetailScreenState();
}

class _HorseDetailScreenState extends State<HorseDetailScreen> {
  final _controller = TextEditingController();
  int? _typedBid;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _readImages(Map<String, dynamic> data) {
    final a = (data['imageUrls'] as List?)?.cast<String>();
    final b = (data['images'] as List?)?.cast<String>();
    return (a ?? b ?? const <String>[]).where((e) => e.trim().isNotEmpty).toList();
  }

  int _intOrZero(Object? v) => (v is num) ? v.toInt() : 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t?.horseDetails ?? 'Horse details'),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService.instance.streamLot(widget.lotId),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Error loading horse'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data ?? {};
          final name = (data['name'] as String?) ?? widget.lotId;
          final city = (data['city'] as String?) ?? 'Riyadh';
          final breed = (data['breed'] as String?) ?? 'Arabian';

          final start = _intOrZero(data['startingPrice']);
          final highest = _intOrZero(data['currentHighest']).clamp(start, 1 << 31);
          final step = _intOrZero(data['minIncrement']).clamp(1, 1 << 20);
          final status = (data['status'] as String?) ?? 'open';

          final images = _readImages(data);

          // seed input with a sensible amount
          final suggested = (highest > 0 ? highest + step : start + step);
          final effective = _typedBid ?? suggested;
          if (_controller.text.isEmpty || int.tryParse(_controller.text) == null) {
            _controller.text = effective.toString();
            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
          }

          return LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth > 900;

              final gallery = GalleryBanner(
                urls: images,
                height: 240, // smaller hero now
              );

              final side = SizedBox(
                width: wide ? 420 : double.infinity,
                child: _rightPanel(
                  context: context,
                  t: t,
                  name: name,
                  city: city,
                  breed: breed,
                  start: start,
                  highest: highest,
                  step: step,
                  status: status,
                  onPlus: () {
                    final now = int.tryParse(_controller.text) ?? suggested;
                    final next = now + step;
                    _controller.text = next.toString();
                    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                    setState(() => _typedBid = next);
                  },
                  onMinus: () {
                    final now = int.tryParse(_controller.text) ?? suggested;
                    final next = (now - step).clamp(step, 1 << 30);
                    _controller.text = next.toString();
                    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                    setState(() => _typedBid = next);
                  },
                  controller: _controller,
                  onChanged: (v) => setState(() => _typedBid = int.tryParse(v)),
                  onPlaceBid: () async {
  final amount = int.tryParse(_controller.text) ?? suggested;
  final ok = await FirestoreService.instance.placeBid(
    lotId: widget.lotId,
    amount: amount,
    userId: 'guest-web', // <-- add this line
  );
  final msg = ok ? (t?.bidPlaced ?? 'Bid placed') : (t?.bidFailed ?? 'Bid failed');
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
},
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                gallery,
                                const SizedBox(height: 16),
                                _bidsSection(context, t),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          side,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          gallery,
                          const SizedBox(height: 16),
                          side,
                          const SizedBox(height: 16),
                          _bidsSection(context, t),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _rightPanel({
    required BuildContext context,
    required AppLocalizations? t,
    required String name,
    required String city,
    required String breed,
    required int start,
    required int highest,
    required int step,
    required String status,
    required VoidCallback onPlus,
    required VoidCallback onMinus,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required Future<void> Function() onPlaceBid,
  }) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('$breed • ${t?.cityLabel ?? "City"}: $city'),
            const SizedBox(height: 6),
            Text(
              '${t?.startingLabel ?? "Starting"}: $start • '
              '${t?.currentHighestLabel ?? "Highest"}: $highest • '
              '${t?.minLabel ?? "Min"} +$step',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 22),

            Row(
              children: [
                IconButton(
                  tooltip: t?.decrement ?? 'Decrease',
                  onPressed: onMinus,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t?.enterAmount ?? 'Enter amount',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                IconButton(
                  tooltip: t?.increment ?? 'Increase',
                  onPressed: onPlus,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: status == 'closed' ? null : onPlaceBid,
                icon: const Icon(Icons.gavel),
                label: Text(t?.placeBid ?? 'Place bid'),
              ),
            ),

            const SizedBox(height: 8),
            if (status == 'closed')
              Text(
                'Closed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bidsSection(BuildContext context, AppLocalizations? t) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t?.recentBids ?? 'Recent bids',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.bidsStream(widget.lotId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Text('Error loading bids');
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(),
                  );
                }
                final bids = snap.data!;
                if (bids.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No bids yet'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bids.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (_, i) {
                    final b = bids[i];
                    final amount =
                        (b['amount'] is num) ? (b['amount'] as num).toInt() : 0;
                    final by = (b['userId'] as String?) ?? 'user';
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.attach_money),
                      title: Text('${t?.currency ?? 'SAR'} $amount'),
                      subtitle: Text('${t?.byUser ?? "By"}: $by'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
