import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/distance.dart';
import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../data/reference_data.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../places/place_autocomplete_field.dart';
import 'car_picker.dart';
import 'routing_service.dart';
import 'transport_providers.dart';

/// Foglio di aggiunta/modifica di una tratta. Con [fromFab] si apre dal bottone
/// flottante.
Future<void> showSegmentSheet(
  BuildContext context, {
  required String tripId,
  TransportSegment? existing,
  bool fromFab = false,
}) {
  return showCartolinaSheet<void>(
    context: context,
    fromFab: fromFab,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _SegmentForm(tripId: tripId, existing: existing),
    ),
  );
}

class _SegmentForm extends ConsumerStatefulWidget {
  const _SegmentForm({required this.tripId, this.existing});
  final String tripId;
  final TransportSegment? existing;

  @override
  ConsumerState<_SegmentForm> createState() => _SegmentFormState();
}

class _SegmentFormState extends ConsumerState<_SegmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _consumptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _manualCostCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();

  TransportMode _mode = TransportMode.car;
  bool _roundTrip = false;
  bool _defaultsLoaded = false;
  ConsumptionUnit _consumptionUnit = ConsumptionUnit.lPer100km;
  DistanceSource _distanceSource = DistanceSource.manual;
  bool _calculating = false;
  double? _originLat;
  double? _originLng;
  double? _destLat;
  double? _destLng;
  CarSpec? _pickedCar;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _mode = e.mode;
      _roundTrip = e.isRoundTrip;
      _consumptionUnit = e.consumptionUnitSnapshot ?? ConsumptionUnit.lPer100km;
      _distanceSource = e.distanceSource;
      _originLat = e.originLat;
      _originLng = e.originLng;
      _destLat = e.destinationLat;
      _destLng = e.destinationLng;
      _originCtrl.text = e.originLabel;
      _destCtrl.text = e.destinationLabel;
      if (e.distanceKm != null) {
        _distanceCtrl.text = _fmtNum(e.distanceKm!);
      }
      if (e.consumptionSnapshot != null) {
        _consumptionCtrl.text = _fmtNum(e.consumptionSnapshot!);
      }
      if (e.fuelPriceCentsSnapshot != null) {
        _priceCtrl.text = _fmtNum(e.fuelPriceCentsSnapshot! / 100);
      }
      if (e.manualCostCents != null) {
        _manualCostCtrl.text = _fmtNum(e.manualCostCents! / 100);
      }
      _providerCtrl.text = e.provider ?? '';
      _defaultsLoaded = true;
    } else {
      _loadDefaults();
    }
  }

  Future<void> _loadDefaults() async {
    final d = await ref.read(transportRepositoryProvider).getFuelDefaults();
    if (!mounted) return;
    setState(() {
      _consumptionCtrl.text = _fmtNum(d.consumption);
      _priceCtrl.text = _fmtNum(d.priceCents / 100);
      _defaultsLoaded = true;
    });
  }

  String _fmtNum(double v) {
    final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    return s.replaceAll('.', ',');
  }

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _distanceCtrl.dispose();
    _consumptionCtrl.dispose();
    _priceCtrl.dispose();
    _manualCostCtrl.dispose();
    _providerCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(transportRepositoryProvider);
    final distance = Fmt.parseDecimal(_distanceCtrl.text);
    final burnsFuel = _mode.burnsFuel;
    final consumption = burnsFuel
        ? Fmt.parseDecimal(_consumptionCtrl.text)
        : null;
    final priceCents = burnsFuel
        ? Fmt.parseMoneyToCents(_priceCtrl.text)
        : null;
    final manualCost = !burnsFuel
        ? Fmt.parseMoneyToCents(_manualCostCtrl.text)
        : null;
    final provider = _providerCtrl.text.trim().isEmpty
        ? null
        : _providerCtrl.text.trim();

    if (widget.existing == null) {
      await repo.addSegment(
        tripId: widget.tripId,
        mode: _mode,
        originLabel: _originCtrl.text.trim(),
        destinationLabel: _destCtrl.text.trim(),
        originLat: _originLat,
        originLng: _originLng,
        destinationLat: _destLat,
        destinationLng: _destLng,
        distanceKm: distance,
        distanceSource: _distanceSource,
        isRoundTrip: _roundTrip,
        consumption: consumption,
        consumptionUnit: burnsFuel ? _consumptionUnit : null,
        fuelPriceCents: priceCents,
        manualCostCents: manualCost,
        provider: provider,
      );
    } else {
      await repo.updateSegment(
        widget.existing!.id,
        mode: _mode,
        originLabel: _originCtrl.text.trim(),
        destinationLabel: _destCtrl.text.trim(),
        originLat: _originLat,
        originLng: _originLng,
        destinationLat: _destLat,
        destinationLng: _destLng,
        distanceKm: distance,
        distanceSource: _distanceSource,
        isRoundTrip: _roundTrip,
        consumption: consumption,
        consumptionUnit: burnsFuel ? _consumptionUnit : null,
        fuelPriceCents: priceCents,
        manualCostCents: manualCost,
        provider: provider,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final repo = ref.read(transportRepositoryProvider);
    final deleted = await repo.deleteSegment(widget.existing!.id);
    if (!mounted) return;
    if (deleted != null) {
      showUndoSnackBar(
        context,
        message: 'Tratta eliminata',
        onUndo: () => repo.restoreSegment(deleted),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _calculateDistance() async {
    if (_originLat == null ||
        _originLng == null ||
        _destLat == null ||
        _destLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Scegli origine e destinazione dai suggerimenti per calcolare la distanza',
          ),
        ),
      );
      return;
    }
    setState(() => _calculating = true);
    double? km;
    var source = DistanceSource.straightLine;
    // Per i mezzi su strada prova il routing reale (OSRM).
    const road = {
      TransportMode.car,
      TransportMode.motorcycle,
      TransportMode.camper,
      TransportMode.bus,
      TransportMode.taxi,
    };
    if (road.contains(_mode)) {
      final routing = RoutingService();
      km = await routing.drivingDistanceKm(
        _originLat!,
        _originLng!,
        _destLat!,
        _destLng!,
      );
      routing.dispose();
      if (km != null) source = DistanceSource.onlineRouting;
    }
    // Fallback offline / altri mezzi: linea d'aria x fattore percorso.
    km ??= Distance.roadEstimateKm(
      _originLat!,
      _originLng!,
      _destLat!,
      _destLng!,
      detourFactor: 1.3,
    );
    if (!mounted) return;
    setState(() {
      _distanceCtrl.text = km!.toStringAsFixed(1).replaceAll('.', ',');
      _distanceSource = source;
      _calculating = false;
    });
  }

  Future<void> _pickCar() async {
    final car = await showCarPicker(context);
    if (car == null || !mounted) return;
    setState(() {
      _pickedCar = car;
      _consumptionUnit = car.unit;
      _consumptionCtrl.text = car.consumption.toString().replaceAll('.', ',');
    });
  }

  String _carDetails(CarSpec car) =>
      '${car.label} · ${car.consumption.toString().replaceAll('.', ',')} ${car.unit.label}';

  @override
  Widget build(BuildContext context) {
    if (!_defaultsLoaded) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Skeleton(height: 32, radius: 16),
            SizedBox(height: 12),
            Skeleton(height: 52, radius: 16),
            SizedBox(height: 12),
            Skeleton(height: 52, radius: 16),
          ],
        ),
      );
    }
    final isEdit = widget.existing != null;
    final burnsFuel = _mode.burnsFuel;
    final car = _pickedCar;
    const numberKeyboard = TextInputType.numberWithOptions(decimal: true);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(isEdit ? 'Modifica tratta' : 'Nuova tratta'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in TransportMode.values)
                  _Choice(
                    label: m.label,
                    selected: _mode == m,
                    onTap: () => setState(() => _mode = m),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlaceAutocompleteField(
                    controller: _originCtrl,
                    label: 'Da',
                    icon: Icons.trip_origin,
                    onSelected: (p) {
                      _originLat = p.latitude;
                      _originLng = p.longitude;
                    },
                    onManualEdit: (_) {
                      _originLat = null;
                      _originLng = null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PlaceAutocompleteField(
                    controller: _destCtrl,
                    label: 'A',
                    icon: Icons.place,
                    onSelected: (p) {
                      _destLat = p.latitude;
                      _destLng = p.longitude;
                    },
                    onManualEdit: (_) {
                      _destLat = null;
                      _destLng = null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _distanceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Distanza (km)',
                      // La fonte si dice solo se non l'ha scritta l'utente.
                      helperText: _distanceSource == DistanceSource.manual
                          ? null
                          : _distanceSource.label,
                    ),
                    keyboardType: numberKeyboard,
                    onChanged: (_) {
                      if (_distanceSource != DistanceSource.manual) {
                        setState(() => _distanceSource = DistanceSource.manual);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _calculating ? null : _calculateDistance,
                    child: _calculating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Calcola'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ItineraCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              onTap: () => setState(() => _roundTrip = !_roundTrip),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Andata e ritorno',
                      style: context.texts.titleSmall?.copyWith(fontSize: 15.5),
                    ),
                  ),
                  Switch(
                    value: _roundTrip,
                    onChanged: (v) => setState(() => _roundTrip = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (burnsFuel) ...[
              ItineraCard(
                padding: const EdgeInsets.all(12),
                onTap: _pickCar,
                child: Row(
                  children: [
                    const IconTile(
                      Icons.directions_car,
                      color: Cartolina.laguna,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scegli dal catalogo auto',
                            style: context.texts.titleSmall?.copyWith(
                              fontSize: 15.5,
                            ),
                          ),
                          if (car != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _carDetails(car),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.bodySmall?.copyWith(
                                color: context.scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _consumptionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Consumo (${_consumptionUnit.label})',
                      ),
                      keyboardType: numberKeyboard,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: InputDecoration(
                        labelText:
                            _consumptionUnit == ConsumptionUnit.kwhPer100km
                            ? 'Prezzo (€/kWh)'
                            : 'Prezzo (€/L)',
                      ),
                      keyboardType: numberKeyboard,
                    ),
                  ),
                ],
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _manualCostCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Costo biglietto (€)',
                      ),
                      keyboardType: numberKeyboard,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _providerCtrl,
                      decoration: const InputDecoration(labelText: 'Operatore'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isEdit) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.tokens.warning,
                        side: BorderSide(
                          color: context.tokens.warning,
                          width: 1.5,
                        ),
                      ),
                      onPressed: _delete,
                      child: const Text('Elimina'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Salva'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Scelta a pillola: laguna quando è selezionata.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: Cartolina.laguna,
      labelStyle: context.texts.labelLarge?.copyWith(
        color: selected ? Cartolina.inchiostro : context.scheme.onSurface,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : context.tokens.hairline,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => onTap(),
    );
  }
}
