import 'dart:convert';

import 'package:latlong2/latlong.dart';

/// (De)serializzazione della geometria di un percorso come JSON `[[lat,lng],...]`.
String encodeGeometry(List<LatLng> pts) => jsonEncode([
  for (final p in pts) [p.latitude, p.longitude],
]);

List<LatLng> decodeGeometry(String? s) {
  if (s == null || s.isEmpty) return const [];
  try {
    final list = jsonDecode(s);
    if (list is! List) return const [];
    return [
      for (final e in list)
        if (e is List && e.length >= 2)
          LatLng((e[0] as num).toDouble(), (e[1] as num).toDouble()),
    ];
  } catch (_) {
    return const [];
  }
}
