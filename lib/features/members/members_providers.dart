import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import '../auth/auth_providers.dart';
import 'members_service.dart';

final membersServiceProvider = Provider<MembersService>((ref) {
  return MembersService(supabaseReady ? Supabase.instance.client : null);
});

/// Membri (e inviti) di un viaggio.
final tripMembersProvider =
    FutureProvider.family<List<TripMember>, String>((ref, tripId) async {
  ref.watch(currentUserProvider);
  return ref.watch(membersServiceProvider).listForTrip(tripId);
});
