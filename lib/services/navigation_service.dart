import 'package:chitchat/screens/auth/phone_sigin_page.dart';
import 'package:chitchat/screens/auth/user_registration.dart';
import 'package:chitchat/screens/index_screen.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  final Map<String, Widget Function(BuildContext)> routes = {
    '/signin': (context) => const PhoneSigninPage(),
    '/index': (context) => const IndexScreen(),
    '/register': (context) => const UserRegistration(),
  };

  void pushNamed(String routeName) {
    navigationKey.currentState?.pushNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    navigationKey.currentState?.push(route);
  }

  void pushReplacementNamed(String routeName) {
    navigationKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    navigationKey.currentState?.pop();
  }
}
