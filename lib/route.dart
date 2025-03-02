import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:dropbucket_flutter/auth_middleware.dart';
import 'package:dropbucket_flutter/screens/screens.dart';
import 'package:dropbucket_flutter/utils/request_upload_query.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';

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

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name!);

    // Verificar si la ruta coincide con el patrón específico
    if (uri.path.startsWith('request_upload_uri/')) {
      // Extraer el valor del path después de 'request_upload_uri/'
      final prefix = uri.path.split('/').last;

      return MaterialPageRoute(
        builder: (context) {
          return FutureBuilder<bool>(
            future:
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).chieckIsAutenticate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == true) {
                  // Descomposición de prefix en prefix mensaje y usuario
                  RequestUploadQuery auxquery = RequestUploadQuery.fromJson(
                    jsonDecode(RequestUploadQuery.simppleDecryptValue(prefix)),
                  );

                  return RequestUploadScreen(
                    query: RequestUploadQuery(
                      auxquery.prefix,
                      auxquery.message,
                      auxquery.user,
                    ),
                  );
                } else {
                  return LoginScreen();
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          );
        },
      );
    }

    if (uri.path.startsWith('request_upload_uri')) {
      final args = uri.queryParameters;
      return MaterialPageRoute(
        builder: (context) {
          return FutureBuilder<bool>(
            future:
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).chieckIsAutenticate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == true) {
                  return RequestUploadScreen(
                    query: RequestUploadQuery(
                      args['prefix'],
                      args['message'],
                      args['user'],
                    ),
                  );
                } else {
                  return LoginScreen();
                }
              }
              return Center(child: CircularProgressIndicator());
            },
          );
        },
      );
    }

    return null;
  }
}
