import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/data/auth_models.dart';
import '../providers/admin_users_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await ref.read(adminUsersProvider.notifier).loadUsers();
  }

  Future<void> _toggleBlock(User user) async {
    try {
      await ref.read(adminUsersProvider.notifier).toggleBlockUser(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isBlocked ? 'User unblocked successfully' : 'User blocked successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update user status: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return '';
    final date = DateTime.parse(dateTime);
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final adminUsersState = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: adminUsersState.status == AdminUsersStatus.loading &&
                adminUsersState.users.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : adminUsersState.status == AdminUsersStatus.error
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          adminUsersState.error ?? 'Failed to load users',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : adminUsersState.users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users yet',
                              style: AppTextStyles.h5,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminUsersState.users.length,
                        itemBuilder: (context, index) {
                          final user = adminUsersState.users[index];
                          return _UserListItem(
                            user: user,
                            joinDate: _formatDate(user.createdAt),
                            onToggleBlock: () => _toggleBlock(user),
                          );
                        },
                      ),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final User user;
  final String joinDate;
  final VoidCallback onToggleBlock;

  const _UserListItem({
    required this.user,
    required this.joinDate,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    user.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Join date and status
                  Row(
                    children: [
                      Text(
                        'Joined: $joinDate',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusBadge(isBlocked: user.isBlocked),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Block/Unblock button
            ElevatedButton(
              onPressed: onToggleBlock,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    user.isBlocked ? AppColors.success : AppColors.error,
                foregroundColor: AppColors.background,
              ),
              child: Text(user.isBlocked ? 'Unblock' : 'Block'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isBlocked;

  const _StatusBadge({required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBlocked
            ? AppColors.error.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isBlocked ? AppColors.error : AppColors.success,
          width: 1,
        ),
      ),
      child: Text(
        isBlocked ? 'Blocked' : 'Active',
        style: AppTextStyles.caption.copyWith(
          color: isBlocked ? AppColors.error : AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
