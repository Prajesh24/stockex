import 'package:stockex/features/auth/data/model/auth_hive_model.dart';
import 'package:stockex/features/auth/data/model/auth_api_model.dart';

// import 'package:stockex/features/auth/data/model/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<AuthHiveModel?> getCurrentUser(String authId);
  Future<bool> logoutUser();
  Future<bool> isEmailExists(String email);
}


abstract interface class IAuthRemoteDatasource {
  Future<bool> registerUser(AuthApiModel user);
  Future<AuthApiModel?> loginUser(String email, String password);
}
