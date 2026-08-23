import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../database.dart';

/// Mappatura per-tabella tra le righe locali (Drift) e quelle remote
/// (Supabase, colonne snake_case). Un solo posto dove vivono le conversioni
/// di tipo (date ISO, enum per nome, numeri, booleani).

class SyncTable {
  const SyncTable({
    required this.name,
    required this.toRemote,
    required this.applyRemote,
    required this.deleteLocal,
  });

  /// Nome tabella (identico in Drift e Supabase).
  final String name;

  /// Riga locale -> mappa per Supabase (null se la riga non esiste piu').
  final Future<Map<String, dynamic>?> Function(AppDatabase db, String id)
      toRemote;

  /// Riga remota -> upsert locale.
  final Future<void> Function(AppDatabase db, Map<String, dynamic> remote)
      applyRemote;

  final Future<void> Function(AppDatabase db, String id) deleteLocal;
}

// --- Helper di conversione -------------------------------------------------

String? _dt(DateTime? d) => d?.toUtc().toIso8601String();
DateTime? _pd(dynamic v) =>
    (v is String && v.isNotEmpty) ? DateTime.parse(v).toLocal() : null;
int? _pi(dynamic v) => (v as num?)?.toInt();
double? _pdouble(dynamic v) => (v as num?)?.toDouble();

T _enumOr<T extends Enum>(List<T> values, dynamic v, T dflt) {
  if (v is String) {
    for (final e in values) {
      if (e.name == v) return e;
    }
  }
  return dflt;
}

T? _enumOrNull<T extends Enum>(List<T> values, dynamic v) {
  if (v is String) {
    for (final e in values) {
      if (e.name == v) return e;
    }
  }
  return null;
}

// --- Elenco delle tabelle sincronizzate ------------------------------------

