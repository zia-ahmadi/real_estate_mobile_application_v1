import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/properties/data/property_models.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onFavouriteToggle;
  final bool showFavourite;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.onFavouriteToggle,
    this.showFavourite = false,
  });

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: property.coverImage != null
                      ? CachedNetworkImage(
                          imageUrl: property.coverImage!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 180,
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 180,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.textLight,
                            ),
                          ),
                        )
                      : Container(
                          height: 180,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: AppColors.textLight,
                          ),
                        ),
                ),
                // Favourite Button
                if (showFavourite && onFavouriteToggle != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavouriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          property.isFavourited ? Icons.favorite : Icons.favorite_border,
                          color: property.isFavourited ? AppColors.error : AppColors.text,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    _formatPrice(property.price),
                    style: AppTextStyles.price,
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    property.title,
                    style: AppTextStyles.h6,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // City
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.city,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Property Details
                  Row(
                    children: [
                      _buildDetailItem(
                        Icons.bed,
                        '${property.bedrooms}',
                      ),
                      const SizedBox(width: 16),
                      _buildDetailItem(
                        Icons.square_foot,
                        '${property.area.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
