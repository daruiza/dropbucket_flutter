import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';

// final logger = Logger(); // Inicializa el logger

class InterceptorService {
  final BuildContext context;
  final AuthProvider _authProvider;

  InterceptorService(this.context)
    : _authProvider = Provider.of<AuthProvider>(context, listen: false);

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
    bool isDownload = false,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);
      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }

      final headers = <String, String>{
        'Authorization': 'Bearer ${_authProvider.token}',
      };
      if (!isDownload) {
        headers['Content-Type'] = 'application/json;charset=utf-8';
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
    bool isLogin = false,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '' && !isLogin) {
        throw Exception('No authentication token found');
      }

      //todas las peticions son json
      final headers = <String, String>{
          'Content-Type': 'application/json;charset=utf-8',
      };
      if (!isLogin) {
        headers['Authorization'] = 'Bearer ${_authProvider.token}';
      }      

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> patch(
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json;charset=utf-8',
        },
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> uploadFile(
    String path, {
    required String filePath,
    required String fileField,
    Map<String, String>? fields,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }

      // Crear request multipart
      final request = http.MultipartRequest('POST', uri);

      // Agregar headers de autorización
      request.headers.addAll({
        'Authorization': 'Bearer ${_authProvider.token}',
      });

      // Agregar el archivo
      final file = await http.MultipartFile.fromPath(
        fileField, // nombre del campo del archivo en el servidor
        filePath, // ruta del archivo en el dispositivo
      );
      request.files.add(file);

      // Agregar campos adicionales si existen
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Enviar la petición
      final streamedResponse = await request.send();

      // Convertir StreamedResponse a Response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> uploadFiles(
    String path, {
    required List<DropItem> files,
    Map<String, String>? fields,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer ${_authProvider.token}',
      });

      // Agregar campos adicionales si existen
      if (fields != null) {
        request.fields.addAll(fields);
      }

      for (var file in files) {
        final fileExt = file.name.split('.').last;
        final mimeType = getMimeType(fileExt).split('/');
        final bytes = await file.readAsBytes();
        http.MultipartFile multipartFile;
        multipartFile = http.MultipartFile.fromBytes(
          'files', // Este es el nombre esperado por el backend
          bytes,
          filename: file.name,
          contentType: MediaType(mimeType[0], mimeType[1]),
        );

        request.files.add(multipartFile);
      }

      // Enviar la petición
      final streamedResponse = await request.send();

      // Convertir StreamedResponse a Response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> uploadByteFile(
    String path, {
    required List<int> fileByte,
    required String fileField,
    required String fileName,
    required String extension,
    Map<String, String>? fields,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }

      // Crear request multipart
      final request = http.MultipartRequest('POST', uri);

      // Agregar headers de autorización
      request.headers.addAll({
        'Authorization': 'Bearer ${_authProvider.token}',
      });

      final fileExt = fileName.split('.').last;
      final mimeType = getMimeType(fileExt).split('/');

      // Agregar el archivo
      final file = http.MultipartFile.fromBytes(
        'file',
        fileByte,
        filename: fileField,
        contentType: MediaType(mimeType[0], mimeType[1]),
      );
      request.files.add(file);

      // Agregar campos adicionales si existen
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Enviar la petición
      final streamedResponse = await request.send();

      // Convertir StreamedResponse a Response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> uploadMultipleFiles(
    String path, {
    required List<PlatformFile> files,
    Map<String, String>? fields,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      if (_authProvider.token == '') {
        throw Exception('No authentication token found');
      }
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer ${_authProvider.token}',
      });

      // Agregar campos adicionales si existen
      if (fields != null) {
        request.fields.addAll(fields);
      }

      for (var file in files) {
        final fileExt = file.name.split('.').last;
        final mimeType = getMimeType(fileExt).split('/');

        http.MultipartFile multipartFile;
        // Verificar si tenemos bytes o necesitamos leer desde el archivo
        if (file.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'files', // Este es el nombre esperado por el backend
            file.bytes!,
            filename: file.name,
            contentType: MediaType(mimeType[0], mimeType[1]),
          );
        } else if (file.path != null) {
          // Leer desde el archivo (funcionará en desktop)
          // final fileStream = File(file.path!).openRead();
          multipartFile = await http.MultipartFile.fromPath(
            'files',
            file.path!,
            contentType: MediaType(mimeType[0], mimeType[1]),
          );
        } else {
          throw Exception(
            'No se pueden obtener los datos del archivo ${file.name}',
          );
        }
        request.files.add(multipartFile);
      }

      // Enviar la petición
      final streamedResponse = await request.send();

      // Convertir StreamedResponse a Response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }


  Future<http.Response> uploadMultipleFilesPublic(
    String path, {
    required List<PlatformFile> files,
    Map<String, String>? fields,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);

      final request = http.MultipartRequest('POST', uri);      

      // Agregar campos adicionales si existen
      if (fields != null) {
        request.fields.addAll(fields);
      }

      for (var file in files) {
        final fileExt = file.name.split('.').last;
        final mimeType = getMimeType(fileExt).split('/');

        http.MultipartFile multipartFile;
        // Verificar si tenemos bytes o necesitamos leer desde el archivo
        if (file.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'files', // Este es el nombre esperado por el backend
            file.bytes!,
            filename: file.name,
            contentType: MediaType(mimeType[0], mimeType[1]),
          );
        } else if (file.path != null) {
          // Leer desde el archivo (funcionará en desktop)
          // final fileStream = File(file.path!).openRead();
          multipartFile = await http.MultipartFile.fromPath(
            'files',
            file.path!,
            contentType: MediaType(mimeType[0], mimeType[1]),
          );
        } else {
          throw Exception(
            'No se pueden obtener los datos del archivo ${file.name}',
          );
        }
        request.files.add(multipartFile);
      }

      // Enviar la petición
      final streamedResponse = await request.send();

      // Convertir StreamedResponse a Response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (context.mounted) {
          _authProvider.handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  String getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'zip':
        return 'application/zip';
      case 'json':
        return 'application/json;charset=utf-8';
      default:
        return 'application/octet-stream'; // Por defecto
    }
  }
}
