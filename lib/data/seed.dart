import 'package:drift/drift.dart';

import '../core/enums.dart';
import '../core/id.dart';
import 'database.dart';

/// Popola il database con i dati di default alla prima apertura:
/// impostazioni, categorie valigia/attivita' di sistema e modelli valigia
/// built-in. Idempotente: non fa nulla se le categorie esistono gia'.
class AppSeed {
  const AppSeed._();

  static Future<void> ensureSeeded(AppDatabase db) async {
    final existing = await db.select(db.packingCategories).get();
    if (existing.isNotEmpty) return;

    await db.transaction(() async {
      await _seedSettings(db);
      await _seedPackingCategories(db);
      await _seedActivityCategories(db);
      await _seedPackingTemplates(db);
    });
  }

  static Future<void> _seedSettings(AppDatabase db) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          const AppSettingsCompanion(id: Value(1)),
        );
  }

  static Future<void> _seedPackingCategories(AppDatabase db) async {
    const cats = <(String, String, String)>[
      ('Documenti', 'badge', '#1565C0'),
      ('Abbigliamento', 'checkroom', '#6A1B9A'),
      ('Igiene', 'wash', '#00838F'),
      ('Scarpe', 'shoe', '#4E342E'),
      ('Elettronica', 'devices', '#37474F'),
      ('Farmaci', 'medical', '#C62828'),
      ('Accessori', 'accessories', '#AD1457'),
      ('Varie', 'category', '#616161'),
    ];
    await db.batch((b) {
      var order = 0;
      for (final (name, icon, color) in cats) {
        b.insert(
          db.packingCategories,
          PackingCategoriesCompanion.insert(
            id: newId(),
            name: name,
            iconKey: Value(icon),
            colorHex: Value(color),
            isSystem: const Value(true),
            sortOrder: Value(order++),
          ),
        );
      }
    });
  }

  static Future<void> _seedActivityCategories(AppDatabase db) async {
    const cats = <(String, String, String)>[
      ('Cibo', 'restaurant', '#EF6C00'),
      ('Visita', 'sightseeing', '#00695C'),
      ('Trasporto', 'transport', '#455A64'),
      ('Alloggio', 'hotel', '#4527A0'),
      ('Relax', 'relax', '#2E7D32'),
      ('Shopping', 'shopping', '#AD1457'),
      ('Altro', 'place', '#616161'),
    ];
    await db.batch((b) {
      var order = 0;
      for (final (name, icon, color) in cats) {
        b.insert(
          db.activityCategories,
          ActivityCategoriesCompanion.insert(
            id: newId(),
            name: name,
            iconKey: Value(icon),
            colorHex: Value(color),
            isSystem: const Value(true),
            sortIndex: Value(order++),
          ),
        );
      }
    });
  }

  static Future<void> _seedPackingTemplates(AppDatabase db) async {
    for (final t in _templates) {
      final templateId = newId();
      await db.into(db.packingTemplates).insert(
            PackingTemplatesCompanion.insert(
              id: templateId,
              name: t.name,
              description: Value(t.description),
              tripType: Value(t.tripType),
              isBuiltIn: const Value(true),
            ),
          );
      await db.batch((b) {
        var order = 0;
        for (final item in t.items) {
          b.insert(
            db.packingTemplateItems,
            PackingTemplateItemsCompanion.insert(
              id: newId(),
              templateId: templateId,
              categoryName: item.category,
              name: item.name,
              baseQuantity: Value(item.qty),
              isEssential: Value(item.essential),
              sortOrder: Value(order++),
            ),
          );
        }
      });
    }
  }
}

// --- Definizione dei modelli valigia built-in ------------------------------

class _TplItem {
  const _TplItem(this.category, this.name, {this.qty = 1, this.essential = false});
  final String category;
  final String name;
  final int qty;
  final bool essential;
}

class _Template {
  const _Template({
    required this.name,
    required this.description,
    required this.tripType,
    required this.items,
  });
  final String name;
  final String description;
  final TripType tripType;
  final List<_TplItem> items;
}

const _essentials = <_TplItem>[
  _TplItem('Documenti', 'Carta d\'identita / passaporto', essential: true),
  _TplItem('Documenti', 'Tessera sanitaria', essential: true),
  _TplItem('Documenti', 'Portafoglio e contanti', essential: true),
  _TplItem('Elettronica', 'Telefono', essential: true),
  _TplItem('Elettronica', 'Caricabatterie'),
  _TplItem('Elettronica', 'Powerbank'),
  _TplItem('Igiene', 'Spazzolino'),
  _TplItem('Igiene', 'Dentifricio'),
  _TplItem('Igiene', 'Deodorante'),
  _TplItem('Farmaci', 'Medicine personali', essential: true),
];

final List<_Template> _templates = [
  _Template(
    name: 'Essenziale',
    description: 'La base che non deve mai mancare, per qualsiasi viaggio.',
    tripType: TripType.generic,
    items: _essentials,
  ),
  _Template(
    name: 'Mare',
    description: 'Vacanza al mare: spiaggia, sole e relax.',
    tripType: TripType.sea,
    items: [
      ..._essentials,
      const _TplItem('Abbigliamento', 'Costume da bagno', qty: 2),
      const _TplItem('Accessori', 'Telo mare', qty: 2),
      const _TplItem('Igiene', 'Crema solare'),
      const _TplItem('Accessori', 'Occhiali da sole'),
      const _TplItem('Accessori', 'Cappello'),
      const _TplItem('Scarpe', 'Infradito / ciabatte'),
      const _TplItem('Abbigliamento', 'Magliette leggere', qty: 4),
      const _TplItem('Abbigliamento', 'Pantaloncini', qty: 3),
    ],
  ),
  _Template(
    name: 'Montagna',
    description: 'Trekking ed escursioni in quota.',
    tripType: TripType.mountain,
    items: [
      ..._essentials,
      const _TplItem('Scarpe', 'Scarponi da trekking', essential: true),
      const _TplItem('Abbigliamento', 'Giacca antipioggia'),
      const _TplItem('Abbigliamento', 'Pile / felpa calda', qty: 2),
      const _TplItem('Abbigliamento', 'Pantaloni da trekking', qty: 2),
      const _TplItem('Accessori', 'Borraccia'),
      const _TplItem('Accessori', 'Zaino da giornata'),
      const _TplItem('Igiene', 'Crema solare'),
      const _TplItem('Farmaci', 'Cerotti'),
    ],
  ),
  _Template(
    name: 'Citta',
    description: 'City break: musei, passeggiate e buon cibo.',
    tripType: TripType.city,
    items: [
      ..._essentials,
      const _TplItem('Scarpe', 'Scarpe comode', essential: true),
      const _TplItem('Abbigliamento', 'Outfit per la sera', qty: 2),
      const _TplItem('Accessori', 'Zaino / borsa'),
      const _TplItem('Accessori', 'Ombrello pieghevole'),
      const _TplItem('Elettronica', 'Auricolari'),
    ],
  ),
  _Template(
    name: 'Lavoro',
    description: 'Trasferta di lavoro: sobrieta ed efficienza.',
    tripType: TripType.business,
    items: [
      ..._essentials,
      const _TplItem('Abbigliamento', 'Abito / camicie', qty: 2),
      const _TplItem('Scarpe', 'Scarpe eleganti'),
      const _TplItem('Elettronica', 'Laptop', essential: true),
      const _TplItem('Elettronica', 'Caricabatterie laptop'),
      const _TplItem('Documenti', 'Badge / biglietti da visita'),
    ],
  ),
];
