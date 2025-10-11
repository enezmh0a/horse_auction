import 'package:flutter/material.dart';

class SafeImg extends StatelessWidget {
  final String path;
  final double w, h;
  const SafeImg(this.path, {super.key, this.w = 72, this.h = 72});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        path,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: w,
          height: h,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}
