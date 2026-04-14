import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';

/// Current user position state
class LocationState {
  const LocationState({
    this.position,
    this.isLoading = false,
    this.error,
    this.permissionDenied = false,
    this.serviceDisabled = false,
  });

  final LatLng? position;
  final bool isLoading;
  final String? error;
  final bool permissionDenied;
  final bool serviceDisabled;

  LocationState copyWith({
    LatLng? position,
    bool? isLoading,
    String? error,
    bool? permissionDenied,
    bool? serviceDisabled,
  }) {
    return LocationState(
      position: position ?? this.position,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      serviceDisabled: serviceDisabled ?? this.serviceDisabled,
    );
  }
}

/// Provider that manages user location
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  StreamSubscription<Position>? _positionStream;

  /// Initialize location services and get current position
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          serviceDisabled: true,
          error: 'Los servicios de ubicación están desactivados',
          // Use Sevilla center as fallback
          position: AppConstants.defaultCenter,
        );
        return;
      }

      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            permissionDenied: true,
            error: 'Permisos de ubicación denegados',
            position: AppConstants.defaultCenter,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          permissionDenied: true,
          error: 'Permisos de ubicación denegados permanentemente',
          position: AppConstants.defaultCenter,
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      state = state.copyWith(
        isLoading: false,
        position: LatLng(position.latitude, position.longitude),
      );
    } on TimeoutException {
      state = state.copyWith(
        isLoading: false,
        error: 'Tiempo de espera agotado obteniendo ubicación',
        position: AppConstants.defaultCenter,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error obteniendo ubicación: ${e.toString()}',
        position: AppConstants.defaultCenter,
      );
    }
  }

  /// Start listening for position updates
  void startListening() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    ).listen(
      (position) {
        state = state.copyWith(
          position: LatLng(position.latitude, position.longitude),
        );
      },
      onError: (error) {
        // Keep last known position on error
      },
    );
  }

  /// Refresh location
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

/// Location state provider
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final notifier = LocationNotifier();
  notifier.initialize();
  return notifier;
});

/// Convenience provider for just the current position
final currentPositionProvider = Provider<LatLng?>((ref) {
  return ref.watch(locationProvider.select((s) => s.position));
});
