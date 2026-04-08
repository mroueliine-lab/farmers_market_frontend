import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:farmers_market/features/auth/data/repositories/auth_repository.dart';
import 'package:farmers_market/core/storage/secure_storage_service.dart';
import '../helpers/fake_dio.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late FakeDio dio;
  late MockSecureStorage storage;
  late AuthRepository repo;

  const loginResponse = {
    'token': 'tok_abc123',
    'user': {
      'id': 1,
      'name': 'Alice',
      'email': 'alice@test.com',
      'role': 'operator',
    },
  };

  setUp(() {
    dio = FakeDio();
    storage = MockSecureStorage();
    repo = AuthRepository(dio, storage);
  });

  group('login', () {
    test('saves token and user, returns UserModel', () async {
      dio.onPost('/login', loginResponse);
      when(() => storage.saveToken(any())).thenAnswer((_) async {});
      when(() => storage.saveUser(any())).thenAnswer((_) async {});

      final user = await repo.login('alice@test.com', 'secret');

      expect(user.email, 'alice@test.com');
      expect(user.role, 'operator');
      verify(() => storage.saveToken('tok_abc123')).called(1);
      verify(() => storage.saveUser(any())).called(1);
    });

    test('propagates API errors', () async {
      dio.onPostThrow('/login', Exception('Network error'));

      expect(() => repo.login('x@x.com', 'bad'), throwsException);
    });
  });

  group('logout', () {
    test('clears all storage even when API call fails', () async {
      dio.onPostThrow('/logout', Exception('offline'));
      when(() => storage.clearAll()).thenAnswer((_) async {});

      await repo.logout();

      verify(() => storage.clearAll()).called(1);
    });
  });

  group('restoreSession', () {
    test('returns UserModel when stored user exists', () async {
      when(() => storage.readUser()).thenAnswer((_) async => {
            'id': 1,
            'name': 'Alice',
            'email': 'alice@test.com',
            'role': 'operator',
          });

      final user = await repo.restoreSession();

      expect(user?.name, 'Alice');
    });

    test('returns null when no stored user', () async {
      when(() => storage.readUser()).thenAnswer((_) async => null);

      final user = await repo.restoreSession();

      expect(user, isNull);
    });
  });
}
