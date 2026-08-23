import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import 'trip_repository.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.watch(databaseProvider));
});

/// Tutti i viaggi (reattivo).
final tripsProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).watchTrips();
});

/// Un singolo viaggio per id (reattivo).
final tripProvider = StreamProvider.family<Trip?, String>((ref, id) {
  return ref.watch(tripRepositoryProvider).watchTrip(id);
});
