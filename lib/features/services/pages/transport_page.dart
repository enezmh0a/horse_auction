import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/core/service_request.dart';
import 'package:horse_auction_baseline/core/services/requests_service.dart';

class TransportPage extends StatefulWidget {
  final String? prefilledLotId;
  const TransportPage({super.key, this.prefilledLotId});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  String _lotId = '';

  @override
  void initState() {
    super.initState();
    _lotId = widget.prefilledLotId ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    await RequestsService.instance.create(
      type: 'transport',
      lotId: _lotId.isEmpty ? 'lot_1' : _lotId,
      contactName: _name.text.trim(),
      contactPhone: _phone.text.trim(),
      notes: _notes.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transportation request sent')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // …your existing UI…
    return Form(
      key: _form,
      child: Column(
        children: [
          // your fields ...
          FilledButton(onPressed: _submit, child: const Text('Send request')),
        ],
      ),
    );
  }
}
