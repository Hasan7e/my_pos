import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/user_store.dart';
import 'package:my_pos/models/app_user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppUser> _filterUsers(List<AppUser> users) {
    final normalized = _query.trim().toLowerCase();
    final sortedUsers = users.toList()
      ..sort((a, b) => a.username.compareTo(b.username));

    if (normalized.isEmpty) return sortedUsers;

    return sortedUsers.where((user) {
      return user.username.toLowerCase().contains(normalized) ||
          user.fullName.toLowerCase().contains(normalized) ||
          user.role.toLowerCase().contains(normalized);
    }).toList();
  }

  Future<void> _toggleUserStatus(AppUser user, List<AppUser> users) async {
    final newStatus = !user.isActive;

    if (user.isAdmin && !newStatus) {
      final activeAdmins = users
          .where(
            (existingUser) => existingUser.isAdmin && existingUser.isActive,
          )
          .length;

      if (activeAdmins <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('At least one active admin account is required'),
          ),
        );
        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(newStatus ? 'Reactivate User' : 'Deactivate User'),
          content: Text(
            newStatus
                ? 'Reactivate ${user.username}? They will be able to log in again.'
                : 'Deactivate ${user.username}? They will no longer be able to log in.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(newStatus ? 'Reactivate' : 'Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await UserStore.instance.setUserActive(user.id, newStatus);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? '${user.username} reactivated'
              : '${user.username} deactivated',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search by username, full name or role',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<Box<AppUser>>(
                valueListenable: UserStore.instance.usersListenable(),
                builder: (context, box, _) {
                  final allUsers = UserStore.instance.getUsers();
                  final users = _filterUsers(allUsers);

                  if (users.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _UserTile(
                        user: user,
                        onToggleStatus: () => _toggleUserStatus(user, allUsers),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onToggleStatus;

  const _UserTile({required this.user, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive ? Colors.green : Colors.redAccent;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(user.isAdmin ? Icons.admin_panel_settings : Icons.person),
        ),
        title: Text(user.fullName.isEmpty ? user.username : user.fullName),
        subtitle: Text(
          '${user.username} | ${user.role} | Created ${user.createdAt.toLocal()}',
        ),
        trailing: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text(user.isActive ? 'Active' : 'Inactive'),
              side: BorderSide(color: statusColor),
              labelStyle: TextStyle(color: statusColor),
            ),
            OutlinedButton.icon(
              onPressed: onToggleStatus,
              icon: Icon(user.isActive ? Icons.block : Icons.check_circle),
              label: Text(user.isActive ? 'Deactivate' : 'Reactivate'),
            ),
          ],
        ),
      ),
    );
  }
}
