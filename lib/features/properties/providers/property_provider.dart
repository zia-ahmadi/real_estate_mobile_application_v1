import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../data/property_models.dart';

enum PropertyStatus { initial, loading, loaded, error }

class PropertyState {
  final PropertyStatus status;
  final List<Property> properties;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? error;

  PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.error,
  });

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    int? currentPage,
    int? lastPage,
    int? total,
    String? error,
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      error: error ?? this.error,
    );
  }
}

class PropertyNotifier extends StateNotifier<PropertyState> {
  final ApiService _apiService;

  PropertyNotifier(this._apiService) : super(PropertyState());

  Future<void> loadProperties({int page = 1}) async {
    state = state.copyWith(status: PropertyStatus.loading, error: null);
    
    try {
      final response = await _apiService.getProperties(page: page);
      final propertyList = PropertyListResponse.fromJson(response);
      
      state = state.copyWith(
        status: PropertyStatus.loaded,
        properties: propertyList.data,
        currentPage: propertyList.currentPage,
        lastPage: propertyList.lastPage,
        total: propertyList.total,
      );
    } catch (e) {
      state = state.copyWith(
        status: PropertyStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> searchProperties(SearchFilters filters) async {
    state = state.copyWith(status: PropertyStatus.loading, error: null);
    
    try {
      final response = await _apiService.searchProperties(filters.toJson());
      final propertyList = PropertyListResponse.fromJson(response);
      
      state = state.copyWith(
        status: PropertyStatus.loaded,
        properties: propertyList.data,
        currentPage: propertyList.currentPage,
        lastPage: propertyList.lastPage,
        total: propertyList.total,
      );
    } catch (e) {
      state = state.copyWith(
        status: PropertyStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.currentPage >= state.lastPage) return;
    
    try {
      final response = await _apiService.getProperties(page: state.currentPage + 1);
      final propertyList = PropertyListResponse.fromJson(response);
      
      state = state.copyWith(
        status: PropertyStatus.loaded,
        properties: [...state.properties, ...propertyList.data],
        currentPage: propertyList.currentPage,
        lastPage: propertyList.lastPage,
        total: propertyList.total,
      );
    } catch (e) {
      // Don't update state on load more error, just log
    }
  }

  void reset() {
    state = PropertyState();
  }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final propertyProvider = StateNotifierProvider<PropertyNotifier, PropertyState>((ref) {
  return PropertyNotifier(ref.watch(apiServiceProvider));
});

final searchFiltersProvider = StateProvider<SearchFilters>((ref) {
  return SearchFilters();
});
