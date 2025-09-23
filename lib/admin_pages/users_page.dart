import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').limit(25).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('${l.error}: ${snap.error}'));
        }
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.usersEmptyHint, textAlign: TextAlign.center),
          ));
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final d = docs[i].data();
            return ListTile(
              title: Text(
                  d['displayName']?.toString() ?? d['uid']?.toString() ?? '—'),
              subtitle: Text(d['email']?.toString() ?? l.noEmail),
              trailing: Text(d['role']?.toString() ?? '—'),
            );
          },
        );
      },
    );
  }
}
