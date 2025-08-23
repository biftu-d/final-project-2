import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get user's chats
  static Future<List<dynamic>> getUserChats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['chats'];
    } else {
      throw Exception('Failed to load chats');
    }
  }

  // Get specific chat messages
  static Future<Map<String, dynamic>> getChatMessages(
    String token,
    String chatId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/$chatId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  // Send message
  static Future<Map<String, dynamic>> sendMessage(
    String token,
    String chatId,
    String content, {
    MessageType messageType = MessageType.text,
    String? fileUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/$chatId/messages'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'content': content,
        'messageType': messageType.toString().split('.').last,
        if (fileUrl != null) 'fileUrl': fileUrl,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  // Get unread message count
  static Future<int> getUnreadCount(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/unread/count'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['unreadCount'];
    } else {
      throw Exception('Failed to get unread count');
    }
  }

  // Delete chat
  static Future<void> deleteChat(String token, String chatId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/chat/$chatId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete chat');
    }
  }
}
