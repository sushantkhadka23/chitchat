import 'dart:convert';

import 'package:chitchat/models/chat_room_model.dart';
import 'package:chitchat/models/message_model.dart';
import 'package:chitchat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //create user data model
  Future<void> addUser({
    required UserModel userModel,
  }) async {
    DocumentReference<Map<String, dynamic>> users =
        _firestore.collection('users').doc(userModel.userId);
    await users.set(userModel.toJson());
  }

  Future<UserModel> fetchUserDetails({
    required String userId,
  }) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('users').doc(userId).get();
    return UserModel.fromJson(doc.data()!);
  }

  // Fetch list of users except onself
  Stream<List<UserModel>> getAllUsers({
    required String userId,
  }) {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != userId)
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    });
  }

  String generateUniqueId({
    required String uid1,
    required String uid2,
  }) {
    // Sort the user IDs to ensure a consistent order
    List<String> sortedUids = [uid1, uid2]..sort();
    String combinedString = '${sortedUids[0]}-${sortedUids[1]}';

    // Create a hash of the combined string
    var bytes = utf8.encode(combinedString); // Convert the string to bytes
    var digest = sha256.convert(bytes); // Create a SHA-256 hash

    // Convert the hash to a string
    return digest.toString();
  }

  Future<bool> chatExistId({
    required String currentUserId,
    required String chatUserId,
  }) async {
    String chatId = generateUniqueId(uid1: currentUserId, uid2: chatUserId);
    // Get the document snapshot for the generated chat ID
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await _firestore.collection('chats').doc(chatId).get();
    // Return true if the document exists, false otherwise
    return docSnapshot.exists;
  }

  Future<void> enterChatRoom({
    required String currentUserId,
    required String chatUserId,
    required ChatRoomModel chatRoomModel,
  }) async {
    // Generate the unique chat ID based on the user IDs
    final chatId = generateUniqueId(uid1: currentUserId, uid2: chatUserId);

    // Check if the chat room already exists
    final chatExists = await chatExistId(
      currentUserId: currentUserId,
      chatUserId: chatUserId,
    );

    if (!chatExists) {
      DocumentReference<Map<String, dynamic>> chats =
          _firestore.collection('chats').doc(chatId);

      await chats.set(chatRoomModel.toJson());
    }
  }

  Future<void> addMessage({
    required String chatId,
    required MessageModel messageModel,
  }) async {
    // Reference to the chat document
    DocumentReference<Map<String, dynamic>> chatDoc =
        _firestore.collection('chats').doc(chatId);

    // Add the message to the 'messages' array field in the chat document
    await chatDoc.update({
      'messages': FieldValue.arrayUnion([messageModel.toJson()])
    });
  }

  Stream<List<MessageModel>> getMessages({
    required String chatId,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((docSnapshot) {
      final data = docSnapshot.data();
      if (data == null || data['messages'] == null) {
        return [];
      }

      return (data['messages'] as List<dynamic>)
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }
}
