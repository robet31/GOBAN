# Goban 🔧

Platform panggil teknisi & cari lokasi tambal ban / service motor.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| App | Flutter (Dart) |
| State Management | flutter_bloc (BLoC) |
| Navigation | go_router |
| Database | SQLite (`sqflite` / SQLite-WASM on web) |
| Auth | Custom JWT (SHA-256 + flutter_secure_storage) |
| Maps | flutter_map + OpenStreetMap |
| Geocoding | Nominatim (OSM) |
| Image Storage | ImgBB |
| Push Notifications | ntfy.sh |
| Location | Geolocator |

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Dart SDK ≥ 3.5.0

### Setup
1. Clone the repository
2. Copy `.env.example` to `.env` and fill in your credentials:
   ```
    IMGBB_API_KEY=your-key
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
    flutter run
    ```

### Google Sign-In configuration

Before using Google Sign-In, configure OAuth clients in Google Cloud for the
following application identities:

- Android: package name `com.goban.goban`; register the SHA-1/SHA-256
  fingerprints for both the debug signing key and the release signing key.
- Web: create a Web application OAuth client and add each deployed web origin
  (and the local development origin) to its authorized JavaScript origins; add
  its public client ID through the `google_sign_in` web configuration outside
  committed source.

Do not commit OAuth client IDs, client secrets, signing keys, or generated
configuration files. The Google Cloud configuration is the remaining external
prerequisite for the Google button to complete authentication on a device or web.

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget (MultiBlocProvider)
├── core/
│   ├── constants/               # API keys, enums
│   ├── router/                  # GoRouter config, route paths
│   ├── theme/                   # Colors, Material theme
│   ├── utils/                   # Haversine, formatters, validators
│   └── widgets/                 # Shared widgets
├── models/                      # Data models (Equatable)
├── services/                    # External service wrappers
└── features/
    ├── auth/                    # Login, register, BLoC
    ├── map/                     # Map screen, markers, filters
    ├── orders/                  # Order lifecycle, history
    ├── technician/              # Dashboard, registration
    ├── locations/               # UGC location submission
    ├── profile/                 # User profile
    └── admin/                   # Admin dashboard
```

## Features

### Customer
- 🗺️ Interactive map with technician/shop markers
- 🔍 Filter by distance, rating, service type
- 📦 Order service (tambal ban, ganti oli, servis mesin)
- 📍 GPS-based location with reverse geocoding
- ⭐ Rate and review technicians
- 📱 Push notifications for order updates

### Teknisi / Mitra
- 🟢 Online/Offline toggle
- 📋 Incoming order management (accept/reject)
- 📊 Daily stats (orders, earnings, rating)
- 📄 Multi-step registration with document upload
- 🔔 Push notifications for new orders

### Admin
- 📊 Dashboard with stats overview
- ✅ Verify technician documents
- 📍 Moderate UGC locations
- 👥 Manage users (ban/unban)
- 📦 View all orders

## Architecture

- **BLoC Pattern** for state management
- **Clean Architecture** (features → services → models)
- **Local offline storage** with SQLite; remote synchronization is not configured
- **Role-Based Routing** via GoRouter redirect guards

## License

MIT
