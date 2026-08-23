import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../sync/login_screen.dart';
import '../trip/trips_screen.dart';
import 'mode_chooser_screen.dart';

/// Schermata radice ('/'): instrada in base allo stato dell'app.
///
/// - modalita' non ancora scelta -> scelta locale/remota;
/// - modalita' remota senza token -> login;
/// - altrimenti -> home dei viaggi.
///
/// E' reattiva: cambiando le impostazioni (scelta modalita', login, logout)
/// la schermata giusta appare da sola.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return settings.when(
      loading: () => const _Splash(),
      error: (e, _) => Scaffold(body: Center(child: Text('Errore: $e'))),
      data: (s) {
        if (!s.modeChosen) return const ModeChooserScreen();
        if (s.appMode == AppMode.remote && s.authToken == null) {
          return const LoginScreen();
        }
        return const TripsScreen();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Itinera',
              style: TextStyle(
                fontFamily: tokens.displayFont,
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: context.scheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: tokens.accent),
            ),
          ],
        ),
      ),
    );
  }
}
