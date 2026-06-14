import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _logout(WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && ref.context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (ref.context.mounted) {
        ref.context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                _getInitials(user.name),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.background,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // User Name
            Text(
              user.name,
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            // User Email
            Text(
              user.email,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Menu Items
            _buildMenuItem(
              icon: Icons.favorite,
              title: 'My Favourites',
              onTap: () => context.push('/favourites'),
            ),
            _buildMenuItem(
              icon: Icons.chat,
              title: 'Chat with Admin',
              onTap: () => context.push('/chat'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
