import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat_model.dart';
import '../../../services/database_service.dart';
import 'chat_event.dart';

/// Chat BLoC for customer↔technician messaging
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final DatabaseService _db;
  String? _currentUserId;

  ChatBloc({DatabaseService? db})
      : _db = db ?? DatabaseService.instance,
        super(const ChatInitial()) {
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> _onLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final results = await _db.query(
        '''SELECT c.*, u.full_name as sender_name, u.avatar_url as sender_avatar
           FROM chats c
           LEFT JOIN users u ON c.sender_id = u.id
           WHERE c.order_id = ?
           ORDER BY c.created_at ASC''',
        [event.orderId],
      );

      final messages = results.map((m) {
        return ChatModel.fromMap(m, currentUserId: _currentUserId);
      }).toList();

      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError('Gagal memuat pesan: $e'));
    }
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messageId = const Uuid().v4();
      final now = DateTime.now();

      await _db.execute(
        '''INSERT INTO chats (id, order_id, sender_id, message, created_at)
           VALUES (?, ?, ?, ?, ?)''',
        [
          messageId,
          event.orderId,
          event.senderId,
          event.message,
          now.toIso8601String()
        ],
      );

      await _db.sync();

      // Reload messages
      add(ChatLoadMessages(event.orderId));
    } catch (e) {
      emit(ChatError('Gagal mengirim pesan: $e'));
    }
  }
}
