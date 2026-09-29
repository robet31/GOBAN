import 'package:equatable/equatable.dart';
import '../core/constants/enums.dart';

/// UGC Location model — user-generated shop pins
class LocationModel extends Equatable {
  final int? id;
  final String name;
  final double lat;
  final double lng;
  final LocationCategory category;
  final String? address;
  final String? phone;
  final String? photoUrl;
  final String addedBy;
  final LocationStatus status;
  final DateTime createdAt;

  // Joined fields
  final String? addedByName;

  const LocationModel({
    this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.category,
    this.address,
    this.phone,
    this.photoUrl,
    required this.addedBy,
    this.status = LocationStatus.pending,
    required this.createdAt,
    this.addedByName,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      category: LocationCategory.fromDbValue(map['category'] as String),
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      photoUrl: map['photo_url'] as String?,
      addedBy: map['added_by'] as String,
      status: LocationStatus.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      addedByName: map['added_by_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'category': category.dbValue,
      'address': address,
      'phone': phone,
      'photo_url': photoUrl,
      'added_by': addedBy,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LocationModel copyWith({
    int? id,
    String? name,
    double? lat,
    double? lng,
    LocationCategory? category,
    String? address,
    String? phone,
    String? photoUrl,
    String? addedBy,
    LocationStatus? status,
    DateTime? createdAt,
    String? addedByName,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      category: category ?? this.category,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      addedBy: addedBy ?? this.addedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      addedByName: addedByName ?? this.addedByName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        lat,
        lng,
        category,
        address,
        phone,
        photoUrl,
        addedBy,
        status,
        createdAt,
      ];
}
