import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../l10n/app_localizations.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  Future<void> _runCloseExpired(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'me-central1')
          .httpsCallable('closeExpiredLotsNow');
      await callable.call();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.serviceDone!)));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l.serviceError}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock_clock_outlined),
            title: Text(l.serviceCloseExpiredTitle),
            subtitle: Text(l.serviceCloseExpiredDesc),
            trailing: FilledButton(
              onPressed: () => _runCloseExpired(context),
              child: Text(l.runNow),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.more_horiz),
            title: Text(l.serviceSoonTitle),
            subtitle: Text(l.serviceSoonDesc),
          ),
        ),
      ],
    );
  }
}
