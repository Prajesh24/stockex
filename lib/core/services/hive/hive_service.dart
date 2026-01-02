import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:path_provider/path_provider.dart';
import 'package:stockex/core/constants/hive_table_constant.dart';
import 'package:stockex/features/auth/data/model/auth_hive_model.dart';

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

    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
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
    final user = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (user.isNotEmpty) {
      return user.first;
    } else {
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
}
