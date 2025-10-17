import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/core/service_request.dart';
import 'package:horse_auction_baseline/core/services/requests_service.dart';

class VeterinaryPage extends StatefulWidget {
  final String? prefilledLotId;
  const VeterinaryPage({super.key, this.prefilledLotId});

  @override
  State<VeterinaryPage> createState() => _VeterinaryPageState();
}

class _VeterinaryPageState extends State<VeterinaryPage> {
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
      type: 'veterinary',
      lotId: _lotId.isEmpty ? 'lot_1' : _lotId, // fallback
      contactName: _name.text.trim(),
      contactPhone: _phone.text.trim(),
      notes: _notes.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Veterinary request sent')));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // …your existing UI…
    // Replace your submit button's onPressed with _submit()
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
