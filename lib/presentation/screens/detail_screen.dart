import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/farmacia.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/pharmacy_marker.dart';

/// Detail screen for a single pharmacy
class DetailScreen extends ConsumerWidget {
  const DetailScreen({
    super.key,
    required this.farmaciaId,
    this.farmacia,
  });

  final int farmaciaId;
  final Farmacia? farmacia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use passed farmacia or show loading
    if (farmacia == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final f = farmacia!;
    final isFav = ref.watch(isFavoriteProvider(f.id));
    final userPos = ref.watch(currentPositionProvider);

    double? distance;
    if (userPos != null) {
      distance = NumExtensions.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        f.lat,
        f.lng,
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with mini map
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: _buildBackButton(context),
            actions: [
              _buildFavoriteButton(context, ref, f, isFav),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMiniMap(f),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    f.displayNombre,
                    style: context.textTheme.headlineSmall,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, duration: 400.ms),

                  const SizedBox(height: 16),

                  // Address card
                  _buildInfoCard(
                    context,
                    icon: Icons.location_on_rounded,
                    title: 'Dirección',
                    content: f.direccion,
                    delay: 100,
                  ),

                  // Distance card
                  if (distance != null)
                    _buildInfoCard(
                      context,
                      icon: Icons.directions_walk_rounded,
                      title: 'Distancia',
                      content: 'A ${distance.toDistanceString()} de tu ubicación',
                      delay: 200,
                    ),

                  // Coordinates card
                  _buildInfoCard(
                    context,
                    icon: Icons.explore_rounded,
                    title: 'Coordenadas',
                    content: '${f.lat.toStringAsFixed(6)}, ${f.lng.toStringAsFixed(6)}',
                    delay: 300,
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActions(context, ref, f),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: context.colorScheme.surface.withValues(alpha: 0.9),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(
    BuildContext context,
    WidgetRef ref,
    Farmacia f,
    bool isFav,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: context.colorScheme.surface.withValues(alpha: 0.9),
        child: IconButton(
          icon: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 20,
            color: isFav ? AppColors.favorite : null,
          ),
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggle(f.id);
            context.showSnackBar(
              isFav ? 'Eliminado de favoritos' : 'Añadido a favoritos',
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniMap(Farmacia f) {
    return IgnorePointer(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(f.lat, f.lng),
          initialZoom: 16,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.osmTileUrl,
            userAgentPackageName: 'com.farmamap.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(f.lat, f.lng),
                width: 50,
                height: 58,
                child: const PharmacyMarker(size: 50, isSelected: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    int delay = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms, delay: delay.ms);
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Farmacia f) {
    return Column(
      children: [
        // Directions button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openDirections(context, f),
            icon: const Icon(Icons.directions_rounded),
            label: const Text('Cómo llegar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 400.ms),

        const SizedBox(height: 12),

        // Copy address button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _copyAddress(context, f),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar dirección'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms),
      ],
    );
  }

  Future<void> _openDirections(BuildContext context, Farmacia f) async {
    final String url;

    if (Platform.isIOS) {
      url = AppConstants.appleMapsDirectionsUrl(f.lat, f.lng);
    } else {
      url = AppConstants.googleMapsDirectionsUrl(f.lat, f.lng);
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          context.showSnackBar('No se pudo abrir la aplicación de mapas', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Error al abrir navegación: $e', isError: true);
      }
    }
  }

  void _copyAddress(BuildContext context, Farmacia f) {
    Clipboard.setData(ClipboardData(text: f.direccion));
    context.showSnackBar('Dirección copiada al portapapeles');
  }
}
