import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/property_card.dart';
import '../data/property_models.dart';
import '../providers/property_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  final _scrollController = ScrollController();
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(propertyProvider.notifier).loadMore();
    }
  }

  Future<void> _loadProperties() async {
    await ref.read(propertyProvider.notifier).loadProperties();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        final filters = SearchFilters(city: query);
        ref.read(propertyProvider.notifier).searchProperties(filters);
      } else {
        ref.read(propertyProvider.notifier).loadProperties();
      }
    });
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
    
    // Reset search when filter changes
    _searchController.clear();
    
    switch (index) {
      case 0: // All
        ref.read(propertyProvider.notifier).loadProperties();
        break;
      case 1: // By City
        // Show city filter dialog
        _showCityFilterDialog();
        break;
      case 2: // By Price
        // Show price filter dialog
        _showPriceFilterDialog();
        break;
      case 3: // By Bedrooms
        // Show bedrooms filter dialog
        _showBedroomsFilterDialog();
        break;
    }
  }

  void _showCityFilterDialog() {
    // TODO: Implement city filter dialog
  }

  void _showPriceFilterDialog() {
    // TODO: Implement price filter dialog
  }

  void _showBedroomsFilterDialog() {
    // TODO: Implement bedrooms filter dialog
  }

  void _navigateToPropertyDetail(int propertyId) {
    context.push('/property/$propertyId');
  }

  void _onFavouriteToggle(Property property) {
    // TODO: Implement favourite toggle
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final propertyState = ref.watch(propertyProvider);
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.home_work, size: 28),
            const SizedBox(width: 8),
            Text(
              'Real Estate',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.background,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: isAuthenticated
                ? const Icon(Icons.person)
                : const Icon(Icons.login),
            onPressed: () {
              if (isAuthenticated) {
                context.push('/profile');
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(propertyProvider.notifier).loadProperties();
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final filters = ['All', 'By City', 'By Price', 'By Bedrooms'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filters[index]),
                      selected: _selectedFilterIndex == index,
                      onSelected: (_) => _onFilterChanged(index),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == index
                            ? AppColors.background
                            : AppColors.text,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Property Grid
          Expanded(
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
                                  Icons.home_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No properties found',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: propertyState.properties.length,
                            itemBuilder: (context, index) {
                              final property = propertyState.properties[index];
                              return PropertyCard(
                                property: property,
                                onTap: () =>
                                    _navigateToPropertyDetail(property.id),
                                showFavourite: isAuthenticated,
                                onFavouriteToggle: () =>
                                    _onFavouriteToggle(property),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/map');
              break;
            case 2:
              if (isAuthenticated) {
                context.push('/favourites');
              }
              break;
            case 3:
              if (isAuthenticated) {
                context.push('/chat');
              }
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
            enabled: isAuthenticated,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            enabled: isAuthenticated,
          ),
        ],
      ),
    );
  }
}
