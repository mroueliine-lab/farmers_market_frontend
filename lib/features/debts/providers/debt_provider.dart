import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/debt_model.dart';
import '../data/repositories/debt_repository.dart';
import '../../../core/providers.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(ref.read(dioProvider));
});

final farmerDebtsProvider = FutureProvider.family<List<DebtModel>, int>((ref, farmerId) async {
  return ref.read(debtRepositoryProvider).getFarmerDebts(farmerId);
});
