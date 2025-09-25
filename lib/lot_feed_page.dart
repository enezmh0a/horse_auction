// imports you need at the top of lot_feed_page.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:horse_auction_app/services/lots_service.dart';
import 'package:horse_auction_app/models/lot.dart';
import 'package:horse_auction_app/l10n/app_localizations.dart'; // your re-export file

// The rest of your file content remains the same as the version I sent before.
// I am showing the full file for completeness.

class LotsHomeTabs extends StatelessWidget {
  const LotsHomeTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        _LotList(statusFilter: null), // All
        _LotList(statusFilter: 'live'), // Live
        _LotList(statusFilter: 'closed'), // Closed
      ],
    );
  }
}

// Remove this custom StatelessWidget class and use Flutter's StatelessWidget instead.

class _LotList extends StatelessWidget {
  const _LotList({required this.statusFilter});
  final String? statusFilter;

  @override
  Widget build(BuildContext context) {
    final base = FirebaseFirestore.instance
        .collection('lots')
        .orderBy('updatedAt', descending: true);

    final query = statusFilter == null
        ? base
        : base.where('status', isEqualTo: statusFilter);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        final l = AppLocalizations.of(context);

        if (snap.hasError) {
          return Center(
              child: Text(l.errorGeneric('${snap.error}') ?? 'Error'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(child: Text(l.noLots ?? 'No lots'));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, idx) {
            final d = docs[idx];
            final lot = d.data();
            final lotId = d.id;

            final name = (lot['name'] ?? lot['title'] ?? lotId).toString();
            final status = (lot['status'] ?? '').toString();

            return ListTile(
              title: Text(name),
              subtitle: Text(_statusLabel(context, status)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == 'live')
                    IconButton(
                      tooltip: AppLocalizations.of(context).bid ?? 'Bid',
                      icon: const Icon(Icons.gavel),
                      onPressed: () =>
                          _promptAndPlaceBid(context, lotId: lotId, lot: lot),
                    ),
                  const Icon(Icons.chevron_left),
                ],
              ),
              onTap: () => _showLotSheet(context, lotId: lotId, lot: lot),
            );
          },
        );
      },
    );
  }

  String _statusLabel(BuildContext context, String status) {
    final l = AppLocalizations.of(context);
    switch (status) {
      case 'live':
        return l.live ?? 'Live';
      case 'closed':
        return l.closed ?? 'Closed';
      case 'published':
        return l.published ?? 'Published';
      default:
        return status.isEmpty ? (l.unknown ?? 'Unknown') : status;
    }
  }

  // ---------- Bottom sheet with details + Bid button ----------
  Future<void> _showLotSheet(
    BuildContext context, {
    required String lotId,
    required Map<String, dynamic> lot,
  }) async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Current & step (client-side preview; server remains authoritative)
    final currentAmount = (lot['lastBidAmount'] ??
        lot['startPrice'] ??
        lot['startingBid'] ??
        0) as num;

    final step = _resolveIncrement(lot);
    final nextMin = currentAmount.toInt() + step;

    String fmtTs(dynamic ts) {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return DateFormat('yyyy-MM-dd HH:mm', locale).format(dt);
      }
      if (ts is DateTime) {
        return DateFormat('yyyy-MM-dd HH:mm', locale).format(ts);
      }
      return ts == null ? '—' : ts.toString();
    }

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((lot['name'] ?? lotId).toString(),
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 24,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _kv(ctx, l.live ?? 'Live',
                      lot['status'] == 'live' ? '✓' : '—'),
                  _kv(ctx, l.startPrice ?? 'Start',
                      '${lot['startPrice'] ?? lot['startingBid'] ?? 0}'),
                  _kv(ctx, l.lastBid ?? 'Last bid', '$currentAmount'),
                  _kv(ctx, l.minStep ?? 'Min step', '$step'),
                  _kv(ctx, l.nextBid ?? 'Next', '$nextMin'),
                  _kv(ctx, l.started ?? 'Started', fmtTs(lot['openAt'])),
                  _kv(ctx, l.ends ?? 'Ends', fmtTs(lot['closeAt'])),
                  _kv(ctx, l.exhibitor ?? 'Exhibitor',
                      '${lot['exhibitorId'] ?? '—'}'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _promptAndPlaceBid(context, lotId: lotId, lot: lot);
                  },
                  child: Text(l.bid ?? 'Bid'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  int _resolveIncrement(Map<String, dynamic> lot) {
    num take(dynamic v) => (v is num && v > 0) ? v : 0;
    final a = take(lot['customIncrement']); // preferred per server rule
    final b = take(lot['minIncrement']); // your existing field in docs
    final c = take(
        lot['exhibitorIncrement']); // optional exhibitor override cached on lot
    final picked = a > 0 ? a : (b > 0 ? b : (c > 0 ? c : 100));
    return picked.toInt();
  }

  Widget _kv(BuildContext context, String k, String v) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ',
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        Text(v, style: t.bodyMedium),
      ],
    );
  }

  // ---------- Bid dialog + callable ----------
  Future<void> _promptAndPlaceBid(
    BuildContext context, {
    required String lotId,
    required Map<String, dynamic> lot,
  }) async {
    final l = AppLocalizations.of(context);

    if (lot['status'] != 'live') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.lotNotLive ?? 'Lot is not live')),
      );
      return;
    }

    final currentAmount = (lot['lastBidAmount'] ??
        lot['startPrice'] ??
        lot['startingBid'] ??
        0) as num;

    final step = _resolveIncrement(lot);
    final clientMin = currentAmount.toInt() + step;

    final ctrl = TextEditingController(text: clientMin.toString());

    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text((l.bidOn(lot['name'] ?? lotId)) ??
              'Bid on ${lot['name'] ?? lotId}'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText:
                  (l.amountLabel(clientMin)) ?? 'Amount (min $clientMin)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(ctx, int.tryParse(ctrl.text.trim())),
              child: Text(l.ok ?? 'OK'),
            ),
          ],
        );
      },
    );

    if (amount == null) return;

    if (amount < clientMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.bidRejectedMin('$clientMin') ??
                'Bid below minimum: $clientMin')),
      );
      return;
    }

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'me-central1');
      final callable = functions.httpsCallable('placeBid');
      final res = await callable.call(<String, dynamic>{
        'lotId': lotId,
        'bidAmount': amount,
      });

      final data = res.data as Map? ?? {};
      final ok = data['ok'] == true;

      if (ok) {
        final next = (data['nextMin'] as num?)?.toInt();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.bidPlacedNext('${next ?? '—'}') ??
                  'Bid placed. Next min: ${next ?? '—'}',
            ),
          ),
        );
      } else {
        final min = (data['minAllowed'] as num?)?.toInt();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.bidRejectedMin('${min ?? clientMin}') ??
                  'Bid rejected. Min: ${min ?? clientMin}',
            ),
          ),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.errorGeneric(e.message ?? e.code) ??
                'Error: ${e.message ?? e.code}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorGeneric('$e') ?? 'Error: $e')),
      );
    }
  }
}

class DateFormat {
  DateFormat(String s, String locale);

  String format(DateTime dt) {
    // Implement your date formatting logic here
    return '';
  }
}
