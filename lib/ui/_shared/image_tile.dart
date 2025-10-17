import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  final String assetPath;
  final double height;
  final double borderRadius;

  const SafeAssetImage({
    super.key,
    required this.assetPath,
    this.height = 180,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.25),
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }
}
