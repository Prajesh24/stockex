import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/services/hive/hive_service.dart';
import 'package:stockex/features/update/data/datascources/update_datascource.dart';
import 'package:stockex/features/update/data/model/update_hive_model.dart';

/// 🔹 Provider
final updateLocalDatasourceProvider = Provider<IUpdateLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return UpdateLocalDatasource(hiveService: hiveService);
});

/// 🔹 Implementation
class UpdateLocalDatasource implements IUpdateLocalDatasource {
  final HiveService _hiveService;

  UpdateLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> updateProfile(UpdateHiveModel profile) async {
    try {
      // Store profile locally using Hive
      // Assuming you have a method in HiveService to update profile
      await _hiveService.saveUpdateProfile(profile);
      return Future.value(true);
    } catch (e) {
      print("Update profile local error: $e");
      return Future.value(false);
    }
  }

  @override
  Future<UpdateHiveModel?> getUserProfile(String userId) async {
    try {
      // Retrieve profile from local storage
      final profile = await _hiveService.getUpdateProfile(userId);
      return Future.value(profile);
    } catch (e) {
      print("Get user profile local error: $e");
      return Future.value(null);
    }
  }

  @override
  Future<bool> deleteProfile(String userId) async {
    try {
      await _hiveService.deleteUpdateProfile(userId);
      return Future.value(true);
    } catch (e) {
      print("Delete profile local error: $e");
      return Future.value(false);
    }
  }
}
