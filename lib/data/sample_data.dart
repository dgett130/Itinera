import 'package:drift/drift.dart';

import '../core/enums.dart';
import '../core/id.dart';
import 'database.dart';

/// Crea un viaggio di esempio alla primissima apertura (se non ci sono viaggi),
/// cosi' l'utente vede subito l'app "viva" invece di schermate vuote.
class SampleData {
  const SampleData._();

  static Future<void> createIfEmpty(AppDatabase db) async {
    final trips = await db.select(db.trips).get();
    if (trips.isNotEmpty) return;

    final packingCats = {
      for (final c in await db.select(db.packingCategories).get()) c.name: c.id,
    };
    final activityCats = {
      for (final c in await db.select(db.activityCategories).get()) c.name: c.id,
    };

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 14));
    final end = start.add(const Duration(days: 2));

    await db.transaction(() async {
      final tripId = newId();
      await db.into(db.trips).insert(
            TripsCompanion.insert(
              id: tripId,
              name: 'Weekend a Firenze',
              destination: const Value('Firenze'),
              country: const Value('Italia'),
              startDate: Value(start),
              endDate: Value(end),
              tripType: const Value(TripType.city),
              climate: const Value(Climate.temperate),
              travelerCount: const Value(2),
              notes: const Value('Viaggio di esempio: puoi modificarlo o eliminarlo.'),
            ),
          );

      // Viaggiatori
      final meId = newId();
      final friendId = newId();
      await db.batch((b) {
        b.insert(
          db.travelers,
          TravelersCompanion.insert(
            id: meId,
            tripId: tripId,
            name: 'Io',
            isSelfUser: const Value(true),
            colorHex: const Value('#00796B'),
          ),
        );
        b.insert(
          db.travelers,
          TravelersCompanion.insert(
            id: friendId,
            tripId: tripId,
            name: 'Alex',
            colorHex: const Value('#EF6C00'),
            sortOrder: const Value(1),
          ),
        );
      });

      // Bagagli
      final trolleyId = newId();
      final backpackId = newId();
      await db.batch((b) {
        b.insert(
          db.bags,
          BagsCompanion.insert(
            id: trolleyId,
            tripId: tripId,
            name: 'Trolley',
            type: const Value(BagType.hold),
            tareWeightGrams: const Value(3200),
            maxWeightGrams: const Value(20000),
          ),
        );
        b.insert(
          db.bags,
          BagsCompanion.insert(
            id: backpackId,
            tripId: tripId,
            name: 'Zaino',
            type: const Value(BagType.cabin),
            tareWeightGrams: const Value(900),
            maxWeightGrams: const Value(8000),
            sortOrder: const Value(1),
          ),
        );
      });

      // Alcuni oggetti valigia
      Future<void> addItem(
        String cat,
        String name, {
        int qty = 1,
        int packed = 0,
        int? grams,
        bool essential = false,
        String? bagId,
        int order = 0,
      }) async {
        await db.into(db.packingItems).insert(
              PackingItemsCompanion.insert(
                id: newId(),
                tripId: tripId,
                categoryId: packingCats[cat]!,
                name: name,
                quantity: Value(qty),
                packedCount: Value(packed),
                unitWeightGrams: Value(grams),
                isEssential: Value(essential),
                bagId: Value(bagId),
                sortOrder: Value(order),
              ),
            );
      }

      await addItem('Documenti', 'Carta d\'identita', essential: true, packed: 1, grams: 20, bagId: backpackId);
      await addItem('Elettronica', 'Caricabatterie', grams: 150, bagId: backpackId, order: 1);
      await addItem('Elettronica', 'Powerbank', grams: 250, bagId: backpackId, order: 2);
      await addItem('Abbigliamento', 'Magliette', qty: 3, grams: 200, bagId: trolleyId, order: 3);
      await addItem('Abbigliamento', 'Jeans', qty: 1, grams: 600, bagId: trolleyId, order: 4);
      await addItem('Scarpe', 'Scarpe comode', qty: 1, packed: 1, grams: 800, bagId: trolleyId, essential: true, order: 5);
      await addItem('Igiene', 'Necessaire', grams: 500, bagId: trolleyId, order: 6);

      // Una tratta in auto Roma -> Firenze
      await db.into(db.transportSegments).insert(
            TransportSegmentsCompanion.insert(
              id: newId(),
              tripId: tripId,
              mode: const Value(TransportMode.car),
              originLabel: const Value('Roma'),
              destinationLabel: const Value('Firenze'),
              distanceKm: const Value(280),
              distanceSource: const Value(DistanceSource.manual),
              isRoundTrip: const Value(true),
              consumptionSnapshot: const Value(6.5),
              consumptionUnitSnapshot: const Value(ConsumptionUnit.lPer100km),
              fuelPriceCentsSnapshot: const Value(185),
            ),
          );

      // Itinerario: 3 giorni con qualche attivita'
      Future<void> addDay(int index, List<(String cat, String title, int? start, int? end, int? costCents)> acts) async {
        final dayId = newId();
        await db.into(db.itineraryDays).insert(
              ItineraryDaysCompanion.insert(
                id: dayId,
                tripId: tripId,
                date: Value(start.add(Duration(days: index))),
                dayIndex: Value(index),
              ),
            );
        var order = 0;
        for (final (cat, title, s, e, cost) in acts) {
          await db.into(db.activities).insert(
                ActivitiesCompanion.insert(
                  id: newId(),
                  dayId: dayId,
                  tripId: tripId,
                  title: title,
                  categoryId: Value(activityCats[cat]),
                  startMinutes: Value(s),
                  endMinutes: Value(e),
                  costCents: Value(cost),
                  sortIndex: Value(order++),
                ),
              );
        }
      }

      await addDay(0, [
        ('Trasporto', 'Partenza e check-in hotel', 9 * 60, 12 * 60, null),
        ('Cibo', 'Pranzo in trattoria', 13 * 60, 14 * 60 + 30, 3500),
        ('Visita', 'Duomo di Firenze', 15 * 60, 17 * 60, 3000),
      ]);
      await addDay(1, [
        ('Visita', 'Galleria degli Uffizi', 10 * 60, 13 * 60, 2500),
        ('Cibo', 'Pausa pranzo', 13 * 60, 14 * 60, 2000),
        ('Relax', 'Passeggiata Ponte Vecchio', 16 * 60, 18 * 60, null),
      ]);
      await addDay(2, [
        ('Shopping', 'Mercato di San Lorenzo', 10 * 60, 12 * 60, null),
        ('Trasporto', 'Ritorno', 15 * 60, 18 * 60, null),
      ]);
    });
  }
}
