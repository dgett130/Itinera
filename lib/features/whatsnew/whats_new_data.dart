import 'package:flutter/material.dart';

/// Versione a cui si riferiscono le novità qui sotto.
///
/// IMPORTANTE: al rilascio, allineala alla versione di `pubspec.yaml` e
/// aggiorna [kWhatsNewItems]. Il pannello "Novità" appare una sola volta quando
/// questa stringa cambia rispetto a quella già vista sul dispositivo.
const String kWhatsNewVersion = '1.3.0';

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
    Icons.notifications_active_outlined,
    'Notifiche',
    'Avvisi push anche ad app chiusa per amici, viaggi condivisi e nuovi '
        'documenti, con un centro notifiche e preferenze per categoria.',
  ),
  WhatsNewItem(
    Icons.folder_shared_outlined,
    'Bacheca del viaggio',
    'Carica e condividi documenti; ora con anteprima in-app di foto e PDF e '
        'download sul dispositivo.',
  ),
  WhatsNewItem(
    Icons.add_to_drive_outlined,
    'Foto su Drive',
    'Aggiungi il link a una cartella Drive per le foto, o creala dall’app se '
        'hai l’account Google collegato.',
  ),
  WhatsNewItem(
    Icons.explore_outlined,
    'Luoghi e percorsi',
    'Scopri luoghi vicini e costruisci percorsi a piedi, in bici o in auto, da '
        'aggiungere alla tabella di marcia.',
  ),
];
