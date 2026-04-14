import 'dart:math' as math;

/// Extensions on num for distance formatting and math utilities
extension NumExtensions on num {
  /// Format distance in meters to a human-readable string
  /// e.g. 450 → "450 m", 1500 → "1,5 km"
  String toDistanceString() {
    if (this < 1000) {
      return '${toInt()} m';
    } else {
      final km = this / 1000;
      return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
    }
  }

  /// Calculate distance between two geo points using Haversine formula
  /// Returns distance in meters
  static double distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
}
