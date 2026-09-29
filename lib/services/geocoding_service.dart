import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/api_constants.dart';

/// Nominatim (OpenStreetMap) geocoding service
/// Rate limited to 1 request per second
class GeocodingService {
  final Dio _dio;
  DateTime _lastRequestTime = DateTime(2000);
  final Map<String, dynamic> _cache = {};

  GeocodingService({Dio? dio}) : _dio = dio ?? Dio();

  String get _baseUrl =>
      dotenv.env[ApiConstants.nominatimBaseUrlKey] ??
      'https://nominatim.openstreetmap.org';

  /// Rate limit enforcement — wait if needed
  Future<void> _enforceRateLimit() async {
    final now = DateTime.now();
    final diff = now.difference(_lastRequestTime);
    if (diff < ApiConstants.nominatimRateLimit) {
      await Future.delayed(ApiConstants.nominatimRateLimit - diff);
    }
    _lastRequestTime = DateTime.now();
  }

  /// Forward geocoding: address text → lat/lng
  Future<List<GeocodingResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    // Check cache
    final cacheKey = 'search:${query.toLowerCase()}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<GeocodingResult>;
    }

    await _enforceRateLimit();

    try {
      final response = await _dio.get(
        '$_baseUrl${ApiConstants.nominatimSearchPath}',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
          'countrycodes': 'id', // Indonesia only
        },
        options: Options(
          headers: {'User-Agent': ApiConstants.userAgent},
        ),
      );

      if (response.statusCode == 200) {
        final results = (response.data as List)
            .map((item) => GeocodingResult.fromNominatim(item))
            .toList();
        _cache[cacheKey] = results;
        return results;
      }
    } catch (e) {
      // Silent fail — return empty
    }
    return [];
  }

  /// Reverse geocoding: lat/lng → address
  Future<String?> reverseGeocode(double lat, double lng) async {
    // Check cache
    final cacheKey =
        'reverse:${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as String?;
    }

    await _enforceRateLimit();

    try {
      final response = await _dio.get(
        '$_baseUrl${ApiConstants.nominatimReversePath}',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': ApiConstants.userAgent},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['display_name'] as String?;
        _cache[cacheKey] = address;
        return address;
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  /// Clear the geocoding cache
  void clearCache() {
    _cache.clear();
  }
}

/// Geocoding result from Nominatim
class GeocodingResult {
  final double lat;
  final double lng;
  final String displayName;
  final String? type;

  const GeocodingResult({
    required this.lat,
    required this.lng,
    required this.displayName,
    this.type,
  });

  factory GeocodingResult.fromNominatim(Map<String, dynamic> data) {
    return GeocodingResult(
      lat: double.parse(data['lat'] as String),
      lng: double.parse(data['lon'] as String),
      displayName: data['display_name'] as String,
      type: data['type'] as String?,
    );
  }
}
