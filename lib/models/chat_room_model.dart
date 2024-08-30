import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final List<String> participantIds;
  final List<Map<String, dynamic>> messages;
  final Timestamp createdAt;

  ChatRoomModel({
    required this.participantIds,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'participant_ids': participantIds,
      'messages': messages,
      'created_at': createdAt,
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      participantIds: List<String>.from(json['participant_ids'] ?? []),
      messages: List<Map<String, dynamic>>.from(json['messages'] ?? []),
      createdAt: json['created_at'] as Timestamp,
    );
  }
}
