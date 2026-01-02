import 'package:stockex/features/auth/data/model/auth_hive_model.dart';

abstract class IAuthDataSource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser(String authId);
  Future<bool> logout();

  //get email exists
  Future<bool> isEmailExists(String email);
}
