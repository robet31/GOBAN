import 'package:equatable/equatable.dart';
import 'dart:convert';

/// Notification model
class NotificationModel extends Equatable {
  final int? id;
  final String userId;
  final String title;
  final String? body;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    this.body,
    this.data,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? parseData(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value.cast<String, dynamic>();
      if (value is String) {
        try {
          return jsonDecode(value) as Map<String, dynamic>;
        } catch (_) {}
      }
      return null;
    }

    return NotificationModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      data: parseData(map['data']),
      read: (map['read'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'data': data != null ? jsonEncode(data) : null,
      'read': read ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      data: data,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, body, data, read, createdAt];
}
