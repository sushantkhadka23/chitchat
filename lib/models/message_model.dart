import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType {
  image,
  text,
  audio,
  files,
}

class MessageModel {
  final String senderId;
  final Timestamp sentAt;
  final String content;
  final ContentType contentType;

  MessageModel({
    required this.senderId,
    required this.sentAt,
    required this.content,
    required this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'sentAt': sentAt,
      'content': content,
      'contentType': _contentTypeToString(contentType),
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'] as String,
      sentAt: json['sentAt'] as Timestamp,
      content: json['content'] as String,
      contentType: _stringToContentType(json['contentType'] as String),
    );
  }

  static String _contentTypeToString(ContentType type) {
    switch (type) {
      case ContentType.text:
        return 'text';
      case ContentType.image:
        return 'image';
      case ContentType.audio:
        return 'audio';
      case ContentType.files:
        return 'files';
    }
  }

  static ContentType _stringToContentType(String type) {
    switch (type) {
      case 'text':
        return ContentType.text;
      case 'image':
        return ContentType.image;
      case 'audio':
        return ContentType.audio;
      case 'files':
        return ContentType.files;
      default:
        throw Exception('Unknown ContentType: $type');
    }
  }
}
