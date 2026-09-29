import 'dart:math' as math;

/// Haversine formula to calculate distance between two geographic coordinates
/// Returns distance in kilometers
class Haversine {
  Haversine._();

  static const double _earthRadiusKm = 6371.0;

  /// Calculate distance between two points in kilometers
  static double distance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Estimate travel time in minutes based on straight-line distance
  /// Assumes average speed of 30 km/h for urban motorcycle travel
  static double estimateTimeMinutes(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    double speedKmh = 30.0,
  }) {
    final dist = distance(lat1, lon1, lat2, lon2);
    return (dist / speedKmh) * 60;
  }

  /// Check if a point is within a given radius
  static bool isWithinRadius(
    double centerLat,
    double centerLon,
    double pointLat,
    double pointLon,
    double radiusKm,
  ) {
    return distance(centerLat, centerLon, pointLat, pointLon) <= radiusKm;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
