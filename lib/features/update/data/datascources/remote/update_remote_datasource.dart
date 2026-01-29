import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/api/api_endpoints.dart';
import 'package:stockex/core/api/app_client.dart';
import 'package:stockex/core/services/storage/token_service.dart';
import 'package:stockex/features/update/data/datascources/update_datascource.dart';
import 'package:stockex/features/update/data/model/update_api_model.dart';
import 'package:dio/dio.dart';

/// 🔹 Provider
final updateRemoteDatasourceProvider = Provider<IUpdateRemoteDatasource>((ref) {
  return UpdateRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

/// 🔹 Implementation
class UpdateRemoteDatasource implements IUpdateRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  UpdateRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  /// ==================== UPDATE PROFILE ====================
  @override
  Future<bool> updateProfile(UpdateApiModel profile) async {
    try {
      final data = profile.toJson();

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print("Update profile error: $e");
      return false;
    }
  }

  /// ==================== UPLOAD PROFILE PICTURE ====================
  @override
  Future<bool> uploadProfilePicture(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadProfilePicture,
        data: formData,
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print("Upload profile picture error: $e");
      return false;
    }
  }

  /// ==================== GET USER PROFILE ====================
  @override
  Future<UpdateApiModel?> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getUserProfile);

      if (response.data["success"] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final profile = UpdateApiModel.fromJson(data);
        return profile;
      }

      return null;
    } catch (e) {
      print("Get user profile error: $e");
      return null;
    }
  }
}
