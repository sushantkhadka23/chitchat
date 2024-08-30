import 'package:chitchat/models/chat_room_model.dart';
import 'package:chitchat/models/user_model.dart';
import 'package:chitchat/screens/chats/chat_conversation_screen.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:chitchat/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthService _authService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _databaseService.getAllUsers(userId: _authService.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users = snapshot.data!;
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserListTile(user);
          },
        );
      },
    );
  }

  Widget _buildUserListTile(UserModel user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: user.userProfileUrl.isNotEmpty
            ? NetworkImage(user.userProfileUrl)
            : null,
        child: user.userProfileUrl.isEmpty
            ? const Icon(Icons.person, size: 28)
            : null,
      ),
      title: Text(
        '${user.firstName} ${user.lastName}'.trim(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onTap: () async {
        final currentUserId = _authService.user!.uid;
        final chatUserId = user.userId;

        final chatRoomModel = ChatRoomModel(
          participantIds: [currentUserId, chatUserId],
          messages: [],
          createdAt: Timestamp.now(),
        );
        await _databaseService.enterChatRoom(
          currentUserId: currentUserId,
          chatUserId: chatUserId,
          chatRoomModel: chatRoomModel,
        );

        _navigationService.push(MaterialPageRoute(
          builder: (context) => ChatConversationScreen(user: user),
        ));
      },
    );
  }
}
