import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/services/interceptor_service.dart';
import 'package:dropbucket_flutter/constants.dart';

class RolService extends ChangeNotifier {  
  final String _baseUrl = '${Constants.apiBaseUrl}/rol';

  final InterceptorService _httpService;
  // final AuthProvider _authProvider;

  RolService(BuildContext context) : _httpService = InterceptorService(context)
  // _authProvider = Provider.of<AuthProvider>(context, listen: false)
  {
    // _initService();
  }

  Future<List<Rol>> rols() async {
    // De momento inecesario pero se pude usar para verificar sin ir a back
    final url = _baseUrl;
    try {
      final response = await _httpService.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Rol.fromJsonList((data as List).map((rol) => (rol)).toList());
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
