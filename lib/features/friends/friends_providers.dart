import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import '../auth/auth_providers.dart';
import 'friends_service.dart';

final friendsServiceProvider = Provider<FriendsService>((ref) {
  return FriendsService(supabaseReady ? Supabase.instance.client : null);
});

/// Elenco amici dell'utente corrente.
final friendsProvider = FutureProvider<List<Friend>>((ref) async {
  ref.watch(currentUserProvider); // ricarica al cambio utente
  return ref.watch(friendsServiceProvider).list();
});
