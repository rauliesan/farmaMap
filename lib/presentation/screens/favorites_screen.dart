import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/extensions/num_extensions.dart';
import '../../data/models/farmacia.dart';
import '../providers/farmacias_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/farmacia_card.dart';
import '../widgets/loading_shimmer.dart';

/// Screen showing favorited pharmacies
class FavoritosScreen extends ConsumerWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final allFarmaciasAsync = ref.watch(allFarmaciasProvider(0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (favoriteIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _showClearDialog(context, ref),
            ),
        ],
      ),
      body: _buildBody(context, ref, favoriteIds, allFarmaciasAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Set<int> favoriteIds,
    AsyncValue<List<Farmacia>> allFarmaciasAsync,
  ) {
    if (favoriteIds.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.favorite_border_rounded,
        title: 'Sin favoritos',
        subtitle: 'Marca farmacias como favoritas para acceder rápidamente a ellas',
      );
    }

    return allFarmaciasAsync.when(
      loading: () => const LoadingShimmer(itemCount: 5),
      error: (error, _) => Center(
        child: Text('Error: $error', style: context.textTheme.bodyMedium),
      ),
      data: (allFarmacias) {
        final favorites = allFarmacias
            .where((f) => favoriteIds.contains(f.id))
            .toList();

        // Sort by distance if location available
        final userPos = ref.read(currentPositionProvider);
        if (userPos != null) {
          favorites.sort((a, b) {
            final distA = NumExtensions.distanceBetween(
              userPos.latitude, userPos.longitude, a.lat, a.lng,
            );
            final distB = NumExtensions.distanceBetween(
              userPos.latitude, userPos.longitude, b.lat, b.lng,
            );
            return distA.compareTo(distB);
          });
        }

        if (favorites.isEmpty) {
          // Favorites exist but not in current page — show message
          return const EmptyStateWidget(
            icon: Icons.favorite_border_rounded,
            title: 'Cargando favoritos...',
            subtitle: 'Tus farmacias favoritas se están cargando',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final farmacia = favorites[index];
            double? distance;
            if (userPos != null) {
              distance = NumExtensions.distanceBetween(
                userPos.latitude,
                userPos.longitude,
                farmacia.lat,
                farmacia.lng,
              );
            }

            return FarmaciaCard(
              farmacia: farmacia,
              distanceMeters: distance,
              isFavorite: true,
              animationIndex: index,
              onTap: () {
                context.push('/detail/${farmacia.id}', extra: farmacia);
              },
              onFavoriteToggle: () {
                ref.read(favoritesProvider.notifier).toggle(farmacia.id);
              },
            );
          },
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar favoritos'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearAll();
              Navigator.pop(dialogContext);
              context.showSnackBar('Favoritos eliminados');
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }
}
