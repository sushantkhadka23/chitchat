import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //adding profile picture of user
  Future<String> uploadProfilePicture({
    required File file,
    required String uid,
  }) async {
    try {
      String fileName = p.basename(file.path);
      String ext = p.extension(fileName);

      // Create a reference with the original filename and extension
      Reference ref =
          _storage.ref().child('profile_pictures').child('$uid$ext');

      // Upload file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<List<String>> uploadMultipleImages({
    required List<File> files,
    required String uid1,
    required String uid2,
  }) async {
    List<String> downloadUrls = [];

    try {
      // Create a folder name based on the user IDs
      String chatFolder = '${uid1}_$uid2';

      for (var file in files) {
        String fileName = p.basename(file.path);
        String ext = p.extension(fileName);

        // Create a reference with the chat folder and file details
        Reference ref = _storage
            .ref()
            .child('message_pictures')
            .child(chatFolder)
            .child('${DateTime.now().millisecondsSinceEpoch}$ext');

        // Upload file to Firebase Storage
        UploadTask uploadTask = ref.putFile(file);
        // Wait for upload to complete
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }

    return downloadUrls;
  }

  Future<String> uploadAudios({
    required File file,
    required String uid1,
    required String uid2,
  }) async {
    try {
      // Create a folder name based on the user IDs
      String chatFolder = '${uid1}_$uid2';

      String fileName = p.basename(file.path);
      String ext = p.extension(fileName);

      // Create a reference with the chat folder and file details
      Reference ref = _storage
          .ref()
          .child('message_audios')
          .child(chatFolder)
          .child('${DateTime.now().millisecondsSinceEpoch}$ext');

      // Upload file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  Future<List<String>> uploadFiles({
    required List<File> files,
    required String uid1,
    required String uid2,
  }) async {
    List<String> downloadUrls = [];
    try {
      String chatFolder = '${uid1}_$uid2';

      for (var file in files) {
        String fileName = p.basename(file.path);
        String ext = p.extension(fileName);

        // Create a reference with the files folder
        Reference ref = _storage
            .ref()
            .child('message_files')
            .child(chatFolder)
            .child('${DateTime.now().millisecondsSinceEpoch}$ext');

        // Upload files to Firebase Storage
        UploadTask uploadTask = ref.putFile(file);
        // Wait for upload to complete
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
    return downloadUrls;
  }
}
