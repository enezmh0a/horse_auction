// lib/services/bidding_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

Future<void> submitBid({
  required BuildContext context,
  required String lotId,
  required num bidAmount,
}) async {
  try {
    final fns = FirebaseFunctions.instanceFor(region: 'me-central1');
    final res = await fns.httpsCallable('placeBid').call({
      'lotId': lotId,
      'bidAmount': bidAmount,
    });
    final data = Map<String, dynamic>.from(res.data as Map);

    if (data['ok'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid placed. Next min: ${data['minAllowed']}')),
      );
    } else {
      final msg = data['reason'] ??
          'Min allowed: ${data['minAllowed']} (step: ${data['usedIncrement']})';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  } on FirebaseFunctionsException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.code} ${e.message ?? ''}')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected: $e')),
    );
  }
}
