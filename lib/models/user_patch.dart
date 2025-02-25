
import 'package:dropbucket_flutter/models/user_response.dart';

class UserPatch {
  final int id;
  final String email;
  final String name;
  final String? password;
  final String? names;
  final String? lastnames;
  final String? phone;
  final String? theme;
  final String? prefix;
  final String? prefixcurrent;
  final String? photo;
  final int rolId;
  final Rol rol;
  final List<Option> options;
  final String token;

  UserPatch({
    required this.id,
    required this.email,
    required this.name,
    this.password,
    this.names,
    this.lastnames,
    this.phone,
    this.theme,
    this.prefix,
    this.prefixcurrent,
    this.photo,
    required this.rolId,
    required this.rol,
    required this.options,
    required this.token,
  });

  factory UserPatch.fromJson(Map<String, dynamic> json) {
    List<Option> userOptions = [];
    if (json['user']?['rol']?['optionrols'] != null) {
      userOptions = (json['user']['rol']['optionrols'] as List)
          .map((optionRol) => optionRol['option'] as Map<String, dynamic>)
          .map((optionJson) => Option.fromJson(optionJson))
          .toList();
    }

    return UserPatch(
      id: json['user']['id'],
      email: json['user']['email'],
      name: json['user']['name'],
      password: json['user']['password'],
      names: json['user']['names'],
      lastnames: json['user']['lastnames'],
      phone: json['user']['phone'],
      theme: json['user']['theme'],
      prefix: json['user']['prefix'],
      prefixcurrent: json['user']['prefixcurrent'] ?? json['user']['prefix'],
      photo: json['user']['photo'],
      rolId: json['user']['rolId'],
      rol: json['user']?['rol'] != null
          ? Rol.fromJson(json['user']?['rol'])
          : Rol(id: 0, name: '', description: ''),
      options: userOptions,
      token: json['token'] ?? '',
    );
  }

  static List<UserResponse> fromJsonList(dynamic json) {
    return (json as List).map((user) => UserResponse.fromJson(user)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      'names': names,
      'lastnames': lastnames,
      'phone': phone,
      'theme': theme,
      'prefix': prefix,
      'prefixcurrent': prefixcurrent,
      'photo': photo,
      'rolId': rolId,
      'rol': rol.toJson(),
      'options': options.map((Option el) => el.toJson()).toList()
    };
  }
}