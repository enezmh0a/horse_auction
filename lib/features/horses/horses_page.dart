import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/lot.dart';
import '../../services/lots_service.dart';
import '../../services/bid_service.dart';
import '../../services/admin_service.dart';

class HorsesPage extends StatefulWidget {
  const HorsesPage({super.key});
  @override
  State<HorsesPage> createState() => _HorsesPageState();
}

class _HorsesPageState extends State<HorsesPage> {
  bool _posting = false;
  bool _seeding = false;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      floatingActionButton: _seedFab(context, ar),
      body: StreamBuilder<List<Lot>>(
        stream: LotsService.instance.streamLots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
                child: Text(ar ? 'خطأ في التحميل' : 'Failed to load'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lots = snap.data!;
          if (lots.isEmpty) {
            return _emptyState(ar);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: lots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _lotTile(context, lots[i], ar),
          );
        },
      ),
    );
  }

  Widget _emptyState(bool ar) => Center(
        child: Opacity(
          opacity: .7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pets, size: 64),
              const SizedBox(height: 8),
              Text(ar ? 'لا توجد خيول بعد' : 'No horses yet'),
              const SizedBox(height: 4),
              Text(
                ar
                    ? 'اضغط زر الإنشاء لإضافة بيانات تجريبية'
                    : 'Use Seed to add demo data',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );

  Widget _lotTile(BuildContext context, Lot lot, bool ar) {
    final stateChip = Chip(
      label: Text(lot.state == AuctionState.live
          ? (ar ? 'مباشر' : 'Live')
          : (ar ? 'مغلق' : 'Closed')),
      visualDensity: VisualDensity.compact,
    );

    final cityChip = Chip(
      label: Text('${ar ? 'المدينة' : 'City'}: ${lot.city}'),
      visualDensity: VisualDensity.compact,
    );

    final stepChip = Chip(
      label: Text('${ar ? 'الزيادة' : 'Step'}: SAR ${lot.step}'),
      visualDensity: VisualDensity.compact,
    );

    final currChip = Chip(
      label: Text('${ar ? 'الحالي' : 'Current'}: SAR ${lot.current}'),
      visualDensity: VisualDensity.compact,
    );

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _thumb(lot.images),
        title: Text(lot.title.isEmpty ? '—' : lot.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Wrap(
          spacing: 8,
          runSpacing: -8,
          children: [stateChip, cityChip, stepChip, currChip],
        ),
        trailing: FilledButton.icon(
          onPressed: lot.state == AuctionState.closed
              ? null
              : () => _showBidDialog(context, lot.id, lot.minBid, ar),
          icon: const Icon(Icons.gavel),
          label: Text(ar ? 'مزايدة' : 'Bid'),
        ),
      ),
    );
  }

  Widget _thumb(List<String> images) {
    final url = images.isNotEmpty ? images.first : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 64,
        height: 64,
        child: url == null
            ? Container(
                color: Colors.black12,
                child: const Icon(Icons.image_not_supported))
            : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                return Container(
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image));
              }),
      ),
    );
  }

  Future<void> _showBidDialog(
      BuildContext rootContext, String lotId, int min, bool ar) async {
    final controller = TextEditingController(text: '$min');
    bool posting = false;

    await showDialog(
      context: rootContext,
      barrierDismissible: !posting,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          Future<void> submit() async {
            final parsed = int.tryParse(controller.text.trim());
            if (parsed == null) {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(content: Text(ar ? 'رقم غير صالح' : 'Invalid number')),
              );
              return;
            }
            if (mounted) setStateDialog(() => posting = true);
            try {
              await BidService.instance
                  .placeBidTx(lotId: lotId, amount: parsed);
              if (!rootContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(
                    content: Text(ar ? 'تم تقديم المزايدة' : 'Bid placed!')),
              );
            } on StateError catch (e) {
              if (!rootContext.mounted) return;
              String msg = ar ? 'خطأ' : 'Error';
              switch (e.message) {
                case 'LOW_BID':
                  msg = '${ar ? "الحد الأدنى" : "Min"}: $min';
                  break;
                case 'BAD_STEP':
                  msg = ar
                      ? 'المبلغ لا يطابق الزيادة'
                      : 'Amount not aligned with step';
                  break;
                case 'CLOSED':
                  msg = ar ? 'المزاد مغلق' : 'Auction is closed';
                  break;
              }
              ScaffoldMessenger.of(rootContext)
                  .showSnackBar(SnackBar(content: Text(msg)));
            } catch (e) {
              if (!rootContext.mounted) return;
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(content: Text('${ar ? "خطأ" : "Error"}: $e')),
              );
            } finally {
              if (mounted) setStateDialog(() => posting = false);
            }
          }

          return AlertDialog(
            title: Text(ar ? 'تقديم مزايدة' : 'Place bid'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(ar ? 'المبلغ' : 'Amount')),
                const SizedBox(height: 8),
                TextField(
                  enabled: !posting,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '12345',
                    helperText: '${ar ? "الحد الأدنى" : "Min"}: $min',
                  ),
                  onSubmitted: (_) => submit(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: posting ? null : () => Navigator.pop(dialogContext),
                child: Text(ar ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                onPressed: posting ? null : submit,
                child: Text(ar ? 'تأكيد' : 'Confirm'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _seedFab(BuildContext context, bool ar) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.auto_fix_high),
      label: Text(ar ? 'إنشاء بيانات تجريبية' : 'Seed lots'),
      onPressed: _seeding
          ? null
          : () async {
              setState(() => _seeding = true);
              try {
                final res = await AdminService.instance.seedLotsOnce();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(res == 'already'
                          ? (ar ? 'تم إنشاؤها مسبقاً.' : 'Already seeded.')
                          : (ar ? 'تم الإنشاء.' : 'Seeded.'))),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${ar ? "خطأ" : "Error"}: $e')),
                );
              } finally {
                if (mounted) setState(() => _seeding = false);
              }
            },
    );
  }
}
