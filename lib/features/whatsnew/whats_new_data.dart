import 'package:flutter/material.dart';

/// Versione a cui si riferiscono le novità qui sotto.
///
/// IMPORTANTE: al rilascio, allineala alla versione di `pubspec.yaml` e
/// aggiorna [kWhatsNewItems]. Il pannello "Novità" appare una sola volta quando
/// questa stringa cambia rispetto a quella già vista sul dispositivo.
const String kWhatsNewVersion = '2.1.0';

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
    Icons.today,
    'In viaggio, la giornata a colpo d’occhio',
    'Sotto il poster del viaggio in corso c’è la scheda «Oggi»: cosa fai adesso, '
        'cosa viene dopo e quanto manca. «Vai» ti porta lì con Google Maps.',
  ),
  WhatsNewItem(
    Icons.wb_sunny,
    'Il poster è vivo',
    'Il cielo segue l’ora della destinazione e il meteo vero: tramonti, stelle, '
        'pioggia e neve. Il meteo si spegne nelle Impostazioni.',
  ),
  WhatsNewItem(
    Icons.add_card,
    'Spesa rapida',
    'Un nuovo widget sulla Home del telefono: tocchi la categoria, scrivi '
        'l’importo e la spesa è salvata.',
  ),
  WhatsNewItem(
    Icons.pie_chart,
    'Divisione per quota',
    'Ora le quote si impostano davvero: un cursore per ciascuno, o il numero '
        'scritto a mano. Gli altri si ricalcolano da soli.',
  ),
];
