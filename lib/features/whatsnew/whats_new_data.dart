import 'package:flutter/material.dart';

/// Versione a cui si riferiscono le novità qui sotto.
///
/// IMPORTANTE: al rilascio, allineala alla versione di `pubspec.yaml` e
/// aggiorna [kWhatsNewItems]. Il pannello "Novità" appare una sola volta quando
/// questa stringa cambia rispetto a quella già vista sul dispositivo.
const String kWhatsNewVersion = '1.5.0';

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
    Icons.photo_outlined,
    'Foto dei luoghi',
    'Nella scheda di un luogo c’è la sua foto, con autore e licenza. Arriva da '
        'Wikimedia Commons, quindi serve la rete.',
  ),
  WhatsNewItem(
    Icons.drive_file_move_outline,
    'Sposta una tappa',
    'Dalla scheda di una tappa, «Sposta» la porta in un altro percorso del '
        'viaggio o in uno nuovo. Si può annullare.',
  ),
  WhatsNewItem(
    Icons.call_split,
    'Dividi un percorso',
    '«Dividi da qui» manda una tappa e le successive in un nuovo percorso. '
        'Se la giornata è troppo lunga, «Dividi in 2 giorni» la taglia a metà.',
  ),
  WhatsNewItem(
    Icons.search,
    'Ricerca per nome più completa',
    'I luoghi trovati per nome hanno orari, ingresso e foto, come quelli '
        'sulla mappa. E «Chiuso ora» ti dice quando riapre.',
  ),
];
