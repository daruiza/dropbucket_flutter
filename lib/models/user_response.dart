// lib/data/models/login_response.dart
class UserResponse {  
  final String id;
  final String email;
  final String name;
  final String? names;
  final String? lastnames;
  final String? phone;
  final String? theme;
  final String? prefix;
  final String? prefixcurrent;
  final String? photo;
  final String rolId;
  final Rol rol;
  final List<Option> options;
  final String token;

  UserResponse({
    required this.id,
    required this.email,
    required this.name,
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

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    try {
      List<Option> userOptions = [];
      if (json['user']?['rol']?['optionrols'] != null) {
        userOptions =
            (json['user']['rol']['optionrols'] as List)
                .map((optionRol) => optionRol['option'] as Map<String, dynamic>)
                .map((optionJson) => Option.fromJson(optionJson))
                .toList();
      }

      return UserResponse(
        id: json['user']['id'].toString(),
        email: json['user']['email'] ?? '',
        name: json['user']['name'] ?? '',
        names: json['user']['names'] ?? '',
        lastnames: json['user']['lastnames'] ?? '',
        phone: json['user']['phone'] ?? '',
        theme: json['user']['theme'] ?? '',
        prefix: json['user']['prefix'] ?? '',
        prefixcurrent: json['user']['prefixcurrent'] ?? json['user']['prefix'],
        photo: json['user']['photo'] ?? '',
        rolId: json['user']['rolId'].toString(),
        rol:
            json['user']?['rol'] != null
                ? Rol.fromJson(json['user']['rol'])
                : Rol(id: '1', name: '', description: ''),
        options: userOptions,
        token: json['token'] ?? '',
      );
    } catch (_) {
      rethrow;
    }
  }

  static List<UserResponse> fromJsonList(dynamic json) {
    return (json as List).map((user) => UserResponse.fromJson(user)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'names': names,
      'lastnames': lastnames,
      'phone': phone,
      'theme': theme,
      'prefix': prefix,
      'prefixcurrent': prefixcurrent,
      'photo': photo,
      'rolId': rolId,
      'rol': rol.toJson(),
      'options': options.map((Option el) => el.toJson()).toList(),
    };
  }
}

class Rol {
  final String id;
  final String name;
  final String description;
  Rol({required this.id, required this.name, required this.description});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  static List<Rol> fromJsonList(dynamic json) {
    return (json as List).map((rol) => Rol.fromJson(rol)).toList();
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class OptionRol {
  final int id;
  final int rolId;
  final int optionId;
  final Option option;

  OptionRol({
    required this.id,
    required this.rolId,
    required this.optionId,
    required this.option,
  });

  factory OptionRol.fromJson(Map<String, dynamic> json) {
    return OptionRol(
      id: json['id'],
      rolId: json['rolId'],
      optionId: json['optionId'],
      option: Option.fromJson(json['option']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rolId': rolId,
      'optionId': optionId,
      'option': option.toJson(),
    };
  }
}

class Option {
  final int id;
  final String name;
  final String? description;

  const Option({required this.id, required this.name, this.description});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] ?? 1,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
