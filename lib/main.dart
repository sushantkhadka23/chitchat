import 'package:chitchat/firebase_options.dart';
import 'package:chitchat/services/auth_service.dart';
import 'package:chitchat/services/navigation_service.dart';
import 'package:chitchat/theme/theme.dart';
import 'package:chitchat/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupLocator();
  runApp(ChitChat());
}

// ignore: must_be_immutable
class ChitChat extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;

  ChitChat({
    super.key,
  }) {
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigationService.navigationKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: _authService.user != null ? '/index' : '/signin',
        routes: _navigationService.routes,
      ),
    );
  }
}
