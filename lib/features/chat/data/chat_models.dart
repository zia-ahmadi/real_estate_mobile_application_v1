class Conversation {
  final int id;
  final int userId;
  final String? userName;
  final String? userEmail;
  final String? lastMessage;
  final String? lastMessageTime;
  final String? createdAt;
  final String? updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String? senderName;
  final String body;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    required this.body,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId: json['sender_id'] as int,
      senderName: json['sender_name'] as String?,
      body: json['body'] as String,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'body': body,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isRead => readAt != null;
}
