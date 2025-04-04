import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropbucket_flutter/constants.dart';

class AuthService extends ChangeNotifier {
  // final String _baseUrl = 'nestjs:3031';
  // final String _baseUrl = 'http://3.239.255.151:3031';
  // final String _baseUrl = 'http://asistirensalud.online:3031';
  // final String _baseUrl = 'http://localhost:3031';
  final String _baseUrl = Constants.apiBaseUrl;

  final _storage = FlutterSecureStorage();

  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
    };     

    try {
      final Response response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(authData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Agregar / al prefix y al prefix
        if (data['user']['prefix'] != null &&
            data['user']['prefix'] != '' &&
            !data['user']['prefix'].endsWith('/')) {
          data['user']['prefix'] += '/';
        }

        data['user']['prefixcurrent'] = data['user']['prefix'] ?? '';

        final userResponse = UserResponse.fromJson(data);

        await _storage.write(key: 'token', value: userResponse.token);
        await _storage.write(
          key: "user_data",
          value: jsonEncode(data),
        ); // Usuario y sus permisos
      } else {
        throw Exception(response.body);
      }
    } catch (_) {
      // todo: Evaluar a ver si se puede llamar aqui el mensajede error
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user_data');
    return;
  }

  Future<String> readToken() async {
    return await _storage.read(key: 'token') ?? '';
  }
}
