import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('it')];

  /// Nome dell'applicazione
  ///
  /// In it, this message translates to:
  /// **'Itinera'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get commonAdd;

  /// No description provided for @commonDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Duplica'**
  String get commonDuplicate;

  /// No description provided for @commonShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get commonShare;

  /// No description provided for @commonClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get commonConfirm;

  /// No description provided for @commonSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca'**
  String get commonSearch;

  /// No description provided for @commonToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get commonToday;

  /// No description provided for @commonNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get commonNotes;

  /// No description provided for @commonName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get commonName;

  /// No description provided for @commonRequired.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get commonRequired;

  /// No description provided for @commonEmpty.
  ///
  /// In it, this message translates to:
  /// **'Niente qui, per ora.'**
  String get commonEmpty;

  /// No description provided for @navTrips.
  ///
  /// In it, this message translates to:
  /// **'Viaggi'**
  String get navTrips;

  /// No description provided for @navPacking.
  ///
  /// In it, this message translates to:
  /// **'Valigia'**
  String get navPacking;

  /// No description provided for @navTransport.
  ///
  /// In it, this message translates to:
  /// **'Viaggio'**
  String get navTransport;

  /// No description provided for @navItinerary.
  ///
  /// In it, this message translates to:
  /// **'Itinerario'**
  String get navItinerary;

  /// No description provided for @tripsTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei viaggi'**
  String get tripsTitle;

  /// No description provided for @tripsUpcoming.
  ///
  /// In it, this message translates to:
  /// **'In arrivo'**
  String get tripsUpcoming;

  /// No description provided for @tripsPast.
  ///
  /// In it, this message translates to:
  /// **'Passati'**
  String get tripsPast;

  /// No description provided for @tripsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun viaggio ancora. Tocca + per crearne uno.'**
  String get tripsEmpty;

  /// No description provided for @tripNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo viaggio'**
  String get tripNew;

  /// No description provided for @tripEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica viaggio'**
  String get tripEdit;

  /// No description provided for @tripName.
  ///
  /// In it, this message translates to:
  /// **'Nome del viaggio'**
  String get tripName;

  /// No description provided for @tripDestination.
  ///
  /// In it, this message translates to:
  /// **'Destinazione'**
  String get tripDestination;

  /// No description provided for @tripCountry.
  ///
  /// In it, this message translates to:
  /// **'Paese'**
  String get tripCountry;

  /// No description provided for @tripStartDate.
  ///
  /// In it, this message translates to:
  /// **'Data di partenza'**
  String get tripStartDate;

  /// No description provided for @tripEndDate.
  ///
  /// In it, this message translates to:
  /// **'Data di ritorno'**
  String get tripEndDate;

  /// No description provided for @tripTravelers.
  ///
  /// In it, this message translates to:
  /// **'Viaggiatori'**
  String get tripTravelers;

  /// No description provided for @tripType.
  ///
  /// In it, this message translates to:
  /// **'Tipo di viaggio'**
  String get tripType;

  /// No description provided for @tripClimate.
  ///
  /// In it, this message translates to:
  /// **'Clima previsto'**
  String get tripClimate;

  /// No description provided for @tripDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questo viaggio e tutti i suoi dati?'**
  String get tripDeleteConfirm;

  /// No description provided for @tripDurationDays.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Meno di un giorno} =1{1 giorno} other{{count} giorni}}'**
  String tripDurationDays(int count);

  /// No description provided for @tripTypeSea.
  ///
  /// In it, this message translates to:
  /// **'Mare'**
  String get tripTypeSea;

  /// No description provided for @tripTypeMountain.
  ///
  /// In it, this message translates to:
  /// **'Montagna'**
  String get tripTypeMountain;

  /// No description provided for @tripTypeCity.
  ///
  /// In it, this message translates to:
  /// **'Citta'**
  String get tripTypeCity;

  /// No description provided for @tripTypeBusiness.
  ///
  /// In it, this message translates to:
  /// **'Lavoro'**
  String get tripTypeBusiness;

  /// No description provided for @tripTypeRoadTrip.
  ///
  /// In it, this message translates to:
  /// **'Road trip'**
  String get tripTypeRoadTrip;

  /// No description provided for @tripTypeBackpacking.
  ///
  /// In it, this message translates to:
  /// **'Zaino in spalla'**
  String get tripTypeBackpacking;

  /// No description provided for @tripTypeGeneric.
  ///
  /// In it, this message translates to:
  /// **'Generico'**
  String get tripTypeGeneric;

  /// No description provided for @climateHot.
  ///
  /// In it, this message translates to:
  /// **'Caldo'**
  String get climateHot;

  /// No description provided for @climateTemperate.
  ///
  /// In it, this message translates to:
  /// **'Temperato'**
  String get climateTemperate;

  /// No description provided for @climateCold.
  ///
  /// In it, this message translates to:
  /// **'Freddo'**
  String get climateCold;

  /// No description provided for @climateTropical.
  ///
  /// In it, this message translates to:
  /// **'Tropicale'**
  String get climateTropical;

  /// No description provided for @climateVariable.
  ///
  /// In it, this message translates to:
  /// **'Variabile'**
  String get climateVariable;

  /// No description provided for @sectionPacking.
  ///
  /// In it, this message translates to:
  /// **'Valigia'**
  String get sectionPacking;

  /// No description provided for @sectionTransport.
  ///
  /// In it, this message translates to:
  /// **'Viaggio e costi'**
  String get sectionTransport;

  /// No description provided for @sectionItinerary.
  ///
  /// In it, this message translates to:
  /// **'Tabella di marcia'**
  String get sectionItinerary;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get settingsLanguage;

  /// No description provided for @settingsCurrency.
  ///
  /// In it, this message translates to:
  /// **'Valuta'**
  String get settingsCurrency;

  /// No description provided for @settingsUnits.
  ///
  /// In it, this message translates to:
  /// **'Unita di misura'**
  String get settingsUnits;

  /// No description provided for @settingsBackup.
  ///
  /// In it, this message translates to:
  /// **'Backup ed esporta'**
  String get settingsBackup;

  /// No description provided for @settingsRestore.
  ///
  /// In it, this message translates to:
  /// **'Ripristina da backup'**
  String get settingsRestore;

  /// No description provided for @backupExport.
  ///
  /// In it, this message translates to:
  /// **'Esporta backup'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In it, this message translates to:
  /// **'Importa backup'**
  String get backupImport;

  /// No description provided for @backupDone.
  ///
  /// In it, this message translates to:
  /// **'Backup esportato'**
  String get backupDone;

  /// No description provided for @backupReminder.
  ///
  /// In it, this message translates to:
  /// **'Ricordati di fare un backup prima di partire.'**
  String get backupReminder;

  /// No description provided for @sectionExplore.
  ///
  /// In it, this message translates to:
  /// **'Luoghi e percorsi'**
  String get sectionExplore;

  /// No description provided for @exploreModuleSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scopri luoghi vicini e costruisci percorsi'**
  String get exploreModuleSubtitle;

  /// No description provided for @exploreTitle.
  ///
  /// In it, this message translates to:
  /// **'Luoghi e percorsi'**
  String get exploreTitle;

  /// No description provided for @exploreSearchArea.
  ///
  /// In it, this message translates to:
  /// **'Cerca in quest\'area'**
  String get exploreSearchArea;

  /// No description provided for @exploreRadius.
  ///
  /// In it, this message translates to:
  /// **'Raggio'**
  String get exploreRadius;

  /// No description provided for @exploreNoDestination.
  ///
  /// In it, this message translates to:
  /// **'Scegli una destinazione per vedere i luoghi vicini'**
  String get exploreNoDestination;

  /// No description provided for @exploreLoading.
  ///
  /// In it, this message translates to:
  /// **'Cerco luoghi nei dintorni…'**
  String get exploreLoading;

  /// No description provided for @exploreEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun luogo trovato qui'**
  String get exploreEmpty;

  /// No description provided for @exploreErrorNetwork.
  ///
  /// In it, this message translates to:
  /// **'Impossibile contattare il servizio dei luoghi'**
  String get exploreErrorNetwork;

  /// No description provided for @exploreRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get exploreRetry;

  /// No description provided for @exploreOffline.
  ///
  /// In it, this message translates to:
  /// **'Sei offline: mostro le ultime proposte salvate'**
  String get exploreOffline;

  /// No description provided for @exploreUpdatedOn.
  ///
  /// In it, this message translates to:
  /// **'Aggiornato il'**
  String get exploreUpdatedOn;

  /// No description provided for @exploreAttribution.
  ///
  /// In it, this message translates to:
  /// **'Dati © OpenStreetMap contributors'**
  String get exploreAttribution;

  /// No description provided for @exploreSuggested.
  ///
  /// In it, this message translates to:
  /// **'Suggeriti'**
  String get exploreSuggested;

  /// No description provided for @exploreSaved.
  ///
  /// In it, this message translates to:
  /// **'Luoghi salvati'**
  String get exploreSaved;

  /// No description provided for @exploreSavedEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun luogo salvato. Tocca un suggerimento o la mappa.'**
  String get exploreSavedEmpty;

  /// No description provided for @exploreShowMore.
  ///
  /// In it, this message translates to:
  /// **'Mostra altri'**
  String get exploreShowMore;

  /// No description provided for @exploreFromCenter.
  ///
  /// In it, this message translates to:
  /// **'dal centro'**
  String get exploreFromCenter;

  /// No description provided for @exploreInUse.
  ///
  /// In it, this message translates to:
  /// **'Luogo usato in un percorso o in un\'attività: non eliminato'**
  String get exploreInUse;

  /// No description provided for @exploreAddManual.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi dalla mappa'**
  String get exploreAddManual;

  /// No description provided for @exploreCategoryAll.
  ///
  /// In it, this message translates to:
  /// **'Tutte'**
  String get exploreCategoryAll;

  /// No description provided for @exploreCatMonument.
  ///
  /// In it, this message translates to:
  /// **'Monumenti e storia'**
  String get exploreCatMonument;

  /// No description provided for @exploreCatMuseum.
  ///
  /// In it, this message translates to:
  /// **'Musei e cultura'**
  String get exploreCatMuseum;

  /// No description provided for @exploreCatNature.
  ///
  /// In it, this message translates to:
  /// **'Natura e parchi'**
  String get exploreCatNature;

  /// No description provided for @exploreCatViewpoint.
  ///
  /// In it, this message translates to:
  /// **'Panorami'**
  String get exploreCatViewpoint;

  /// No description provided for @exploreCatReligious.
  ///
  /// In it, this message translates to:
  /// **'Architettura e luoghi religiosi'**
  String get exploreCatReligious;

  /// No description provided for @exploreCatAttraction.
  ///
  /// In it, this message translates to:
  /// **'Attrazioni'**
  String get exploreCatAttraction;

  /// No description provided for @exploreCatOther.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get exploreCatOther;

  /// No description provided for @routesTitle.
  ///
  /// In it, this message translates to:
  /// **'Percorsi'**
  String get routesTitle;

  /// No description provided for @routesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun percorso. Creane uno dai luoghi salvati.'**
  String get routesEmpty;

  /// No description provided for @routeNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo percorso'**
  String get routeNew;

  /// No description provided for @routeDefaultName.
  ///
  /// In it, this message translates to:
  /// **'Percorso di visita'**
  String get routeDefaultName;

  /// No description provided for @routeRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina percorso'**
  String get routeRename;

  /// No description provided for @routeDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina percorso'**
  String get routeDelete;

  /// No description provided for @routeDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questo percorso?'**
  String get routeDeleteConfirm;

  /// No description provided for @routeStops.
  ///
  /// In it, this message translates to:
  /// **'Tappe'**
  String get routeStops;

  /// No description provided for @routeAddStop.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi tappa'**
  String get routeAddStop;

  /// No description provided for @routeMinStops.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi almeno 2 tappe.'**
  String get routeMinStops;

  /// No description provided for @routePickPlace.
  ///
  /// In it, this message translates to:
  /// **'Scegli un luogo salvato'**
  String get routePickPlace;

  /// No description provided for @routeNoPlaceLeft.
  ///
  /// In it, this message translates to:
  /// **'Tutti i luoghi salvati sono già nel percorso.'**
  String get routeNoPlaceLeft;

  /// No description provided for @routeMode.
  ///
  /// In it, this message translates to:
  /// **'Mezzo'**
  String get routeMode;

  /// No description provided for @routeModeWalk.
  ///
  /// In it, this message translates to:
  /// **'A piedi'**
  String get routeModeWalk;

  /// No description provided for @routeModeBike.
  ///
  /// In it, this message translates to:
  /// **'Bicicletta'**
  String get routeModeBike;

  /// No description provided for @routeModeCar.
  ///
  /// In it, this message translates to:
  /// **'Auto'**
  String get routeModeCar;

  /// No description provided for @routeFixedStart.
  ///
  /// In it, this message translates to:
  /// **'Partenza fissa'**
  String get routeFixedStart;

  /// No description provided for @routeReturnToStart.
  ///
  /// In it, this message translates to:
  /// **'Ritorno alla partenza'**
  String get routeReturnToStart;

  /// No description provided for @routeOptimize.
  ///
  /// In it, this message translates to:
  /// **'Ottimizza percorso'**
  String get routeOptimize;

  /// No description provided for @routeRestoreManual.
  ///
  /// In it, this message translates to:
  /// **'Ripristina ordine manuale'**
  String get routeRestoreManual;

  /// No description provided for @routeRecalculate.
  ///
  /// In it, this message translates to:
  /// **'Ricalcola'**
  String get routeRecalculate;

  /// No description provided for @routeOptimizedBadge.
  ///
  /// In it, this message translates to:
  /// **'Ordine ottimizzato'**
  String get routeOptimizedBadge;

  /// No description provided for @routeAddToItinerary.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi all\'itinerario'**
  String get routeAddToItinerary;

  /// No description provided for @routePickDay.
  ///
  /// In it, this message translates to:
  /// **'Scegli il giorno'**
  String get routePickDay;

  /// No description provided for @routeDayUnplanned.
  ///
  /// In it, this message translates to:
  /// **'Non programmato'**
  String get routeDayUnplanned;

  /// No description provided for @routeSourceOnline.
  ///
  /// In it, this message translates to:
  /// **'Percorso stradale reale'**
  String get routeSourceOnline;

  /// No description provided for @routeSourceEstimate.
  ///
  /// In it, this message translates to:
  /// **'Stima (linea d\'aria)'**
  String get routeSourceEstimate;

  /// No description provided for @routeDistance.
  ///
  /// In it, this message translates to:
  /// **'Distanza'**
  String get routeDistance;

  /// No description provided for @routeDuration.
  ///
  /// In it, this message translates to:
  /// **'Durata'**
  String get routeDuration;

  /// No description provided for @routeComputing.
  ///
  /// In it, this message translates to:
  /// **'Calcolo…'**
  String get routeComputing;

  /// No description provided for @routeAddedToDay.
  ///
  /// In it, this message translates to:
  /// **'Percorso aggiunto all\'itinerario'**
  String get routeAddedToDay;

  /// No description provided for @routeAlreadyInDay.
  ///
  /// In it, this message translates to:
  /// **'Percorso già presente in quel giorno'**
  String get routeAlreadyInDay;

  /// No description provided for @unitKm.
  ///
  /// In it, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitMeter.
  ///
  /// In it, this message translates to:
  /// **'m'**
  String get unitMeter;

  /// No description provided for @unitHour.
  ///
  /// In it, this message translates to:
  /// **'h'**
  String get unitHour;

  /// No description provided for @unitMin.
  ///
  /// In it, this message translates to:
  /// **'min'**
  String get unitMin;

  /// No description provided for @bachecaTitle.
  ///
  /// In it, this message translates to:
  /// **'Bacheca'**
  String get bachecaTitle;

  /// No description provided for @bachecaModuleSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Documenti e file condivisi del viaggio'**
  String get bachecaModuleSubtitle;

  /// No description provided for @bachecaAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi file'**
  String get bachecaAdd;

  /// No description provided for @bachecaOpen.
  ///
  /// In it, this message translates to:
  /// **'Apri'**
  String get bachecaOpen;

  /// No description provided for @bachecaDownload.
  ///
  /// In it, this message translates to:
  /// **'Scarica'**
  String get bachecaDownload;

  /// No description provided for @bachecaDownloaded.
  ///
  /// In it, this message translates to:
  /// **'File salvato sul dispositivo'**
  String get bachecaDownloaded;

  /// No description provided for @bachecaDownloadError.
  ///
  /// In it, this message translates to:
  /// **'Download non riuscito'**
  String get bachecaDownloadError;

  /// No description provided for @bachecaShare.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get bachecaShare;

  /// No description provided for @bachecaOpenExternal.
  ///
  /// In it, this message translates to:
  /// **'Apri esternamente'**
  String get bachecaOpenExternal;

  /// No description provided for @bachecaEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun file'**
  String get bachecaEmptyTitle;

  /// No description provided for @bachecaEmptyMessage.
  ///
  /// In it, this message translates to:
  /// **'Carica biglietti, programmi e documenti da condividere con il gruppo.'**
  String get bachecaEmptyMessage;

  /// No description provided for @bachecaNoAccountTitle.
  ///
  /// In it, this message translates to:
  /// **'Serve un account'**
  String get bachecaNoAccountTitle;

  /// No description provided for @bachecaNoAccountMessage.
  ///
  /// In it, this message translates to:
  /// **'Accedi per caricare e condividere i file del viaggio.'**
  String get bachecaNoAccountMessage;

  /// No description provided for @bachecaUploaded.
  ///
  /// In it, this message translates to:
  /// **'File caricato'**
  String get bachecaUploaded;

  /// No description provided for @bachecaUploadError.
  ///
  /// In it, this message translates to:
  /// **'Caricamento non riuscito'**
  String get bachecaUploadError;

  /// No description provided for @bachecaTooBig.
  ///
  /// In it, this message translates to:
  /// **'File troppo grande (max 25 MB)'**
  String get bachecaTooBig;

  /// No description provided for @bachecaOpenError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il file'**
  String get bachecaOpenError;

  /// No description provided for @bachecaDeleted.
  ///
  /// In it, this message translates to:
  /// **'File eliminato'**
  String get bachecaDeleted;

  /// No description provided for @bachecaDeleteError.
  ///
  /// In it, this message translates to:
  /// **'Eliminazione non riuscita'**
  String get bachecaDeleteError;

  /// No description provided for @bachecaDeleteConfirm.
  ///
  /// In it, this message translates to:
  /// **'Vuoi eliminare \"{name}\"?'**
  String bachecaDeleteConfirm(String name);

  /// No description provided for @tripDriveSection.
  ///
  /// In it, this message translates to:
  /// **'Foto e Drive'**
  String get tripDriveSection;

  /// No description provided for @tripDriveLink.
  ///
  /// In it, this message translates to:
  /// **'Link cartella Drive'**
  String get tripDriveLink;

  /// No description provided for @tripDriveHint.
  ///
  /// In it, this message translates to:
  /// **'Un link a una cartella Drive per condividere le foto del viaggio con il gruppo.'**
  String get tripDriveHint;

  /// No description provided for @tripDriveCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea cartella Drive'**
  String get tripDriveCreate;

  /// No description provided for @tripDriveNeedName.
  ///
  /// In it, this message translates to:
  /// **'Inserisci prima il nome del viaggio'**
  String get tripDriveNeedName;

  /// No description provided for @tripDriveCreated.
  ///
  /// In it, this message translates to:
  /// **'Cartella Drive creata e link inserito'**
  String get tripDriveCreated;

  /// No description provided for @tripDriveError.
  ///
  /// In it, this message translates to:
  /// **'Creazione della cartella Drive non riuscita'**
  String get tripDriveError;

  /// No description provided for @tripDrivePhotos.
  ///
  /// In it, this message translates to:
  /// **'Foto del viaggio'**
  String get tripDrivePhotos;

  /// No description provided for @tripDriveOpen.
  ///
  /// In it, this message translates to:
  /// **'Apri la cartella Drive condivisa'**
  String get tripDriveOpen;

  /// No description provided for @tripDriveOpenError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il link'**
  String get tripDriveOpenError;

  /// No description provided for @notificationsTitle.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In it, this message translates to:
  /// **'Segna lette'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessuna notifica'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In it, this message translates to:
  /// **'Qui vedrai richieste di amicizia, viaggi condivisi e nuovi documenti.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsPrefsTitle.
  ///
  /// In it, this message translates to:
  /// **'Preferenze notifiche'**
  String get notificationsPrefsTitle;

  /// No description provided for @notificationsPushMaster.
  ///
  /// In it, this message translates to:
  /// **'Notifiche push'**
  String get notificationsPushMaster;

  /// No description provided for @notificationsPushMasterHint.
  ///
  /// In it, this message translates to:
  /// **'Ricevi avvisi anche quando l\'app è chiusa'**
  String get notificationsPushMasterHint;

  /// No description provided for @notificationsCategories.
  ///
  /// In it, this message translates to:
  /// **'Categorie'**
  String get notificationsCategories;

  /// No description provided for @notificationsFriendRequests.
  ///
  /// In it, this message translates to:
  /// **'Richieste di amicizia'**
  String get notificationsFriendRequests;

  /// No description provided for @notificationsSharedTrips.
  ///
  /// In it, this message translates to:
  /// **'Viaggi condivisi con me'**
  String get notificationsSharedTrips;

  /// No description provided for @notificationsNewDocuments.
  ///
  /// In it, this message translates to:
  /// **'Nuovi documenti in bacheca'**
  String get notificationsNewDocuments;

  /// No description provided for @notificationsSystemMessages.
  ///
  /// In it, this message translates to:
  /// **'Messaggi di sistema'**
  String get notificationsSystemMessages;

  /// No description provided for @notificationsLocalSection.
  ///
  /// In it, this message translates to:
  /// **'Scadenze (locali)'**
  String get notificationsLocalSection;

  /// No description provided for @notificationsDeadlines.
  ///
  /// In it, this message translates to:
  /// **'Promemoria scadenze'**
  String get notificationsDeadlines;

  /// No description provided for @notificationsDeadlinesHint.
  ///
  /// In it, this message translates to:
  /// **'Avvisi prima della partenza (valigia, backup). Restano sul dispositivo.'**
  String get notificationsDeadlinesHint;

  /// No description provided for @notificationsPrefsFooter.
  ///
  /// In it, this message translates to:
  /// **'Le preferenze valgono per tutti i tuoi dispositivi. Se disattivi le notifiche push non riceverai avvisi ad app chiusa.'**
  String get notificationsPrefsFooter;

  /// No description provided for @timeJustNow.
  ///
  /// In it, this message translates to:
  /// **'adesso'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In it, this message translates to:
  /// **'{count} min fa'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In it, this message translates to:
  /// **'{count} h fa'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In it, this message translates to:
  /// **'{count} g fa'**
  String timeDaysAgo(int count);

  /// No description provided for @adminMsgTitle.
  ///
  /// In it, this message translates to:
  /// **'Messaggio di sistema'**
  String get adminMsgTitle;

  /// No description provided for @adminMsgFieldTitle.
  ///
  /// In it, this message translates to:
  /// **'Titolo'**
  String get adminMsgFieldTitle;

  /// No description provided for @adminMsgFieldBody.
  ///
  /// In it, this message translates to:
  /// **'Testo'**
  String get adminMsgFieldBody;

  /// No description provided for @adminMsgRecipients.
  ///
  /// In it, this message translates to:
  /// **'Destinatari'**
  String get adminMsgRecipients;

  /// No description provided for @adminMsgAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get adminMsgAll;

  /// No description provided for @adminMsgOneUser.
  ///
  /// In it, this message translates to:
  /// **'Un utente'**
  String get adminMsgOneUser;

  /// No description provided for @adminMsgUser.
  ///
  /// In it, this message translates to:
  /// **'Scegli un utente'**
  String get adminMsgUser;

  /// No description provided for @adminMsgMyself.
  ///
  /// In it, this message translates to:
  /// **'Io (me stesso)'**
  String get adminMsgMyself;

  /// No description provided for @adminMsgNoFriends.
  ///
  /// In it, this message translates to:
  /// **'Nessun contatto: aggiungi amici per inviare a un singolo utente.'**
  String get adminMsgNoFriends;

  /// No description provided for @adminMsgPickUser.
  ///
  /// In it, this message translates to:
  /// **'Scegli un utente destinatario'**
  String get adminMsgPickUser;

  /// No description provided for @adminMsgSend.
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get adminMsgSend;

  /// No description provided for @adminMsgSent.
  ///
  /// In it, this message translates to:
  /// **'Inviato a {count} destinatari'**
  String adminMsgSent(int count);

  /// No description provided for @adminMsgError.
  ///
  /// In it, this message translates to:
  /// **'Invio non riuscito'**
  String get adminMsgError;

  /// No description provided for @whatsNewTitle.
  ///
  /// In it, this message translates to:
  /// **'Novità'**
  String get whatsNewTitle;

  /// No description provided for @whatsNewGotIt.
  ///
  /// In it, this message translates to:
  /// **'Ho capito'**
  String get whatsNewGotIt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
