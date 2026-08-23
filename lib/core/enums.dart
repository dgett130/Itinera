/// Enum di dominio condivisi da tutta l'app.
///
/// Sono memorizzati nel database come *nome* (textEnum di Drift), non come
/// indice: aggiungere/riordinare i valori non corrompe i dati esistenti,
/// purche' non si rinomini un valore gia' salvato.
library;

/// Tipo di viaggio, usato per suggerire liste valigia e modelli di giornata.
enum TripType { sea, mountain, city, business, roadTrip, backpacking, generic }

/// Clima previsto, guida i suggerimenti della valigia.
enum Climate { hot, temperate, cold, tropical, variable }

/// Tipologia di bagaglio.
enum BagType { cabin, hold, personal, backpack, duffel }

/// Mezzo di trasporto di una tratta.
enum TransportMode {
  car,
  motorcycle,
  camper,
  plane,
  train,
  ferry,
  bus,
  taxi,
  bicycle,
  walk,
  other,
}

/// Modi con motore a cui si applica il calcolo carburante.
extension TransportModeX on TransportMode {
  bool get burnsFuel =>
      this == TransportMode.car ||
      this == TransportMode.motorcycle ||
      this == TransportMode.camper;
}

/// Tipo di alimentazione del veicolo.
enum FuelType { petrol, diesel, lpg, cng, electric, hybrid }

/// Unita' di misura del consumo di un veicolo.
enum ConsumptionUnit { lPer100km, kwhPer100km, kmPerL }

/// Da dove proviene la distanza di una tratta (priorita' decrescente d'affidabilita').
enum DistanceSource { manual, onlineRouting, cached, straightLine }

/// Categoria di una voce di spesa.
enum CostCategory {
  fuel,
  ticket,
  toll,
  parking,
  rental,
  baggage,
  insurance,
  taxi,
  accommodation,
  food,
  activity,
  other,
}

/// Una spesa e' una stima (pianificazione) o un costo reale sostenuto.
enum CostStatus { estimate, actual }

/// Metodo di divisione di una spesa tra i viaggiatori.
enum SplitMethod { equal, weighted, custom, none }

/// Stato di un'attivita' dell'itinerario.
enum ActivityStatus { planned, done, skipped, cancelled }

/// Tipo di luogo associato a un'attivita'.
enum PlaceType { poi, hotel, restaurant, station, custom }

/// Provenienza di un luogo salvato.
enum LocationSource { manual, osm, mapPick, transportLeg }

/// Sistema di unita' di misura preferito dall'utente.
enum UnitSystem { metric, imperial }

/// Modalita' dell'app: dati solo locali oppure sincronizzati con un server.
enum AppMode { local, remote }

/// Stile visivo (tema) di un viaggio.
///
/// Ogni viaggio puo' avere una propria identita' grafica: un trekking in
/// montagna indossa lo stile cartografico "Atlante", una vacanza al mare il
/// "Boarding Pass", una city break il "Sunset". Salvato per nome (textEnum);
/// `null` sul viaggio significa "automatico" (dedotto dal tipo di viaggio).
enum TripStyle { atlante, boardingPass, sunset }
