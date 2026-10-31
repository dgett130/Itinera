import 'package:flutter/material.dart';

/// Versione a cui si riferiscono le novità qui sotto.
///
/// IMPORTANTE: al rilascio, allineala alla versione di `pubspec.yaml` e
/// aggiorna [kWhatsNewItems]. Il pannello "Novità" appare una sola volta quando
/// questa stringa cambia rispetto a quella già vista sul dispositivo.
const String kWhatsNewVersion = '2.0.0';

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
    Icons.palette,
    'Una veste tutta nuova',
    'Colori, caratteri e icona nuovi. Ogni viaggio ha il suo manifesto, deciso '
        'dal tipo di viaggio.',
  ),
  WhatsNewItem(
    Icons.calendar_month,
    'Il widget sulla Home',
    'Il conto alla rovescia, la valigia e il programma del giorno, senza '
        'aprire l’app. Toccalo per andare al punto giusto.',
  ),
  WhatsNewItem(
    Icons.star,
    'Più vita tra le schermate',
    'Il sole all’apertura, il poster che si apre, gli spilli sulla mappa. E '
        'quando la valigia è pronta si festeggia.',
  ),
  WhatsNewItem(
    Icons.delete,
    '«Annulla» se elimini per sbaglio',
    'Oggetti, bagagli, tratte, spese e attività tornano con un tocco.',
  ),
  WhatsNewItem(
    Icons.dark_mode,
    'Bello anche al buio',
    'Il tema scuro è tutto nuovo, mappe comprese. Lo scegli nelle Impostazioni.',
  ),
];
