import 'enums.dart';

/// Durata di visita predefinita (minuti) per categoria di luogo. È una stima
/// di partenza: l'utente potrà cambiarla tappa per tappa.
int defaultVisitMinutes(PoiCategory? category) => switch (category) {
  PoiCategory.monument => 45,
  PoiCategory.museum => 90,
  PoiCategory.nature => 60,
  PoiCategory.viewpoint => 20,
  PoiCategory.religious => 30,
  PoiCategory.attraction => 60,
  PoiCategory.other || null => 30,
};
