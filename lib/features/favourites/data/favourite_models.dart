import '../../properties/data/property_models.dart';

// Reuse Property model from properties feature
// The API returns full property data with favourites

class FavouriteResponse {
  final bool success;
  final bool isFavourited;

  FavouriteResponse({
    required this.success,
    required this.isFavourited,
  });

  factory FavouriteResponse.fromJson(Map<String, dynamic> json) {
    return FavouriteResponse(
      success: json['success'] as bool? ?? false,
      isFavourited: json['is_favourited'] as bool? ?? false,
    );
  }
}
