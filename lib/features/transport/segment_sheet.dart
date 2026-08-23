import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/distance.dart';
import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/widgets.dart';
import '../places/place_autocomplete_field.dart';
import 'car_picker.dart';
import 'routing_service.dart';
import 'transport_providers.dart';

/// Foglio di aggiunta/modifica di una tratta.
Future<void> showSegmentSheet(
  BuildContext context, {
  required String tripId,
  TransportSegment? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
    final consumption =
        burnsFuel ? Fmt.parseDecimal(_consumptionCtrl.text) : null;
    final priceCents =
        burnsFuel ? Fmt.parseMoneyToCents(_priceCtrl.text) : null;
    final manualCost = !burnsFuel
        ? Fmt.parseMoneyToCents(_manualCostCtrl.text)
        : null;
    final provider =
        _providerCtrl.text.trim().isEmpty ? null : _providerCtrl.text.trim();

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
          _originLat!, _originLng!, _destLat!, _destLng!);
      routing.dispose();
      if (km != null) source = DistanceSource.onlineRouting;
    }
    // Fallback offline / altri mezzi: linea d'aria x fattore percorso.
    km ??= Distance.roadEstimateKm(
        _originLat!, _originLng!, _destLat!, _destLng!,
        detourFactor: 1.3);
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
      _consumptionUnit = car.unit;
      _consumptionCtrl.text =
          car.consumption.toString().replaceAll('.', ',');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_defaultsLoaded) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final isEdit = widget.existing != null;
    final burnsFuel = _mode.burnsFuel;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(isEdit ? 'Modifica tratta' : 'Nuova tratta'),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransportMode>(
                initialValue: _mode,
                decoration: const InputDecoration(labelText: 'Mezzo'),
                items: [
                  for (final m in TransportMode.values)
                    DropdownMenuItem(
                      value: m,
                      child: Row(
                        children: [
                          Icon(m.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(m.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _mode = v ?? _mode),
              ),
              const SizedBox(height: 12),
              PlaceAutocompleteField(
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
              const SizedBox(height: 12),
              PlaceAutocompleteField(
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _distanceCtrl,
                decoration: InputDecoration(
                  labelText: 'Distanza (km)',
                  helperText: _distanceSource.label,
                  suffixIcon: _calculating
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : TextButton(
                          onPressed: _calculateDistance,
                          child: const Text('Calcola'),
                        ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) {
                  if (_distanceSource != DistanceSource.manual) {
                    setState(() => _distanceSource = DistanceSource.manual);
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Andata e ritorno'),
                value: _roundTrip,
                onChanged: (v) => setState(() => _roundTrip = v),
              ),
              if (burnsFuel) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _pickCar,
                    icon: const Icon(Icons.directions_car, size: 18),
                    label: const Text('Scegli dal catalogo auto'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _consumptionCtrl,
                        decoration: InputDecoration(
                          labelText: 'Consumo (${_consumptionUnit.label})',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        decoration: InputDecoration(
                          labelText: _consumptionUnit ==
                                  ConsumptionUnit.kwhPer100km
                              ? 'Prezzo (EUR/kWh)'
                              : 'Prezzo (EUR/L)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                TextFormField(
                  controller: _manualCostCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Costo biglietto (EUR)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _providerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Operatore / compagnia (opzionale)',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isEdit)
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(transportRepositoryProvider)
                            .deleteSegment(widget.existing!.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Elimina'),
                    ),
                  const Spacer(),
                  FilledButton(onPressed: _save, child: const Text('Salva')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
