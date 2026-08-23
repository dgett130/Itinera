import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/data/sample_data.dart';
import 'package:itinera/data/seed.dart';
import 'package:itinera/features/trip/trips_screen.dart';
import 'package:itinera/l10n/app_localizations.dart';
import 'package:itinera/providers.dart';

void main() {
  testWidgets('la home mostra il viaggio di esempio', (tester) async {
    await initializeDateFormatting('it_IT', null);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    await AppSeed.ensureSeeded(db);
    await SampleData.createIfEmpty(db);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const TripsScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('I miei viaggi'), findsOneWidget);
    expect(find.text('Weekend a Firenze'), findsOneWidget);

    await db.close();
  });
}
