import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/database.dart';
import 'weather_report.dart';

/// Il meteo della destinazione da Open-Meteo (gratuito, senza chiave), con una
/// memoria nelle preferenze locali: entro [fresh] non si chiede di nuovo, e
/// senza rete si usa l'ultimo noto se non e' piu' vecchio di [stale].
class WeatherService {
  WeatherService(this._db, {http.Client? client})
    : _client = client ?? http.Client();

  final AppDatabase _db;
  final http.Client _client;

  static const fresh = Duration(minutes: 30);
  static const stale = Duration(hours: 12);

  /// Coordinate arrotondate a circa un chilometro: stessa memoria per tutti i
  /// viaggi nello stesso posto.
  static String key(double lat, double lng) =>
      'weather:${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';

  Future<WeatherReport?> report(double lat, double lng, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final cached = await _cached(lat, lng);
    if (cached != null && at.difference(cached.fetchedAt) < fresh) {
      return cached;
    }
    try {
      final r = await _fetch(lat, lng, at);
      await _db.setPref(key(lat, lng), jsonEncode(r.toJson()));
      return r;
    } catch (_) {
      // Senza rete (o servizio giu'): l'ultimo noto, se recente.
      if (cached != null && at.difference(cached.fetchedAt) < stale) {
        return cached;
      }
      return null;
    }
  }

  Future<WeatherReport?> _cached(double lat, double lng) async {
    final raw = await _db.getPref(key(lat, lng));
    if (raw == null) return null;
    try {
      return WeatherReport.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<WeatherReport> _fetch(double lat, double lng, DateTime now) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(4),
      'longitude': lng.toStringAsFixed(4),
      'current': 'temperature_2m,weather_code',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
      'timezone': 'auto',
      'timeformat': 'unixtime',
      'forecast_days': '8',
    });
    final res = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw http.ClientException('Open-Meteo ${res.statusCode}', uri);
    }
    return WeatherReport.fromOpenMeteo(
      (jsonDecode(res.body) as Map).cast<String, Object?>(),
      now,
    );
  }
}
