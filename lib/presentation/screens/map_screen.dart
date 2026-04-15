import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farmacia.dart';
import '../providers/auth_provider.dart';
import '../providers/farmacias_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/add_farmacia_bottom_sheet.dart';
import '../widgets/farmacia_bottom_sheet.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/pharmacy_marker.dart';
import '../widgets/radius_selector.dart';
import '../widgets/user_location_marker.dart';

/// Main map screen showing pharmacies on an interactive map
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _mapController;
  Farmacia? _selectedFarmacia;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnUser() {
    final position = ref.read(currentPositionProvider);
    if (position != null) {
      _mapController.move(position, 15.0);
    } else {
      context.showSnackBar(
        'Ubicación no disponible',
        isError: true,
      );
    }
  }

  void _onMarkerTap(Farmacia farmacia) {
    setState(() => _selectedFarmacia = farmacia);

    final userPos = ref.read(currentPositionProvider);
    double? distance;
    if (userPos != null) {
      distance = NumExtensions.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        farmacia.lat,
        farmacia.lng,
      );
    }

    FarmaciaBottomSheet.show(
      context,
      farmacia: farmacia,
      distanceMeters: distance,
      onDetailsTap: () {
        Navigator.of(context).pop();
        context.push('/detail/${farmacia.id}', extra: farmacia);
      },
      onDirectionsTap: () {
        Navigator.of(context).pop();
        _openDirections(farmacia);
      },
    ).then((_) {
      setState(() => _selectedFarmacia = null);
    });
  }

  Future<void> _openDirections(Farmacia farmacia) async {
    final url = AppConstants.googleMapsDirectionsUrl(farmacia.lat, farmacia.lng);
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          context.showSnackBar('No se pudo abrir la aplicación de mapas', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error al abrir navegación', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-center the map exactly on the user when the location becomes available the first time
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if ((previous == null || previous.position == null) && next.position != null) {
        _mapController.move(next.position!, 15.0);
      }
    });

    final locationState = ref.watch(locationProvider);
    final farmaciasAsync = ref.watch(mapFarmaciasProvider);
    final selectedRadius = ref.watch(selectedRadiusProvider);
    final userPosition = locationState.position;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          farmaciasAsync.when(
            data: (farmacias) => _buildMap(
              farmacias: farmacias,
              userPosition: userPosition,
              selectedRadius: selectedRadius,
            ),
            loading: () => const MapLoadingShimmer(),
            error: (error, _) => _buildMap(
              farmacias: [],
              userPosition: userPosition,
              selectedRadius: selectedRadius,
            ),
          ),

          // Top bar with search + actions
          Positioned(
            top: context.topPadding + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // Radius selector
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: RadiusSelector(
              selectedRadius: selectedRadius,
              onChanged: (radius) {
                ref.read(selectedRadiusProvider.notifier).state = radius;
              },
            ),
          ),

          // Pharmacy count badge
          Positioned(
            bottom: 148,
            left: 0,
            right: 0,
            child: Center(
              child: farmaciasAsync.when(
                data: (farmacias) => _buildCountBadge(farmacias.length),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),

      // FAB: center on user & add pharmacy
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ref.watch(isAdminProvider))
            FloatingActionButton(
              heroTag: 'add_farmacia',
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                final userPos = ref.read(currentPositionProvider);
                if (userPos != null) {
                  AddFarmaciaBottomSheet.show(
                    context,
                    lat: userPos.latitude,
                    lng: userPos.longitude,
                  );
                } else {
                  context.showSnackBar(
                    'Buscando ubicación actual...',
                    isError: true,
                  );
                }
              },
              child: const Icon(Icons.add_location_alt_rounded),
            ),
          if (ref.watch(isAdminProvider)) const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'center_location',
            onPressed: _centerOnUser,
            child: locationState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location_rounded, size: 20),
          ),
          const SizedBox(height: 60),
        ],
      ),

      // Bottom navigation
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMap({
    required List<Farmacia> farmacias,
    required LatLng? userPosition,
    required double selectedRadius,
  }) {
    final center = userPosition ?? AppConstants.defaultCenter;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: AppConstants.defaultZoom,
        minZoom: AppConstants.minZoom,
        maxZoom: AppConstants.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) {
          // Deseleccionar farmacia si se toca en una zona vacía del mapa
          if (_selectedFarmacia != null) {
            setState(() => _selectedFarmacia = null);
          }
        },
        onLongPress: (tapPosition, point) {
          if (ref.read(isAdminProvider)) {
            AddFarmaciaBottomSheet.show(
              context,
              lat: point.latitude,
              lng: point.longitude,
            );
          }
        },
      ),
      children: [
        // OSM Tile Layer
        TileLayer(
          urlTemplate: AppConstants.osmTileUrl,
          userAgentPackageName: 'com.farmamap.app',
          maxZoom: 19,
        ),

        // Radius circle
        if (userPosition != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: userPosition,
                radius: selectedRadius,
                useRadiusInMeter: true,
                color: AppColors.radiusFill,
                borderColor: AppColors.radiusStroke.withValues(alpha: 0.4),
                borderStrokeWidth: 2,
              ),
            ],
          ),

        // User location marker
        if (userPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userPosition,
                width: 72,
                height: 72,
                child: const UserLocationMarker(),
              ),
            ],
          ),

        // Pharmacy markers (drawn after user location so they are clickable)
        MarkerLayer(
          markers: farmacias
              .where((f) => f.hasValidCoordinates)
              .map((farmacia) => Marker(
                    point: LatLng(farmacia.lat, farmacia.lng),
                    width: 40,
                    height: 48,
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(farmacia),
                      child: PharmacyMarker(
                        isSelected: _selectedFarmacia?.id == farmacia.id,
                      ),
                    ),
                  ))
              .toList(),
        ),

        // Attribution
        const RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Search button
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: context.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Buscar farmacia...',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        '$count farmacias encontradas',
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break; // Already on map
          case 1:
            context.push('/list');
            break;
          case 2:
            context.push('/profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt_rounded),
          label: 'Lista',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
