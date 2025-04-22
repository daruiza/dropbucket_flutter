import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class RequestUploadQuery {
  final String? prefix;
  final String? message;
  final String? user;
  final String? date;

  RequestUploadQuery(this.prefix, this.message, this.user, this.date);

  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final iv = encrypt.IV.fromLength(16);

  factory RequestUploadQuery.fromJson(Map<String, dynamic> json) {
    return RequestUploadQuery(
      json['prefix'] ?? '',
      json['message'] ?? '',
      json['user'] ?? '',
      json['date'] ?? '',
    );
  }

  static String encryptValue(String value) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(value, iv: iv);
    // Base64 seguro para URLs
    String base64 = encrypted.base64;
    String base64UrlSafe = base64
        .replaceAll('+', '-') // Reemplaza '+' con '-'
        .replaceAll('/', '_') // Reemplaza '/' con '_'
        .replaceAll('=', ''); // Quita '='
    return base64UrlSafe;
  }

  static String decryptValue(String encryptedValue) {
    // Restore Base64 padding
    String base64 = encryptedValue
        .replaceAll('-', '+') // Replace '-' with '+'
        .replaceAll('_', '/'); // Replace '_' with '/'

    // Add padding '=' characters
    while (base64.length % 4 != 0) {
      base64 += '=';
    }
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(base64, iv: iv);
  }

  static String encriptarPrefix(String prefix) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(prefix, iv: iv);
    return encrypted.base64;
  }

  static String desencriptarPrefix(String prefixEncriptado) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(prefixEncriptado, iv: iv);
    return decrypted;
  }

  /// Método para encriptar un valor
  static String simpleEncryptValue(String value) {
    // Convierte el valor en bytes usando UTF-8
    List<int> bytes = utf8.encode(value);
    // Convierte los bytes a base64 seguro para URLs
    String base64UrlSafe = base64Url.encode(bytes);
    return base64UrlSafe;
  }

  /// Método para desencriptar un valor
  static String simppleDecryptValue(String encryptedValue) {
    // Convierte el base64 seguro para URLs de vuelta a bytes
    List<int> bytes = base64Url.decode(encryptedValue);
    // Convierte los bytes a un string UTF-8
    return utf8.decode(bytes);
  }
}
