import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.4)),
    );

    if (url == null || url!.trim().isEmpty) {
      return placeholder;
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder,
      loadingBuilder: (ctx, child, prog) => prog == null ? child : placeholder,
    );
  }
}
