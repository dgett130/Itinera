import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import 'packing_repository.dart';

final packingRepositoryProvider = Provider<PackingRepository>((ref) {
  return PackingRepository(ref.watch(databaseProvider));
});

final packingCategoriesProvider =
    StreamProvider<List<PackingCategory>>((ref) {
  return ref.watch(packingRepositoryProvider).watchCategories();
});

final packingItemsProvider =
    StreamProvider.family<List<PackingItem>, String>((ref, tripId) {
  return ref.watch(packingRepositoryProvider).watchItems(tripId);
});

final bagsProvider = StreamProvider.family<List<Bag>, String>((ref, tripId) {
  return ref.watch(packingRepositoryProvider).watchBags(tripId);
});

final packingTemplatesProvider =
    StreamProvider<List<PackingTemplate>>((ref) {
  return ref.watch(packingRepositoryProvider).watchTemplates();
});
