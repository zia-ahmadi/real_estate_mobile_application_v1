import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/property_models.dart';
import '../providers/property_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const MapScreen({super.key, this.propertyId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Property? _selectedProperty;
  bool _isBottomSheetOpen = false;

  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060); // New York

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    await ref.read(propertyProvider.notifier).loadProperties();
  }

  void _updateMarkers(List<Property> properties) {
    final Set<Marker> markers = {};

    for (final property in properties) {
      if (property.hasLocation) {
        final markerId = MarkerId(property.id.toString());
        markers.add(
          Marker(
            markerId: markerId,
            position: LatLng(property.latitude!, property.longitude!),
            infoWindow: InfoWindow(
              title: property.title,
              snippet: _formatPrice(property.price),
            ),
            onTap: () {
              _showPropertyBottomSheet(property);
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });

    // If a specific property ID is provided, center on it
    if (widget.propertyId != null) {
      final targetProperty = properties.firstWhere(
        (p) => p.id == int.parse(widget.propertyId!),
        orElse: () => properties.first,
      );

      if (targetProperty.hasLocation) {
        _moveToProperty(targetProperty);
        _showPropertyBottomSheet(targetProperty);
      }
    } else if (properties.isNotEmpty) {
      // Center on first property with location
      final firstProperty = properties.firstWhere(
        (p) => p.hasLocation,
        orElse: () => properties.first,
      );

      if (firstProperty.hasLocation) {
        _moveToProperty(firstProperty);
      }
    }
  }

  Future<void> _moveToProperty(Property property) async {
    if (_mapController != null && property.hasLocation) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(property.latitude!, property.longitude!),
            zoom: 14,
          ),
        ),
      );
    }
  }

  void _showPropertyBottomSheet(Property property) {
    setState(() {
      _selectedProperty = property;
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PropertyBottomSheet(
        property: property,
        onViewDetails: () {
          Navigator.pop(context);
          context.push('/property/${property.id}');
        },
      ),
    ).then((_) {
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);

    // Update markers when properties load
    if (propertyState.status == PropertyStatus.loaded &&
        propertyState.properties.isNotEmpty &&
        _markers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMarkers(propertyState.properties);
      });
    }

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultLocation,
          zoom: 12,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
          if (propertyState.status == PropertyStatus.loaded) {
            _updateMarkers(propertyState.properties);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (propertyState.status == PropertyStatus.loaded) {
            _updateMarkers(propertyState.properties);
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _PropertyBottomSheet extends StatelessWidget {
  final Property property;
  final VoidCallback onViewDetails;

  const _PropertyBottomSheet({
    required this.property,
    required this.onViewDetails,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Cover Image
          if (property.coverImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: property.coverImage!,
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
              ),
            ),
          const SizedBox(height: 16),
          // Price
          Text(
            _formatPrice(property.price),
            style: AppTextStyles.priceLarge,
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            property.title,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 8),
          // Bedrooms Badge
          Row(
            children: [
              const Icon(
                Icons.bed,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${property.bedrooms} Bedrooms',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('View Details'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
