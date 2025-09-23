// lib/widgets/safe_network_image.dart
import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _placeholder(width, height);
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (c, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (c, _, __) => _placeholder(width, height),
    );
  }

  Widget _placeholder(double? w, double? h) {
    return Container(
      width: w,
      height: h,
      color: Colors.black12,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
