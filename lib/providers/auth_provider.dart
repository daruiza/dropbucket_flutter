import 'package:dropbucket_flutter/utils/request_upload_query.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:dropbucket_flutter/constants.dart';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropbucket_flutter/utils/data_utils.dart';

class AuthProvider extends ChangeNotifier {
  // BuildContext context;
  final _storage = FlutterSecureStorage();
  UserResponse? user;
  String token = '';
  bool isAuthenticated = false;

  // UserResponse? get user => _user;
  // String get token => _token;
  // bool get isAuthenticated => _isAuthenticated;

  // set user(UserResponse? value) {
  //   _user = value;
  //   //notifyListeners();
  // }

  // set token(String value) {
  //   _token = value;
  //   //notifyListeners();
  // }

  // set isAuthenticated(bool value) {
  //   _isAuthenticated = value;
  //   //notifyListeners();
  // }

  // AuthProvider(this.context) {
  AuthProvider() {
    checkToken();
  }

  Future<bool> chieckIsAutorizeDate(Map<String, String> args) async {
    return !DateUtilsLocal.limitDate(
      Constants.limitDateValid,
      DateTime.parse(args['date'] ?? ''),
      DateTime.now(),
    );
  }

  Future<bool> chieckIsAutorizeDate02(String prefix) async {
    RequestUploadQuery auxquery = RequestUploadQuery.fromJson(
      jsonDecode(RequestUploadQuery.simppleDecryptValue(prefix)),
    );
    return !DateUtilsLocal.limitDate(
      Constants.limitDateValid,
      DateTime.parse(auxquery.date ?? ''),
      DateTime.now(),
    );
  }

  Future<bool> chieckIsAutenticate() async {
    final token = await _storage.read(key: 'token');
    return token != null && token != '';
  }

  checkToken() async {
    final token = await _storage.read(key: 'token');
    this.token = '';
    isAuthenticated = false;
    user = null;
    if (token != null && token != '') {
      try {
        String payload = utf8.decode(
          base64.decode(base64.normalize(token.split('.')[1])),
        );
        Map<String, dynamic> payloadMap = json.decode(payload);

        // Obtener el tiempo de expiración
        int exp = payloadMap['exp'];
        // Obtener la hora actual en segundos desde la época Unix
        int ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // Verificar si el token ha expirado
        if (ahora < exp) {
          this.token = token;
          isAuthenticated = true;
          final user = await _storage.read(key: 'user_data');
          this.user = UserResponse.fromJson(jsonDecode(user ?? ''));
        }
      } catch (e) {
        // TODO: enviar un mensaje de token expirado
        rethrow;
      }
    }
    notifyListeners();
  }

  // Método para manejar la redirección segura en caso de error 401
  void handleUnauthorized(BuildContext context) async {
    token = '';
    user = null;
    isAuthenticated = false;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user_data');
    if (context.mounted) {
      _redirectToLogin(context); // Navega al login
    }
  }

  Future<void> setUserPrefix(
    BuildContext context,
    prefix, [
    bool replace = false,
    bool notify = true,
  ]) async {
    final token = await _storage.read(key: 'token');
    if (token != '') {
      final userData = await _storage.read(key: "user_data") ?? '';
      final userJson = jsonDecode(userData);
      userJson['user']['prefixcurrent'] =
          replace ? prefix : '${userJson['user']['prefixcurrent']}$prefix/';
      await _storage.delete(key: 'user_data');
      await _storage.write(key: "user_data", value: jsonEncode(userJson));
      user = UserResponse.fromJson(userJson);
      if (notify) {
        notifyListeners();
      }
    } else {
      //emitimos error de autenticación
      if (context.mounted) {
        _redirectToLogin(context);
      }
    }
  }

  // Método para navegar al login utilizando el contexto
  void _redirectToLogin(BuildContext context) {
    // esta forma falla
    // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const LoginScreen();
        },
      ),
      (_) => false,
    );
  }
}
