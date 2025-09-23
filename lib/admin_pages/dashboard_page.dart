import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<int> _countByStatus(String status) async {
    final snap = await FirebaseFirestore.instance
        .collection('lots')
        .where('status', isEqualTo: status)
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _CountCard(title: l.statLotsLive, future: _countByStatus('live')),
              _CountCard(
                  title: l.statLotsPublished,
                  future: _countByStatus('published')),
              _CountCard(
                  title: l.statLotsClosed, future: _countByStatus('closed')),
            ],
          ),
          const SizedBox(height: 24),
          Text(l.recentActivity, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text(l.noData),
              subtitle: const Text('—'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.title, required this.future});

  final String title;
  final Future<int> future;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<int>(
            future: future,
            builder: (context, snap) {
              final value = snap.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(value?.toString() ?? '—',
                      style: Theme.of(context).textTheme.headlineMedium),
                  if (snap.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('${l.error}: ${snap.error}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
