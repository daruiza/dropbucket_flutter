import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:http/http.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/services/interceptor_service.dart';

class BucketService extends ChangeNotifier {
  // final String _baseUrl = 'nestjs:3000/bucket';
  final String _baseUrl = 'http://3.239.255.151:3000/bucket';
  // final String _baseUrl = 'http://temposolutions.online:3000/bucket';
  // final String _baseUrl = 'http://localhost:3000/bucket';
  final InterceptorService _httpService;
  final AuthProvider _authProvider;

  ApiResponse items = ApiResponse(files: [], folders: []);
  bool isLoading = false;

  // ApiResponse get items => _items;
  // set items(ApiResponse value) {
  //   _items = value;
  //   // notifyListeners();
  // }

  // bool get isLoading => _isLoading;
  // set isLoading(bool value) {
  //   _isLoading = value;
  //   // notifyListeners();
  // }

  BucketService(BuildContext context)
    : _httpService = InterceptorService(context),
      _authProvider = Provider.of<AuthProvider>(context, listen: false) {
    // _initService();
  }

  // void _initService() async {
  //   try {
  //     items = await fetchItemsList();
  //   } catch (e) {
  //     // TODO: necesitamos impimir en caso de error
  //     rethrow;
  //   } finally {
  //     isLoading = false;
  //   }
  // }

  void itemsList() async {
    try {
      items = await fetchItemsList();
    } catch (e) {
      // TODO: necesitamos impimir en caso de error
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> itemsListFuture() async {
    try {
      items = await fetchItemsList();
    } catch (e) {
      // TODO: necesitamos impimir en caso de error
      rethrow;
    } finally {}
  }

  Future<ApiResponse> fetchItemsList() async {
    final url = '$_baseUrl/list';
    try {
      final response = await _httpService.get(
        url,
        queryParams: {
          'prefix': _authProvider.user?.prefixcurrent ?? '',
          'size': 'false',
          'sort': '{"by": "date", "order": "asc"}',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> existFile(String prefix) async {
    final url = '$_baseUrl/exists';
    try {
      final response = await _httpService.get(
        url,
        queryParams: {'key': prefix},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> storeFile({
    required PlatformFile file,
    String? prefix,
  }) async {
    final url = '$_baseUrl/upload';
    try {
      final response = await _httpService.uploadByteFile(
        url,
        fileField: file.name,
        fileByte: file.bytes!,
        fileName: file.name,
        extension: file.extension ?? file.name.split('.').last,
        fields: {'prefix': prefix ?? _authProvider.user?.prefixcurrent ?? ''},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> storeFiles({
    required List<PlatformFile> files,
    String? prefix,
  }) async {
    final url = '$_baseUrl/upload-multiple';
    try {
      final response = await _httpService.uploadMultipleFiles(
        url,
        files: files,
        fields: {'prefix': prefix ?? _authProvider.user?.prefixcurrent ?? ''},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> storeBlobFiles({
    required List<DropItem> files,
    String? prefix,
  }) async {
    final url = '$_baseUrl/upload-multiple';
    try {      

      final response = await _httpService.uploadFiles(
        url,
        files: files,
        fields: {'prefix': prefix ?? _authProvider.user?.prefixcurrent ?? ''},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> renamePrefix({
    required String name,
    required String rename,
  }) async {
    final url = '$_baseUrl/renameprefix';
    try {
      final response = await _httpService.get(
        url,
        queryParams: {'oldprefix': name, 'newprefix': rename},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> renameFile({
    required String name,
    required String rename,
  }) async {
    final url = '$_baseUrl/renamefile';
    try {
      final response = await _httpService.get(
        url,
        queryParams: {'oldkey': name, 'newkey': rename},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> downloadFile({required FileItem file}) async {
    final url = '$_baseUrl/object';
    try {
      final response = await _httpService.get(
        url,
        queryParams: {'key': file.name},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sharedFile({required FileItem file}) async {
    final url = '$_baseUrl/url';
    try {
      final response = await _httpService.get(
        url,
        queryParams: {'key': file.name},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteFile(
    fileItem, {
    required FileItem file,
    String? fileName,
  }) async {
    final url = _baseUrl;
    try {
      final response = await _httpService.delete(
        url,
        queryParams: {'key': fileName ?? file.name},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createFolder(String prefix) async {
    final url = '$_baseUrl/create/prefix';
    try {
      final response = await _httpService.post(
        url,
        queryParams: {
          'key': '${_authProvider.user?.prefixcurrent ?? ''}$prefix',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteFolder(String prefix) async {
    final url = '$_baseUrl/delete/prefix';
    try {
      final response = await _httpService.delete(
        url,
        queryParams: {
          'key': '${_authProvider.user?.prefixcurrent ?? ''}$prefix',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