List<SyncTable> buildSyncTables(AppDatabase db) => [
      // trips ---------------------------------------------------------------
      SyncTable(
        name: 'trips',
        toRemote: (db, id) async {
          final t = await (db.select(db.trips)..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (t == null) return null;
          return {
            'id': t.id,
            'name': t.name,
            'destination': t.destination,
            'country': t.country,
            'start_date': _dt(t.startDate),
            'end_date': _dt(t.endDate),
            'trip_type': t.tripType.name,
            'climate': t.climate.name,
            'traveler_count': t.travelerCount,
            'home_currency': t.homeCurrency,
            'cover_image_path': t.coverImagePath,
            'theme_style': t.themeStyle?.name,
            'notes': t.notes,
            'created_at': _dt(t.createdAt),
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.trips).insertOnConflictUpdate(TripsCompanion(
                id: Value(m['id'] as String),
                name: Value(m['name'] as String),
                destination: Value(m['destination'] as String?),
                country: Value(m['country'] as String?),
                startDate: Value(_pd(m['start_date'])),
                endDate: Value(_pd(m['end_date'])),
                tripType:
                    Value(_enumOr(TripType.values, m['trip_type'], TripType.generic)),
                climate:
                    Value(_enumOr(Climate.values, m['climate'], Climate.temperate)),
                travelerCount: Value(_pi(m['traveler_count']) ?? 1),
                homeCurrency: Value(m['home_currency'] as String? ?? 'EUR'),
                coverImagePath: Value(m['cover_image_path'] as String?),
                themeStyle: Value(_enumOrNull(TripStyle.values, m['theme_style'])),
                notes: Value(m['notes'] as String?),
                createdAt: Value(_pd(m['created_at']) ?? DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.trips)..where((x) => x.id.equals(id))).go(),
      ),

      // travelers -----------------------------------------------------------
      SyncTable(
        name: 'travelers',
        toRemote: (db, id) async {
          final t =
              await (db.select(db.travelers)..where((x) => x.id.equals(id)))
                  .getSingleOrNull();
          if (t == null) return null;
          return {
            'id': t.id,
            'trip_id': t.tripId,
            'name': t.name,
            'share_weight': t.shareWeight,
            'color_hex': t.colorHex,
            'is_self_user': t.isSelfUser,
            'sort_order': t.sortOrder,
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.travelers).insertOnConflictUpdate(TravelersCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                name: Value(m['name'] as String),
                shareWeight: Value(_pdouble(m['share_weight']) ?? 1.0),
                colorHex: Value(m['color_hex'] as String?),
                isSelfUser: Value(m['is_self_user'] as bool? ?? false),
                sortOrder: Value(_pi(m['sort_order']) ?? 0),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.travelers)..where((x) => x.id.equals(id))).go(),
      ),

      // bags ----------------------------------------------------------------
      SyncTable(
        name: 'bags',
        toRemote: (db, id) async {
          final b = await (db.select(db.bags)..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (b == null) return null;
          return {
            'id': b.id,
            'trip_id': b.tripId,
            'name': b.name,
            'type': b.type.name,
            'tare_weight_grams': b.tareWeightGrams,
            'max_weight_grams': b.maxWeightGrams,
            'color_hex': b.colorHex,
            'sort_order': b.sortOrder,
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.bags).insertOnConflictUpdate(BagsCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                name: Value(m['name'] as String),
                type: Value(_enumOr(BagType.values, m['type'], BagType.hold)),
                tareWeightGrams: Value(_pi(m['tare_weight_grams']) ?? 0),
                maxWeightGrams: Value(_pi(m['max_weight_grams'])),
                colorHex: Value(m['color_hex'] as String?),
                sortOrder: Value(_pi(m['sort_order']) ?? 0),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.bags)..where((x) => x.id.equals(id))).go(),
      ),

      // packing_items -------------------------------------------------------
      SyncTable(
        name: 'packing_items',
        toRemote: (db, id) async {
          final p = await (db.select(db.packingItems)
                ..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (p == null) return null;
          return {
            'id': p.id,
            'trip_id': p.tripId,
            'category_id': p.categoryId,
            'bag_id': p.bagId,
            'name': p.name,
            'quantity': p.quantity,
            'packed_count': p.packedCount,
            'unit_weight_grams': p.unitWeightGrams,
            'is_essential': p.isEssential,
            'notes': p.notes,
            'sort_order': p.sortOrder,
            'created_at': _dt(p.createdAt),
          };
        },
        applyRemote: (db, m) async {
          await db
              .into(db.packingItems)
              .insertOnConflictUpdate(PackingItemsCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                categoryId: Value(m['category_id'] as String),
                bagId: Value(m['bag_id'] as String?),
                name: Value(m['name'] as String),
                quantity: Value(_pi(m['quantity']) ?? 1),
                packedCount: Value(_pi(m['packed_count']) ?? 0),
                unitWeightGrams: Value(_pi(m['unit_weight_grams'])),
                isEssential: Value(m['is_essential'] as bool? ?? false),
                notes: Value(m['notes'] as String?),
                sortOrder: Value(_pi(m['sort_order']) ?? 0),
                createdAt: Value(_pd(m['created_at']) ?? DateTime.now()),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.packingItems)..where((x) => x.id.equals(id))).go(),
      ),

      // transport_segments --------------------------------------------------
      SyncTable(
        name: 'transport_segments',
        toRemote: (db, id) async {
          final s = await (db.select(db.transportSegments)
                ..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (s == null) return null;
          return {
            'id': s.id,
            'trip_id': s.tripId,
            'sequence_index': s.sequenceIndex,
            'mode': s.mode.name,
            'origin_label': s.originLabel,
            'origin_lat': s.originLat,
            'origin_lng': s.originLng,
            'destination_label': s.destinationLabel,
            'destination_lat': s.destinationLat,
            'destination_lng': s.destinationLng,
            'distance_km': s.distanceKm,
            'distance_source': s.distanceSource.name,
            'detour_factor': s.detourFactor,
            'is_round_trip': s.isRoundTrip,
            'departure_at': _dt(s.departureAt),
            'arrival_at': _dt(s.arrivalAt),
            'vehicle_id': s.vehicleId,
            'consumption_snapshot': s.consumptionSnapshot,
            'consumption_unit_snapshot': s.consumptionUnitSnapshot?.name,
            'fuel_price_cents_snapshot': s.fuelPriceCentsSnapshot,
            'manual_cost_cents': s.manualCostCents,
            'provider': s.provider,
            'booking_ref': s.bookingRef,
            'seat_info': s.seatInfo,
            'notes': s.notes,
          };
        },
        applyRemote: (db, m) async {
          await db
              .into(db.transportSegments)
              .insertOnConflictUpdate(TransportSegmentsCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                sequenceIndex: Value(_pi(m['sequence_index']) ?? 0),
                mode: Value(
                    _enumOr(TransportMode.values, m['mode'], TransportMode.car)),
                originLabel: Value(m['origin_label'] as String? ?? ''),
                originLat: Value(_pdouble(m['origin_lat'])),
                originLng: Value(_pdouble(m['origin_lng'])),
                destinationLabel: Value(m['destination_label'] as String? ?? ''),
                destinationLat: Value(_pdouble(m['destination_lat'])),
                destinationLng: Value(_pdouble(m['destination_lng'])),
                distanceKm: Value(_pdouble(m['distance_km'])),
                distanceSource: Value(_enumOr(DistanceSource.values,
                    m['distance_source'], DistanceSource.manual)),
                detourFactor: Value(_pdouble(m['detour_factor']) ?? 1.3),
                isRoundTrip: Value(m['is_round_trip'] as bool? ?? false),
                departureAt: Value(_pd(m['departure_at'])),
                arrivalAt: Value(_pd(m['arrival_at'])),
                // I veicoli sono locali (non sincronizzati): evito la FK verso
                // un veicolo inesistente su un altro device. Gli snapshot di
                // consumo/prezzo bastano per i calcoli e la visualizzazione.
                vehicleId: const Value(null),
                consumptionSnapshot: Value(_pdouble(m['consumption_snapshot'])),
                consumptionUnitSnapshot: Value(_enumOrNull(
                    ConsumptionUnit.values, m['consumption_unit_snapshot'])),
                fuelPriceCentsSnapshot:
                    Value(_pi(m['fuel_price_cents_snapshot'])),
                manualCostCents: Value(_pi(m['manual_cost_cents'])),
                provider: Value(m['provider'] as String?),
                bookingRef: Value(m['booking_ref'] as String?),
                seatInfo: Value(m['seat_info'] as String?),
                notes: Value(m['notes'] as String?),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.transportSegments)..where((x) => x.id.equals(id)))
                .go(),
      ),

      // cost_items ----------------------------------------------------------
      SyncTable(
        name: 'cost_items',
        toRemote: (db, id) async {
          final c = await (db.select(db.costItems)..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (c == null) return null;
          return {
            'id': c.id,
            'trip_id': c.tripId,
            'segment_id': c.segmentId,
            'category': c.category.name,
            'description': c.description,
            'amount_cents': c.amountCents,
            'currency': c.currency,
            'date': _dt(c.date),
            'status': c.status.name,
            'paid_by_traveler_id': c.paidByTravelerId,
            'split_method': c.splitMethod.name,
            'receipt_photo_path': c.receiptPhotoPath,
            'created_at': _dt(c.createdAt),
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.costItems).insertOnConflictUpdate(CostItemsCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                segmentId: Value(m['segment_id'] as String?),
                category: Value(_enumOr(
                    CostCategory.values, m['category'], CostCategory.other)),
                description: Value(m['description'] as String?),
                amountCents: Value(_pi(m['amount_cents']) ?? 0),
                currency: Value(m['currency'] as String? ?? 'EUR'),
                date: Value(_pd(m['date'])),
                status: Value(
                    _enumOr(CostStatus.values, m['status'], CostStatus.actual)),
                paidByTravelerId: Value(m['paid_by_traveler_id'] as String?),
                splitMethod: Value(_enumOr(
                    SplitMethod.values, m['split_method'], SplitMethod.equal)),
                receiptPhotoPath: Value(m['receipt_photo_path'] as String?),
                createdAt: Value(_pd(m['created_at']) ?? DateTime.now()),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.costItems)..where((x) => x.id.equals(id))).go(),
      ),

      // cost_splits ---------------------------------------------------------
      SyncTable(
        name: 'cost_splits',
        toRemote: (db, id) async {
          final s = await (db.select(db.costSplits)..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (s == null) return null;
          return {
            'id': s.id,
            'cost_item_id': s.costItemId,
            'traveler_id': s.travelerId,
            'share_weight': s.shareWeight,
            'share_amount_cents': s.shareAmountCents,
            'settled': s.settled,
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.costSplits).insertOnConflictUpdate(CostSplitsCompanion(
                id: Value(m['id'] as String),
                costItemId: Value(m['cost_item_id'] as String),
                travelerId: Value(m['traveler_id'] as String),
                shareWeight: Value(_pdouble(m['share_weight']) ?? 1.0),
                shareAmountCents: Value(_pi(m['share_amount_cents']) ?? 0),
                settled: Value(m['settled'] as bool? ?? false),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.costSplits)..where((x) => x.id.equals(id))).go(),
      ),

      // itinerary_days ------------------------------------------------------
      SyncTable(
        name: 'itinerary_days',
        toRemote: (db, id) async {
          final d = await (db.select(db.itineraryDays)
                ..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (d == null) return null;
          return {
            'id': d.id,
            'trip_id': d.tripId,
            'date': _dt(d.date),
            'day_index': d.dayIndex,
            'title': d.title,
            'notes': d.notes,
            'sort_index': d.sortIndex,
          };
        },
        applyRemote: (db, m) async {
          await db
              .into(db.itineraryDays)
              .insertOnConflictUpdate(ItineraryDaysCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                date: Value(_pd(m['date'])),
                dayIndex: Value(_pi(m['day_index']) ?? 0),
                title: Value(m['title'] as String?),
                notes: Value(m['notes'] as String?),
                sortIndex: Value(_pi(m['sort_index']) ?? 0),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.itineraryDays)..where((x) => x.id.equals(id))).go(),
      ),

      // locations -----------------------------------------------------------
      SyncTable(
        name: 'locations',
        toRemote: (db, id) async {
          final l = await (db.select(db.locations)..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (l == null) return null;
          return {
            'id': l.id,
            'trip_id': l.tripId,
            'label': l.label,
            'address': l.address,
            'latitude': l.latitude,
            'longitude': l.longitude,
            'place_type': l.placeType?.name,
            'notes': l.notes,
            'source': l.source.name,
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.locations).insertOnConflictUpdate(LocationsCompanion(
                id: Value(m['id'] as String),
                tripId: Value(m['trip_id'] as String),
                label: Value(m['label'] as String),
                address: Value(m['address'] as String?),
                latitude: Value(_pdouble(m['latitude'])),
                longitude: Value(_pdouble(m['longitude'])),
                placeType: Value(_enumOrNull(PlaceType.values, m['place_type'])),
                notes: Value(m['notes'] as String?),
                source: Value(_enumOr(
                    LocationSource.values, m['source'], LocationSource.manual)),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.locations)..where((x) => x.id.equals(id))).go(),
      ),

      // activities ----------------------------------------------------------
      SyncTable(
        name: 'activities',
        toRemote: (db, id) async {
          final a = await (db.select(db.activities)..where((x) => x.id.equals(id)))
              .getSingleOrNull();
          if (a == null) return null;
          return {
            'id': a.id,
            'day_id': a.dayId,
            'trip_id': a.tripId,
            'title': a.title,
            'category_id': a.categoryId,
            'start_minutes': a.startMinutes,
            'end_minutes': a.endMinutes,
            'is_all_day': a.isAllDay,
            'location_id': a.locationId,
            'cost_cents': a.costCents,
            'currency': a.currency,
            'status': a.status.name,
            'ignore_conflict': a.ignoreConflict,
            'notes': a.notes,
            'booking_ref': a.bookingRef,
            'booking_url': a.bookingUrl,
            'sort_index': a.sortIndex,
            'created_at': _dt(a.createdAt),
          };
        },
        applyRemote: (db, m) async {
          await db.into(db.activities).insertOnConflictUpdate(ActivitiesCompanion(
                id: Value(m['id'] as String),
                dayId: Value(m['day_id'] as String),
                tripId: Value(m['trip_id'] as String),
                title: Value(m['title'] as String),
                categoryId: Value(m['category_id'] as String?),
                startMinutes: Value(_pi(m['start_minutes'])),
                endMinutes: Value(_pi(m['end_minutes'])),
                isAllDay: Value(m['is_all_day'] as bool? ?? false),
                locationId: Value(m['location_id'] as String?),
                costCents: Value(_pi(m['cost_cents'])),
                currency: Value(m['currency'] as String? ?? 'EUR'),
                status: Value(_enumOr(
                    ActivityStatus.values, m['status'], ActivityStatus.planned)),
                ignoreConflict: Value(m['ignore_conflict'] as bool? ?? false),
                notes: Value(m['notes'] as String?),
                bookingRef: Value(m['booking_ref'] as String?),
                bookingUrl: Value(m['booking_url'] as String?),
                sortIndex: Value(_pi(m['sort_index']) ?? 0),
                createdAt: Value(_pd(m['created_at']) ?? DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ));
        },
        deleteLocal: (db, id) =>
            (db.delete(db.activities)..where((x) => x.id.equals(id))).go(),
      ),
    ];
