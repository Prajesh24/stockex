import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:path_provider/path_provider.dart';
import 'package:stockex/core/constants/hive_table_constant.dart';
import 'package:stockex/features/auth/data/model/auth_hive_model.dart';
import 'package:stockex/features/update/data/model/update_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  //Initialize HIve
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    // _registerAdapters();
    // await _openBoxes();

    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.updateTypeId)) {
      Hive.registerAdapter(UpdateHiveModelAdapter());
    }

    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }

    if (!Hive.isBoxOpen(HiveTableConstant.updateTable)) {
      await Hive.openBox<UpdateHiveModel>(HiveTableConstant.updateTable);
    }
  }

  //Register all type adapters
  // void _registerAdapters() {
  //   if (!Hive.isAdapterRegistered(HiveTableConstant.batchTypeId)) {
  //     Hive.registerAdapter(BatchHiveModelAdapter());
  //   }
  // }

  // //Open all boxes
  // Future<void> _openBoxes() async {
  //   // await Hive.openBox<BatchHiveModel>(HiveTableConstant.batchTable);
  //   await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  // }

  // // Delete all batches
  // Future<void> deleteAllBatches() async {
  //   await _batchBox.clear();
  // }

  // Close all boxes
  // Future<void> close() async {
  //   await Hive.close();
  // }

  // ==================== Batch CRUD Operations ====================

  // // Get batch box
  // Box<BatchHiveModel> get _batchBox =>
  //     Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

  // Create a new batch
  // Future<BatchHiveModel> createBatch(BatchHiveModel batch) async {
  //   await _batchBox.put(batch.batchId, batch);
  //   return batch;
  // }

  // Get all batches
  // List<BatchHiveModel> getAllBatches() {
  //   return _batchBox.values.toList();
  // }

  // Get batch by ID
  // BatchHiveModel? getBatchById(String batchId) {
  //   return _batchBox.get(batchId);
  // }

  // Update a batch
  // Future<void> updateBatch(BatchHiveModel batch) async {
  //   await _batchBox.put(batch.batchId, batch);
  // }

  // Delete a batch
  // Future<void> deleteBatch(String batchId) async {
  //   await _batchBox.delete(batchId);
  // }

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  //register
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  //login
  Future<AuthHiveModel> loginUser(String email, String password) async {
    try {
      // Debug: Print all users to see what's stored
      print('Total users in Hive: ${_authBox.length}');
      print('Looking for email: $email, password: $password');
      
      for (var user in _authBox.values) {
        print('Stored user - email: ${user.email}, password: ${user.password}');
      }
      
      // Search for user with case-insensitive email
      final user = _authBox.values.firstWhere(
        (u) => u.email.toLowerCase().trim() == email.toLowerCase().trim() && 
               u.password == password,
        orElse: () => throw Exception('Invalid email or password'),
      );
      return user;
    } catch (e) {
      print('Login error: $e');
      throw Exception('User not found');
    }
  }

  //logout
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  //is email exists
  bool isEmailExists(String email) {
    final user = _authBox.values.where((user) => user.email == email);
    return user.isNotEmpty;
  }

  // Update user email
  Future<void> updateUserEmail(String authId, String newEmail) async {
    final user = _authBox.get(authId);
    if (user != null) {
      final updatedUser = AuthHiveModel(
        authId: user.authId,
        fullName: user.fullName,
        email: newEmail,
        phoneNumber: user.phoneNumber,
        password: user.password,
      );
      await _authBox.put(authId, updatedUser);
    }
  }

  // ==================== Update Profile CRUD Operations ====================

  Box<UpdateHiveModel> get _updateBox =>
      Hive.box<UpdateHiveModel>(HiveTableConstant.updateTable);

  // Save/Update profile
  Future<void> saveUpdateProfile(UpdateHiveModel profile) async {
    await _updateBox.put('profile_key', profile);
  }

  // Get user profile
  Future<UpdateHiveModel?> getUpdateProfile(String userId) async {
    return _updateBox.get('profile_key');
  }

  // Delete profile
  Future<void> deleteUpdateProfile(String userId) async {
    await _updateBox.delete('profile_key');
  }
}
