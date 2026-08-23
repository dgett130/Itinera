import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import 'transport_repository.dart';

final transportRepositoryProvider = Provider<TransportRepository>((ref) {
  return TransportRepository(ref.watch(databaseProvider));
});

final segmentsProvider =
    StreamProvider.family<List<TransportSegment>, String>((ref, tripId) {
  return ref.watch(transportRepositoryProvider).watchSegments(tripId);
});

final travelersProvider =
    StreamProvider.family<List<Traveler>, String>((ref, tripId) {
  return ref.watch(transportRepositoryProvider).watchTravelers(tripId);
});

final expensesProvider =
    StreamProvider.family<List<CostItem>, String>((ref, tripId) {
  return ref.watch(transportRepositoryProvider).watchExpenses(tripId);
});

final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(transportRepositoryProvider).watchVehicles();
});

/// Riepilogo "chi deve a chi", ricalcolato quando spese o viaggiatori cambiano.
final settlementProvider =
    FutureProvider.family<SettlementResult, String>((ref, tripId) async {
  ref.watch(expensesProvider(tripId));
  ref.watch(travelersProvider(tripId));
  return ref.watch(transportRepositoryProvider).computeSettlement(tripId);
});
