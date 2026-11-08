import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../ui/poster_sky.dart';
import '../trip/trip_providers.dart';
import 'live_sky.dart';
import 'weather_report.dart';
import 'weather_service.dart';

const String _kPosterWeatherPref = 'poster_weather';

/// "Meteo sul poster" (Impostazioni): acceso salvo scelta contraria, locale al
/// dispositivo.
class PosterWeatherController extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final v = await ref.read(databaseProvider).getPref(_kPosterWeatherPref);
    state = v != '0';
  }

  Future<void> set(bool on) async {
    state = on;
    await ref
        .read(databaseProvider)
        .setPref(_kPosterWeatherPref, on ? '1' : '0');
  }
}

final posterWeatherProvider = NotifierProvider<PosterWeatherController, bool>(
  PosterWeatherController.new,
);

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(ref.watch(databaseProvider)),
);

/// L'ora, aggiornata ogni minuto: il sole si sposta piano. Scatta allo
/// scoccare del minuto, cosi' "adesso" e il conto alla rovescia della scheda
/// Oggi cambiano insieme all'orologio del telefono.
final minuteClockProvider = StreamProvider<DateTime>((ref) {
  final clock = StreamController<DateTime>();
  Timer? timer;
  void next() {
    final n = DateTime.now();
    timer = Timer(
      Duration(milliseconds: 60000 - n.second * 1000 - n.millisecond),
      () {
        clock.add(DateTime.now());
        next();
      },
    );
  }

  clock.add(DateTime.now());
  next();
  ref.onDispose(() {
    timer?.cancel();
    clock.close();
  });
  return clock.stream;
});

/// Il meteo di un punto (coordinate arrotondate). Si richiede ogni 10 minuti:
/// il servizio risponde dalla memoria finche' ha meno di 30 minuti.
final weatherReportProvider =
    FutureProvider.family<WeatherReport?, ({double lat, double lng})>((
      ref,
      at,
    ) {
      ref.watch(
        minuteClockProvider.select(
          (c) => (c.value?.millisecondsSinceEpoch ?? 0) ~/ 600000,
        ),
      );
      return ref.watch(weatherServiceProvider).report(at.lat, at.lng);
    });

double _round2(double v) => (v * 100).roundToDouble() / 100;

/// Il cielo vivo del poster di un viaggio; null = poster di sempre (viaggio
/// concluso o destinazione senza coordinate).
final posterSkyProvider = Provider.family<PosterSky?, String>((ref, tripId) {
  final trip = ref.watch(tripProvider(tripId)).value;
  final lat = trip?.destinationLat, lng = trip?.destinationLng;
  if (trip == null || lat == null || lng == null) return null;
  final now = ref.watch(minuteClockProvider).value ?? DateTime.now();
  if (tripConcluded(trip.startDate, trip.endDate, now)) return null;
  final window = weatherWindow(trip.startDate, trip.endDate, now);
  final report =
      window != WeatherWindow.none && ref.watch(posterWeatherProvider)
      ? ref
            .watch(
              weatherReportProvider((lat: _round2(lat), lng: _round2(lng))),
            )
            .value
      : null;
  return buildPosterSky(
    lat: lat,
    lng: lng,
    nowUtc: now.toUtc(),
    window: window,
    report: report,
    start: trip.startDate,
    place: trip.destination,
  );
});

/// L'ora della destinazione di un viaggio, aggiornata ogni minuto (i campi
/// sono l'ora del posto). Senza coordinate, quella del telefono.
final tripLocalNowProvider = Provider.family<DateTime, String>((ref, tripId) {
  final now = ref.watch(minuteClockProvider).value ?? DateTime.now();
  final trip = ref.watch(tripProvider(tripId)).value;
  final lat = trip?.destinationLat, lng = trip?.destinationLng;
  if (lat == null || lng == null) {
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }
  // Il meteo (e con lui il fuso) si chiede solo durante il viaggio, come il
  // poster: per gli altri basta la stima.
  final during =
      weatherWindow(trip!.startDate, trip.endDate, now) == WeatherWindow.now;
  final report = during && ref.watch(posterWeatherProvider)
      ? ref
            .watch(
              weatherReportProvider((lat: _round2(lat), lng: _round2(lng))),
            )
            .value
      : null;
  return destinationNow(now, lng, offsetSeconds: report?.utcOffsetSeconds);
});
