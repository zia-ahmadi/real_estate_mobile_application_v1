import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/favourites/providers/favourite_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/property_models.dart';
import '../providers/property_provider.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const PropertyDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _currentImageIndex = 0;

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  Future<void> _toggleFavourite(Property property) async {
    final success = await ref.read(favouriteProvider.notifier).toggleFavourite(property.id);
    
    if (!mounted) return;
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favourites'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      // Reload property to update favourite status
      await ref.read(propertyDetailProvider(int.parse(widget.id)).notifier).loadProperty(int.parse(widget.id));
    }
  }

  void _deleteProperty(int propertyId) async {
    // TODO: Implement delete property
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete logic here
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final property = ref.watch(propertyDetailProvider(int.parse(widget.id)));
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isAdmin = authState.user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: property == null
          ? const Center(
              child: LoadingWidget(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel
                  if (property.images.isNotEmpty)
                    Stack(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            enableInfiniteScroll: property.images.length > 1,
                            autoPlay: property.images.length > 1,
                            autoPlayInterval: const Duration(seconds: 5),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                          ),
                          items: property.images.map((imageUrl) {
                            return Builder(
                              builder: (BuildContext context) {
                                return CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 300,
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 300,
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        // Image indicators
                        if (property.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: property.images.asMap().entries.map((entry) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == entry.key
                                        ? AppColors.background
                                        : AppColors.background.withOpacity(0.5),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      height: 300,
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  // Property Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Text(
                          _formatPrice(property.price),
                          style: AppTextStyles.priceLarge,
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          property.title,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        // Badges Row
                        Row(
                          children: [
                            _buildBadge(Icons.bed, '${property.bedrooms} Beds'),
                            const SizedBox(width: 12),
                            _buildBadge(Icons.bathtub, '${property.bathrooms} Baths'),
                            const SizedBox(width: 12),
                            _buildBadge(Icons.square_foot, '${property.area.toStringAsFixed(0)} m²'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.city,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    property.address,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        const Divider(),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          'Description',
                          style: AppTextStyles.h5,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          property.description,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        // View on Map Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/map?propertyId=${property.id}');
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Authenticated User Actions
                        if (isAuthenticated) ...[
                          // Save to Favourites
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _toggleFavourite(property),
                              icon: Icon(
                                property.isFavourited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(
                                property.isFavourited
                                    ? 'Remove from Favourites'
                                    : 'Save to Favourites',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: property.isFavourited
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Chat with Admin (only for non-admin users)
                          if (!isAdmin)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/chat');
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text('Chat with Admin'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                        ],
                        // Admin Actions
                        if (isAdmin) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.push('/admin/listing/${property.id}/edit');
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _deleteProperty(property.id),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
