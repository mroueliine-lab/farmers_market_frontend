import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/providers.dart';

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(null);

  Future<void> restoreSession() async {
    final user = await _repository.restoreSession();
    state = user;
  }

  Future<void> login(String email, String password) async {
    final user = await _repository.login(email, password);
    state = user;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(storageProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
