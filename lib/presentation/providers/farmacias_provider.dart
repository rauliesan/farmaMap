import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/supabase_farmacias_datasource.dart';
import '../../data/models/farmacia.dart';
import '../../data/repositories/farmacias_repository.dart';
import '../../data/repositories/farmacias_repository_impl.dart';
import 'location_provider.dart';

// ─── Infrastructure Providers ────────────────────────────────

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Datasource provider
final farmaciasDatasourceProvider = Provider<SupabaseFarmaciasDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseFarmaciasDatasource(client);
});

/// Repository provider
final farmaciasRepositoryProvider = Provider<FarmaciasRepository>((ref) {
  final datasource = ref.watch(farmaciasDatasourceProvider);
  return FarmaciasRepositoryImpl(datasource);
});

// ─── Selected Radius ─────────────────────────────────────────

/// Currently selected search radius (in meters)
final selectedRadiusProvider = StateProvider<double>((ref) {
  return AppConstants.defaultRadius;
});

// ─── Farmacias Data Providers ────────────────────────────────

/// All farmacias (paginated)
final allFarmaciasProvider = FutureProvider.autoDispose
    .family<List<Farmacia>, int>((ref, page) async {
  final repo = ref.watch(farmaciasRepositoryProvider);
  final offset = page * AppConstants.pageSize;
  return repo.getAll(offset: offset, limit: AppConstants.pageSize);
});

/// Nearby farmacias based on user location and selected radius
final nearbyFarmaciasProvider =
    FutureProvider.autoDispose<List<Farmacia>>((ref) async {
  final position = ref.watch(currentPositionProvider);
  final radius = ref.watch(selectedRadiusProvider);
  final repo = ref.watch(farmaciasRepositoryProvider);

  if (position == null) return [];

  return repo.getNearby(
    lat: position.latitude,
    lng: position.longitude,
    radiusMeters: radius,
  );
});

/// All farmacias for the map (no pagination, get a reasonable set)
final mapFarmaciasProvider =
    FutureProvider.autoDispose<List<Farmacia>>((ref) async {
  final position = ref.watch(currentPositionProvider);
  final radius = ref.watch(selectedRadiusProvider);
  final repo = ref.watch(farmaciasRepositoryProvider);

  if (position == null) {
    // If no location, get all farmacias (up to 1000)
    return repo.getAll(offset: 0, limit: 1000);
  }

  return repo.getNearby(
    lat: position.latitude,
    lng: position.longitude,
    radiusMeters: radius,
  );
});

/// Accumulated list of farmacias for infinite scroll
class FarmaciasListNotifier extends StateNotifier<FarmaciasListState> {
  FarmaciasListNotifier(this._repository)
      : super(const FarmaciasListState());

  final FarmaciasRepository _repository;

  /// Load initial page
  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final farmacias = await _repository.getAll(
        offset: 0,
        limit: AppConstants.pageSize,
      );
      state = state.copyWith(
        farmacias: farmacias,
        currentPage: 0,
        hasMore: farmacias.length >= AppConstants.pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar farmacias: ${e.toString()}',
      );
    }
  }

  /// Load next page
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final farmacias = await _repository.getAll(
        offset: nextPage * AppConstants.pageSize,
        limit: AppConstants.pageSize,
      );

      state = state.copyWith(
        farmacias: [...state.farmacias, ...farmacias],
        currentPage: nextPage,
        hasMore: farmacias.length >= AppConstants.pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando más farmacias: ${e.toString()}',
      );
    }
  }

  /// Refresh the list from scratch
  Future<void> refresh() async {
    state = const FarmaciasListState();
    await loadInitial();
  }
}

/// State for the paginated farmacias list
class FarmaciasListState {
  const FarmaciasListState({
    this.farmacias = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  final List<Farmacia> farmacias;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  FarmaciasListState copyWith({
    List<Farmacia>? farmacias,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return FarmaciasListState(
      farmacias: farmacias ?? this.farmacias,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for paginated farmacias list
final farmaciasListProvider =
    StateNotifierProvider<FarmaciasListNotifier, FarmaciasListState>((ref) {
  final repo = ref.watch(farmaciasRepositoryProvider);
  final notifier = FarmaciasListNotifier(repo);
  notifier.loadInitial();
  return notifier;
});
