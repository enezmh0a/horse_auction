import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = 'support@horse-auction.sa';
    final phone = '+966-555-000-000';
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Get in touch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
              leading: const Icon(Icons.email_outlined), title: Text(email)),
          ListTile(
              leading: const Icon(Icons.call_outlined), title: Text(phone)),
          const SizedBox(height: 24),
          const Text('Send a message',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const _ContactForm(),
        ],
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _msg = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Your name')),
          const SizedBox(height: 8),
          TextFormField(
              controller: _msg,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Message')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent (demo)')));
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
