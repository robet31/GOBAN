import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/technician_profile.dart';
import '../../../models/location_model.dart';

// ─── Events ───

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapLoadMarkers extends MapEvent {
  const MapLoadMarkers();
}

class MapLocationUpdated extends MapEvent {
  final LatLng position;
  const MapLocationUpdated(this.position);
  @override
  List<Object?> get props => [position];
}

class MapFilterChanged extends MapEvent {
  final MapFilter filter;
  const MapFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class MapMarkerTapped extends MapEvent {
  final MarkerData marker;
  const MapMarkerTapped(this.marker);
  @override
  List<Object?> get props => [marker];
}

// ─── States ───

abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final LatLng userPosition;
  final List<MarkerData> markers;
  final MapFilter filter;
  final MarkerData? selectedMarker;

  const MapLoaded({
    required this.userPosition,
    required this.markers,
    this.filter = const MapFilter(),
    this.selectedMarker,
  });

  MapLoaded copyWith({
    LatLng? userPosition,
    List<MarkerData>? markers,
    MapFilter? filter,
    MarkerData? selectedMarker,
  }) {
    return MapLoaded(
      userPosition: userPosition ?? this.userPosition,
      markers: markers ?? this.markers,
      filter: filter ?? this.filter,
      selectedMarker: selectedMarker,
    );
  }

  @override
  List<Object?> get props => [userPosition, markers, filter, selectedMarker];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Data Classes ───

enum MarkerType { technician, location, crowdsourced }

class MarkerData extends Equatable {
  final String id;
  final MarkerType type;
  final LatLng position;
  final String name;
  final double? rating;
  final int? reviewCount;
  final double? distanceKm;
  final int? priceEstimate;
  final List<String>? services;
  final String? photoUrl;
  final bool? isOnline;

  // Source data reference
  final TechnicianProfile? technicianProfile;
  final LocationModel? locationModel;

  const MarkerData({
    required this.id,
    required this.type,
    required this.position,
    required this.name,
    this.rating,
    this.reviewCount,
    this.distanceKm,
    this.priceEstimate,
    this.services,
    this.photoUrl,
    this.isOnline,
    this.technicianProfile,
    this.locationModel,
  });

  @override
  List<Object?> get props => [id, type, position, name];
}

class MapFilter extends Equatable {
  final double? maxDistanceKm;
  final double? minRating;
  final String? serviceType;
  final int? maxPrice;

  const MapFilter({
    this.maxDistanceKm,
    this.minRating,
    this.serviceType,
    this.maxPrice,
  });

  MapFilter copyWith({
    double? maxDistanceKm,
    double? minRating,
    String? serviceType,
    int? maxPrice,
  }) {
    return MapFilter(
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minRating: minRating ?? this.minRating,
      serviceType: serviceType ?? this.serviceType,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  bool get hasActiveFilters =>
      maxDistanceKm != null ||
      minRating != null ||
      serviceType != null ||
      maxPrice != null;

  @override
  List<Object?> get props => [maxDistanceKm, minRating, serviceType, maxPrice];
}
