import 'dart:async';
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/l10n/app_localizations.dart';

class CountdownText extends StatefulWidget {
  final DateTime endsAt;
  const CountdownText({super.key, required this.endsAt});
  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late Timer _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    setState(
      () => _left = widget.endsAt.isAfter(now)
          ? widget.endsAt.difference(now)
          : Duration.zero,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    if (_left.inSeconds <= 0)
      return Text(t.badge_sold, style: const TextStyle(color: Colors.red));
    final h = _left.inHours, m = _left.inMinutes % 60, s = _left.inSeconds % 60;
    final time = h > 0 ? "${h}h ${m}m ${s}s" : "${m}m ${s}s";
    return Text(t.chip_endsIn(time));
  }
}
