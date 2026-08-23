import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase_config.dart';
import 'data/database.dart';
import 'data/seed.dart';
import 'providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dati locale italiani per DateFormat.
  await initializeDateFormatting('it_IT', null);

  // Inizializzazione Supabase (account/profilo). Non fatale: se le chiavi
  // mancano o la rete non c'e', l'app continua in modalita' locale.
  if (SupabaseConfig.hasCredentials) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // Chiave anon legacy (JWT): resta valida; il warning e' solo perche'
        // le versioni recenti preferiscono il nuovo formato publishableKey.
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.anonKey,
      );
      supabaseReady = true;
      // Link di recupero password: porta alla schermata "nuova password".
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          appRouter.push('/reset-password');
        }
      });
    } catch (_) {
      supabaseReady = false;
    }
  }

  // Apertura DB + caricamento dati di default e viaggio di esempio.
  // Fatto prima di runApp cosi' la UI parte con il DB gia' pronto.
  final db = AppDatabase();
  // Solo dati di riferimento locali (categorie, modelli): i viaggi arrivano
  // dall'account via sincronizzazione.
  await AppSeed.ensureSeeded(db);

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const ItineraApp(),
    ),
  );
}
