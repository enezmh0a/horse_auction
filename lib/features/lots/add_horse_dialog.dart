// lib/features/horses/add_horse_dialog.dart
import 'package:flutter/material.dart';
import 'package:horse_auction_baseline/services/firestore_service.dart';
import 'package:horse_auction_baseline/models/lot_model.dart';

class AddHorseDialog extends StatefulWidget {
  const AddHorseDialog({super.key});

  @override
  State<AddHorseDialog> createState() => _AddHorseDialogState();
}

class _AddHorseDialogState extends State<AddHorseDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _ownerController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _minIncrementController = TextEditingController(
    text: '50',
  ); // default 50
  final _imageUrlController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _ownerController.dispose();
    _startPriceController.dispose();
    _minIncrementController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final breed = _breedController.text.trim();
      final owner = _ownerController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      // ✅ Parse strictly as int (no num/double)
      final age = int.parse(_ageController.text.trim());
      final startingPrice = int.parse(_startPriceController.text.trim());
      final minIncrement = int.parse(_minIncrementController.text.trim());

      await LotsService.instance.addHorse(
        name: nameController.text,
        breed: breedController.text,
        age: int.tryParse(ageController.text) ?? 0,
        owner: ownerController.text,
        startingPrice: double.tryParse(startingPriceController.text) ?? 0,
        minIncrement: double.tryParse(minIncController.text) ?? 0,
        imageUrl: imageUrlController.text,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add horse: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Horse'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age (years)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid integer';
                  return null;
                },
              ),
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(labelText: 'Owner'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _startPriceController,
                decoration: const InputDecoration(
                  labelText: 'Starting Price (SAR)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid integer';
                  return null;
                },
              ),
              TextFormField(
                controller: _minIncrementController,
                decoration: const InputDecoration(
                  labelText: 'Min Increment (SAR)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a positive integer';
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child:
              _saving ? const CircularProgressIndicator() : const Text('Save'),
        ),
      ],
    );
  }
}
