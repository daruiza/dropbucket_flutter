class UserCreate {
  final String email;
  final String name;
  final String password;
  final String? names;
  final String? lastnames;
  final String? phone;
  final String? theme;
  final String? prefix;
  final String? photo;
  final String rolId;

  UserCreate({
    required this.email,
    required this.name,
    required this.password,
    required this.rolId,
    this.names,
    this.lastnames,
    this.phone,
    this.theme,
    this.prefix,
    this.photo,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) {
    return UserCreate(
      email: json['user']['email'],
      name: json['user']['name'],
      password: json['user']['password'],
      names: json['user']['names'],
      lastnames: json['user']['lastnames'],
      phone: json['user']['phone'],
      theme: json['user']['theme'],
      prefix: json['user']['prefix'],
      photo: json['user']['photo'],
      rolId: json['user']['rolId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'names': names,
      'lastnames': lastnames,
      'phone': phone,
      'theme': theme,
      'prefix': prefix,
      'photo': photo,
      'rolId': rolId,
    };
  }
}
