import 'package:chitchat/models/user_model.dart';
import 'package:chitchat/screens/chats/chat_screen.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexState();
}

class _IndexState extends State<IndexScreen> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: const ChatsScreen(),
    );
  }

  AppBar _buildAppbar() {
    final theme = Theme.of(context).colorScheme;
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        children: [
          _fetchUserImage(),
          const SizedBox(width: 20),
          Text(
            'Chitchat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fetchUserImage() {
    return FutureBuilder<UserModel>(
      future: _databaseService.fetchUserDetails(userId: _authService.user!.uid),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 23,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const CircleAvatar(
            radius: 23,
            child: Icon(Icons.error, size: 28),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const CircleAvatar(
            radius: 23,
            child: Icon(Icons.person, size: 28),
          );
        } else {
          final user = snapshot.data!;
          return CircleAvatar(
            radius: 20,
            backgroundImage: user.userProfileUrl.isNotEmpty
                ? NetworkImage(user.userProfileUrl)
                : null,
            child: user.userProfileUrl.isEmpty
                ? const Icon(Icons.person, size: 28)
                : null,
          );
        }
      },
    );
  }
}
