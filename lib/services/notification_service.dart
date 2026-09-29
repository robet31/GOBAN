import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';
import 'database_service.dart';

/// Push notification service using ntfy.sh
/// Also manages local notification persistence in database
class NotificationService {
  final Dio _dio;
  final DatabaseService _db;

  NotificationService({Dio? dio, DatabaseService? db})
      : _dio = dio ?? Dio(),
        _db = db ?? DatabaseService.instance;

  String get _baseUrl =>
      dotenv.env[ApiConstants.ntfyBaseUrlKey] ?? 'https://ntfy.sh';

  /// Send push notification via ntfy.sh
  Future<void> sendPush({
    required String userId,
    required String title,
    String? body,
    Map<String, dynamic>? data,
    String? topic,
  }) async {
    final ntfyTopic = topic ?? '${ApiConstants.ntfyDefaultTopic}-$userId';

    try {
      await _dio.post(
        '$_baseUrl/$ntfyTopic',
        data: body ?? title,
        options: Options(
          headers: {
            'Title': title,
            'Priority': '3', // default priority
            'Tags': 'wrench', // 🔧 emoji tag
          },
        ),
      );
    } catch (e) {
      // ntfy.sh might be unavailable; don't crash
    }

    // Also save to local database
    await saveNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Save notification to database
  Future<void> saveNotification({
    required String userId,
    required String title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      userId: userId,
      title: title,
      body: body,
      data: data,
      createdAt: DateTime.now(),
    );

    await _db.execute(
      '''INSERT INTO notifications (user_id, title, body, data, read, created_at) 
         VALUES (?, ?, ?, ?, 0, ?)''',
      [
        notification.userId,
        notification.title,
        notification.body,
        notification.data != null ? notification.toMap()['data'] : null,
        notification.createdAt.toIso8601String(),
      ],
    );
  }

  /// Get notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final results = await _db.query(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50',
      [userId],
    );
    return results.map((m) => NotificationModel.fromMap(m)).toList();
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    final results = await _db.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND read = 0',
      [userId],
    );
    return results.first['count'] as int? ?? 0;
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    await _db.execute(
      'UPDATE notifications SET read = 1 WHERE id = ?',
      [notificationId],
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    await _db.execute(
      'UPDATE notifications SET read = 1 WHERE user_id = ? AND read = 0',
      [userId],
    );
  }

  /// Send order-related notifications
  Future<void> notifyOrderAccepted({
    required String customerId,
    required String technicianName,
    required String orderId,
  }) async {
    await sendPush(
      userId: customerId,
      title: 'Order Diterima! 🎉',
      body: '$technicianName sedang menuju lokasi Anda',
      data: {'order_id': orderId, 'type': 'order_accepted'},
    );
  }

  Future<void> notifyOrderCompleted({
    required String customerId,
    required String orderId,
  }) async {
    await sendPush(
      userId: customerId,
      title: 'Servis Selesai! ✅',
      body: 'Silakan konfirmasi pembayaran dan berikan rating',
      data: {'order_id': orderId, 'type': 'order_completed'},
    );
  }

  Future<void> notifyNewOrder({
    required String technicianId,
    required String serviceType,
    required double distanceKm,
  }) async {
    await sendPush(
      userId: technicianId,
      title: 'Order Baru Masuk! 🔔',
      body:
          '$serviceType — ${distanceKm.toStringAsFixed(1)} km dari lokasi Anda',
      data: {'type': 'new_order'},
    );
  }

  Future<void> notifyLocationApproved({
    required String userId,
    required String locationName,
  }) async {
    await sendPush(
      userId: userId,
      title: 'Lokasi Disetujui! 📍',
      body: '$locationName sudah tampil di peta',
      data: {'type': 'location_approved'},
    );
  }

  Future<void> notifyTechnicianVerified({
    required String technicianId,
  }) async {
    await sendPush(
      userId: technicianId,
      title: 'Akun Diverifikasi! ✅',
      body: 'Selamat! Anda bisa mulai menerima order',
      data: {'type': 'technician_verified'},
    );
  }
}
