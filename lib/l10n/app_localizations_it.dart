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
}
