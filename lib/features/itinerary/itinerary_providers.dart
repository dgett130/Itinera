import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import 'itinerary_repository.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(ref.watch(databaseProvider));
});

final itineraryDaysProvider =
    StreamProvider.family<List<ItineraryDay>, String>((ref, tripId) {
  return ref.watch(itineraryRepositoryProvider).watchDays(tripId);
});

final activitiesProvider =
    StreamProvider.family<List<Activity>, String>((ref, tripId) {
  return ref.watch(itineraryRepositoryProvider).watchActivities(tripId);
});

final activityCategoriesProvider =
    StreamProvider<List<ActivityCategory>>((ref) {
  return ref.watch(itineraryRepositoryProvider).watchCategories();
});

final locationsProvider =
    StreamProvider.family<List<Location>, String>((ref, tripId) {
  return ref.watch(itineraryRepositoryProvider).watchLocations(tripId);
});
