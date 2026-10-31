import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase_config.dart';
import 'data/database.dart';
import 'data/seed.dart';
import 'features/auth/password_reset_screen.dart';
import 'features/notifications/push_service.dart';
import 'providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Licenze dei font impacchettati, visibili nella pagina delle licenze.
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in const [
      ('Bricolage Grotesque', 'OFL-BricolageGrotesque.txt'),
      ('Figtree', 'OFL-Figtree.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString('assets/licenses/$file'));
    }
  });

  // Dati locale italiani per DateFormat.
  await initializeDateFormatting('it_IT', null);

  // Apertura DB: prima di Supabase, perche' il link di recupero password annota
  // qui che il cambio e' in corso.
  final db = AppDatabase();

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
          unawaited(db.setPref(kPasswordRecoveryPref, '1'));
          appRouter.go('/reset-password');
        }
      });
    } catch (_) {
      supabaseReady = false;
    }
  }

  // Inizializzazione Firebase (per le notifiche push). Non fatale: se manca la
  // config o fallisce, l'app continua senza push.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  // Caricamento dati di default e viaggio di esempio, prima di runApp cosi' la
  // UI parte con il DB gia' pronto.
  // Solo dati di riferimento locali (categorie, modelli): i viaggi arrivano
  // dall'account via sincronizzazione.
  await AppSeed.ensureSeeded(db);

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const ItineraApp(),
    ),
  );

  // Cambio password lasciato a meta' (app chiusa): si riprende da li'.
  final session = supabaseReady
      ? Supabase.instance.client.auth.currentSession
      : null;
  if (await db.getPref(kPasswordRecoveryPref) == '1') {
    if (session != null) {
      appRouter.go('/reset-password');
    } else {
      await db.setPref(kPasswordRecoveryPref, '0');
    }
  }
}
