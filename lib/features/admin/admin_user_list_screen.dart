import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_profile.dart';
import '../../data/providers/user_providers.dart';
import '../../data/providers/repository_providers.dart';

class AdminUserListScreen extends ConsumerWidget {
  const AdminUserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUserProfilesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return UserListItem(user: user);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class UserListItem extends ConsumerWidget {
  const UserListItem({super.key, required this.user});
  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = user.isAdmin ?? false;
    return ListTile(
      title: Text(user.displayName ?? user.email ?? user.id),
      subtitle: Text(user.email ?? ''),
      trailing: Switch(
        value: isAdmin,
        onChanged: (val) {
          ref.read(userRepositoryProvider).toggleAdmin(user.id, val);
        },
      ),
    );
  }
}
