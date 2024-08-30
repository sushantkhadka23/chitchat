import 'package:chitchat/services/alert_service.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:chitchat/services/navigation_service.dart';
import 'package:chitchat/services/permission_service.dart';
import 'package:chitchat/services/storage_service.dart';
import 'package:get_it/get_it.dart';

Future<void> setupLocator() async {
  final GetIt getIt = GetIt.instance;

  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );

  getIt.registerSingleton<AuthService>(
    AuthService(),
  );

  getIt.registerSingleton<AlertService>(
    AlertService(),
  );
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
  getIt.registerSingleton<StorageService>(
    StorageService(),
  );
  getIt.registerSingleton<PermissionService>(
    PermissionService(),
  );
}
