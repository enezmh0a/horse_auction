import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/lot_model.dart';
import '../services/live_bids_service.dart';

class LotsPage extends StatefulWidget {
  const LotsPage({super.key});

  @override
  State<LotsPage> createState() => _LotsPageState();
}

class _LotsPageState extends State<LotsPage> {
  final _svc = LiveBidsService.instance;
  LotModel? _selected;

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isAr = langCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'الخيول' : 'Lots'),
          centerTitle: true,
        ),
        body: ValueListenableBuilder<List<LotModel>>(
          valueListenable: _svc.lotsListenable,
          builder: (context, lots, _) {
            if (lots.isEmpty) {
              return Center(
                  child: Text(isAr ? 'لا يوجد خيول' : 'No lots available'));
            }
            _selected ??= lots.first;
            return LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 1100;
                return Row(
                  children: [
                    // LEFT: list of lots
                    SizedBox(
                      width: wide ? 420 : 360,
                      child: _LotsList(
                        lots: lots,
                        selected: _selected,
                        onTap: (l) => setState(() => _selected = l),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    // RIGHT: details + bidding
                    Expanded(
                      child: _LotDetail(
                        lot: _selected!,
                        isAr: isAr,
                        onBidRequested: (amount) async {
                          final ok = await _confirmBid(context, isAr, amount);
                          if (!ok) return;
                          final accepted = _svc.placeBid(_selected!.id, amount);
                          if (!accepted) {
                            final min = _selected!.currentBid.value +
                                _selected!.minIncrement;
                            _snack(
                                context,
                                isAr
                                    ? 'العرض منخفض. الحد الأدنى $min'
                                    : 'Bid too low. Minimum is $min');
                          } else {
                            _snack(context,
                                isAr ? 'تم تقديم العرض' : 'Bid placed');
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmBid(BuildContext ctx, bool isAr, int amount) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (c) => AlertDialog(
            title: Text(isAr ? 'تأكيد المزايدة' : 'Confirm bid'),
            content: Text(isAr
                ? 'تأكيد تقديم عرض بقيمة $amount ؟'
                : 'Confirm placing a bid of $amount?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(isAr ? 'إلغاء' : 'Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(isAr ? 'تأكيد' : 'Confirm')),
            ],
          ),
        ) ??
        false;
  }

  void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _LotsList extends StatelessWidget {
  const _LotsList({
    required this.lots,
    required this.selected,
    required this.onTap,
  });

  final List<LotModel> lots;
  final LotModel? selected;
  final ValueChanged<LotModel> onTap;

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isAr = langCode == 'ar';

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: lots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final lot = lots[i];
        final isSel = lot.id == selected?.id;

        return InkWell(
          onTap: () => onTap(lot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSel ? 2 : 1,
              ),
              color: isSel
                  ? Theme.of(context).colorScheme.primary.withOpacity(.06)
                  : null,
            ),
            child: Row(
              children: [
                _Thumb(firstExistingAsset(lot.images)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lot.titleForLocale(isAr ? 'ar' : 'en'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<int>(
                          valueListenable: lot.currentBid,
                          builder: (context, bid, _) => Text(
                            (isAr ? 'العرض الحالي: ' : 'Current bid: ') +
                                bid.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (isAr ? 'الحد الأدنى للزيادة: ' : 'Min increment: ') +
                              lot.minIncrement.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LotDetail extends StatefulWidget {
  const _LotDetail({
    required this.lot,
    required this.isAr,
    required this.onBidRequested,
  });

  final LotModel lot;
  final bool isAr;
  final ValueChanged<int> onBidRequested;

  @override
  State<_LotDetail> createState() => _LotDetailState();
}

class _LotDetailState extends State<_LotDetail> {
  int _carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lot = widget.lot;
    final isAr = widget.isAr;

    final minNext = lot.currentBid.value + lot.minIncrement;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Media carousel with arrows
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _Media(lot.images, _carouselIndex),
                Positioned(
                  left: 8,
                  child: _NavBtn(
                      icon: Icons.chevron_left,
                      onTap: () => _go(-1, lot.images.length)),
                ),
                Positioned(
                  right: 8,
                  child: _NavBtn(
                      icon: Icons.chevron_right,
                      onTap: () => _go(1, lot.images.length)),
                ),
                Positioned(
                  bottom: 8,
                  child: _Dots(count: lot.images.length, index: _carouselIndex),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Prominent bid panel
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<int>(
                valueListenable: lot.currentBid,
                builder: (context, bid, _) {
                  final reserveText = lot.reserveMet
                      ? (isAr ? 'تم بلوغ الحد الأدنى' : 'Reserve met')
                      : (isAr ? 'الحد الأدنى غير مُحقق' : 'Reserve not met');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lot.titleForLocale(isAr ? 'ar' : 'en'),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            text: (isAr ? 'العرض الحالي' : 'Current bid') +
                                ': $bid',
                            color: Colors.blueGrey.shade50,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            text: (isAr ? 'الحد الأدنى للزيادة' : 'Min inc.') +
                                ': ${lot.minIncrement}',
                            color: Colors.orange.shade50,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            text: reserveText,
                            color: lot.reserveMet
                                ? Colors.green.shade50
                                : Colors.amber.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.tonal(
                            onPressed: lot.isClosed
                                ? null
                                : () => widget.onBidRequested(minNext),
                            child: Text(isAr ? '+ الحد الأدنى' : '+ Min'),
                          ),
                          FilledButton(
                            onPressed: lot.isClosed
                                ? null
                                : () => widget
                                    .onBidRequested(minNext + lot.minIncrement),
                            child: Text(isAr ? '+ 2× الحد الأدنى' : '+ 2× Min'),
                          ),
                          OutlinedButton(
                            onPressed: lot.isClosed
                                ? null
                                : () async {
                                    final ctrl = TextEditingController(
                                        text: minNext.toString());
                                    final ok =
                                        await _askCustom(context, isAr, ctrl);
                                    if (ok) {
                                      final value =
                                          int.tryParse(ctrl.text.trim());
                                      if (value != null)
                                        widget.onBidRequested(value);
                                    }
                                  },
                            child: Text(isAr ? 'مبلغ مخصص' : 'Custom amount'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bulleted horse details under the picture
          if (lot.details != null && lot.details!.isNotEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isAr ? 'تفاصيل الحصان' : 'Horse details',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...lot.details!.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text('${e.key}: ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Expanded(child: Text(e.value)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    Text(
                      lot.descriptionForLocale(isAr ? 'ar' : 'en'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _go(int delta, int len) {
    setState(() {
      _carouselIndex = (_carouselIndex + delta) % len;
      if (_carouselIndex < 0) _carouselIndex += len;
    });
  }

  Future<bool> _askCustom(
      BuildContext ctx, bool isAr, TextEditingController ctrl) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (c) => AlertDialog(
            title: Text(isAr ? 'مبلغ مخصص' : 'Custom amount'),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'المبلغ' : 'Amount',
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(isAr ? 'إلغاء' : 'Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(isAr ? 'تأكيد' : 'Confirm')),
            ],
          ),
        ) ??
        false;
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(this.asset);
  final String? asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(14), right: Radius.circular(0)),
      child: SizedBox(
        width: 110,
        height: 92,
        child: asset == null
            ? Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported))
            : Image.asset(asset!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported));
              }),
      ),
    );
  }
}

class _Media extends StatelessWidget {
  const _Media(this.assets, this.index);
  final List<String> assets;
  final int index;

  @override
  Widget build(BuildContext context) {
    final asset = firstExistingAsset(assets);
    if (asset == null) {
      return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.image, size: 64));
    }
    // Show selected index if available; otherwise show first existing.
    final shown = (index < assets.length) ? assets[index] : asset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        shown,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.image, size: 64)),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.25),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white70,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text),
    );
  }
}

/// Returns the first asset from [assets] that likely exists, or null.
String? firstExistingAsset(List<String> assets) {
  // We can’t check filesystem here; just return the first path.
  // If it fails at runtime, errorBuilder shows a placeholder.
  return assets.isEmpty ? null : assets.first;
}
