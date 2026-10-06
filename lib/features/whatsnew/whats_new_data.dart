import 'package:flutter/material.dart';

/// Versione a cui si riferiscono le novità qui sotto.
///
/// IMPORTANTE: al rilascio, allineala alla versione di `pubspec.yaml` e
/// aggiorna [kWhatsNewItems]. Il pannello "Novità" appare una sola volta quando
/// questa stringa cambia rispetto a quella già vista sul dispositivo.
const String kWhatsNewVersion = '1.4.0';

/// Una voce dell'elenco novità (icona + titolo + descrizione breve).
class WhatsNewItem {
  const WhatsNewItem(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

/// Novità curate per la versione corrente (in italiano, testo per l'utente).
const List<WhatsNewItem> kWhatsNewItems = [
  WhatsNewItem(
    Icons.route_outlined,
    'Percorsi in tre passi',
    'Scegli, Ordina, Pianifica: tutto su una mappa a schermo pieno. Cerca '
        'nella zona che stai guardando o per nome, oppure tieni premuto per '
        'un punto qualsiasi. I luoghi che avevi salvato sono nella bozza '
        '«Luoghi salvati».',
  ),
  WhatsNewItem(
    Icons.place_outlined,
    'Scheda del luogo',
    'Orari in italiano, se è aperto adesso, ingresso, durata della visita, '
        'sito web e le tue note.',
  ),
  WhatsNewItem(
    Icons.directions_walk,
    'Tempi tra le tappe',
    'Quanto ci metti da una tappa all’altra, da dove parti, se torni al '
        'punto di partenza e un suggerimento per l’ordine più veloce.',
  ),
  WhatsNewItem(
    Icons.schedule,
    'Scaletta della giornata',
    'Scegli giorno e ora di partenza: vedi a che ora arrivi a ogni tappa e '
        'quando finisci. Nella tabella di marcia il percorso ha i suoi orari.',
  ),
  WhatsNewItem(
    Icons.warning_amber_outlined,
    'Avvisi utili',
    'Ti avvisa se un luogo è chiuso quando arrivi, se la giornata è lunga o '
        'la strada è tanta. Le soglie si cambiano in Impostazioni.',
  ),
];
