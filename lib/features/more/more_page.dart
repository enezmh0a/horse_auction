import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';
import '../../data/providers/auth_providers.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t.tabMore, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (user == null)
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(t.signIn),
            onTap:
                () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const _EmailSignIn())),
          )
        else ...[
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: Text('${t.signedInAs} ${user.email ?? user.uid}'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(t.signOut),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
        ],
        const Divider(),
        ListTile(
          leading: const Icon(Icons.medical_services),
          title: Text(AppLocalizations.of(context)!.vets),
          subtitle: const Text('Find vets near you'),
        ),
        ListTile(
          leading: const Icon(Icons.local_shipping),
          title: Text(AppLocalizations.of(context)!.transport),
          subtitle: const Text('Transporters / drivers'),
        ),
      ],
    );
  }
}

class _EmailSignIn extends StatefulWidget {
  const _EmailSignIn();
  @override
  State<_EmailSignIn> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<_EmailSignIn> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.signIn)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pass,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed:
                busy
                    ? null
                    : () async {
                      setState(() => busy = true);
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email.text.trim(),
                          password: pass.text.trim(),
                        );
                        if (mounted) Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? e.code)),
                        );
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
            child: Text(t.signIn),
          ),
        ],
      ),
    );
  }
}
