import '../models/lot_model.dart';

/// Returns the best single URL for list tiles/thumbs.
String imageForLot(Lot lot) {
  // Try list of images first (if your model has it)
  final images =
      (lot as dynamic).images as List<String>?; // ignore: avoid_dynamic_calls
  if (images != null && images.isNotEmpty) return images.first;

  // Fallbacks for older shapes
  final cover =
      (lot as dynamic).coverImage as String?; // ignore: avoid_dynamic_calls
  final single =
      (lot as dynamic).image as String?; // ignore: avoid_dynamic_calls
  if (cover != null && cover.isNotEmpty) return cover;
  if (single != null && single.isNotEmpty) return single;

  // Last resort placeholder
  return 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=1200';
}
