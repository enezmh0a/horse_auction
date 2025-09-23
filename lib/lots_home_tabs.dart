import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart';
import 'package:horse_auction_app/locale_singleton.dart';

/// Simple 3-tab home: All / Live / Closed
class LotsHomeTabs extends StatefulWidget {
  const LotsHomeTabs({super.key});

  @override
  State<LotsHomeTabs> createState() => _LotsHomeTabsState();
}

class _LotsHomeTabsState extends State<LotsHomeTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l?.lots ?? 'Lots'),
        actions: [
          // Language menu (EN/AR)
          IconButton(
            tooltip: l?.language ?? 'Language',
            icon: const Icon(Icons.language),
            onPressed: () {
              showMenu<Locale>(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 56, 16, 0),
                items: [
                  PopupMenuItem(
                    value: const Locale('en'),
                    child: Text(l?.langEnglish ?? 'English'),
                  ),
                  PopupMenuItem(
                    value: const Locale('ar'),
                    child: Text(l?.langArabic ?? 'العربية'),
                  ),
                ],
              ).then(AppLocale.instance.setLocale);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l?.tabAll ?? 'All'),
            Tab(text: l?.tabLive ?? 'Live'),
            Tab(text: l?.tabClosed ?? 'Closed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _LotsList(kind: _LotKind.all),
          _LotsList(kind: _LotKind.live),
          _LotsList(kind: _LotKind.closed),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _seedLots,
        icon: const Icon(Icons.add),
        label: Text(l?.seedLots ?? 'Seed lots'),
      ),
    );
  }
}

enum _LotKind { all, live, closed }

class _LotsList extends StatelessWidget {
  const _LotsList({required this.kind});

  final _LotKind kind;

  Query<Map<String, dynamic>> _query() {
    final lots = FirebaseFirestore.instance.collection('lots');
    switch (kind) {
      case _LotKind.all:
        return lots.orderBy('tsUpdated', descending: true);
      case _LotKind.live:
        return lots
            .where('status', isEqualTo: 'live')
            .orderBy('tsUpdated', descending: true);
      case _LotKind.closed:
        return lots
            .where('status', isEqualTo: 'closed')
            .orderBy('tsUpdated', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query().snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
              child: Text(l?.errorLoadingLots ?? 'Error loading lots'));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(child: Text(l?.noData ?? 'Nothing to show'));
        }

        final docs = snap.data!.docs;
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();

            final title = (data['title'] ?? data['name'] ?? doc.id).toString();
            final status = (data['status'] ?? '').toString().toLowerCase();

            final current = (data['current'] as num?) ?? 0;
            final next = (data['next'] as num?);
            final step = (data['step'] as num?);

            final hasImage = (data['images'] is List &&
                    (data['images'] as List).isNotEmpty) ||
                (data['image'] ?? '').toString().isNotEmpty;

            final isLive = status == 'live';

            return Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {/* push details page later if you like */},
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _thumb(hasImage: hasImage),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _chip(l?.current ?? 'Current', _sar(current)),
                                if (next != null)
                                  _chip(l?.next ?? 'Next', _sar(next)),
                                if (step != null)
                                  _chip(l?.step ?? 'Step', _sar(step)),
                                if (status.isNotEmpty)
                                  Chip(
                                    label: Text(
                                      status == 'live'
                                          ? (l?.statusLive ?? 'Live')
                                          : (l?.statusClosed ?? 'Closed'),
                                    ),
                                    side: BorderSide.none,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: isLive
                            ? () async {
                                final amount = await _askBidAmount(context,
                                    min: _minAllowed(current, step));
                                if (amount == null) return;
                                await _placeBid(doc.reference, amount);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(l?.bidPlaced ?? 'Bid placed')),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.gavel),
                        label: Text(l?.bid ?? 'Bid'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- helpers ----------

  static num _minAllowed(num current, num? step) {
    final inc = (step ?? 0) <= 0 ? 0 : step!;
    return current + inc;
  }

  static Future<num?> _askBidAmount(BuildContext context,
      {required num min}) async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: min.toStringAsFixed(0));
    final value = await showDialog<num>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l?.placeBid ?? 'Place bid'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l?.amount ?? 'Amount',
            helperText: '${l?.min ?? 'Min'}: ${min.toStringAsFixed(0)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = num.tryParse(ctrl.text.trim());
              Navigator.of(context).pop(parsed);
            },
            child: Text(l?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
    return value;
  }

  static Future<void> _placeBid(
    DocumentReference<Map<String, dynamic>> lotRef,
    num amount,
  ) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(lotRef);
      if (!snap.exists) {
        throw Exception('Lot not found');
      }
      final data = snap.data()!;
      final status = (data['status'] ?? '').toString();
      if (status != 'live') {
        throw Exception('Not live');
      }

      final current = (data['current'] as num?) ?? 0;
      final step = (data['step'] as num?) ?? 0;
      final min = _minAllowed(current, step);
      if (amount < min) {
        throw Exception('Bid below minimum');
      }

      final newCurrent = amount;
      final newNext = amount + (step > 0 ? step : 0);

      tx.update(lotRef, {
        'current': newCurrent,
        'next': newNext,
        'tsUpdated': FieldValue.serverTimestamp(),
      });

      // optional history record
      final bidsRef = lotRef.collection('bids').doc();
      tx.set(bidsRef, {
        'amount': newCurrent,
        'ts': FieldValue.serverTimestamp(),
      });
    });
  }

  Widget _thumb({required bool hasImage}) {
    return Container(
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(hasImage ? Icons.image : Icons.image_not_supported_outlined),
    );
  }

  Widget _chip(String label, String value) {
    return Chip(
      side: BorderSide.none,
      label: Text('$label: $value'),
    );
  }

  String _sar(num v) => 'SAR ${v.toStringAsFixed(0)}';
}

// ---------- quick demo seed ----------

Future<void> _seedLots() async {
  final lots = FirebaseFirestore.instance.collection('lots');

  final batch = FirebaseFirestore.instance.batch();
  final now = FieldValue.serverTimestamp();

  final samples = [
    {
      'title': 'Bay Stallion',
      'status': 'live',
      'current': 12000,
      'step': 500,
      'next': 12500,
      'tsUpdated': now,
    },
    {
      'title': 'Grey Gelding',
      'status': 'live',
      'current': 15750,
      'step': 250,
      'next': 16000,
      'tsUpdated': now,
    },
    {
      'title': 'Chestnut Mare',
      'status': 'closed',
      'current': 8300,
      'step': 500,
      'next': 0,
      'tsUpdated': now,
    },
  ];

  for (final s in samples) {
    final id = lots.doc().id;
    batch.set(lots.doc(id), s);
  }

  await batch.commit();
}
