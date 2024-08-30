import 'dart:io';
import 'package:chitchat/widgets/media_options_sheet.dart';
import 'package:chitchat/models/message_model.dart';
import 'package:chitchat/models/user_model.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:chitchat/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

class ChatConversationScreen extends StatefulWidget {
  final UserModel user;
  const ChatConversationScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late StorageService _storageService;

  //from dash_chat
  late ChatUser _currentUser;
  late ChatUser _chatUser;

  //for image
  List<File>? _selectedImages;
  final ImagePicker _picker = ImagePicker();

  //for audio
  final AudioRecorder audioRecorder = AudioRecorder();
  bool _isRecording = false;
  // ignore: unused_field
  String? _audioPath;

  //for files
  List<File>? _files;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _storageService = _getIt.get<StorageService>();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    _chatUser = ChatUser(
      id: widget.user.userId,
      firstName: widget.user.firstName,
      profileImage: widget.user.userProfileUrl,
    );
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImages = [File(image.path)];
      });
      await uploadImagesToChat();
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80,
    );
    setState(() {
      _selectedImages = images.map((xFile) => File(xFile.path)).toList();
    });
    await uploadImagesToChat();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        _files = result.files.map((file) => File(file.path!)).toList();
      });
    }
    await uploadFilesToChat();
  }

  Future<void> uploadImagesToChat() async {
    if (_selectedImages != null && _selectedImages!.isNotEmpty) {
      List<String> imageUrls = await _storageService.uploadMultipleImages(
        files: _selectedImages!,
        uid1: _currentUser.id,
        uid2: _chatUser.id,
      );

      for (var url in imageUrls) {
        final chatMessage = ChatMessage(
          user: _currentUser,
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(
              url: url,
              fileName: "",
              type: MediaType.image,
            )
          ],
        );
        await _sendMessages(chatMessage);
      }
    } else {
      throw Exception('No images selected for upload.');
    }
  }

  Future<void> uploadFilesToChat() async {
    if (_files != null && _files!.isNotEmpty) {
      // Upload files to Firebase Storage
      List<String> downloadUrls = await _storageService.uploadFiles(
        files: _files!,
        uid1: _currentUser.id,
        uid2: _chatUser.id,
      );

      for (var url in downloadUrls) {
        final fileType = p.extension(_files!.first.path);

        final chatMessage = ChatMessage(
          user: _currentUser,
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(
              url: url,
              fileName: p.basename(_files!.first.path),
              type: _getMediaType(fileType),
            )
          ],
        );
        await _sendMessages(chatMessage);
      }
    } else {
      throw Exception('No files selected for upload.');
    }
  }

  MediaType _getMediaType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
        return MediaType.image;
      case '.mp3':
      case '.wav':
      case '.m4a':
        return MediaType.video;
      default:
        return MediaType.file;
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) {
      String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        setState(() {
          _isRecording = false;
          _audioPath = filePath;
        });
      }
    } else {
      if (await audioRecorder.hasPermission()) {
        final Directory appDocumentDir =
            await getApplicationDocumentsDirectory();
        final String filePath = p.join(appDocumentDir.path, "recording.m4a");

        await audioRecorder.start(
          const RecordConfig(),
          path: filePath,
        );
        setState(() {
          _isRecording = true;
          _audioPath = filePath;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final filePath = await audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = filePath;
      });
      await uploadAudioToChat(filePath!);
    } catch (e) {
      throw ("Failed to recording.Error:$e");
    }
  }

  Future<void> uploadAudioToChat(String filePath) async {
    final file = File(filePath);
    final fileName = p.basename(filePath);

    try {
      // Upload the audio file
      String downloadUrl = await _storageService.uploadAudios(
        file: file,
        uid1: _currentUser.id,
        uid2: _chatUser.id,
      );

      // Create and send the chat message with audio
      final chatMessage = ChatMessage(
        user: _currentUser,
        createdAt: DateTime.now(),
        medias: [
          ChatMedia(
            url: downloadUrl,
            fileName: fileName,
            type: MediaType.video,
          )
        ],
      );
      await _sendMessages(chatMessage);
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  Future<void> _sendMessages(ChatMessage chatMessage) async {
    final chatId = _databaseService.generateUniqueId(
      uid1: _currentUser.id,
      uid2: _chatUser.id,
    );

    ContentType contentType;
    String content;

    if (chatMessage.medias != null && chatMessage.medias!.isNotEmpty) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        contentType = ContentType.image;
        content = chatMessage.medias!.first.url;
      } else if (chatMessage.medias!.first.type == MediaType.video) {
        contentType = ContentType.audio;
        content = chatMessage.medias!.first.url;
      } else if (chatMessage.medias!.first.type == MediaType.file) {
        contentType = ContentType.files;
        content = chatMessage.medias!.first.url;
      } else {
        contentType = ContentType.text;
        content = chatMessage.text;
      }
    } else {
      contentType = ContentType.text;
      content = chatMessage.text;
    }

    // Create the MessageModel
    final messageModel = MessageModel(
      senderId: _currentUser.id,
      sentAt: Timestamp.fromDate(chatMessage.createdAt),
      content: content,
      contentType: contentType,
    );

    // Add the message to the database
    await _databaseService.addMessage(
      chatId: chatId,
      messageModel: messageModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.secondaryContainer,
      leading: IconButton(
        icon: Icon(
          Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
          color: colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'userAvatar',
            child: CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.user.userProfileUrl.isNotEmpty
                    ? NetworkImage(widget.user.userProfileUrl)
                    : null,
                child: widget.user.userProfileUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 25,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context) {
    final currentUserId = _authService.user!.uid;
    final chatUserId = widget.user.userId;
    final chatId = _databaseService.generateUniqueId(
      uid1: currentUserId,
      uid2: chatUserId,
    );
    final theme = Theme.of(context).colorScheme;

    return StreamBuilder<List<MessageModel>>(
      stream: _databaseService.getMessages(chatId: chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final messages = snapshot.data!
            .map((message) {
              final messageUser =
                  message.senderId == currentUserId ? _currentUser : _chatUser;
              if (message.contentType == ContentType.image) {
                return ChatMessage(
                  text: '',
                  user: messageUser,
                  createdAt: message.sentAt.toDate(),
                  medias: [
                    ChatMedia(
                      url: message.content,
                      fileName: '',
                      type: MediaType.image,
                    ),
                  ],
                );
              } else if (message.contentType == ContentType.audio) {
                return ChatMessage(
                  text: '',
                  user: messageUser,
                  createdAt: message.sentAt.toDate(),
                  medias: [
                    ChatMedia(
                      url: message.content,
                      fileName: '',
                      type: MediaType.video,
                    ),
                  ],
                );
              } else if (message.contentType == ContentType.files) {
                return ChatMessage(
                  text: '',
                  user: messageUser,
                  createdAt: message.sentAt.toDate(),
                  medias: [
                    ChatMedia(
                      url: message.content,
                      fileName: '',
                      type: MediaType.file,
                    ),
                  ],
                );
              } else {
                return ChatMessage(
                  text: message.content,
                  user: messageUser,
                  createdAt: message.sentAt.toDate(),
                );
              }
            })
            .toList()
            .reversed
            .toList();

        return Container(
          color: theme.secondaryContainer,
          child: DashChat(
            currentUser: _currentUser,
            onSend: _sendMessages,
            messages: messages,
            inputOptions: InputOptions(
              alwaysShowSend: true,
              autocorrect: true,
              sendOnEnter: true,
              inputDecoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.onSurface,
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Icon(
                  Icons.insert_emoticon_outlined,
                  color: theme.onSurface,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => showMediaOptionsSheet(
                        context: context,
                        onCameraTap: _pickFromCamera,
                        onGalleryTap: _pickImages,
                        onFilesTap: _pickFiles,
                      ),
                      icon: const Icon(Icons.attach_file),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (_isRecording) {
                          await _stopRecording();
                        } else {
                          await _startRecording();
                        }
                      },
                      icon: Icon(
                        _isRecording
                            ? FluentIcons.stop_24_regular
                            : FluentIcons.mic_28_regular,
                        color: theme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              inputTextStyle: TextStyle(
                color: theme.onSurface,
              ),
            ),
            messageOptions: MessageOptions(
              messagePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              showTime: true,
              showOtherUsersAvatar: true,
              containerColor: theme.primary.withOpacity(0.3),
              textColor: theme.onSurface,
              currentUserContainerColor: theme.onPrimaryContainer,
              currentUserTextColor: theme.onPrimary,
              timeTextColor: theme.onSurface,
              showOtherUsersName: true,
              currentUserTimeTextColor: theme.onPrimary.withOpacity(0.8),
              spaceWhenAvatarIsHidden: 10,
            ),
          ),
        );
      },
    );
  }
}
