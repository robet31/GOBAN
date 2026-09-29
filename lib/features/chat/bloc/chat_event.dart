import 'package:equatable/equatable.dart';
import '../../../models/chat_model.dart';

// ─── Events ───
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatLoadMessages extends ChatEvent {
  final String orderId;
  const ChatLoadMessages(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class ChatSendMessage extends ChatEvent {
  final String orderId;
  final String senderId;
  final String message;
  const ChatSendMessage({
    required this.orderId,
    required this.senderId,
    required this.message,
  });
  @override
  List<Object?> get props => [orderId, senderId, message];
}

// ─── States ───
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatModel> messages;
  const ChatLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
