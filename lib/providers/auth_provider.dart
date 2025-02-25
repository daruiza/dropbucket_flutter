import 'dart:convert';

import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  // BuildContext context;
  final _storage = FlutterSecureStorage();
  UserResponse? _user;
  String _token = '';
  bool _isAuthenticated = false;

  UserResponse? get user => _user;
  String get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  set user(UserResponse? value) {
    _user = value;
    notifyListeners();
  }

  set token(String value) {
    _token = value;
    notifyListeners();
  }

  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  // AuthProvider(this.context) {
  AuthProvider() {
    checkToken();
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
      }
    }    // notifyListeners();
  }

  // Método para manejar la redirección segura en caso de error 401
  void handleUnauthorized(BuildContext context) async {
    _token = '';
    _user = null;
    _isAuthenticated = false;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user_data');
    if (context.mounted) {
      _redirectToLogin(context); // Navega al login
    }
  }

  Future<void> setUserPrefix(prefix, [bool replace = false]) async {
    final userJson = jsonDecode(await _storage.read(key: "user_data") ?? '');
    userJson['user']['prefixcurrent'] =
        replace ? prefix : '${userJson['user']['prefixcurrent']}$prefix/';
    await _storage.delete(key: 'user_data');
    await _storage.write(key: "user_data", value: jsonEncode(userJson));
    user = UserResponse.fromJson(userJson);
    notifyListeners();
  }

  // Método para navegar al login utilizando el contexto
  void _redirectToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
