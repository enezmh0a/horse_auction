import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart'; // ADDED: Required to define the 'user' type in the ListView builder
import '../../data/providers/firestore_providers.dart';
import '../../data/repositories/user_repository.dart';

class AdminDebugPanelScreen extends ConsumerWidget {
  const AdminDebugPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Correctly access userProfileStreamProvider from firestore_providers.dart
    final usersAsyncValue = ref.watch(userProfileStreamProvider);
    final userRepository = ref.watch(userRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Debug Panel')),
      body: usersAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) {
          return ListView(
            children: users.map((user) {
              // Now the compiler knows what 'user' is because UserModel is imported
              final isAdmin = user.role == 'admin';
              return ListTile(
                title: Text(user.displayName ?? user.email),
                subtitle: Text('ID: ${user.id} | Role: ${user.role}'),
                trailing: Switch(
                  value: isAdmin,
                  onChanged: (newValue) async {
                    // FIX: Correctly call the method from the repository
                    await userRepository.toggleAdminStatus(user.id, newValue);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
