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
  }) : _apiClient = apiClient,
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

      if (response.data["success"] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final user = AuthApiModel.fromJson(data);

        // Safety: ensure mandatory fields
        final userId = user.id ?? '';
        final userEmail = user.email;
        final userFullName = user.fullName;

        // Save to session
        await _userSessionService.saveUserSession(
          userId: userId,
          email: userEmail,
          fullName: userFullName,
          phoneNumber: user.phoneNumber ?? '',
          profileImage: user.profilePicture ?? '',
        );

        // Save token
        final token = response.data['token'];
        if (token != null && token is String) {
          await _tokenService.saveToken(token);
        }

        return user;
      }

      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  /// ==================== REGISTER ====================
  @override
  Future<AuthApiModel?> registerUser(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final registeredUser = AuthApiModel.fromJson(data);

        // Optional: save session after registration if needed
        // await _userSessionService.saveUserSession(
        //   userId: registeredUser.id ?? '',
        //   email: registeredUser.email,
        //   fullName: registeredUser.fullName,
        //   phoneNumber: registeredUser.phoneNumber,
        //   profileImage: registeredUser.profilePicture,
        // );

        return registeredUser;
      }

      return null;
    } catch (e) {
      print("Register error: $e");
      return null;
    }
  }
}
