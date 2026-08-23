import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_config.dart';
import '../../data/sync/sync_providers.dart';
import '../../ui/widgets.dart';
import '../auth/auth_providers.dart';
import '../auth/auth_screen.dart';
import '../trip/trips_screen.dart';

/// Schermata radice ('/'): l'app e' basata su account.
///
/// - non loggato  -> schermata di accesso/registrazione;
/// - loggato      -> home dei viaggi, con il motore di sync avviato.
///
/// Reattiva: al login/logout la schermata giusta appare da sola.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.hasCredentials || !supabaseReady) {
      return const _AccountUnavailable();
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AuthScreen();

    // Avvia (e mantiene vivo) il motore di sincronizzazione finche' loggato.
    ref.watch(syncEngineProvider);
    return const TripsScreen();
  }
}

class _AccountUnavailable extends StatelessWidget {
  const _AccountUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Account non disponibile',
        message: 'Configura le chiavi Supabase per usare Itinera.',
      ),
    );
  }
}
