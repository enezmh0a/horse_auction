import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart';
import 'package:horse_auction_app/widgets/safe_network_image.dart';

class HorseDetailScreen extends StatelessWidget {
  final String lotId;
  const HorseDetailScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('lots').doc(lotId).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
              appBar: AppBar(), body: Center(child: Text(l?.error ?? 'Error')));
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final lot = snap.data!.data() as Map<String, dynamic>;
        final name = (lot['name'] ?? 'Unnamed').toString();
        final images = (lot['images'] as List?)?.cast<String>() ?? const [];
        final breed = (lot['breed'] ?? '').toString();
        final age = (lot['age'] ?? '').toString();
        final state = (lot['state'] ?? '').toString();
        final current = (lot['current'] ?? 0).toInt();
        final minInc = (lot['minIncrement'] ?? 100).toInt();
        final start = (lot['startingBid'] ?? 0).toInt();

        return Scaffold(
          appBar: AppBar(title: Text(name, overflow: TextOverflow.ellipsis)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Gallery(images: images),
              const SizedBox(height: 16),
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(context, '${l?.breed ?? "Breed"}: $breed'),
                  _chip(context, '${l?.age ?? "Age"}: $age'),
                  _chip(context, '${l?.state ?? "State"}: $state'),
                  _chip(context, '${l?.current ?? "Current"}: $current'),
                  _chip(context, '${l?.minPlus ?? "Min +"}: $minInc'),
                  _chip(context, '${l?.start ?? "Start"}: $start'),
                ],
              ),
              const SizedBox(height: 16),
              _InlineBidBox(lotId: lotId, current: current, step: minInc),
              const SizedBox(height: 24),
              Text('Recent bids',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _BidList(lotId: lotId),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}

class _Gallery extends StatefulWidget {
  final List<String> images;
  const _Gallery({required this.images});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images.isNotEmpty ? widget.images : [''];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SafeNetworkImage(
            url: imgs[index],
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (imgs.length > 1) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(imgs.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => index = i),
                    child: Opacity(
                      opacity: i == index ? 1 : .5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SafeNetworkImage(
                          url: imgs[i],
                          width: 72,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineBidBox extends StatefulWidget {
  final String lotId;
  final int current;
  final int step;
  const _InlineBidBox(
      {required this.lotId, required this.current, required this.step});

  @override
  State<_InlineBidBox> createState() => _InlineBidBoxState();
}

class _InlineBidBoxState extends State<_InlineBidBox> {
  final controller = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    controller.text = (widget.current + widget.step).toString();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText:
                  '${l?.placeBid ?? "Place bid"} (${l?.amount ?? "Amount"})',
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _busy
              ? null
              : () async {
                  final v = int.tryParse(controller.text.trim()) ?? 0;
                  if (v < widget.current + widget.step) return;
                  setState(() => _busy = true);
                  final ok = await _tx(widget.lotId, v);
                  setState(() => _busy = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? (l?.bidPlaced ?? 'Bid placed!')
                          : (l?.error ?? 'Error')),
                    ),
                  );
                },
          icon: const Icon(Icons.gavel),
          label: Text(l?.placeBid ?? 'Place bid'),
        )
      ],
    );
  }

  Future<bool> _tx(String lotId, int amount) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.runTransaction((tx) async {
        final ref = db.collection('lots').doc(lotId);
        final snap = await tx.get(ref);
        final data = snap.data() as Map<String, dynamic>;
        final current = (data['current'] ?? 0).toInt();
        final step = (data['minIncrement'] ?? 100).toInt();
        if (amount < current + step) throw Exception('too low');

        tx.update(ref,
            {'current': amount, 'updatedAt': FieldValue.serverTimestamp()});
        tx.set(ref.collection('bids').doc(), {
          'amount': amount,
          'status': 'accepted',
          'bidder': 'Anonymous',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _BidList extends StatelessWidget {
  final String lotId;
  const _BidList({required this.lotId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lots')
          .doc(lotId)
          .collection('bids')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();

        // If Firestore ever delivered a duplicate locally, collapse by id
        final docs = {
          for (final d in snap.data!.docs) d.id: d,
        }.values.toList();

        return Column(
          children: docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            final amount = (m['amount'] ?? 0).toInt();
            final status = (m['status'] ?? '').toString().toUpperCase();
            final ts = (m['createdAt'] as Timestamp?)?.toDate();
            final dt = ts?.toIso8601String() ?? '';
            final color = status == 'ACCEPTED'
                ? Colors.green
                : status == 'REJECTED'
                    ? Colors.red
                    : Colors.grey;

            return ListTile(
              dense: true,
              leading: Icon(Icons.show_chart, color: color),
              title: Text('SAR $amount'),
              subtitle: Text(dt),
              trailing: Text(status, style: TextStyle(color: color)),
            );
          }).toList(),
        );
      },
    );
  }
}
