import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request location permission
  Future<bool> handleLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    return status.isGranted;
  }

  Future<bool> handleNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    return status.isGranted;
  }

  Future<bool> handleContactsPermission() async {
    PermissionStatus status = await Permission.contacts.status;

    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    return status.isGranted;
  }

  Future<bool> handleMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }
}
