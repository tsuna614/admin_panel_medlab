class MessageItem {
  final String message;
  final String senderType;
  final String? userId;
  final DateTime? createdAt;

  MessageItem({
    required this.message,
    required this.senderType,
    this.userId,
    this.createdAt,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      message: json['message'] as String,
      senderType: json['senderType'] as String,
      // userId: json['userId'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'userId': userId};
  }
}

class MessageModel {
  final String conversationId;
  final List<MessageItem> adminMessages;

  MessageModel({required this.conversationId, required this.adminMessages});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      conversationId: json['_id'] as String,
      adminMessages: (json['adminMessage'] as List<dynamic>)
          .map((item) => MessageItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'adminMessages': adminMessages.map((e) => e.toJson()).toList(),
    };
  }
}
