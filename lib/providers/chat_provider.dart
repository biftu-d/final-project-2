import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  Chat? _currentChat;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadChats(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ChatService.getUserChats(token);
      _chats = data.map((json) => Chat.fromJson(json)).toList();
      await _updateUnreadCount(token);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadChatMessages(String token, String chatId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ChatService.getChatMessages(token, chatId);
      _currentChat = Chat.fromJson(response['chat']);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(
    String token,
    String chatId,
    String content, {
    MessageType messageType = MessageType.text,
    String? fileUrl,
  }) async {
    try {
      final response = await ChatService.sendMessage(
        token,
        chatId,
        content,
        messageType: messageType,
        fileUrl: fileUrl,
      );

      // Update current chat with new message
      if (_currentChat?.id == chatId) {
        final newMessage = ChatMessage.fromJson(response['chatMessage']);
        _currentChat = Chat(
          id: _currentChat!.id,
          participants: _currentChat!.participants,
          serviceId: _currentChat!.serviceId,
          paymentId: _currentChat!.paymentId,
          isActive: _currentChat!.isActive,
          lastMessage: newMessage,
          messages: [..._currentChat!.messages, newMessage],
          unreadCount: _currentChat!.unreadCount,
          createdAt: _currentChat!.createdAt,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _updateUnreadCount(String token) async {
    try {
      _unreadCount = await ChatService.getUnreadCount(token);
    } catch (e) {
      // Silently handle error for unread count
    }
  }

  Future<void> deleteChat(String token, String chatId) async {
    try {
      await ChatService.deleteChat(token, chatId);
      _chats.removeWhere((chat) => chat.id == chatId);
      if (_currentChat?.id == chatId) {
        _currentChat = null;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentChat() {
    _currentChat = null;
    notifyListeners();
  }
}
