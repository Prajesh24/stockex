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
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  /// ==================== UPDATE PROFILE ====================
  /// Sends name + email as JSON to PUT /auth/update-profile
  /// If imagePath is provided, sends as multipart instead
  @override
  Future<bool> updateProfile(UpdateApiModel profile) async {
    // If there's an image to upload, send as multipart form data
    if (profile.imagePath != null && profile.imagePath!.isNotEmpty) {
      return _updateProfileWithImage(profile);
    }

    // Otherwise send as plain JSON
    try {
      final data = profile.toJson()
        ..removeWhere((key, value) => value == null); // strip null fields

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return true;
      }

      throw Exception(
        response.data['message'] ?? 'Failed to update profile',
      );
    } on DioException {
      rethrow; // let repository handle DioException
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  /// Sends profile data + image as multipart to PUT /auth/update-profile
  /// Backend uses uploads.single("image") — field name must be "image"
  Future<bool> _updateProfileWithImage(UpdateApiModel profile) async {
    try {
      final formMap = <String, dynamic>{};

      if (profile.name != null) formMap['name'] = profile.name;
      if (profile.email != null) formMap['email'] = profile.email;

      // ✅ Field name must match backend: uploads.single("image")
      formMap['image'] = await MultipartFile.fromFile(
        profile.imagePath!,
        filename: profile.imagePath!.split('/').last,
      );

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return true;
      }

      throw Exception(
        response.data['message'] ?? 'Failed to update profile with image',
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Upload profile picture error: $e');
    }
  }

  /// ==================== UPLOAD PROFILE PICTURE (standalone) ====================
  /// Note: backend doesn't have a separate upload endpoint.
  /// This delegates to updateProfile with only the image path set.
  @override
  Future<bool> uploadProfilePicture(String imagePath) async {
    final profileWithImage = UpdateApiModel(imagePath: imagePath);
    return _updateProfileWithImage(profileWithImage);
  }

  /// ==================== GET USER PROFILE ====================
  /// Fixed: endpoint is /auth/whoami not /auth/profile
  @override
  Future<UpdateApiModel?> getUserProfile() async {
    try {
      // ✅ Fixed endpoint: backend route is GET /auth/whoami
      final response = await _apiClient.get(ApiEndpoints.getUserProfile);

      if (response.statusCode == 200 && response.data["success"] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UpdateApiModel.fromJson(data);
      }

      throw Exception(
        response.data['message'] ?? 'Failed to fetch profile',
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Get user profile error: $e');
    }
  }
}