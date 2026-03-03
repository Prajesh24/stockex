// lib/core/api/app_client.dart
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:stockex/core/api/api_endpoints.dart';
import 'package:stockex/core/services/storage/token_service.dart';

/// 🔹 Provider with injected TokenService
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ApiClient {
  late final Dio _dio;
  final TokenService _tokenService;

  ApiClient({required TokenService tokenService}) : _tokenService = tokenService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: const {
          'Content-Type': "application/json",
          'Accept': "application/json",
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
        receiveDataWhenStatusError: true,
      ),
    );

    // 🔐 Auth interceptor with injected TokenService
    _dio.interceptors.add(_AuthInterceptor(tokenService: _tokenService));

    // 🔁 Retry on network failure
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // 🐞 Logger (Debug only)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // FILE UPLOAD
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) {
    return _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

// 🔐 Auth Interceptor with Injected TokenService
class _AuthInterceptor extends Interceptor {
  final TokenService _tokenService;

  _AuthInterceptor({required TokenService tokenService})
      : _tokenService = tokenService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final path = options.path;
    final isAuthEndpoint =
        path.contains('/login') || path.contains('/register');

    if (kDebugMode) {
      print('🔐 AuthInterceptor:');
      print('  Path: $path');
      print('  Is Auth Endpoint: $isAuthEndpoint');
    }

    if (!isAuthEndpoint) {
      // ✅ Get token from injected service (synchronous)
      final token = _tokenService.getToken();

      if (kDebugMode) {
        print('  Token: ${token != null ? 'Found' : 'NOT FOUND'}');
      }

      if (token != null && token.isNotEmpty) {
        options.headers["Authorization"] = "Bearer $token";

        if (kDebugMode) {
          print('  ✅ Added Authorization header');
        }
      } else {
        if (kDebugMode) {
          print('  ⚠️ No token available');
        }
      }
    }

    if (kDebugMode) print('');

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        print('🚫 401 Unauthorized - Clearing token');
      }

      // Clear token on 401
      _tokenService.removeToken();

      // TODO: Navigate to login or emit logout event
    }
    handler.next(err);
  }
}