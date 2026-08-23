import 'package:flutter/material.dart';

/// Mappa una chiave-icona salvata nel DB (stringa stabile) a un [IconData].
///
/// Salvare una stringa invece dell'intero codepoint rende i dati leggibili e
/// indipendenti dal font delle icone.
IconData iconForKey(String key) {
  return _icons[key] ?? Icons.label_outline;
}

const Map<String, IconData> _icons = {
  // Categorie valigia
  'badge': Icons.badge,
  'checkroom': Icons.checkroom,
  'wash': Icons.wash,
  'shoe': Icons.ice_skating,
  'devices': Icons.devices,
  'medical': Icons.medical_services,
  'accessories': Icons.watch,
  'category': Icons.category,
  // Categorie attivita'
  'restaurant': Icons.restaurant,
  'sightseeing': Icons.photo_camera,
  'transport': Icons.directions,
  'hotel': Icons.hotel,
  'relax': Icons.spa,
  'shopping': Icons.shopping_bag,
  'place': Icons.place,
};
