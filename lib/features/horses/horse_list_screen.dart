import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horse_auction_app/services/firestore_service.dart';
import 'horse_detail_screen.dart';

class HorseListScreen extends StatelessWidget {
  const HorseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horse Auction Lots')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.instance.lotsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No horses available yet'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final title = (data['name'] ?? 'Unnamed') as String;
              final breed = (data['breed'] ?? '') as String;
              final currentHighest = (data['currentHighest'] ?? 0) as num;
              final minIncrement = (data['minIncrement'] ?? 50) as num;
              final startingPrice = (data['startingPrice'] ?? 0) as num;

              return ListTile(
                title: Text(title),
                subtitle: Text('$breed • Highest: ${currentHighest.toInt()} • Min +${minIncrement.toInt()} • Start ${startingPrice.toInt()}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HorseDetailScreen(horseId: doc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // quick adder to keep things simple (optional)
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) {
              final nameCtrl = TextEditingController();
              final breedCtrl = TextEditingController(text: 'Arabian');
              final ageCtrl = TextEditingController(text: '4');
              final ownerCtrl = TextEditingController(text: 'owner');
              final startCtrl = TextEditingController(text: '20000');
              return AlertDialog(
                title: const Text('Add Horse'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                      TextField(controller: breedCtrl, decoration: const InputDecoration(labelText: 'Breed')),
                      TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age (int)'), keyboardType: TextInputType.number),
                      TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Owner')),
                      TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Starting price (int)'), keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () async {
                      try {
                        final age = int.tryParse(ageCtrl.text.trim()) ?? 0;
                        final start = int.tryParse(startCtrl.text.trim()) ?? 0;
                        await FirestoreService.instance.addHorse(
                          name: nameCtrl.text.trim().isEmpty ? 'Horse' : nameCtrl.text.trim(),
                          breed: breedCtrl.text.trim(),
                          age: age,
                          owner: ownerCtrl.text.trim(),
                          startingPrice: start,
                        );
                        // close dialog
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Add failed: $e')));
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
          if (ok == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horse added')));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
