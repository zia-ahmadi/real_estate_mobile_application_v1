import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/admin_models.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    await ref.read(adminProvider.notifier).loadDashboard();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
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

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: adminState.status == AdminStatus.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : adminState.status == AdminStatus.error
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
                        adminState.error ?? 'Failed to load dashboard',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _StatCard(
                            icon: Icons.home_work,
                            label: 'Total Properties',
                            value: adminState.stats?.totalProperties ?? 0,
                            color: AppColors.primary,
                          ),
                          _StatCard(
                            icon: Icons.check_circle,
                            label: 'Available',
                            value: adminState.stats?.availableProperties ?? 0,
                            color: AppColors.success,
                          ),
                          _StatCard(
                            icon: Icons.people,
                            label: 'Total Users',
                            value: adminState.stats?.totalUsers ?? 0,
                            color: AppColors.accent,
                          ),
                          _StatCard(
                            icon: Icons.message,
                            label: 'New Messages',
                            value: adminState.stats?.unreadMessages ?? 0,
                            color: AppColors.info,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Navigation Menu
                      Text(
                        'Management',
                        style: AppTextStyles.h5,
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.list,
                        title: 'Manage Listings',
                        subtitle: 'Add, edit, or delete properties',
                        onTap: () => context.push('/admin/listings'),
                      ),
                      _buildMenuItem(
                        icon: Icons.chat,
                        title: 'Chat Inbox',
                        subtitle: 'View and respond to messages',
                        onTap: () => context.push('/admin/chats'),
                      ),
                      _buildMenuItem(
                        icon: Icons.manage_accounts,
                        title: 'Manage Users',
                        subtitle: 'View and manage user accounts',
                        onTap: () => context.push('/admin/users'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 32),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: AppTextStyles.h3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
