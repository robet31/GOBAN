import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/haversine.dart';
import '../../../models/order_model.dart';
import '../../../services/database_service.dart';
import '../../../services/notification_service.dart';
import 'order_event.dart';

/// Order BLoC — manages order lifecycle
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final DatabaseService _db;
  final NotificationService _notifications;

  OrderBloc({
    DatabaseService? db,
    NotificationService? notifications,
  })  : _db = db ?? DatabaseService.instance,
        _notifications = notifications ?? NotificationService(),
        super(const OrderInitial()) {
    on<OrderCreate>(_onCreate);
    on<OrderLoadHistory>(_onLoadHistory);
    on<OrderLoadDetail>(_onLoadDetail);
    on<OrderAccept>(_onAccept);
    on<OrderReject>(_onReject);
    on<OrderStartService>(_onStartService);
    on<OrderComplete>(_onComplete);
    on<OrderCancel>(_onCancel);
    on<OrderLoadIncoming>(_onLoadIncoming);
    on<OrderSubmitReview>(_onSubmitReview);
  }

  Future<void> _onCreate(OrderCreate event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    try {
      final orderId = const Uuid().v4();
      final now = DateTime.now();

      // Calculate distance
      final techRows = await _db.query(
        'SELECT lat, lng FROM technician_profiles WHERE id = ?',
        [event.technicianId],
      );
      double? distanceKm;
      if (techRows.isNotEmpty) {
        distanceKm = Haversine.distance(
          event.customerLat,
          event.customerLng,
          (techRows.first['lat'] as num).toDouble(),
          (techRows.first['lng'] as num).toDouble(),
        );
      }

      await _db.execute(
        '''INSERT INTO orders (id, customer_id, technician_id, service_type, 
           description, status, customer_lat, customer_lng, customer_address, 
           price, payment_method, distance_km, created_at)
           VALUES (?, ?,
           ?, ?, ?, 'waiting', ?, ?, ?, ?, ?, ?, ?)''',
        [
          orderId,
          event.customerId,
          event.technicianId,
          event.serviceType,
          event.description,
          event.customerLat,
          event.customerLng,
          event.customerAddress,
          event.price,
          event.paymentMethod.name,
          distanceKm,
          now.toIso8601String(),
        ],
      );

      // Notify technician
      await _notifications.notifyNewOrder(
        technicianId: event.technicianId,
        serviceType: event.serviceType,
        distanceKm: distanceKm ?? 0,
      );

      await _db.sync();

      final order = OrderModel(
        id: orderId,
        customerId: event.customerId,
        technicianId: event.technicianId,
        serviceType: event.serviceType,
        description: event.description,
        customerLat: event.customerLat,
        customerLng: event.customerLng,
        customerAddress: event.customerAddress,
        price: event.price,
        paymentMethod: event.paymentMethod,
        distanceKm: distanceKm,
        createdAt: now,
      );

      emit(OrderCreated(order));
    } catch (e) {
      emit(OrderError('Gagal membuat order: $e'));
    }
  }

  Future<void> _onLoadHistory(
      OrderLoadHistory event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    try {
      final String whereClause;
      if (event.role == UserRole.admin) {
        whereClause = '1=1';
      } else if (event.role == UserRole.technician) {
        whereClause = 'o.technician_id = ?';
      } else {
        whereClause = 'o.customer_id = ?';
      }

      final results = await _db.query(
        '''SELECT o.*, 
           c.full_name as customer_name,
           t.full_name as technician_name
           FROM orders o 
           LEFT JOIN users c ON o.customer_id = c.id
           LEFT JOIN users t ON o.technician_id = t.id
           WHERE $whereClause
           ORDER BY o.created_at DESC
           LIMIT 50''',
        event.role == UserRole.admin ? null : [event.userId],
      );

      final orders = results.map((m) => OrderModel.fromMap(m)).toList();
      emit(OrderHistoryLoaded(orders));
    } catch (e) {
      emit(OrderError('Gagal memuat riwayat: $e'));
    }
  }

  Future<void> _onLoadDetail(
      OrderLoadDetail event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    try {
      final results = await _db.query(
        '''SELECT o.*, 
           c.full_name as customer_name,
           t.full_name as technician_name,
           t.phone as technician_phone,
           t.avatar_url as technician_avatar,
           tp.rating_avg as technician_rating
           FROM orders o 
           LEFT JOIN users c ON o.customer_id = c.id
           LEFT JOIN users t ON o.technician_id = t.id
           LEFT JOIN technician_profiles tp ON o.technician_id = tp.id
           WHERE o.id = ?''',
        [event.orderId],
      );

      if (results.isEmpty) {
        emit(const OrderError('Order tidak ditemukan'));
        return;
      }

      emit(OrderDetailLoaded(OrderModel.fromMap(results.first)));
    } catch (e) {
      emit(OrderError('Gagal memuat detail: $e'));
    }
  }

  Future<void> _onAccept(OrderAccept event, Emitter<OrderState> emit) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _db.execute(
        "UPDATE orders SET status = 'accepted', technician_id = ?, accepted_at = ? WHERE id = ?",
        [event.technicianId, now, event.orderId],
      );
      await _db.sync();
      add(OrderLoadDetail(event.orderId));
    } catch (e) {
      emit(OrderError('Gagal menerima order: $e'));
    }
  }

  Future<void> _onReject(OrderReject event, Emitter<OrderState> emit) async {
    try {
      await _db.execute(
        "UPDATE orders SET status = 'cancelled' WHERE id = ?",
        [event.orderId],
      );
      await _db.sync();
    } catch (e) {
      emit(OrderError('Gagal menolak order: $e'));
    }
  }

  Future<void> _onStartService(
      OrderStartService event, Emitter<OrderState> emit) async {
    try {
      await _db.execute(
        "UPDATE orders SET status = 'ongoing' WHERE id = ?",
        [event.orderId],
      );
      await _db.sync();
      add(OrderLoadDetail(event.orderId));
    } catch (e) {
      emit(OrderError('Gagal memulai servis: $e'));
    }
  }

  Future<void> _onComplete(
      OrderComplete event, Emitter<OrderState> emit) async {
    try {
      final now = DateTime.now().toIso8601String();
      await _db.execute(
        "UPDATE orders SET status = 'completed', price = ?, completed_at = ? WHERE id = ?",
        [event.finalPrice, now, event.orderId],
      );

      // Update technician stats
      await _db.execute(
        'UPDATE technician_profiles SET total_orders = total_orders + 1 WHERE id = (SELECT technician_id FROM orders WHERE id = ?)',
        [event.orderId],
      );

      await _db.sync();
      add(OrderLoadDetail(event.orderId));
    } catch (e) {
      emit(OrderError('Gagal menyelesaikan order: $e'));
    }
  }

  Future<void> _onCancel(OrderCancel event, Emitter<OrderState> emit) async {
    try {
      await _db.execute(
        "UPDATE orders SET status = 'cancelled' WHERE id = ?",
        [event.orderId],
      );
      await _db.sync();
      add(OrderLoadDetail(event.orderId));
    } catch (e) {
      emit(OrderError('Gagal membatalkan order: $e'));
    }
  }

  Future<void> _onLoadIncoming(
      OrderLoadIncoming event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    try {
      final results = await _db.query(
        '''SELECT o.*, c.full_name as customer_name
           FROM orders o
           LEFT JOIN users c ON o.customer_id = c.id
           WHERE (o.technician_id = ? OR o.technician_id IS NULL)
           AND o.status = 'waiting'
           ORDER BY o.created_at DESC''',
        [event.technicianId],
      );
      final orders = results.map((m) => OrderModel.fromMap(m)).toList();
      emit(OrderIncomingLoaded(orders));
    } catch (e) {
      emit(OrderError('Gagal memuat order masuk: $e'));
    }
  }

  Future<void> _onSubmitReview(
      OrderSubmitReview event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    try {
      final orders = await _db.query(
        'SELECT technician_id, status FROM orders WHERE id = ? AND customer_id = ?',
        [event.orderId, event.reviewerId],
      );
      if (orders.isEmpty ||
          orders.first['status'] != OrderStatus.completed.name) {
        emit(const OrderError(
            'Review hanya dapat dikirim untuk order yang selesai'));
        return;
      }

      final technicianId = orders.first['technician_id'] as String?;
      if (technicianId == null) {
        emit(const OrderError('Teknisi pada order tidak ditemukan'));
        return;
      }

      await _db.execute(
        '''INSERT INTO reviews (order_id, reviewer_id, rating, comment, created_at)
           VALUES (?, ?, ?, ?, ?)''',
        [
          event.orderId,
          event.reviewerId,
          event.rating,
          event.comment,
          DateTime.now().toIso8601String(),
        ],
      );
      await _db.execute(
        '''UPDATE technician_profiles
           SET rating_avg = COALESCE((
             SELECT AVG(r.rating)
             FROM reviews r
             INNER JOIN orders o ON o.id = r.order_id
             WHERE o.technician_id = technician_profiles.id
           ), 0)
           WHERE id = ?''',
        [technicianId],
      );
      await _db.sync();
      emit(const OrderReviewSubmitted());
    } catch (e) {
      emit(OrderError('Gagal mengirim review: $e'));
    }
  }
}
