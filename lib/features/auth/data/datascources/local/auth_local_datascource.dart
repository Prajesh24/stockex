import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/services/hive/hive_service.dart';
import 'package:stockex/features/auth/data/datascources/auth_datascource.dart';
import 'package:stockex/features/auth/data/model/auth_hive_model.dart';

//Provider
final authLocalDataSourceProvider = Provider<AuthLocalDatascource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatascource(hiveService: hiveService);
});

class AuthLocalDatascource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatascource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser(String authId) {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
   try {
      final exists = _hiveService.isEmailExists(email);

      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      throw Exception('Login failed');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }
}
