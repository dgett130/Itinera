import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/sample_data.dart';
import 'data/seed.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dati locale italiani per DateFormat.
  await initializeDateFormatting('it_IT', null);

  // Apertura DB + caricamento dati di default e viaggio di esempio.
  // Fatto prima di runApp cosi' la UI parte con il DB gia' pronto.
  final db = AppDatabase();
  await AppSeed.ensureSeeded(db);
  await SampleData.createIfEmpty(db);

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const ItineraApp(),
    ),
  );
}
