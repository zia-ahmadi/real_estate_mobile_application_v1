import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../properties/data/property_models.dart';
import '../../properties/providers/property_provider.dart';

class AdminListingsScreen extends ConsumerStatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  ConsumerState<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends ConsumerState<AdminListingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    await ref.read(propertyProvider.notifier).loadProperties();
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  Future<void> _deleteProperty(Property property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${property.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ApiService().deleteProperty(property.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Property deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadProperties();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete property: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Listings'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProperties,
        child: propertyState.status == PropertyStatus.loading &&
                propertyState.properties.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : propertyState.status == PropertyStatus.error
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
                          propertyState.error ?? 'Failed to load properties',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProperties,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : propertyState.properties.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No properties yet',
                              style: AppTextStyles.h5,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first property',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: propertyState.properties.length,
                        itemBuilder: (context, index) {
                          final property = propertyState.properties[index];
                          return _PropertyListItem(
                            property: property,
                            formatPrice: _formatPrice,
                            onEdit: () => context.push('/admin/listing/${property.id}/edit'),
                            onDelete: () => _deleteProperty(property),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/listing/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final Property property;
  final String Function(double) formatPrice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PropertyListItem({
    required this.property,
    required this.formatPrice,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: property.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: property.coverImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.image,
                        size: 32,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Property Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    formatPrice(property.price),
                    style: AppTextStyles.price,
                  ),
                  const SizedBox(height: 4),
                  // Status Badge
                  _StatusBadge(status: property.status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAvailable = status == 'available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAvailable ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Sold',
        style: AppTextStyles.caption.copyWith(
          color: isAvailable ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
