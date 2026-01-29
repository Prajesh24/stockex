import 'package:stockex/features/update/data/model/update_hive_model.dart';
import 'package:stockex/features/update/data/model/update_api_model.dart';

abstract interface class IUpdateLocalDatasource {
  Future<bool> updateProfile(UpdateHiveModel profile);
  Future<UpdateHiveModel?> getUserProfile(String userId);
  Future<bool> deleteProfile(String userId);
}

abstract interface class IUpdateRemoteDatasource {
  Future<bool> updateProfile(UpdateApiModel profile);
  Future<bool> uploadProfilePicture(String imagePath);
  Future<UpdateApiModel?> getUserProfile();
}
