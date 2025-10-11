import 'package:horse_auction_baseline/models/lot_model.dart';

extension LotCompat on Lot {
  int? get currentBid {
    try {
      return (this as dynamic).currentBid as int?;
    } catch (_) {}
    try {
      return (this as dynamic).currentHighestBid as int?;
    } catch (_) {}
    return null;
  }

  int? get minBidIncrement {
    try {
      return (this as dynamic).minBidIncrement as int?;
    } catch (_) {}
    try {
      return (this as dynamic).minIncrement as int?;
    } catch (_) {}
    return null;
  }

  int? get startingPrice {
    try {
      return (this as dynamic).startingPrice as int?;
    } catch (_) {}
    try {
      return (this as dynamic).startPrice as int?;
    } catch (_) {}
    return null;
  }

  String? get id {
    try {
      return (this as dynamic).id as String?;
    } catch (_) {}
    try {
      return (this as dynamic).docId as String?;
    } catch (_) {}
    return null;
  }

  String? get name {
    try {
      return (this as dynamic).name as String?;
    } catch (_) {}
    try {
      return (this as dynamic).title as String?;
    } catch (_) {}
    return null;
  }

  String? get description {
    try {
      return (this as dynamic).description as String?;
    } catch (_) {}
    try {
      return (this as dynamic).desc as String?;
    } catch (_) {}
    return null;
  }

  List<String>? get imageUrls {
    try {
      return (this as dynamic).imageUrls?.cast<String>();
    } catch (_) {}
    try {
      return (this as dynamic).images?.cast<String>();
    } catch (_) {}
    return null;
  }
}
