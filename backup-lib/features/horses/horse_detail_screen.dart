import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Corrected the package name in the import path
import 'package:horse_auction_app/services/firestore_service.dart';

class HorseDetailsScreen extends StatefulWidget {
  final String horseId;

  const HorseDetailsScreen({Key? key, required this.horseId}) : super(key: key);

  @override
  _HorseDetailsScreenState createState() => _HorseDetailsScreenState();
}

class _HorseDetailsScreenState extends State<HorseDetailsScreen> {
  final _bidController = TextEditingController();
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService.instance;

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _placeBid() async {
    final amount = num.tryParse(_bidController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid amount.')),
      );
      return;
    }

    // NOTE: Replace 'test-user' with your actual authenticated user's ID
    final userId = 'test-user';

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.placeBid(
        horseId: widget.horseId,
        lotId: widget
            .horseId, // Provide the required lotId argument; adjust if needed
        amount: amount.toInt(),
        userId: userId,
      );
      _bidController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Bid placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction Details'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.streamHorse(widget.horseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Horse not found.'));
          }

          final horse = snapshot.data!.data()!;
          final currentHighest = horse['currentHighest'] ?? 0;
          final startingPrice = horse['startingPrice'] ?? 0;
          final displayPrice =
              currentHighest > 0 ? currentHighest : startingPrice;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (horse['imageUrl'] != null && horse['imageUrl'].isNotEmpty)
                  Image.network(horse['imageUrl'],
                      height: 250, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 16),
                // Updated Text Styles
                Text(horse['name'] ?? 'No Name',
                    style: Theme.of(context).textTheme.headlineMedium),
                Text('${horse['breed']} • ${horse['age']} years old',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 24),
                Text('Current Bid: \$${displayPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('Minimum Increment: \$${horse['minIncrement'] ?? 50}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bidController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Your Bid Amount',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _placeBid,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Place Bid'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Bids History',
                    style: Theme.of(context).textTheme.titleLarge),
                _buildBidsList(widget.horseId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBidsList(String horseId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.bidsStream(horseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Loading bids...'),
          );
        }
        final bids = snapshot.data!;
        if (bids.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('No bids yet. Be the first!'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bids.length,
          itemBuilder: (context, index) {
            final bid = bids[index];
            return ListTile(
              leading: const Icon(Icons.gavel),
              title: Text('\$${bid['amount']}'),
              subtitle: Text('by User: ${bid['userId']}'),
            );
          },
        );
      },
    );
  }
}
