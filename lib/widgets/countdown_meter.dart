// lib/widgets/countdown_meter.dart
import 'dart:async';
import 'package:flutter/material.dart';

class CountdownMeter extends StatefulWidget {
  final DateTime closeAt;
  final Duration warning;
  final TextStyle? style;

  const CountdownMeter({
    super.key,
    required this.closeAt,
    this.warning = const Duration(minutes: 5),
    this.style,
  });

  @override
  State<CountdownMeter> createState() => _CountdownMeterState();
}

class _CountdownMeterState extends State<CountdownMeter> {
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
    setState(() {
      _left = widget.closeAt.difference(now);
      if (_left.isNegative) _left = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
             '${m.toString().padLeft(2, '0')}:'
             '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
           '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ended = _left == Duration.zero;
    final urgent = _left <= widget.warning && !ended;
    final color = ended ? Colors.grey : (urgent ? Colors.redAccent : Colors.green);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ended ? Icons.timer_off : Icons.timer, color: color),
        const SizedBox(width: 6),
        Text(
          ended ? 'Auction ended' : _fmt(_left),
          style: (widget.style ?? const TextStyle(fontWeight: FontWeight.w600)).copyWith(color: color),
        ),
      ],
    );
  }
}
