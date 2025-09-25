import 'dart:math';
import 'package:flutter/foundation.dart';

class Lot {
  final String id;
  final String title;
  final String city;
  final int step;
  final bool live;
  final List<String> images; // network URLs
  final int current;

  const Lot({
    required this.id,
    required this.title,
    required this.city,
    required this.step,
    required this.live,
    required this.current,
    this.images = const [],
  });

  Lot copyWith({
    String? id,
    String? title,
    String? city,
    int? step,
    bool? live,
    int? current,
    List<String>? images,
  }) {
    return Lot(
      id: id ?? this.id,
      title: title ?? this.title,
      city: city ?? this.city,
      step: step ?? this.step,
      live: live ?? this.live,
      current: current ?? this.current,
      images: images ?? this.images,
    );
  }
}

class LotsService {
  LotsService._();
  static final LotsService instance = LotsService._();

  final ValueNotifier<List<Lot>> lots = ValueNotifier<List<Lot>>(<Lot>[]);

  Lot? byId(String id) {
    try {
      return lots.value.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setAll(List<Lot> next) => lots.value = List<Lot>.unmodifiable(next);

  void upsert(Lot lot) {
    final list = List<Lot>.from(lots.value);
    final i = list.indexWhere((e) => e.id == lot.id);
    if (i >= 0) {
      list[i] = lot;
    } else {
      list.add(lot);
    }
    _setAll(list);
  }

  /// Seeds demo lots once; returns 'already' if data exists.
  String seedLotsOnce() {
    if (lots.value.isNotEmpty) return 'already';

    final r = Random(42);
    const cities = ['Riyadh', 'Jeddah', 'Dammam', 'Diriyah'];
    const titles = [
      'عبدالرحمن – مهر مكس',
      'مهرة – يحق للمشتري التسمية',
      'كادي – مهرة مكس',
      'Lot X',
      'Lot Y',
      'Lot Z',
    ];

    // Helper to create stable, cacheable placeholder images
    String _img(String seed) => 'https://picsum.photos/seed/$seed/800/600';

    final data = List<Lot>.generate(6, (i) {
      final live = i != 1 && i != 5;
      final step = 100;
      final curr = [20000, 15200, 2600, 1900, 20100, 3200][i % 6];

      // 3 images per lot
      final imgs = <String>[
        _img('horse_${i}_a'),
        _img('horse_${i}_b'),
        _img('horse_${i}_c'),
      ];

      return Lot(
        id: _randId(r),
        title: titles[i % titles.length],
        city: cities[i % cities.length],
        step: step,
        live: live,
        current: curr,
        images: imgs,
      );
    });

    _setAll(data);
    return 'done';
  }

  static String _randId(Random r) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
