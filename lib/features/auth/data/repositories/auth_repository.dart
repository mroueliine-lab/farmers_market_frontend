import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../../core/storage/secure_storage_service.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = response.data['token'] as String;
    final user = UserModel.fromJson(response.data['user']);
    await _storage.saveToken(token);
    await _storage.saveUser(user.toJson());
    return user;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<UserModel?> restoreSession() async {
  final userData = await _storage.readUser();
  if (userData == null) return null;
  return UserModel.fromJson(userData);
}
}
