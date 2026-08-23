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
