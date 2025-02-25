import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/services/interceptor_service.dart';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/models/user_create.dart';
import 'package:dropbucket_flutter/models/user_patch.dart';

// class UserService extends ChangeNotifier {
class UserService {
  final String _baseUrl = 'http://localhost:3000/user';
  final InterceptorService _httpService;
  final AuthProvider _authProvider;
  final _storage = FlutterSecureStorage();

  UserService(BuildContext context)
    : _httpService = InterceptorService(context),
      _authProvider = Provider.of<AuthProvider>(context, listen: false);

  Future<UserResponse> user() async {    
    final user = _authProvider.user;
    final url = '$_baseUrl/${user?.id}';
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserResponse.fromJson({'user': data});
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCreate> userPost(UserCreate userData) async {    
    final url = _baseUrl;
    try {
      final response = await _httpService.post(url, body: userData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserCreate.fromJson({'user': data});
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserResponse> userPatch(UserResponse userResponse) async {    
    final url = '$_baseUrl/${userResponse.id}';
    try {
      final response = await _httpService.patch(url, body: userResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Actualizamos la data del store
        final userData = await _storage.read(key: 'user_data');
        Map<String, dynamic> jsonUser = jsonDecode(userData ?? '');

        // actualizamos user con la la información de userData
        jsonUser['user']['email'] = userResponse.email;
        jsonUser['user']['name'] = userResponse.name;
        jsonUser['user']['names'] = userResponse.names;
        jsonUser['user']['lastnames'] = userResponse.lastnames;
        jsonUser['user']['phone'] = userResponse.phone;
        jsonUser['user']['theme'] = userResponse.theme;
        jsonUser['user']['prefix'] = userResponse.prefix;
        jsonUser['user']['photo'] = userResponse.photo;

        // UserResponse user = UserResponse.fromJson(jsonUser);

        // actualizamos user con la la información de userData
        await _storage.write(
          key: "user_data",
          value: jsonEncode(jsonUser),
        ); 

        return UserResponse.fromJson({'user': data});
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserResponse> userPatchPassword(UserPatch userData) async {   
    final url = '$_baseUrl/${userData.id}';
    try {
      final response = await _httpService.patch(url, body: userData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserResponse.fromJson({'user': data});
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteUser(UserResponse user) async {   
    final url = '$_baseUrl/${user.id}';
    try {
      final response = await _httpService.delete(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserResponse>> users() async {   
    final url = _baseUrl;
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserResponse.fromJsonList(
          (data as List).map((user) => ({'user': user})).toList(),
        );
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
