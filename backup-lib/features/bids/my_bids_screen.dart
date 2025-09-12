import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyBidsScreen extends StatelessWidget {
  const MyBidsScreen({super.key});

  Future<User> _ensureUser() async {
    final auth = FirebaseAuth.instance;
    return auth.currentUser ?? (await auth.signInAnonymously()).user!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _ensureUser(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final uid = authSnap.data!.uid;

        final q = FirebaseFirestore.instance
            .collectionGroup('bids')
            .where('bidderId', isEqualTo: uid)
            .orderBy('createdAt', descending: true);

        return Scaffold(
          appBar: AppBar(title: const Text('My Bids')),
          body: StreamBuilder<QuerySnapshot>(
            stream: q.snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(child: Text("You haven't placed any bids yet."));
              }
              final docs = snap.data!.docs;
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final data = d.data() as Map<String, dynamic>;
                  final amount = (data['amount'] is num) ? (data['amount'] as num).toInt() : 0;
                  final ts = data['createdAt'];
                  final when = (ts is Timestamp) ? ts.toDate().toLocal().toString() : '—';

                  final path = d.reference.path; // lots/{horseId}/bids/{bidId}
                  String horseId = '—';
                  final parts = path.split('/');
                  final lotIdx = parts.indexOf('lots');
                  if (lotIdx >= 0 && lotIdx + 1 < parts.length) {
                    horseId = parts[lotIdx + 1];
                  }

                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('$amount SAR'),
                    subtitle: Text('Horse: $horseId\n$when'),
                    isThreeLine: true,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
