import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/num_extensions.dart';
import '../../data/models/farmacia.dart';
import '../providers/farmacias_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/farmacia_card.dart';
import '../widgets/loading_shimmer.dart';

/// List screen showing pharmacies sorted by distance
class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(farmaciasListProvider.notifier).loadMore();
    }
  }

  double? _distanceTo(Farmacia farmacia) {
    final userPos = ref.read(currentPositionProvider);
    if (userPos == null) return null;
    return NumExtensions.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      farmacia.lat,
      farmacia.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(farmaciasListProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmacias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: _buildBody(listState, favorites),
    );
  }

  Widget _buildBody(FarmaciasListState listState, Set<int> favorites) {
    if (listState.farmacias.isEmpty && listState.isLoading) {
      return const LoadingShimmer(itemCount: 8);
    }

    if (listState.error != null && listState.farmacias.isEmpty) {
      return ErrorStateWidget(
        message: listState.error!,
        onRetry: () => ref.read(farmaciasListProvider.notifier).refresh(),
      );
    }

    if (listState.farmacias.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.local_pharmacy_outlined,
        title: 'No hay farmacias',
        subtitle: 'No se encontraron farmacias en esta zona',
      );
    }

    // Sort by distance if location is available
    final userPos = ref.read(currentPositionProvider);
    final sorted = List<Farmacia>.from(listState.farmacias);
    if (userPos != null) {
      sorted.sort((a, b) {
        final distA = NumExtensions.distanceBetween(
          userPos.latitude, userPos.longitude, a.lat, a.lng,
        );
        final distB = NumExtensions.distanceBetween(
          userPos.latitude, userPos.longitude, b.lat, b.lng,
        );
        return distA.compareTo(distB);
      });
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(farmaciasListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: sorted.length + (listState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= sorted.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final farmacia = sorted[index];
          final distance = _distanceTo(farmacia);
          final isFav = favorites.contains(farmacia.id);

          return FarmaciaCard(
            farmacia: farmacia,
            distanceMeters: distance,
            isFavorite: isFav,
            animationIndex: index,
            onTap: () {
              context.push('/detail/${farmacia.id}', extra: farmacia);
            },
            onFavoriteToggle: () {
              ref.read(favoritesProvider.notifier).toggle(farmacia.id);
            },
          );
        },
      ),
    );
  }
}
