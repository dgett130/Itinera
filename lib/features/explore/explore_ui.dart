import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';

/// Etichette, icone, colori e formattazioni condivise dalle schermate
/// "Luoghi e percorsi". Tutte le stringhe visibili passano dalla l10n.

String poiCategoryLabel(AppLocalizations l10n, PoiCategory c) => switch (c) {
  PoiCategory.monument => l10n.exploreCatMonument,
  PoiCategory.museum => l10n.exploreCatMuseum,
  PoiCategory.nature => l10n.exploreCatNature,
  PoiCategory.viewpoint => l10n.exploreCatViewpoint,
  PoiCategory.religious => l10n.exploreCatReligious,
  PoiCategory.attraction => l10n.exploreCatAttraction,
  PoiCategory.other => l10n.exploreCatOther,
};

IconData poiCategoryIcon(PoiCategory c) => switch (c) {
  PoiCategory.monument => Icons.account_balance,
  PoiCategory.museum => Icons.museum_outlined,
  PoiCategory.nature => Icons.park_outlined,
  PoiCategory.viewpoint => Icons.landscape_outlined,
  PoiCategory.religious => Icons.church_outlined,
  PoiCategory.attraction => Icons.attractions_outlined,
  PoiCategory.other => Icons.place_outlined,
};

/// Le sei categorie mostrate come filtri (l'ordine e' quello del requisito).
const List<PoiCategory> exploreFilterCategories = [
  PoiCategory.monument,
  PoiCategory.museum,
  PoiCategory.nature,
  PoiCategory.viewpoint,
  PoiCategory.religious,
  PoiCategory.attraction,
];

Color poiCategoryColor(PoiCategory c) => switch (c) {
  PoiCategory.monument => const Color(0xFF8D6E63),
  PoiCategory.museum => const Color(0xFF5C6BC0),
  PoiCategory.nature => const Color(0xFF2E7D32),
  PoiCategory.viewpoint => const Color(0xFF00897B),
  PoiCategory.religious => const Color(0xFF7E57C2),
  PoiCategory.attraction => const Color(0xFFEF6C00),
  PoiCategory.other => const Color(0xFF757575),
};

String routeModeLabel(AppLocalizations l10n, RouteTravelMode m) => switch (m) {
  RouteTravelMode.walk => l10n.routeModeWalk,
  RouteTravelMode.bike => l10n.routeModeBike,
  RouteTravelMode.car => l10n.routeModeCar,
};

IconData routeModeIcon(RouteTravelMode m) => switch (m) {
  RouteTravelMode.walk => Icons.directions_walk,
  RouteTravelMode.bike => Icons.directions_bike,
  RouteTravelMode.car => Icons.directions_car,
};

/// Distanza leggibile: metri sotto 1 km, altrimenti km con un decimale.
String formatDistance(AppLocalizations l10n, num meters) {
  if (meters < 1000) return '${meters.round()} ${l10n.unitMeter}';
  final km = meters / 1000.0;
  final s = km >= 10 ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
  return '$s ${l10n.unitKm}';
}

/// Durata leggibile: "h min", "h" (ore tonde) oppure "min".
String formatDuration(AppLocalizations l10n, num seconds) {
  final total = seconds.round();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  if (h > 0 && m == 0) return '$h ${l10n.unitHour}';
  if (h > 0) return '$h ${l10n.unitHour} $m ${l10n.unitMin}';
  return '$m ${l10n.unitMin}';
}

/// Giorni dell'itinerario per le scelte dell'utente: prima quelli con una
/// data (in ordine), poi quelli senza ("Non programmato") in fondo.
List<ItineraryDay> sortDaysForPicker(List<ItineraryDay> days) {
  final sorted = [...days];
  sorted.sort((a, b) {
    final da = a.date;
    final db = b.date;
    if (da != null && db != null) return da.compareTo(db);
    if (da != null) return -1;
    if (db != null) return 1;
    return a.sortIndex.compareTo(b.sortIndex);
  });
  return sorted;
}
