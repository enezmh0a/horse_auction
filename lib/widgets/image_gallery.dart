import 'package:flutter/material.dart';

class ImageGallery extends StatefulWidget {
  final List<String> urls; // network URLs
  const ImageGallery({super.key, required this.urls});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final imgs = widget.urls.isEmpty
        ? ['https://picsum.photos/seed/horse/900/600'] // fallback
        : widget.urls;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imgs[idx], fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imgs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => idx = i),
              child: Container(
                width: 96,
                decoration: BoxDecoration(
                  border: Border.all(color: i == idx ? Colors.brown : Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(imgs[i], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
