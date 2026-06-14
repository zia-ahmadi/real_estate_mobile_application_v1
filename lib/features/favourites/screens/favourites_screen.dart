import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/property_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../properties/data/property_models.dart';
import '../providers/favourite_provider.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({super.key});

  @override
  ConsumerState<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends ConsumerState<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    await ref.read(favouriteProvider.notifier).loadFavourites();
  }

  Future<void> _onRefresh() async {
    await _loadFavourites();
  }

  void _navigateToPropertyDetail(int propertyId) {
    context.push('/property/$propertyId');
  }

  Future<void> _onFavouriteToggle(Property property) async {
    final success = await ref.read(favouriteProvider.notifier).toggleFavourite(property.id);
    
    if (!mounted) return;
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favourites'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favouriteState = ref.watch(favouriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favourites'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: favouriteState.status == FavouriteStatus.loading &&
                favouriteState.favourites.isEmpty
            ? const LoadingWidget()
            : favouriteState.status == FavouriteStatus.error
                ? AppErrorWidget(
                    message: favouriteState.error ?? 'Failed to load favourites',
                    onRetry: _loadFavourites,
                  )
                : favouriteState.favourites.isEmpty
                    ? const AppEmptyWidget(
                        message:
                            'Tap the heart icon on any property to save it here',
                        icon: Icons.favorite_border,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favouriteState.favourites.length,
                        itemBuilder: (context, index) {
                          final property = favouriteState.favourites[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PropertyCard(
                              property: property.copyWith(isFavourited: true),
                              onTap: () => _navigateToPropertyDetail(property.id),
                              showFavourite: true,
                              onFavouriteToggle: () => _onFavouriteToggle(property),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
