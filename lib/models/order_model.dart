import 'package:equatable/equatable.dart';
import '../core/constants/enums.dart';

/// Order data model
class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String? technicianId;
  final String serviceType;
  final String? description;
  final OrderStatus status;
  final double customerLat;
  final double customerLng;
  final String? customerAddress;
  final int? price;
  final PaymentMethod? paymentMethod;
  final double? distanceKm;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Joined fields (populated from queries)
  final String? customerName;
  final String? technicianName;
  final String? technicianPhone;
  final String? technicianAvatar;
  final double? technicianRating;

  const OrderModel({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.serviceType,
    this.description,
    this.status = OrderStatus.waiting,
    required this.customerLat,
    required this.customerLng,
    this.customerAddress,
    this.price,
    this.paymentMethod,
    this.distanceKm,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.customerName,
    this.technicianName,
    this.technicianPhone,
    this.technicianAvatar,
    this.technicianRating,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      technicianId: map['technician_id'] as String?,
      serviceType: map['service_type'] as String,
      description: map['description'] as String?,
      status: OrderStatus.fromString(map['status'] as String),
      customerLat: (map['customer_lat'] as num).toDouble(),
      customerLng: (map['customer_lng'] as num).toDouble(),
      customerAddress: map['customer_address'] as String?,
      price: map['price'] as int?,
      paymentMethod: map['payment_method'] != null
          ? PaymentMethod.fromString(map['payment_method'] as String)
          : null,
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      acceptedAt: map['accepted_at'] != null
          ? DateTime.parse(map['accepted_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      customerName: map['customer_name'] as String?,
      technicianName: map['technician_name'] as String?,
      technicianPhone: map['technician_phone'] as String?,
      technicianAvatar: map['technician_avatar'] as String?,
      technicianRating: (map['technician_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'technician_id': technicianId,
      'service_type': serviceType,
      'description': description,
      'status': status.name,
      'customer_lat': customerLat,
      'customer_lng': customerLng,
      'customer_address': customerAddress,
      'price': price,
      'payment_method': paymentMethod?.name,
      'distance_km': distanceKm,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? technicianId,
    String? serviceType,
    String? description,
    OrderStatus? status,
    double? customerLat,
    double? customerLng,
    String? customerAddress,
    int? price,
    PaymentMethod? paymentMethod,
    double? distanceKm,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? customerName,
    String? technicianName,
    String? technicianPhone,
    String? technicianAvatar,
    double? technicianRating,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      status: status ?? this.status,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      customerAddress: customerAddress ?? this.customerAddress,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      customerName: customerName ?? this.customerName,
      technicianName: technicianName ?? this.technicianName,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      technicianAvatar: technicianAvatar ?? this.technicianAvatar,
      technicianRating: technicianRating ?? this.technicianRating,
    );
  }

  /// Check if the order can be cancelled
  bool get canCancel =>
      status == OrderStatus.waiting || status == OrderStatus.accepted;

  /// Check if order is active
  bool get isActive =>
      status == OrderStatus.waiting ||
      status == OrderStatus.accepted ||
      status == OrderStatus.ongoing;

  /// Get service type label
  String get serviceLabel {
    return ServiceType.fromDbValue(serviceType).label;
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        technicianId,
        serviceType,
        description,
        status,
        customerLat,
        customerLng,
        customerAddress,
        price,
        paymentMethod,
        distanceKm,
        createdAt,
        acceptedAt,
        completedAt,
      ];
}
