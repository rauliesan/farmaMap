import 'package:latlong2/latlong.dart';

/// Global application constants
class AppConstants {
  AppConstants._();

  // ─── Map defaults ──────────────────────────────────────────
  /// Default center: Sevilla, Spain
  static const LatLng defaultCenter = LatLng(37.3886, -5.9823);

  /// Default zoom level
  static const double defaultZoom = 13.0;

  /// Min/Max zoom
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;

  // ─── Radius options (meters) ───────────────────────────────
  static const List<double> radiusOptions = [500, 1000, 2000, 5000];
  static const double defaultRadius = 2000;

  /// Human-readable radius labels
  static final Map<double, String> radiusLabels = {
    500: '500 m',
    1000: '1 km',
    2000: '2 km',
    5000: '5 km',
  };

  // ─── Pagination ────────────────────────────────────────────
  static const int pageSize = 20;

  // ─── Search ────────────────────────────────────────────────
  static const int searchDebounceMs = 300;
  static const int maxSearchHistory = 10;

  // ─── Storage Keys ──────────────────────────────────────────
  static const String keyFavorites = 'farmamap_favorites';
  static const String keySearchHistory = 'farmamap_search_history';
  static const String keyThemeMode = 'farmamap_theme_mode';
  static const String keySelectedRadius = 'farmamap_selected_radius';

  // ─── OpenStreetMap ─────────────────────────────────────────
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmAttribution = '© OpenStreetMap contributors';

  // ─── Navigation URLs ──────────────────────────────────────
  static String googleMapsDirectionsUrl(double lat, double lng) =>
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

  static String appleMapsDirectionsUrl(double lat, double lng) =>
      'https://maps.apple.com/?daddr=$lat,$lng';
}
