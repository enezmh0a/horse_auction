import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'l10n/app_localizations.dart';

class LotDetailsPage extends StatelessWidget {
  final String lotId;
  const LotDetailsPage({super.key, required this.lotId});

  @override
  Widget build(BuildContext context) {
    final lotRef = FirebaseFirestore.instance.collection('lots').doc(lotId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: lotRef.snapshots(),
      builder: (context, snap) {
        final l = AppLocalizations.of(context);

        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(l.appTitle ?? 'Horse Auctions')),
            body:
                Center(child: Text(l.errorLoadingLots ?? 'Error loading lots')),
          );
        }
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(l.appTitle ?? 'Horse Auctions')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text(l.appTitle ?? 'Horse Auctions')),
            body: Center(
                child: Text(
                    l.errorGeneric('Lot not found') ?? 'Error: Lot not found')),
          );
        }

        final data = snap.data!.data()!;
        final name = (data['name'] ?? lotId).toString();
        final status = (data['status'] ?? '').toString();
        final imageUrl = (data['imageUrl'] ?? '').toString();
        final exhibitor =
            (data['exhibitorName'] ?? data['exhibitorId'] ?? '').toString();

        final startPrice =
            (data['startPrice'] ?? data['startingBid'] ?? 0) as num;
        final lastBid = (data['lastBidAmount'] ?? 0) as num;

        final tsStart = data['auctionStart'] ?? data['startAt'];
        final tsEnd = data['auctionEnd'] ?? data['endAt'];

        return Scaffold(
          appBar: AppBar(title: Text(name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero / image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 72),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 12),

                // Facts
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FactChip(
                        label: l.startPrice ?? 'Start',
                        value: _sar(startPrice)),
                    _FactChip(
                      label: l.lastBid ?? 'Last bid',
                      value: lastBid > 0 ? _sar(lastBid) : '—',
                    ),
                    if (exhibitor.isNotEmpty)
                      _FactChip(
                          label: l.exhibitor ?? 'Exhibitor', value: exhibitor),
                    if (tsStart != null)
                      _FactChip(
                          label: l.started ?? 'Started',
                          value: _fmtTs(tsStart)),
                    if (tsEnd != null)
                      _FactChip(label: l.ends ?? 'Ends', value: _fmtTs(tsEnd)),
                  ],
                ),
                const SizedBox(height: 16),

                // Bid button
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.icon(
                    onPressed: status == 'live'
                        ? () => _showPlaceBidDialog(context,
                            lotId: lotId, lotName: name)
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l.biddingDisabled ??
                                      'Bidding disabled for this lot')),
                            );
                          },
                    icon: const Icon(Icons.gavel),
                    label: Text(l.bid ?? 'Bid'),
                  ),
                ),

                const SizedBox(height: 24),

                // Description (optional)
                if ((data['description'] ?? '').toString().isNotEmpty) ...[
                  Text(
                    l.lots ?? 'Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text((data['description']).toString()),
                  const SizedBox(height: 24),
                ],

                // Bid history
                Text('Bids', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: lotRef
                      .collection('bids')
                      .orderBy('createdAt', descending: true)
                      .limit(50)
                      .snapshots(),
                  builder: (context, bidSnap) {
                    if (bidSnap.hasError) {
                      return Text(l.errorGeneric('Failed to load bids') ??
                          'Error: Failed to load bids');
                    }
                    if (!bidSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final bids = bidSnap.data!.docs;
                    if (bids.isEmpty) {
                      return const Text('—');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bids.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (_, i) {
                        final b = bids[i].data();
                        final amt = (b['amount'] ?? 0) as num;
                        final uid = (b['bidderUid'] ?? '—').toString();
                        final when = b['createdAt'];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_sar(amt),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(_fmtTs(when)),
                            Text(_shortUid(uid)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ————— Bid dialog & call —————
  Future<void> _showPlaceBidDialog(BuildContext context,
      {required String lotId, required String lotName}) async {
    final l = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                l.errorGeneric('Not signed in') ?? 'Error: Not signed in')),
      );
      return;
    }

    final ctrl = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.bidOn(lotName) ?? 'Bid on $lotName'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(hintText: l.enterAmount ?? 'Enter amount'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l.cancel ?? 'Cancel')),
            FilledButton(
              onPressed: () {
                final v = int.tryParse(ctrl.text.trim());
                Navigator.pop(ctx, v);
              },
              child: Text(l.ok ?? 'OK'),
            ),
          ],
        );
      },
    );

    if (amount == null) return;

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'me-central1');
      final callable = fn.httpsCallable('placeBid');
      final res = await callable
          .call<Map<String, dynamic>>({'lotId': lotId, 'bidAmount': amount});
      final data = res.data;
      if (data['ok'] == true) {
        final next = data['nextMin'];
        final msg = l.bidPlacedNext('${next ?? '—'}') ??
            'Bid placed. Next min: ${next ?? '—'}';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      } else {
        final min = data['minAllowed'] ?? data['min'] ?? data['nextMin'];
        final msg = l.bidRejectedMin('$min') ?? 'Bid rejected. Minimum: $min';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
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

// ————— helpers —————
class _FactChip extends StatelessWidget {
  final String label;
  final String value;
  const _FactChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = status.isEmpty ? (l.unknown ?? 'Unknown') : status;
    final color = switch (status) {
      'live' => Colors.green,
      'closed' => Colors.red,
      'published' => Colors.blueGrey,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

String _sar(num n) => 'SAR ${_fmtInt(n)}';
String _fmtInt(num n) => n.toStringAsFixed(0);

String _fmtTs(dynamic ts) {
  if (ts == null) return '—';
  DateTime dt;
  if (ts is Timestamp) {
    dt = ts.toDate();
  } else if (ts is DateTime) {
    dt = ts;
  } else if (ts is String) {
    dt = DateTime.tryParse(ts) ?? DateTime.now();
  } else {
    return '—';
  }
  return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
}

String _two(int v) => v.toString().padLeft(2, '0');
String _shortUid(String uid) =>
    uid.length <= 6 ? uid : '…${uid.substring(uid.length - 6)}';
