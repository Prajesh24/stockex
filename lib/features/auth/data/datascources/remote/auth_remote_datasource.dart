// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stockex/core/api/api_endpoints.dart';
import 'package:stockex/core/api/app_client.dart';
import 'package:stockex/core/services/storage/token_service.dart';
import 'package:stockex/core/services/storage/user_session_service.dart';

import 'package:stockex/features/auth/data/datascources/auth_datascource.dart';
import 'package:stockex/features/auth/data/model/auth_api_model.dart';

/// 🔹 Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

/// 🔹 Implementation
class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  /// ==================== LOGIN ====================
  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      if (kDebugMode) {
        print('🔍 Full Login Response: ${response.data}');
      }

      if (response.data["success"] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          if (kDebugMode) print(' No data in response');
          return null;
        }

        final user = AuthApiModel.fromJson(data);

        // Save to session
        await _userSessionService.saveUserSession(
          userId: user.id ?? '',
          email: user.email,
          fullName: user.name,
          profileImage: user.imageUrl ?? '',
        );

        // Extract token
        final token = response.data['token'] ??
            response.data['accessToken'] ??
            response.data['access_token'];

        if (kDebugMode) {
          print('🔑 Token found: ${token != null ? 'Yes' : 'No'}');
        }

        if (token != null && token is String) {
          await _tokenService.saveToken(token);

          // Verify
          final savedToken = _tokenService.getToken();
          if (kDebugMode) {
            print('💾 Token saved verification: ${savedToken != null ? '✅' : '❌'}');
          }
        } else {
          if (kDebugMode) print('❌ No valid token in response');
        }

        return user;
      } else {
        if (kDebugMode) print('❌ Login failed: ${response.data['message']}');
      }

      return null;
    } catch (e) {
      if (kDebugMode) print("❌ Login error: $e");
      return null;
    }
  }

  /// ==================== REGISTER ====================
  @override
  Future<AuthApiModel?> registerUser(
    AuthApiModel user, {
    String? confirmPassword,
  }) async {
    try {
      if (kDebugMode) {
        print('RegisterUser called with confirmPassword: $confirmPassword');
      }

      final requestData = {
        ...user.toJson(),
        'confirmPassword': confirmPassword,
      };

      // Remove null _id to allow MongoDB auto-generation
      requestData.remove('_id');

      if (kDebugMode) print('Sending request data: $requestData');

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);
        return registeredUser;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (kDebugMode) print("❌ Register DioException: ${e.response?.data}");
      rethrow;
    } catch (e) {
      if (kDebugMode) print("❌ Register error: $e");
      rethrow;
    }
  }
}