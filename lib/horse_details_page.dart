import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// same i18n helper as list page
bool _isArabic(BuildContext ctx) => Directionality.of(ctx) == TextDirection.rtl;
String _t(BuildContext ctx, String en, String ar) => _isArabic(ctx) ? ar : en;

class HorseDetailsPage extends StatefulWidget {
  const HorseDetailsPage({super.key, required this.lotId});
  final String lotId;

  @override
  State<HorseDetailsPage> createState() => _HorseDetailsPageState();
}

class _HorseDetailsPageState extends State<HorseDetailsPage> {
  final _amountCtrl = TextEditingController();
  int _page = 0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lotRef =
        FirebaseFirestore.instance.collection('lots').doc(widget.lotId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: lotRef.snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(_t(ctx, 'Lot not found', 'العنصر غير موجود'))),
          );
        }

        final lot = snap.data!.data()!;
        final name = (lot['name'] as String?) ?? widget.lotId;
        final city = (lot['location'] as String?) ?? '-';
        final breed = (lot['breed'] as String?) ?? 'Arabian';
        final imgs = (lot['imageUrls'] as List?)?.cast<String>() ?? const [];
        final last = (lot['lastBidAmount'] as num?)?.toInt() ?? 0;
        final start = (lot['startPrice'] as num?)?.toInt() ?? 0;
        final step = (lot['minIncrement'] as num?)?.toInt() ??
            (lot['customIncrement'] as num?)?.toInt() ??
            100;
        final nextMin = max(last > 0 ? (last + step) : start, 0);

        return Scaffold(
          appBar: AppBar(title: Text(_t(ctx, 'Horse Details', 'تفاصيل الجواد'))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- gallery ---
              AspectRatio(
                aspectRatio: 16 / 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      PageView.builder(
                        onPageChanged: (i) => setState(() => _page = i),
                        itemCount: max(imgs.length, 1),
                        itemBuilder: (_, i) {
                          final url = (imgs.isEmpty) ? null : imgs[i];
                          return Container(
                            color: Colors.black,
                            child: url == null
                                ? Center(
                                    child: Icon(Icons.image_not_supported_outlined,
                                        color: Colors.white.withOpacity(.6),
                                        size: 56),
                                  )
                                : Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white)),
                                  ),
                          );
                        },
                      ),
                      if (imgs.length > 1)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Wrap(
                                  spacing: 6,
                                  children: List.generate(
                                    imgs.length,
                                    (i) => Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i == _page
                                            ? Colors.white
                                            : Colors.white38,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // thumbnails
              if (imgs.length > 1)
                SizedBox(
                  height: 66,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imgs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        onTap: () => setState(() => _page = i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imgs[i],
                            width: 100,
                            height: 66,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.black12, width: 100, height: 66),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // title + meta
              Text(name, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '$breed • $city',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_t(ctx, 'Starting', 'سعر البدء')}: $start  •  '
                '${_t(ctx, 'Current Highest', 'أعلى مزايدة')}: $last  •  '
                '${_t(ctx, 'Min', 'أدنى زيادة')}: +$step',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),

              // bid controls
              Row(
                children: [
                  IconButton(
                    tooltip: _t(ctx, 'Minus', 'إنقاص'),
                    onPressed: () {
                      final x = int.tryParse(_amountCtrl.text.trim()) ?? nextMin;
                      _amountCtrl.text = max(0, x - step).toString();
                      setState(() {});
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl..text = _amountCtrl.text.isEmpty ? nextMin.toString() : _amountCtrl.text,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            '${_t(ctx, 'Enter amount', 'أدخل المبلغ')} (${_t(ctx, 'min', 'الحد الأدنى')} $nextMin)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _t(ctx, 'Plus', 'زيادة'),
                    onPressed: () {
                      final x = int.tryParse(_amountCtrl.text.trim()) ?? nextMin;
                      _amountCtrl.text = (x + step).toString();
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _placeBid(ctx, widget.lotId, nextMin),
                    child: Text(_t(ctx, 'Place bid', 'تنفيذ المزايدة')),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // recent bids
              Text(_t(ctx, 'Recent bids', 'أحدث المزايدات'),
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: lotRef
                    .collection('bids')
                    .orderBy('amount', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (_, bidsSnap) {
                  if (!bidsSnap.hasData) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  }
                  final bids = bidsSnap.data!.docs;
                  if (bids.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_t(ctx, 'No bids yet', 'لا توجد مزايدات حتى الآن')),
                    );
                  }
                  return Column(
                    children: bids.map((b) {
                      final m = b.data();
                      final amt = (m['amount'] as num?)?.toInt() ?? 0;
                      final uid = (m['bidderUid'] as String?) ?? '—';
                      final ts = (m['createdAt'] as Timestamp?)?.toDate();
                      return ListTile(
                        leading: const Icon(Icons.trending_up),
                        title: Text(amt.toString()),
                        subtitle: Text('${_t(ctx, 'by', 'بواسطة')} $uid'),
                        trailing: Text(ts?.toLocal().toString().split('.').first ?? ''),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeBid(BuildContext context, String lotId, int nextMin) async {
    final text = _amountCtrl.text.trim();
    final amount = int.tryParse(text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t(context, 'Enter a valid number', 'أدخل رقماً صحيحاً'))),
      );
      return;
    }
    try {
      final fns = FirebaseFunctions.instanceFor(region: 'me-central1');
      final callable = fns.httpsCallable('placeBid');
      final res = await callable.call(<String, dynamic>{
        'lotId': lotId,
        'bidAmount': amount,
      });

      final data = (res.data as Map?)?.cast<String, dynamic>() ?? const {};
      final ok = data['ok'] == true;
      if (ok) {
        final next = (data['nextMin'] as num?)?.toInt();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t(
            context,
            'Bid placed. Next min: ${next ?? '—'}',
            'تمت المزايدة. الحد التالي: ${next ?? '—'}',
          ))),
        );
      } else {
        final reason = (data['reason'] as String?) ?? 'rejected';
        final min = (data['minAllowed'] as num?)?.toInt() ?? nextMin;
        final label = reason == 'Bid below minimum step'
            ? _t(context, 'Bid below minimum: $min', 'المزايدة أقل من الحد الأدنى: $min')
            : _t(context, 'Bid rejected', 'تم رفض المزايدة');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
      }
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? e.code)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t(context, 'Error: $e', 'خطأ: $e'))),
      );
    }
  }
}
