import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants/api_constants.dart';

/// GPS location service wrapper
/// Handles permissions, position retrieval, and continuous tracking
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LatLng> _locationController =
      StreamController<LatLng>.broadcast();

  /// Stream of location updates
  Stream<LatLng> get locationStream => _locationController.stream;

  /// Checks location access and only opens the OS prompt when requested.
  Future<bool> checkPermissions({bool requestPermission = false}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  Future<LatLng> getCurrentPosition({bool requestPermission = false}) async {
    final hasPermission =
        await checkPermissions(requestPermission: requestPermission);
    if (!hasPermission) {
      // Return default Jakarta coordinates if no permission
      return const LatLng(
        ApiConstants.defaultLat,
        ApiConstants.defaultLng,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return const LatLng(
        ApiConstants.defaultLat,
        ApiConstants.defaultLng,
      );
    }
  }

  /// Start continuous location tracking (for technician)
  /// Updates every 3-5 seconds
  void startTracking({
    int distanceFilter = 10, // meters
  }) {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    ).listen(
      (position) {
        _locationController.add(LatLng(position.latitude, position.longitude));
      },
      onError: (error) {
        // Silent fail — keep last known position
      },
    );
  }

  /// Stop location tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calculate distance between two points
  double distanceBetween(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        ) /
        1000; // Convert to km
  }

  /// Dispose streams
  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
