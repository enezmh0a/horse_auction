import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:horse_auction_app/services/firestore_service.dart';
import 'package:horse_auction_app/features/horses/add_horse_dialog.dart';

import 'horse_detail_screen.dart';

class HorseListScreen extends StatelessWidget {
  const HorseListScreen({super.key});

  num _num(dynamic v, [num fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horse Auction Lots')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.instance.lotsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data ?? const [];
          if (docs.isEmpty) {
            return const Center(child: Text('No horses available yet'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i];
              final name = (data['name'] ?? '') as String? ?? '';
              final breed = (data['breed'] ?? '') as String? ?? '';
              final starting = _num(data['startingPrice']);
              final current = _num(data['currentHighest']);
              final minInc = _num(data['minIncrement'], 50);

              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(name.isEmpty ? '(Unnamed horse)' : name),
                subtitle: Text(
                  'Breed: $breed\nStart: $starting  |  Current: $current  |  +$minInc',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HorseDetailsScreen(horseId: data['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add horse',
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => const AddHorseDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
