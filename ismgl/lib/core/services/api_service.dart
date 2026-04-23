import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:ismgl/app/routes/app_routes.dart';
import 'package:ismgl/core/services/storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storage = Get.find<StorageService>();
  Future<bool>? _refreshFuture;
  DateTime? _lastRefreshAt;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        // Ne pas lever d’exception sur 4xx/5xx : normaliser en Map côté client.
        validateStatus: (status) => status != null && status < 600,
      ),
    );
    debugPrint('🌐 ApiService.baseUrl=${_dio.options.baseUrl}');
    _setupInterceptors();
  }

  String get baseUrl => _dio.options.baseUrl;

  /// Racine du backend sans `/api/v1` (ex. `http://192.168.1.69/ismgl-api`).
  String get serverRoot {
    var u = baseUrl.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    const suffix = '/api/v1';
    if (u.length >= suffix.length &&
        u.substring(u.length - suffix.length).toLowerCase() == suffix) {
      return u.substring(0, u.length - suffix.length);
    }
    return u;
  }

  /// [href] absolue ou chemin commençant par `/` ou relatif au [serverRoot].
  String resolvePublicUrl(String href) {
    final h = href.trim();
    if (h.isEmpty) return baseUrl;
    if (h.startsWith('http://') || h.startsWith('https://')) return h;
    final root = serverRoot;
    if (h.startsWith('/')) return '$root$h';
    return '$root/$h';
  }

  String _resolveBaseUrl() {
    const androidEnv =
        String.fromEnvironment('API_BASE_URL_ANDROID', defaultValue: '');
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (androidEnv.isNotEmpty) return androidEnv;
    if (env.isNotEmpty) return env;
    // Use machine LAN IP by default for real device + web testing.
    // Override with --dart-define=API_BASE_URL=... when needed.
    return 'http://192.168.137.2/ismgl-api/api/v1';
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storage.getToken()?.trim();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint(
              '🔐 Bearer injecte sur ${options.path} (${token.substring(0, token.length > 16 ? 16 : token.length)}...)',
            );
          } else {
            debugPrint('⚠️ Aucun token pour ${options.path}');
          }

          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          if (token != null && token.isNotEmpty && _storage.isTokenExpired()) {
            debugPrint('🔄 Token expire: tentative refresh');
            final refreshed = await _refreshTokenSafe();
            if (refreshed) {
              final newToken = _storage.getToken()?.trim();
              if (newToken != null && newToken.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $newToken';
              }
              debugPrint('✅ Token rafraichi');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint('❌ ${e.response?.statusCode} ${e.requestOptions.path} ${e.message}');
          if (e.response?.statusCode == 401) {
            final path = e.requestOptions.path;
            if (path.contains('/auth/login') ||
                path.contains('/auth/refresh') ||
                path.contains('/auth/forgot-password') ||
                path.contains('/auth/reset-password')) {
              return handler.next(e);
            }

            final alreadyRetried = e.requestOptions.extra['auth_retried'] == true;
            if (alreadyRetried) {
              debugPrint('⏭️ Requête déjà retentée une fois: $path');
              return handler.next(e);
            }

            final refreshed = await _refreshTokenSafe();
            if (refreshed) {
              final opts = e.requestOptions;
              opts.extra['auth_retried'] = true;
              final fresh = _storage.getToken()?.trim();
              if (fresh == null || fresh.isEmpty) {
                debugPrint('⛔ Token absent après refresh');
                return handler.next(e);
              }
              opts.headers['Authorization'] = 'Bearer $fresh';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (retryError) {
                debugPrint('⚠️ Retry after refresh failed: $retryError');
                return handler.next(e);
              }
            }
            debugPrint('⛔ Refresh échoué: fermeture de session');
            await _storage.clearSession();
            Get.offAllNamed(AppRoutes.login);
          }
          return handler.next(e);
        },
      ),
    );

  }

  Future<bool> _refreshTokenSafe() async {
    if (_refreshFuture != null) return _refreshFuture!;
    _refreshFuture = _refreshToken();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.trim().isEmpty) {
        debugPrint('❌ No refresh token found');
        return false;
      }

      debugPrint('🔄 Refreshing token...');
      final response = await Dio().post(
        '${_dio.options.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken.trim()},
      );

      final body = response.data;
      if (response.statusCode == 200 && body is Map && body['data'] is Map) {
        final data = body['data'] as Map<String, dynamic>;
        final token = (data['token'] ?? data['access_token'] ?? '').toString().trim();
        if (token.isEmpty) return false;

        await _storage.saveToken(token);
        await _storage.saveRefreshToken(
          (data['refresh_token']?.toString().trim().isNotEmpty ?? false)
              ? data['refresh_token'].toString().trim()
              : refreshToken.trim(),
        );
        await _storage.saveTokenExpiry(
          DateTime.now().add(
            Duration(
              seconds: int.tryParse(data['expires_in']?.toString() ?? '86400') ??
                  86400,
            ),
          ),
        );
        _lastRefreshAt = DateTime.now();
        debugPrint('✅ Token refreshed successfully');
        return true;
      }
      debugPrint('❌ Refresh failed with status ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Refresh error: $e');
    }
    return false;
  }

  Map<String, dynamic> _fromHttpResponse(Response<dynamic> response) {
    final code = response.statusCode ?? 0;
    if (code >= 400) {
      final data = response.data;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        m['success'] = m['success'] ?? false;
        m['status_code'] = m['status_code'] ?? code;
        m['message'] = m['message']?.toString() ?? 'Erreur serveur ($code)';
        return m;
      }
      if (data is String && data.isNotEmpty) {
        final short =
            data.length > 220 ? '${data.substring(0, 220)}…' : data;
        return {
          'success': false,
          'message': short,
          'status_code': code,
          'data': null,
        };
      }
      return {
        'success': false,
        'message': 'Erreur serveur ($code)',
        'status_code': code,
        'data': null,
      };
    }
    return _normalizeBody(response.data, code);
  }

  // GET
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? params}) async {
    try {
      debugPrint('\n🔵 GET: $endpoint');
      debugPrint('   Params: $params');
      final response = await _dio.get(endpoint, queryParameters: params);
      return _fromHttpResponse(response);
    } on DioException catch (e) {
      debugPrint('   ❌ Error: ${e.message}');
      return _handleError(e);
    }
  }

  // POST
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      debugPrint('\n🔵 POST: $endpoint');
      debugPrint('   Data: $data');
      final response = await _dio.post(endpoint, data: data);
      return _fromHttpResponse(response);
    } on DioException catch (e) {
      debugPrint('   ❌ Error: ${e.message}');
      return _handleError(e);
    }
  }

  // PUT
  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      debugPrint('\n🔵 PUT: $endpoint');
      debugPrint('   Data: $data');
      final response = await _dio.put(endpoint, data: data);
      return _fromHttpResponse(response);
    } on DioException catch (e) {
      debugPrint('   ❌ Error: ${e.message}');
      return _handleError(e);
    }
  }

  // PATCH
  Future<Map<String, dynamic>> patch(String endpoint, {dynamic data}) async {
    try {
      debugPrint('\n🔵 PATCH: $endpoint');
      debugPrint('   Data: $data');
      final response = await _dio.patch(endpoint, data: data);
      return _fromHttpResponse(response);
    } on DioException catch (e) {
      debugPrint('   ❌ Error: ${e.message}');
      return _handleError(e);
    }
  }

  // DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      debugPrint('\n🔵 DELETE: $endpoint');
      final response = await _dio.delete(endpoint);
      return _fromHttpResponse(response);
    } on DioException catch (e) {
      debugPrint('   ❌ Error: ${e.message}');
      return _handleError(e);
    }
  }

  // Upload multipart
  Future<Map<String, dynamic>> upload(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, File>? files,
    String method = 'POST',
  }) async {
    try {
      debugPrint('\n🔵 UPLOAD [$method]: $endpoint');
      debugPrint('   Fields: $fields');
      debugPrint('   Files: ${files?.keys}');
      
      final formData = FormData.fromMap(fields);

      if (files != null) {
        for (final entry in files.entries) {
          debugPrint('   Adding file: ${entry.key} = ${entry.value.path}');
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(entry.value.path),
          ));
        }
      }

      final response = method == 'POST'
          ? await _dio.post(endpoint, data: formData)
          : await _dio.put(endpoint, data: formData);

      return _fromHttpResponse(response);
    } on DioException catch (e) {
      debugPrint('   ❌ Error: ${e.message}');
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleError(DioException e) {
    debugPrint('\n🔴 ERROR HANDLER:');
    debugPrint('   Type: ${e.type}');
    debugPrint('   Message: ${e.message}');
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      debugPrint('   ⚠️ Timeout error');
      return {
        'success': false,
        'message': 'Délai de connexion dépassé. Vérifiez votre connexion.',
        'status_code': 408,
        'data': null
      };
    }

    if (e.type == DioExceptionType.connectionError) {
      debugPrint('   ⚠️ Connection error');
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur.',
        'status_code': 503,
        'data': null
      };
    }

    if (e.type == DioExceptionType.unknown) {
      final sinceRefresh = _lastRefreshAt == null
          ? null
          : DateTime.now().difference(_lastRefreshAt!);
      debugPrint('   ⚠️ Unknown network error (since refresh: $sinceRefresh)');
    }

    if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is Map<String, dynamic>) {
        responseData['success'] = responseData['success'] ?? false;
        responseData['status_code'] =
            responseData['status_code'] ?? e.response!.statusCode;
        return responseData;
      }
      return {
        'success': false,
        'message': 'Erreur serveur',
        'status_code': e.response!.statusCode,
        'data': null,
      };
    }

    debugPrint('   ⚠️ Unknown error');
    return {
      'success': false,
      'message': 'Une erreur inattendue est survenue.',
      'status_code': 500,
      'data': null
    };
  }

  Map<String, dynamic> _normalizeBody(dynamic body, int? statusCode) {
    if (body is Map<String, dynamic>) {
      body['success'] = body['success'] ?? ((statusCode ?? 500) < 400);
      body['status_code'] = body['status_code'] ?? statusCode ?? 0;
      return body;
    }
    return {
      'success': (statusCode ?? 500) < 400,
      'status_code': statusCode ?? 0,
      'message': 'Réponse invalide du serveur',
      'data': null,
    };
  }

  /// GET binaire (PDF, HTML, etc.) — chemin relatif à [baseUrl].
  Future<Uint8List?> fetchBytes(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('\n🔵 GET bytes: $endpoint');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 120),
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode != null &&
          response.statusCode! < 400 &&
          response.data != null) {
        final d = response.data;
        if (d is Uint8List) return d;
        if (d is List<int>) return Uint8List.fromList(d);
      }
      debugPrint('   ⚠️ fetchBytes status ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('   ❌ fetchBytes: ${e.message}');
    } catch (e) {
      debugPrint('   ❌ fetchBytes: $e');
    }
    return null;
  }

  /// GET binaire depuis une URL absolue (fichier dans `/uploads/`, etc.).
  Future<Uint8List?> fetchBytesUri(String absoluteUrl) async {
    try {
      debugPrint('\n🔵 GET bytes URI: $absoluteUrl');
      final response = await _dio.getUri(
        Uri.parse(absoluteUrl),
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 120),
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode != null &&
          response.statusCode! < 400 &&
          response.data != null) {
        final d = response.data;
        if (d is Uint8List) return d;
        if (d is List<int>) return Uint8List.fromList(d);
      }
      debugPrint('   ⚠️ fetchBytesUri status ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('   ❌ fetchBytesUri: ${e.message}');
    } catch (e) {
      debugPrint('   ❌ fetchBytesUri: $e');
    }
    return null;
  }
}
