import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class PropertyCard extends StatelessWidget {
  final String id;
  final String title;
  final String city;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String? coverImage;
  final bool isFeatured;
  final VoidCallback onTap;
  final VoidCallback? onFavouriteToggle;
  final bool isFavourited;

  const PropertyCard({
    super.key,
    required this.id,
    required this.title,
    required this.city,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    this.coverImage,
    this.isFeatured = false,
    required this.onTap,
    this.onFavouriteToggle,
    this.isFavourited = false,
  });

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
                  child: coverImage != null
                      ? CachedNetworkImage(
                          imageUrl: coverImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: AppColors.textLight,
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: AppColors.textLight,
                          ),
                        ),
                ),
                // Featured Badge
                if (isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favourite Button
                if (onFavouriteToggle != null)
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
                          isFavourited ? Icons.favorite : Icons.favorite_border,
                          color: isFavourited ? AppColors.error : AppColors.text,
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
                    '\$${price.toStringAsFixed(2)}',
                    style: AppTextStyles.price,
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    title,
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
                          city,
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
                        '$bedrooms',
                        'Bedrooms',
                      ),
                      const SizedBox(width: 16),
                      _buildDetailItem(
                        Icons.bathtub,
                        '$bathrooms',
                        'Bathrooms',
                      ),
                      const SizedBox(width: 16),
                      _buildDetailItem(
                        Icons.square_foot,
                        '${area.toStringAsFixed(0)}',
                        'Sq ft',
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

  Widget _buildDetailItem(IconData icon, String value, String label) {
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
