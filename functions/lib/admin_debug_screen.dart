import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:horse_auction_app/widgets/bid_box.dart';

class AdminDebugScreen extends StatefulWidget {
  const AdminDebugScreen({super.key});

  @override
  State<AdminDebugScreen> createState() => _AdminDebugScreenState();
}

class _AdminDebugScreenState extends State<AdminDebugScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;
  bool? _isAdmin;
  bool _busy = false;

  FirebaseFunctions get _fx =>
      FirebaseFunctions.instanceFor(region: 'me-central1');

  Future<void> _checkAdminClaim() async {
    setState(() => _busy = true);
    try {
      final token = await _user?.getIdTokenResult(true);
      setState(() => _isAdmin = token?.claims?['admin'] == true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('admin = ${_isAdmin == true}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read admin claim: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runCloseExpired() async {
    setState(() => _busy = true);
    try {
      await _fx.httpsCallable('closeExpiredLotsNow').call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Closed expired lots (if any)')),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${e.code}: ${e.message ?? 'error'}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uidText = _user == null ? 'Not signed in' : 'UID: ${_user!.uid}';
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Debug')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(uidText),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _checkAdminClaim,
                  child: const Text('Check admin claim'),
                ),
                ElevatedButton(
                  onPressed: _runCloseExpired,
                  child: const Text('Run closeExpiredLotsNow'),
                ),
              ],
            ),
            if (_isAdmin != null) ...[
              const SizedBox(height: 8),
              Text('admin = ${_isAdmin!}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Text('Test bidding (lot01)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const BidBox(lotId: 'lot01'),
          ],
        ),
      ),
    );
  }
}
