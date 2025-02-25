import 'package:dropbucket_flutter/auth_middleware.dart';
import 'package:dropbucket_flutter/screens/screens.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String login = 'login';
  static const String profile = 'profile';
  static const String home = 'home';
  static const String welcome = 'welcome';
  static const String bucket = 'bucket';
  static const String users = 'users';
  static const String test = 'test';
  static const String requestUpload = 'request_upload';

  static const initialRoute = Routes.login;

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/':
          (context) => AuthMiddleware(
            child: const HomeScreen(),
            onUnauthorized: () => const LoginScreen(),
          ),
      Routes.home:
          (context) => AuthMiddleware(
            child: const HomeScreen(),
            onUnauthorized: () => const LoginScreen(),
          ),
      Routes.profile:
          (context) => AuthMiddleware(
            child: const ProfileScreen(),
            onUnauthorized: () => const LoginScreen(),
          ),
      Routes.login:
          (context) => AuthMiddleware(
            child: const LoginScreen(),
            onUnauthorized: () => const LoginScreen(),
          ),
      // '/': (context) => HomeScreen(),
      // Routes.home: (context) => HomeScreen(),
      // Routes.profile: (context) => ProfileScreen(),
      // Routes.login: (context) => LoginScreen(),
    };
  }
}
