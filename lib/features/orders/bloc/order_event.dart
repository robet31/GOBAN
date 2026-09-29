import 'package:equatable/equatable.dart';
import '../../../core/constants/enums.dart';
import '../../../models/order_model.dart';

// ─── Events ───
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderCreate extends OrderEvent {
  final String customerId;
  final String technicianId;
  final String serviceType;
  final String? description;
  final double customerLat;
  final double customerLng;
  final String? customerAddress;
  final int? price;
  final PaymentMethod paymentMethod;

  const OrderCreate({
    required this.customerId,
    required this.technicianId,
    required this.serviceType,
    this.description,
    required this.customerLat,
    required this.customerLng,
    this.customerAddress,
    this.price,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [customerId, technicianId, serviceType];
}

class OrderLoadHistory extends OrderEvent {
  final String userId;
  final UserRole role;
  const OrderLoadHistory({required this.userId, required this.role});
  @override
  List<Object?> get props => [userId, role];
}

class OrderLoadDetail extends OrderEvent {
  final String orderId;
  const OrderLoadDetail(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class OrderAccept extends OrderEvent {
  final String orderId;
  final String technicianId;
  const OrderAccept({required this.orderId, required this.technicianId});
  @override
  List<Object?> get props => [orderId, technicianId];
}

class OrderReject extends OrderEvent {
  final String orderId;
  const OrderReject(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class OrderStartService extends OrderEvent {
  final String orderId;
  const OrderStartService(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class OrderComplete extends OrderEvent {
  final String orderId;
  final int finalPrice;
  const OrderComplete({required this.orderId, required this.finalPrice});
  @override
  List<Object?> get props => [orderId, finalPrice];
}

class OrderCancel extends OrderEvent {
  final String orderId;
  const OrderCancel(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class OrderLoadIncoming extends OrderEvent {
  final String technicianId;
  const OrderLoadIncoming(this.technicianId);
  @override
  List<Object?> get props => [technicianId];
}

class OrderSubmitReview extends OrderEvent {
  final String orderId;
  final String reviewerId;
  final int rating;
  final String? comment;

  const OrderSubmitReview({
    required this.orderId,
    required this.reviewerId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [orderId, reviewerId, rating, comment];
}

// ─── States ───
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderCreated extends OrderState {
  final OrderModel order;
  const OrderCreated(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderHistoryLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrderHistoryLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  const OrderDetailLoaded(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderUpdated extends OrderState {
  final OrderModel order;
  const OrderUpdated(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderIncomingLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrderIncomingLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderReviewSubmitted extends OrderState {
  const OrderReviewSubmitted();
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}
