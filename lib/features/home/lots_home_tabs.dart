import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:horse_auction_app/l10n/app_localizations.dart';
import 'package:horse_auction_app/l10n/locale_controller.dart';

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
        title: Text(l?.lotsTitle ?? 'Lots'),
        actions: [
          IconButton(
            tooltip: l?.language ?? 'Language',
            icon: const Icon(Icons.language),
            onPressed: () async {
              final choice = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
                items: [
                  PopupMenuItem(
                    value: 'en',
                    child: Text(l?.langEnglish ?? 'English'),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Text(l?.langArabic ?? 'العربية'),
                  ),
                ],
              );
              if (choice != null) {
                LocaleController.maybeOf(context)?.setLocale(Locale(choice));
              }
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
            final data = docs[i].data();
            final title =
                (data['title'] ?? data['name'] ?? docs[i].id).toString();
            final status = (data['status'] ?? '').toString().toLowerCase();
            final current =
                (data['current'] ?? data['currentPrice'] ?? 0) as num? ?? 0;
            final next = (data['next'] ?? data['nextPrice']) as num?;
            final step =
                (data['step'] ?? data['min'] ?? data['increment']) as num?;
            final hasImage = (data['images'] is List &&
                    (data['images'] as List).isNotEmpty) ||
                (data['image'] ?? '').toString().isNotEmpty;

            final isLive = status == 'live';

            return Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: push lot details if you have a page
                },
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
                            ? () =>
                                _showPlaceBidDialog(context, docs[i].reference)
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

  Future<void> _showPlaceBidDialog(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> lotRef,
  ) async {
    final l = AppLocalizations.of(context);
    final lotSnap = await lotRef.get();
    final data = lotSnap.data() ?? {};
    final current = (data['current'] ?? 0) as num? ?? 0;
    final step = (data['step'] ?? data['increment'] ?? 0) as num? ?? 0;
    final min = (current + step).toDouble();

    final controller = TextEditingController(text: min.toStringAsFixed(0));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l?.placeBid ?? 'Place bid'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l?.amount ?? 'Amount',
            helperText: '${l?.min ?? 'Min'}: ${min.toStringAsFixed(0)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final amount = num.tryParse(controller.text) ?? 0;
    if (amount < min) return;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(lotRef);
      final d = snap.data() ?? {};
      final cur = (d['current'] ?? 0) as num? ?? 0;
      final stp = (d['step'] ?? d['increment'] ?? 0) as num? ?? 0;
      final requiredMin = cur + stp;
      if (amount < requiredMin) {
        throw StateError('Bid below min');
      }
      tx.update(lotRef, {
        'current': amount,
        'next': amount + stp,
        'tsUpdated': FieldValue.serverTimestamp(),
      });
      // Optional: append to subcollection
      tx.set(lotRef.collection('bids').doc(), {
        'amount': amount,
        'ts': FieldValue.serverTimestamp(),
      });
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l?.bidPlaced ?? 'Bid placed')),
      );
    }
  }
}
