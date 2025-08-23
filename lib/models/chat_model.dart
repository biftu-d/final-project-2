class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final MessageType messageType;
  final String? fileUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    this.messageType = MessageType.text,
    this.fileUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ??
          json['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: json['senderId'],
      content: json['content'],
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['messageType'],
        orElse: () => MessageType.text,
      ),
      fileUrl: json['fileUrl'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Chat {
  final String id;
  final List<String> participants;
  final String serviceId;
  final String paymentId;
  final bool isActive;
  final ChatMessage? lastMessage;
  final List<ChatMessage> messages;
  final int unreadCount;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.participants,
    required this.serviceId,
    required this.paymentId,
    this.isActive = true,
    this.lastMessage,
    this.messages = const [],
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'],
      participants: List<String>.from(json['participants'] ?? []),
      serviceId: json['serviceId'],
      paymentId: json['paymentId'],
      isActive: json['isActive'] ?? true,
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((msg) => ChatMessage.fromJson(msg))
              .toList() ??
          [],
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Connection {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final String paymentId;
  final String chatId;
  final ConnectionStatus status;
  final DateTime connectionDate;
  final DateTime expiresAt;

  Connection({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.paymentId,
    required this.chatId,
    required this.status,
    required this.connectionDate,
    required this.expiresAt,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      providerId: json['providerId'],
      serviceId: json['serviceId'],
      paymentId: json['paymentId'],
      chatId: json['chatId'],
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ConnectionStatus.active,
      ),
      connectionDate: DateTime.parse(json['connectionDate']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}

enum MessageType { text, image, file, system }

enum ConnectionStatus { active, completed, cancelled }
