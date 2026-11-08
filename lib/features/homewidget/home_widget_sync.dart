import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/enums.dart';
import '../../router.dart';
import '../../ui/posters.dart';
import '../auth/auth_providers.dart';
import '../itinerary/itinerary_providers.dart';
import '../packing/packing_providers.dart';
import '../transport/transport_providers.dart';
import '../trip/trip_providers.dart';
import 'widget_snapshot.dart';

const _provider = 'ItineraWidgetProvider';
const _qualified = 'org.itinera.itinera.ItineraWidgetProvider';
const _expenseProvider = 'ExpenseWidgetProvider';
const _expenseQualified = 'org.itinera.itinera.ExpenseWidgetProvider';

bool get _supported => !kIsWeb && Platform.isAndroid;

/// Tiene aggiornati i widget sulla Home ("Il mio viaggio" e "Spesa rapida"):
/// va tenuto vivo con `ref.watch`.
/// Senza account (o dopo il logout) il widget viene svuotato.
final homeWidgetSyncProvider = Provider<void>((ref) {
  if (!_supported) return;
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    unawaited(_writer.push(null));
    return;
  }
  final trips = ref.watch(tripsProvider).value;
  if (trips == null) return;
  final trip = pickWidgetTrip(trips, DateTime.now());
  if (trip == null) {
    unawaited(_writer.push(null));
    return;
  }
  final items = ref.watch(packingItemsProvider(trip.id)).value;
  final days = ref.watch(itineraryDaysProvider(trip.id)).value;
  final activities = ref.watch(activitiesProvider(trip.id)).value;
  final expenses = ref.watch(expensesProvider(trip.id)).value;
  // Si aspetta di avere tutto, per non far lampeggiare dati a meta'.
  if (items == null ||
      days == null ||
      activities == null ||
      expenses == null) {
    return;
  }
  unawaited(
    _writer.push(
      WidgetSnapshot.from(
        trip: trip,
        items: items,
        days: days,
        activities: activities,
        expenses: expenses,
      ),
    ),
  );
});

const _linkChannel = MethodChannel('itinera/widget');

/// Apre il punto giusto dell'app quando si tocca il widget. Il collegamento lo
/// annota Android e si legge una volta sola: all'avvio e a ogni ritorno in
/// primo piano.
final homeWidgetLinksProvider = Provider<void>((ref) {
  if (!_supported) return;
  // Senza accesso resta in attesa: dopo il login si apre il viaggio toccato.
  if (ref.watch(currentUserProvider) == null) return;

  Future<void> openPending() async {
    final link = await _linkChannel.invokeMethod<String>('takePendingLink');
    final path = homeWidgetLinkToPath(link == null ? null : Uri.tryParse(link));
    if (path == null) return;
    appRouter.go('/');
    unawaited(appRouter.push(path));
  }

  void run() => unawaited(
    openPending().catchError((Object e) {
      debugPrint('Collegamento del widget non aperto: $e');
    }),
  );

  run();
  final lifecycle = AppLifecycleListener(onResume: run);
  ref.onDispose(lifecycle.dispose);
});

/// `itinera-widget://trip/ID[/packing|/itinerary|/transport|/expense]` e
/// `itinera-widget://new-trip` -> rotta dell'app. La spesa rapida porta con
/// se' la categoria scelta sul widget.
String? homeWidgetLinkToPath(Uri? uri) {
  if (uri == null || uri.scheme != 'itinera-widget') return null;
  if (uri.host == 'new-trip') return '/trip/new';
  if (uri.host != 'trip') return null;
  final parts = uri.pathSegments;
  if (parts.isEmpty) return null;
  final section = parts.length > 1 ? parts[1] : '';
  return switch (section) {
    'packing' => '/trip/${parts[0]}/packing',
    'itinerary' => '/trip/${parts[0]}/itinerary',
    'transport' => '/trip/${parts[0]}/transport',
    'expense' => Uri(
      path: '/trip/${parts[0]}/expense',
      queryParameters: {
        'from': 'widget',
        'category': ?uri.queryParameters['category'],
        if (uri.queryParameters['pick'] == '1') 'pick': '1',
      },
    ).toString(),
    _ => '/trip/${parts[0]}',
  };
}

final _writer = _WidgetWriter();

/// Scrive solo quando qualcosa cambia davvero e una richiesta alla volta;
/// ogni widget si ridisegna solo se cambiano i suoi dati.
class _WidgetWriter {
  String? _last;
  String? _lastExpense;
  TripType? _lastPoster;
  Future<void> _queue = Future.value();

  Future<void> push(WidgetSnapshot? snap) {
    return _queue = _queue.then((_) => _write(snap)).catchError((Object e) {
      debugPrint('Widget Home non aggiornato: $e');
    });
  }

  Future<void> _write(WidgetSnapshot? snap) async {
    final data = snap?.toData() ?? const <String, String>{'trip_id': ''};
    final expense = snap?.expenseData() ?? const <String, String>{'trip_id': ''};
    final signature = jsonEncode(data);
    final expenseSignature = jsonEncode(expense);
    if (signature == _last && expenseSignature == _lastExpense) return;
    if (snap != null && snap.type != _lastPoster) {
      await HomeWidget.saveFile(
        'poster_scene',
        await _renderScene(snap.type),
        extension: 'png',
      );
      _lastPoster = snap.type;
    }
    for (final e in {...data, ...expense}.entries) {
      await HomeWidget.saveWidgetData<String>(e.key, e.value);
    }
    if (signature != _last) {
      await HomeWidget.updateWidget(
        name: _provider,
        qualifiedAndroidName: _qualified,
      );
      _last = signature;
    }
    if (expenseSignature != _lastExpense) {
      await HomeWidget.updateWidget(
        name: _expenseProvider,
        qualifiedAndroidName: _expenseQualified,
      );
      _lastExpense = expenseSignature;
    }
  }

  /// Disegna la scena del viaggio in un PNG trasparente: sfondo e scritte li
  /// aggiunge il widget, alla sua dimensione reale.
  Future<Uint8List> _renderScene(TripType type) async {
    const w = 1116, h = 720;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    PosterPainter(
      type,
      paintBackground: false,
      decor: false,
    ).paint(canvas, Size(w.toDouble(), h.toDouble()));
    final image = await recorder.endRecording().toImage(w, h);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
