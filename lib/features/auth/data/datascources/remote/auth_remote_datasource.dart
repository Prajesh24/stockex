import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stockex/core/api/api_endpoints.dart';
import 'package:stockex/core/api/app_client.dart';

import 'package:stockex/features/auth/data/datascources/auth_datascource.dart';
import 'package:stockex/features/auth/data/model/auth_api_model.dart';


// 🔹 Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});


// 🔹 Implementation
class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  // 🔐 LOGIN
  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.data["success"] == true) {
      final userData = response.data["data"] as Map<String, dynamic>;
      return AuthApiModel.fromJson(userData);
    }

    return null;
  }

  // 📝 REGISTER
  @override
  Future<bool> registerUser(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data["success"] == true) {
      return true;
    }

    return false;
  }
}
