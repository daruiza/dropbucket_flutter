import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

//import 'package:http/http.dart';
//import 'package:http/http.dart' as http;
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:dropbucket_flutter/services/interceptor_service.dart';
import 'package:dropbucket_flutter/constants.dart';

class AuthService extends ChangeNotifier {  
  final String _baseUrl = Constants.apiBaseUrl;
  //final InterceptorService _httpService;
  final Dio _dio = Dio();

  final _storage = FlutterSecureStorage();

  //AuthService(BuildContext context)
  //  : _httpService = InterceptorService(context);

  Future<void> loginUser(String email, String password) async {
    //final url = Uri.parse('$_baseUrl/auth/login');
    //final headers = {
      // 'Content-Type': 'application/x-www-form-urlencoded',
      //"Content-Type": "application/json;charset=utf-8",
      //"Accept": "application/json;charset=utf-8",
    //};

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
    };     

    try {
      //final Response response = await http.post(
      //  url,
      //  headers: headers,
      //  body: jsonEncode(authData),
      //);

      //final response = await _httpService.post(
      //  '$_baseUrl/auth/login', 
      //  body: authData,
      //  isLogin: true,
      //);

       final Response response = await _dio.post(
        '$_baseUrl/auth/login',
        data: authData, // `dio` automáticamente codifica a JSON si el header es correcto
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //final data = jsonDecode(response.body);
        final data = response.data;

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
        throw Exception(response);
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
