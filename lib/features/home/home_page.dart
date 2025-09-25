import 'package:flutter/material.dart';
import 'package:horse_auction_app/services/lots_service.dart' as svc;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<svc.Lot>>(
      valueListenable: svc.LotsService.instance.lots,
      builder: (context, lots, _) {
        final live = lots.where((e) => e.live).toList();
        final closed = lots.length - live.length;
        final top = live.isEmpty
            ? null
            : live.reduce((a, b) => a.current >= b.current ? a : b);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _metric(
                      'Top current', top == null ? '-' : 'SAR ${top.current}',
                      sub: top?.title),
                  _metric('Closed', '$closed', icon: Icons.lock_outline),
                  _metric('Live', '${live.length}',
                      icon: Icons.play_circle_fill),
                  _metric('Total lots', '${lots.length}',
                      icon: Icons.inventory_2),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Recent lots', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              ...lots.take(5).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(e.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          _chip('Current: SAR ${e.current}'),
                          _chip('Step: SAR ${e.step}'),
                          _chip('City: ${e.city}'),
                          _chip(e.live ? 'Live' : 'Closed'),
                        ]),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _metric(String title, String value, {String? sub, IconData? icon}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              if (sub != null) Text(sub, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}
