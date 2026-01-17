/// Model representing a chat message between matched users
class MessageModel {
  int? id;
  int? matchId;
  String? senderId;
  String? receiverId;
  String? messageText;
  String? messageType;
  DateTime? sentAt;
  DateTime? readAt;
  bool? isRead;
  String? senderName;

  MessageModel({
    this.id,
    this.matchId,
    this.senderId,
    this.receiverId,
    this.messageText,
    this.messageType,
    this.sentAt,
    this.readAt,
    this.isRead,
    this.senderName,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    matchId = json['match_id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    messageText = json['message_text'] ?? '';
    messageType = json['message_type'] ?? 'text';
    sentAt = json['sent_at'] != null
        ? DateTime.tryParse(json['sent_at'])
        : null;
    readAt = json['read_at'] != null
        ? DateTime.tryParse(json['read_at'])
        : null;
    isRead = json['is_read'] ?? false;
    senderName = json['sender_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_text': messageText,
      'message_type': messageType,
      'sent_at': sentAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
    };
  }

  /// Check if this message was sent by the current user
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }
}

/// Response model for messages list API
class MessagesResponseModel {
  bool? success;
  String? message;
  List<MessageModel>? messages;

  MessagesResponseModel({
    this.success,
    this.message,
    this.messages,
  });

  MessagesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    // API returns data array
    if (json['data'] != null) {
      messages = <MessageModel>[];
      json['data'].forEach((v) {
        messages!.add(MessageModel.fromJson(v));
      });
    } else if (json['messages'] != null) {
      messages = <MessageModel>[];
      json['messages'].forEach((v) {
        messages!.add(MessageModel.fromJson(v));
      });
    }
  }
}

/// Response model for send message API
class SendMessageResponseModel {
  bool? success;
  String? message;
  MessageModel? sentMessage;

  SendMessageResponseModel({
    this.success,
    this.message,
    this.sentMessage,
  });

  SendMessageResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    if (json['data'] != null) {
      sentMessage = MessageModel.fromJson(json['data']);
    }
  }
}
