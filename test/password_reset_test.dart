import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:itinera/data/database.dart';
import 'package:itinera/features/auth/auth_providers.dart';
import 'package:itinera/features/auth/auth_service.dart';
import 'package:itinera/features/auth/password_reset_screen.dart';
import 'package:itinera/providers.dart';
import 'package:itinera/ui/itinera_theme.dart';

class _FakeAuth implements AuthService {
  var signedOut = 0;
  String? newPassword;

  @override
  Future<void> signOut() async => signedOut++;

  @override
  Future<void> updatePassword(String password) async => newPassword = password;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late _FakeAuth auth;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    auth = _FakeAuth();
    await db.setPref(kPasswordRecoveryPref, '1');
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester t) async {
    await t.binding.setSurfaceSize(const Size(412, 917));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final router = GoRouter(
      initialLocation: '/reset-password',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Radice')),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (_, _) => const PasswordResetScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: MaterialApp.router(
          theme: ItineraTheme.brand(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  // Le scritture Drift vanno lasciate finire fuori dal tempo finto del test.
  Future<void> settle(WidgetTester t) async {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pumpAndSettle();
  }

  Future<String?> pref(WidgetTester t) async =>
      t.runAsync<String?>(() => db.getPref(kPasswordRecoveryPref));

  testWidgets('tornare indietro chiede conferma: «Resta» non cambia nulla', (
    t,
  ) async {
    await pump(t);
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.text('Lasciare il cambio password?'), findsOneWidget);

    await t.tap(find.text('Resta'));
    await t.pumpAndSettle();
    expect(find.text('Scegli una nuova password'), findsOneWidget);
    expect(auth.signedOut, 0);
    expect(await pref(t), '1');
  });

  testWidgets('«Annulla» e poi «Esci» fanno uscire anche dall\'account', (
    t,
  ) async {
    await pump(t);
    await t.ensureVisible(find.text('Annulla'));
    await t.tap(find.text('Annulla'));
    await t.pumpAndSettle();
    await t.tap(find.text('Esci'));
    await settle(t);

    expect(auth.signedOut, 1);
    expect(find.text('Radice'), findsOneWidget);
    expect(await pref(t), '0');
  });

  testWidgets('salvare cambia la password e chiude il cambio in corso', (
    t,
  ) async {
    await pump(t);
    await t.enterText(find.byType(TextFormField).at(0), 'nuovapass');
    await t.enterText(find.byType(TextFormField).at(1), 'nuovapass');
    await t.tap(find.text('Salva password'));
    await settle(t);

    expect(auth.newPassword, 'nuovapass');
    expect(auth.signedOut, 0);
    expect(find.text('Radice'), findsOneWidget);
    expect(await pref(t), '0');
  });
}
