// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Itinera';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonEdit => 'Modifica';

  @override
  String get commonAdd => 'Aggiungi';

  @override
  String get commonDuplicate => 'Duplica';

  @override
  String get commonShare => 'Condividi';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonConfirm => 'Conferma';

  @override
  String get commonSearch => 'Cerca';

  @override
  String get commonToday => 'Oggi';

  @override
  String get commonNotes => 'Note';

  @override
  String get commonName => 'Nome';

  @override
  String get commonRequired => 'Campo obbligatorio';

  @override
  String get commonEmpty => 'Niente qui, per ora.';

  @override
  String get navTrips => 'Viaggi';

  @override
  String get navPacking => 'Valigia';

  @override
  String get navTransport => 'Viaggio';

  @override
  String get navItinerary => 'Itinerario';

  @override
  String get tripsTitle => 'I miei viaggi';

  @override
  String get tripsUpcoming => 'In arrivo';

  @override
  String get tripsPast => 'Passati';

  @override
  String get tripsEmpty => 'Nessun viaggio ancora. Tocca + per crearne uno.';

  @override
  String get tripNew => 'Nuovo viaggio';

  @override
  String get tripEdit => 'Modifica viaggio';

  @override
  String get tripName => 'Nome del viaggio';

  @override
  String get tripDestination => 'Destinazione';

  @override
  String get tripCountry => 'Paese';

  @override
  String get tripStartDate => 'Data di partenza';

  @override
  String get tripEndDate => 'Data di ritorno';

  @override
  String get tripTravelers => 'Viaggiatori';

  @override
  String get tripType => 'Tipo di viaggio';

  @override
  String get tripClimate => 'Clima previsto';

  @override
  String get tripDeleteConfirm =>
      'Eliminare questo viaggio e tutti i suoi dati?';

  @override
  String tripDurationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
      zero: 'Meno di un giorno',
    );
    return '$_temp0';
  }

  @override
  String get tripTypeSea => 'Mare';

  @override
  String get tripTypeMountain => 'Montagna';

  @override
  String get tripTypeCity => 'Citta';

  @override
  String get tripTypeBusiness => 'Lavoro';

  @override
  String get tripTypeRoadTrip => 'Road trip';

  @override
  String get tripTypeBackpacking => 'Zaino in spalla';

  @override
  String get tripTypeGeneric => 'Generico';

  @override
  String get climateHot => 'Caldo';

  @override
  String get climateTemperate => 'Temperato';

  @override
  String get climateCold => 'Freddo';

  @override
  String get climateTropical => 'Tropicale';

  @override
  String get climateVariable => 'Variabile';

  @override
  String get sectionPacking => 'Valigia';

  @override
  String get sectionTransport => 'Viaggio e costi';

  @override
  String get sectionItinerary => 'Tabella di marcia';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsCurrency => 'Valuta';

  @override
  String get settingsUnits => 'Unita di misura';

  @override
  String get settingsBackup => 'Backup ed esporta';

  @override
  String get settingsRestore => 'Ripristina da backup';

  @override
  String get backupExport => 'Esporta backup';

  @override
  String get backupImport => 'Importa backup';

  @override
  String get backupDone => 'Backup esportato';

  @override
  String get backupReminder => 'Ricordati di fare un backup prima di partire.';

  @override
  String get sectionExplore => 'Luoghi e percorsi';

  @override
  String get exploreModuleSubtitle =>
      'Scopri luoghi vicini e costruisci percorsi';

  @override
  String get exploreTitle => 'Luoghi e percorsi';

  @override
  String get exploreSearchArea => 'Cerca in quest\'area';

  @override
  String get exploreRadius => 'Raggio';

  @override
  String get exploreNoDestination =>
      'Scegli una destinazione per vedere i luoghi vicini';

  @override
  String get exploreLoading => 'Cerco luoghi nei dintorni…';

  @override
  String get exploreEmpty => 'Nessun luogo trovato qui';

  @override
  String get exploreErrorNetwork =>
      'Impossibile contattare il servizio dei luoghi';

  @override
  String get exploreRetry => 'Riprova';

  @override
  String get exploreOffline => 'Sei offline: mostro le ultime proposte salvate';

  @override
  String get exploreUpdatedOn => 'Aggiornato il';

  @override
  String get exploreAttribution => 'Dati © OpenStreetMap contributors';

  @override
  String get exploreSuggested => 'Suggeriti';

  @override
  String get exploreSaved => 'Luoghi salvati';

  @override
  String get exploreSavedEmpty =>
      'Nessun luogo salvato. Tocca un suggerimento o la mappa.';

  @override
  String get exploreShowMore => 'Mostra altri';

  @override
  String get exploreFromCenter => 'dal centro';

  @override
  String get exploreInUse =>
      'Luogo usato in un percorso o in un\'attività: non eliminato';

  @override
  String get exploreAddManual => 'Aggiungi dalla mappa';

  @override
  String get exploreCategoryAll => 'Tutte';

  @override
  String get exploreCatMonument => 'Monumenti e storia';

  @override
  String get exploreCatMuseum => 'Musei e cultura';

  @override
  String get exploreCatNature => 'Natura e parchi';

  @override
  String get exploreCatViewpoint => 'Panorami';

  @override
  String get exploreCatReligious => 'Architettura e luoghi religiosi';

  @override
  String get exploreCatAttraction => 'Attrazioni';

  @override
  String get exploreCatOther => 'Altro';

  @override
  String get routesTitle => 'Percorsi';

  @override
  String get routesEmpty => 'Nessun percorso. Creane uno dai luoghi salvati.';

  @override
  String get routeNew => 'Nuovo percorso';

  @override
  String get routeDefaultName => 'Percorso di visita';

  @override
  String get routeRename => 'Rinomina percorso';

  @override
  String get routeDelete => 'Elimina percorso';

  @override
  String get routeDeleteConfirm => 'Eliminare questo percorso?';

  @override
  String get routeStops => 'Tappe';

  @override
  String get routeAddStop => 'Aggiungi tappa';

  @override
  String get routeMinStops => 'Aggiungi almeno 2 tappe.';

  @override
  String get routePickPlace => 'Scegli un luogo salvato';

  @override
  String get routeNoPlaceLeft =>
      'Tutti i luoghi salvati sono già nel percorso.';

  @override
  String get routeMode => 'Mezzo';

  @override
  String get routeModeWalk => 'A piedi';

  @override
  String get routeModeBike => 'Bicicletta';

  @override
  String get routeModeCar => 'Auto';

  @override
  String get routeFixedStart => 'Partenza fissa';

  @override
  String get routeReturnToStart => 'Ritorno alla partenza';

  @override
  String get routeOptimize => 'Ottimizza percorso';

  @override
  String get routeRestoreManual => 'Ripristina ordine manuale';

  @override
  String get routeRecalculate => 'Ricalcola';

  @override
  String get routeOptimizedBadge => 'Ordine ottimizzato';

  @override
  String get routeAddToItinerary => 'Aggiungi all\'itinerario';

  @override
  String get routePickDay => 'Scegli il giorno';

  @override
  String get routeDayUnplanned => 'Non programmato';

  @override
  String get routeSourceOnline => 'Percorso stradale reale';

  @override
  String get routeSourceEstimate => 'Stima (linea d\'aria)';

  @override
  String get routeDistance => 'Distanza';

  @override
  String get routeDuration => 'Durata';

  @override
  String get routeComputing => 'Calcolo…';

  @override
  String get routeAddedToDay => 'Percorso aggiunto all\'itinerario';

  @override
  String get routeAlreadyInDay => 'Percorso già presente in quel giorno';

  @override
  String get unitKm => 'km';

  @override
  String get unitMeter => 'm';

  @override
  String get unitHour => 'h';

  @override
  String get unitMin => 'min';

  @override
  String get bachecaTitle => 'Bacheca';

  @override
  String get bachecaModuleSubtitle => 'Documenti e file condivisi del viaggio';

  @override
  String get bachecaAdd => 'Aggiungi file';

  @override
  String get bachecaOpen => 'Apri';

  @override
  String get bachecaEmptyTitle => 'Nessun file';

  @override
  String get bachecaEmptyMessage =>
      'Carica biglietti, programmi e documenti da condividere con il gruppo.';

  @override
  String get bachecaNoAccountTitle => 'Serve un account';

  @override
  String get bachecaNoAccountMessage =>
      'Accedi per caricare e condividere i file del viaggio.';

  @override
  String get bachecaUploaded => 'File caricato';

  @override
  String get bachecaUploadError => 'Caricamento non riuscito';

  @override
  String get bachecaTooBig => 'File troppo grande (max 25 MB)';

  @override
  String get bachecaOpenError => 'Impossibile aprire il file';

  @override
  String get bachecaDeleted => 'File eliminato';

  @override
  String get bachecaDeleteError => 'Eliminazione non riuscita';

  @override
  String bachecaDeleteConfirm(String name) {
    return 'Vuoi eliminare \"$name\"?';
  }
}
