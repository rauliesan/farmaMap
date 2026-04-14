import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/farmacia.dart';
import 'farmacias_provider.dart';

/// Search state
class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
  });

  final String query;
  final List<Farmacia> results;
  final bool isLoading;
  final String? error;
  final bool hasSearched;

  SearchState copyWith({
    String? query,
    List<Farmacia>? results,
    bool? isLoading,
    String? error,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

/// Search notifier with debounce
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());

  final Ref _ref;
  Timer? _debounceTimer;

  /// Update search query with debounce
  void updateQuery(String query) {
    state = state.copyWith(query: query);

    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: [],
        hasSearched: false,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _performSearch(query.trim()),
    );
  }

  /// Execute the search
  Future<void> _performSearch(String query) async {
    try {
      final repo = _ref.read(farmaciasRepositoryProvider);
      final results = await repo.search(query);

      // Only update if the query hasn't changed while we were loading
      if (state.query.trim() == query) {
        state = state.copyWith(
          results: results,
          isLoading: false,
          hasSearched: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasSearched: true,
        error: 'Error en la búsqueda: ${e.toString()}',
      );
    }
  }

  /// Clear search
  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Search provider
final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

// ─── Search History ──────────────────────────────────────────

/// Search history provider
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(AppConstants.keySearchHistory);
      if (stored != null) {
        final List<dynamic> items = jsonDecode(stored);
        state = items.cast<String>();
      }
    } catch (_) {
      state = [];
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keySearchHistory,
        jsonEncode(state),
      );
    } catch (_) {}
  }

  /// Add a search term to history
  void add(String query) {
    if (query.trim().isEmpty) return;
    final trimmed = query.trim();

    // Remove if already exists (to move to top)
    final updated = state.where((s) => s != trimmed).toList();
    updated.insert(0, trimmed);

    // Limit size
    if (updated.length > AppConstants.maxSearchHistory) {
      state = updated.sublist(0, AppConstants.maxSearchHistory);
    } else {
      state = updated;
    }
    _save();
  }

  /// Remove a specific entry
  void remove(String query) {
    state = state.where((s) => s != query).toList();
    _save();
  }

  /// Clear all history
  void clearAll() {
    state = [];
    _save();
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});
