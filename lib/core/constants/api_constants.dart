// Core Constants - API Constants
// All API endpoints and configuration keys

class ApiConstants {
  ApiConstants._();

  // ImgBB
  static const String imgbbApiKeyKey = 'IMGBB_API_KEY';
  static const String imgbbUploadUrl = 'https://api.imgbb.com/1/upload';

  // iPaymu
  static const String ipaymuVaKey = 'IPAYMU_VA';
  static const String ipaymuApiKeyKey = 'IPAYMU_API_KEY';
  static const String ipaymuIsSandboxKey = 'IPAYMU_IS_SANDBOX';
  static const String ipaymuSandboxUrl =
      'https://sandbox.ipaymu.com/api/v2/payment';
  static const String ipaymuProductionUrl =
      'https://my.ipaymu.com/api/v2/payment';

  // Nominatim (OpenStreetMap Geocoding)
  static const String nominatimBaseUrlKey = 'NOMINATIM_BASE_URL';
  static const String nominatimSearchPath = '/search';
  static const String nominatimReversePath = '/reverse';

  // ntfy.sh (Push Notifications)
  static const String ntfyBaseUrlKey = 'NTFY_BASE_URL';
  static const String ntfyDefaultTopic = 'goban-notifications';

  // JWT
  static const String jwtSecretKey = 'JWT_SECRET';
  static const Duration jwtExpiration = Duration(days: 30);

  // Map
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgent = 'com.goban.app';

  // Default coordinates (Jakarta)
  static const double defaultLat = -6.2088;
  static const double defaultLng = 106.8456;
  static const double defaultZoom = 13.0;

  // Search radius
  static const double maxSearchRadiusKm = 10.0;
  static const double defaultSearchRadiusKm = 5.0;

  // Rate limiting
  static const Duration nominatimRateLimit = Duration(seconds: 1);
}
