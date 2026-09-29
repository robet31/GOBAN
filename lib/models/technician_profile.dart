import 'package:equatable/equatable.dart';
import 'dart:convert';

/// Technician profile model with shop info, services, and verification status
class TechnicianProfile extends Equatable {
  final String id;
  final String? shopName;
  final double lat;
  final double lng;
  final String? address;
  final List<String> services;
  final int? priceEstimate;
  final bool isOnline;
  final bool isVerified;
  final String? ktpUrl;
  final String? simUrl;
  final String? stnkUrl;
  final String? shopPhotoUrl;
  final double ratingAvg;
  final int totalOrders;
  final DateTime createdAt;

  const TechnicianProfile({
    required this.id,
    this.shopName,
    required this.lat,
    required this.lng,
    this.address,
    this.services = const [],
    this.priceEstimate,
    this.isOnline = false,
    this.isVerified = false,
    this.ktpUrl,
    this.simUrl,
    this.stnkUrl,
    this.shopPhotoUrl,
    this.ratingAvg = 0,
    this.totalOrders = 0,
    required this.createdAt,
  });

  factory TechnicianProfile.fromMap(Map<String, dynamic> map) {
    List<String> parseServices(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.cast<String>();
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded.cast<String>();
        } catch (_) {}
        return [];
      }
      return [];
    }

    return TechnicianProfile(
      id: map['id'] as String,
      shopName: map['shop_name'] as String?,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      address: map['address'] as String?,
      services: parseServices(map['services']),
      priceEstimate: map['price_estimate'] as int?,
      isOnline: (map['is_online'] as int? ?? 0) == 1,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      ktpUrl: map['ktp_url'] as String?,
      simUrl: map['sim_url'] as String?,
      stnkUrl: map['stnk_url'] as String?,
      shopPhotoUrl: map['shop_photo_url'] as String?,
      ratingAvg: (map['rating_avg'] as num? ?? 0).toDouble(),
      totalOrders: map['total_orders'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'lat': lat,
      'lng': lng,
      'address': address,
      'services': jsonEncode(services),
      'price_estimate': priceEstimate,
      'is_online': isOnline ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'ktp_url': ktpUrl,
      'sim_url': simUrl,
      'stnk_url': stnkUrl,
      'shop_photo_url': shopPhotoUrl,
      'rating_avg': ratingAvg,
      'total_orders': totalOrders,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TechnicianProfile copyWith({
    String? id,
    String? shopName,
    double? lat,
    double? lng,
    String? address,
    List<String>? services,
    int? priceEstimate,
    bool? isOnline,
    bool? isVerified,
    String? ktpUrl,
    String? simUrl,
    String? stnkUrl,
    String? shopPhotoUrl,
    double? ratingAvg,
    int? totalOrders,
    DateTime? createdAt,
  }) {
    return TechnicianProfile(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      services: services ?? this.services,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      ktpUrl: ktpUrl ?? this.ktpUrl,
      simUrl: simUrl ?? this.simUrl,
      stnkUrl: stnkUrl ?? this.stnkUrl,
      shopPhotoUrl: shopPhotoUrl ?? this.shopPhotoUrl,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopName,
        lat,
        lng,
        address,
        services,
        priceEstimate,
        isOnline,
        isVerified,
        ktpUrl,
        simUrl,
        stnkUrl,
        shopPhotoUrl,
        ratingAvg,
        totalOrders,
        createdAt,
      ];
}
