import 'package:flutter_test/flutter_test.dart';
import 'package:farmers_market/features/farmers/data/repositories/farmer_repository.dart';
import '../helpers/fake_dio.dart';

void main() {
  late FakeDio dio;
  late FarmerRepository repo;

  final farmerJson = {
    'data': {
      'id': 1,
      'firstname': 'Jean',
      'lastname': 'Dupont',
      'email': 'jean@farm.com',
      'phone_number': '0600000001',
      'identifier': 'F001',
      'credit_limit': 10000,
      'debts': [],
    }
  };

  setUp(() {
    dio = FakeDio();
    repo = FarmerRepository(dio);
  });

  group('search', () {
    test('returns Farmer when API finds a match', () async {
      dio.onGet('/farmers/search', farmerJson);

      final farmer = await repo.search('F001');

      expect(farmer, isNotNull);
      expect(farmer!.identifier, 'F001');
      expect(farmer.firstname, 'Jean');
    });

    test('returns null on 404', () async {
      dio.onGetThrow(
        '/farmers/search',
        fakeDioException('/farmers/search', 404),
      );

      final farmer = await repo.search('unknown');

      expect(farmer, isNull);
    });

    test('rethrows non-404 errors', () async {
      dio.onGetThrow(
        '/farmers/search',
        fakeDioException('/farmers/search', 500),
      );

      expect(() => repo.search('F001'), throwsA(anything));
    });
  });

  group('show', () {
    test('returns Farmer by id', () async {
      dio.onGet('/farmers/1', farmerJson);

      final farmer = await repo.show(1);

      expect(farmer.id, 1);
      expect(farmer.lastname, 'Dupont');
    });
  });

  group('create', () {
    test('returns Farmer with empty debts list', () async {
      dio.onPost('/farmers', farmerJson);

      final farmer = await repo.create(
        firstname: 'Jean',
        lastname: 'Dupont',
        email: 'jean@farm.com',
        phoneNumber: '0600000001',
        identifier: 'F001',
        creditLimit: 10000,
      );

      expect(farmer.id, 1);
      expect(farmer.debts, isEmpty);
    });
  });
}
