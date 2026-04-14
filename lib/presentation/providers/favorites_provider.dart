import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Manages favorite pharmacy IDs persisted locally
class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(AppConstants.keyFavorites);
      if (stored != null) {
        final List<dynamic> ids = jsonDecode(stored);
        state = ids.map((e) => e as int).toSet();
      }
    } catch (_) {
      // Silently handle corrupted data
      state = {};
    }
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyFavorites,
        jsonEncode(state.toList()),
      );
    } catch (_) {
      // Silently handle save errors
    }
  }

  /// Toggle a pharmacy's favorite status
  void toggle(int farmaciaId) {
    if (state.contains(farmaciaId)) {
      state = {...state}..remove(farmaciaId);
    } else {
      state = {...state, farmaciaId};
    }
    _saveFavorites();
  }

  /// Check if a pharmacy is favorited
  bool isFavorite(int farmaciaId) => state.contains(farmaciaId);

  /// Remove a specific favorite
  void remove(int farmaciaId) {
    state = {...state}..remove(farmaciaId);
    _saveFavorites();
  }

  /// Clear all favorites
  void clearAll() {
    state = {};
    _saveFavorites();
  }
}

/// Favorites provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

/// Check if a specific pharmacy is favorited
final isFavoriteProvider = Provider.family<bool, int>((ref, id) {
  return ref.watch(favoritesProvider).contains(id);
});
