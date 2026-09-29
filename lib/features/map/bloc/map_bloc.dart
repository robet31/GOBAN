import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' hide Haversine;
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/haversine.dart';
import '../../../models/technician_profile.dart';
import '../../../models/location_model.dart';
import '../../../services/database_service.dart';
import '../../../services/location_service.dart';
import 'map_event.dart';

/// Map BLoC — manages map markers, user location, and filtering
class MapBloc extends Bloc<MapEvent, MapState> {
  final DatabaseService _db;
  final LocationService _locationService;

  MapBloc({
    DatabaseService? db,
    LocationService? locationService,
  })  : _db = db ?? DatabaseService.instance,
        _locationService = locationService ?? LocationService(),
        super(const MapInitial()) {
    on<MapLoadMarkers>(_onLoadMarkers);
    on<MapLocationUpdated>(_onLocationUpdated);
    on<MapFilterChanged>(_onFilterChanged);
    on<MapMarkerTapped>(_onMarkerTapped);
  }

  Future<void> _onLoadMarkers(
    MapLoadMarkers event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    try {
      // Get user position
      final userPos = await _locationService.getCurrentPosition();

      // Load technicians
      final techRows = await _db.query(
        'SELECT * FROM technician_profiles WHERE is_online = 1 AND is_verified = 1',
      );
      final technicians =
          techRows.map((r) => TechnicianProfile.fromMap(r)).toList();

      // Load approved UGC locations
      final locRows = await _db.query(
        "SELECT * FROM locations WHERE status = 'approved'",
      );
      final locations = locRows.map((r) => LocationModel.fromMap(r)).toList();

      // Convert to markers
      final markers = <MarkerData>[];

      for (final tech in technicians) {
        final dist = Haversine.distance(
          userPos.latitude,
          userPos.longitude,
          tech.lat,
          tech.lng,
        );
        markers.add(MarkerData(
          id: 'tech_${tech.id}',
          type: MarkerType.technician,
          position: LatLng(tech.lat, tech.lng),
          name: tech.shopName ?? 'Teknisi',
          rating: tech.ratingAvg,
          reviewCount: tech.totalOrders,
          distanceKm: dist,
          priceEstimate: tech.priceEstimate,
          services: tech.services,
          photoUrl: tech.shopPhotoUrl,
          isOnline: tech.isOnline,
          technicianProfile: tech,
        ));
      }

      for (final loc in locations) {
        final dist = Haversine.distance(
          userPos.latitude,
          userPos.longitude,
          loc.lat,
          loc.lng,
        );
        markers.add(MarkerData(
          id: 'loc_${loc.id}',
          type: MarkerType.crowdsourced,
          position: LatLng(loc.lat, loc.lng),
          name: loc.name,
          distanceKm: dist,
          photoUrl: loc.photoUrl,
          locationModel: loc,
        ));
      }

      // Sort by distance
      markers
          .sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));

      emit(MapLoaded(
        userPosition: userPos,
        markers: markers,
      ));
    } catch (e) {
      emit(MapError('Gagal memuat peta: $e'));
    }
  }

  Future<void> _onLocationUpdated(
    MapLocationUpdated event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final current = state as MapLoaded;
      // Recalculate distances
      final updatedMarkers = current.markers.map((m) {
        final dist = Haversine.distance(
          event.position.latitude,
          event.position.longitude,
          m.position.latitude,
          m.position.longitude,
        );
        return MarkerData(
          id: m.id,
          type: m.type,
          position: m.position,
          name: m.name,
          rating: m.rating,
          reviewCount: m.reviewCount,
          distanceKm: dist,
          priceEstimate: m.priceEstimate,
          services: m.services,
          photoUrl: m.photoUrl,
          isOnline: m.isOnline,
          technicianProfile: m.technicianProfile,
          locationModel: m.locationModel,
        );
      }).toList();

      emit(current.copyWith(
        userPosition: event.position,
        markers: updatedMarkers,
      ));
    }
  }

  void _onFilterChanged(
    MapFilterChanged event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final current = state as MapLoaded;
      emit(current.copyWith(filter: event.filter));
    }
  }

  void _onMarkerTapped(
    MapMarkerTapped event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final current = state as MapLoaded;
      emit(current.copyWith(selectedMarker: event.marker));
    }
  }

  /// Get filtered markers based on current filter
  List<MarkerData> getFilteredMarkers(MapLoaded state) {
    var markers = state.markers;
    final filter = state.filter;

    if (filter.maxDistanceKm != null) {
      markers = markers
          .where((m) => (m.distanceKm ?? 0) <= filter.maxDistanceKm!)
          .toList();
    }
    if (filter.minRating != null) {
      markers =
          markers.where((m) => (m.rating ?? 0) >= filter.minRating!).toList();
    }
    if (filter.serviceType != null) {
      markers = markers.where((m) {
        if (m.services != null) {
          return m.services!.contains(filter.serviceType);
        }
        return true;
      }).toList();
    }
    if (filter.maxPrice != null) {
      markers = markers
          .where((m) => (m.priceEstimate ?? 0) <= filter.maxPrice!)
          .toList();
    }

    return markers;
  }
}
