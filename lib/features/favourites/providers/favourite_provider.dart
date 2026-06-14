import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../properties/data/property_models.dart';
import '../../properties/providers/property_provider.dart';
import '../data/favourite_models.dart';

enum FavouriteStatus { initial, loading, loaded, error }

class FavouriteState {
  final FavouriteStatus status;
  final List<Property> favourites;
  final String? error;

  FavouriteState({
    this.status = FavouriteStatus.initial,
    this.favourites = const [],
    this.error,
  });

  FavouriteState copyWith({
    FavouriteStatus? status,
    List<Property>? favourites,
    String? error,
  }) {
    return FavouriteState(
      status: status ?? this.status,
      favourites: favourites ?? this.favourites,
      error: error ?? this.error,
    );
  }
}

class FavouriteNotifier extends StateNotifier<FavouriteState> {
  final ApiService _apiService;

  FavouriteNotifier(this._apiService) : super(FavouriteState());

  Future<void> loadFavourites() async {
    state = state.copyWith(status: FavouriteStatus.loading, error: null);
    
    try {
      final response = await _apiService.getFavourites();
      final properties = (response as List<dynamic>)
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList();
      
      state = state.copyWith(
        status: FavouriteStatus.loaded,
        favourites: properties,
      );
    } catch (e) {
      state = state.copyWith(
        status: FavouriteStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> toggleFavourite(int propertyId) async {
    try {
      final response = await _apiService.toggleFavourite(propertyId);
      final favouriteResponse = FavouriteResponse.fromJson(response);
      
      // Update the favourites list
      if (favouriteResponse.isFavourited) {
        // Property was added to favourites - we need to reload to get the full list
        await loadFavourites();
      } else {
        // Property was removed from favourites - remove from local list
        final updatedFavourites = state.favourites
            .where((p) => p.id != propertyId)
            .toList();
        state = state.copyWith(favourites: updatedFavourites);
      }
      
      return favouriteResponse.isFavourited;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = FavouriteState();
  }
}

// Provider
final favouriteProvider = StateNotifierProvider<FavouriteNotifier, FavouriteState>((ref) {
  return FavouriteNotifier(ref.watch(apiServiceProvider));
});
