import 'package:flutter/material.dart';
import '../models/lot_model.dart';

class LotHeroGallery extends StatefulWidget {
  const LotHeroGallery({super.key, required this.lot});
  final Lot lot;

  @override
  State<LotHeroGallery> createState() => _LotHeroGalleryState();
}

class _LotHeroGalleryState extends State<LotHeroGallery> {
  final PageController _pc = PageController();
  int _i = 0;

  List<String> _images(Lot lot) {
    final list =
        (lot as dynamic).images as List<String>?; // ignore: avoid_dynamic_calls
    if (list != null && list.isNotEmpty) return list;

    final cover =
        (lot as dynamic).coverImage as String?; // ignore: avoid_dynamic_calls
    final single =
        (lot as dynamic).image as String?; // ignore: avoid_dynamic_calls
    if (cover != null && cover.isNotEmpty) return [cover];
    if (single != null && single.isNotEmpty) return [single];

    return const [
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=1600',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final imgs = _images(widget.lot);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _i = i),
              itemCount: imgs.length,
              itemBuilder:
                  (_, i) => Image.network(
                    imgs[i],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const ColoredBox(
                          color: Color(0x11000000),
                          child: Center(
                            child: Icon(Icons.broken_image_outlined, size: 48),
                          ),
                        ),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (imgs.length > 1)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder:
                  (_, i) => GestureDetector(
                    onTap:
                        () => _pc.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        ),
                    child: Opacity(
                      opacity: i == _i ? 1 : .6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(imgs[i], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemCount: imgs.length,
            ),
          ),
      ],
    );
  }
}
