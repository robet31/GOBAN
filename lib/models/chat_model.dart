import 'package:equatable/equatable.dart';

/// Chat message model
class ChatModel extends Equatable {
  final String id;
  final String orderId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  // Joined fields
  final String? senderName;
  final String? senderAvatar;
  final bool? isMe;

  const ChatModel({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.isMe,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    return ChatModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      senderId: map['sender_id'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      senderName: map['sender_name'] as String?,
      senderAvatar: map['sender_avatar'] as String?,
      isMe: currentUserId != null ? map['sender_id'] == currentUserId : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, orderId, senderId, message, createdAt];
}
