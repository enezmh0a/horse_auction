import 'dart:math' as math;
import 'package:flutter/material.dart';

class GalleryBanner extends StatefulWidget {
  const GalleryBanner({
    super.key,
    required this.urls,
    this.height = 170, // compact by default
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.heroBackground, // optional custom bg behind contain
  });

  final List<String> urls;
  final double height;
  final BorderRadius borderRadius;
  final Color? heroBackground;

  @override
  State<GalleryBanner> createState() => _GalleryBannerState();
}

class _GalleryBannerState extends State<GalleryBanner> {
  late final PageController _pageCtrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls.where((e) => e.trim().isNotEmpty).toList();
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    // Cap hero height so it never gets too tall on very wide screens.
    final double heroH = math.min(widget.height, media.size.height * 0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO
        ClipRRect(
          borderRadius: widget.borderRadius,
          child: Container(
            height: heroH,
            width: double.infinity,
<<<<<<< HEAD
            color:
                widget.heroBackground ??
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
            child:
                urls.isEmpty
                    ? Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                    : PageView.builder(
                      controller: _pageCtrl,
                      itemCount: urls.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder:
                          (_, i) => Center(
                            // Show whole image (no crop) and keep the fixed height.
                            child: Image.network(
                              urls[i],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: heroH,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.broken_image_outlined,
                                    size: 36,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                    ),
=======
            color: widget.heroBackground ??
                theme.colorScheme.surfaceVariant.withOpacity(0.6),
            child: urls.isEmpty
                ? Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        size: 36, color: theme.colorScheme.onSurfaceVariant),
                  )
                : PageView.builder(
                    controller: _pageCtrl,
                    itemCount: urls.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => Center(
                      // Show whole image (no crop) and keep the fixed height.
                      child: Image.network(
                        urls[i],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: heroH,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.broken_image_outlined,
                          size: 36,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
>>>>>>> origin/main
          ),
        ),

        const SizedBox(height: 10),

        // THUMBNAILS (only if > 1)
        if (urls.length > 1)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final selected = i == _page;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _pageCtrl.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                    setState(() => _page = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
<<<<<<< HEAD
                        color:
                            selected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
=======
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
>>>>>>> origin/main
                        width: selected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        urls[i],
                        fit: BoxFit.cover, // small thumbnails can be cropped
<<<<<<< HEAD
                        errorBuilder:
                            (_, __, ___) => Icon(
                              Icons.image_not_supported_outlined,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
=======
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
>>>>>>> origin/main
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
