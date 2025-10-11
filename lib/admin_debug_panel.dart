import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

class AdminDebugPanel extends StatelessWidget {
  const AdminDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Not signed in')));
              return;
            }
            // refresh token to include any new custom claims
            final token = await user.getIdTokenResult(true);
            final isAdmin = token.claims?['admin'] == true;
            debugPrint('Claims: ${token.claims}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('admin = $isAdmin')));
          },
          child: const Text('Check admin claim'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              final fns = FirebaseFunctions.instanceFor(region: 'me-central1');
              final res = await fns.httpsCallable('closeExpiredLotsNow').call();
              debugPrint('closeExpiredLotsNow OK: ${res.data}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Closed expired lots (if any)')),
              );
            } catch (e, st) {
              debugPrint('closeExpiredLotsNow error: $e\n$st');
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          child: const Text('Run closeExpiredLotsNow'),
        ),
      ],
    );
  }
}
