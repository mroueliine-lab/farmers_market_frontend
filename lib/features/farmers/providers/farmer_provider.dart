import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/farmer_model.dart';
import '../data/repositories/farmer_repository.dart';
import '../../../core/providers.dart';

final farmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  return FarmerRepository(ref.read(dioProvider));
});

final farmerSearchProvider = FutureProvider.family<Farmer?, String>((ref, query) async {
  if (query.isEmpty) return null;
  return ref.read(farmerRepositoryProvider).search(query);
});

final farmerDetailProvider = FutureProvider.family<Farmer, int>((ref, id) async {
  return ref.read(farmerRepositoryProvider).show(id);
});
