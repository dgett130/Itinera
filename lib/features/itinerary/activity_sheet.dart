import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/widgets.dart';
import '../places/geocoding_service.dart';
import '../places/map_picker_screen.dart';
import '../places/place_autocomplete_field.dart';
import 'itinerary_providers.dart';

/// Etichetta di un giorno per i menu (data o "Non programmato").
String dayLabel(ItineraryDay day) {
  if (day.date == null) return 'Non programmato';
  return Fmt.dateShort(day.date!);
}

/// Foglio di aggiunta/modifica di un'attivita'.
Future<void> showActivitySheet(
  BuildContext context, {
  required String tripId,
  required String dayId,
  required List<ItineraryDay> days,
  required List<ActivityCategory> categories,
  Activity? existing,
  Location? existingLocation,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ActivityForm(
        tripId: tripId,
        dayId: dayId,
        days: days,
        categories: categories,
        existing: existing,
        existingLocation: existingLocation,
      ),
    ),
  );
}

class _ActivityForm extends ConsumerStatefulWidget {
  const _ActivityForm({
    required this.tripId,
    required this.dayId,
    required this.days,
    required this.categories,
    this.existing,
    this.existingLocation,
  });

  final String tripId;
  final String dayId;
  final List<ItineraryDay> days;
  final List<ActivityCategory> categories;
  final Activity? existing;
  final Location? existingLocation;

  @override
  ConsumerState<_ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<_ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late String _dayId;
  String? _categoryId;
  int? _start;
  int? _end;
  double? _locLat;
  double? _locLng;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _dayId = e?.dayId ?? widget.dayId;
    _categoryId = e?.categoryId;
    _start = e?.startMinutes;
    _end = e?.endMinutes;
    if (e != null) {
      _titleCtrl.text = e.title;
      if (e.costCents != null) {
        _costCtrl.text =
            (e.costCents! / 100).toStringAsFixed(2).replaceAll('.', ',');
      }
      _notesCtrl.text = e.notes ?? '';
    }
    _locationCtrl.text = widget.existingLocation?.label ?? '';
    _locLat = widget.existingLocation?.latitude;
    _locLng = widget.existingLocation?.longitude;
  }

  Future<void> _pickOnMap() async {
    final initial = (_locLat != null && _locLng != null)
        ? LatLng(_locLat!, _locLng!)
        : null;
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: initial)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _locLat = picked.latitude;
      _locLng = picked.longitude;
    });
    // Prova a ricavare un'etichetta leggibile (se online).
    final geocoding = GeocodingService();
    final label = await geocoding.reverse(picked.latitude, picked.longitude);
    geocoding.dispose();
    if (!mounted) return;
    if (label != null && label.isNotEmpty) {
      _locationCtrl.text = label;
    } else if (_locationCtrl.text.trim().isEmpty) {
      _locationCtrl.text =
          '${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _costCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _start : _end;
    final initial = current != null
        ? TimeOfDay(hour: current ~/ 60, minute: current % 60)
        : const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      final minutes = picked.hour * 60 + picked.minute;
      if (isStart) {
        _start = minutes;
        if (_end != null && _end! < minutes) _end = minutes;
      } else {
        _end = minutes;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start != null && _end != null && _end! < _start!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fine non puo precedere l\'inizio')),
      );
      return;
    }
    final repo = ref.read(itineraryRepositoryProvider);
    final cost = _costCtrl.text.trim().isEmpty
        ? null
        : Fmt.parseMoneyToCents(_costCtrl.text);
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    final locationId = await repo.upsertLocationLabel(
      widget.tripId,
      widget.existing?.locationId,
      _locationCtrl.text,
      latitude: _locLat,
      longitude: _locLng,
    );

    if (widget.existing == null) {
      await repo.addActivity(
        tripId: widget.tripId,
        dayId: _dayId,
        title: _titleCtrl.text.trim(),
        categoryId: _categoryId,
        startMinutes: _start,
        endMinutes: _end,
        costCents: cost,
        locationId: locationId,
        notes: notes,
      );
    } else {
      await repo.updateActivity(
        widget.existing!.id,
        dayId: _dayId,
        title: _titleCtrl.text.trim(),
        categoryId: _categoryId,
        startMinutes: _start,
        endMinutes: _end,
        costCents: cost,
        locationId: locationId,
        notes: notes,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(isEdit ? 'Modifica attività' : 'Nuova attività'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                autofocus: !isEdit,
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _dayId,
                decoration: const InputDecoration(labelText: 'Giorno'),
                items: [
                  for (final d in widget.days)
                    DropdownMenuItem(value: d.id, child: Text(dayLabel(d))),
                ],
                onChanged: (v) => setState(() => _dayId = v ?? _dayId),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nessuna')),
                  for (final c in widget.categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'Inizio',
                      minutes: _start,
                      onTap: () => _pickTime(isStart: true),
                      onClear: () => setState(() => _start = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeField(
                      label: 'Fine',
                      minutes: _end,
                      onTap: () => _pickTime(isStart: false),
                      onClear: () => setState(() => _end = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PlaceAutocompleteField(
                      controller: _locationCtrl,
                      label: 'Luogo (opzionale)',
                      onSelected: (place) {
                        _locLat = place.latitude;
                        _locLng = place.longitude;
                      },
                      onManualEdit: (_) {
                        _locLat = null;
                        _locLng = null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: IconButton.filledTonal(
                      onPressed: _pickOnMap,
                      icon: const Icon(Icons.map),
                      tooltip: 'Scegli sulla mappa',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                decoration: const InputDecoration(labelText: 'Costo (EUR)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isEdit)
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(itineraryRepositoryProvider)
                            .deleteActivity(widget.existing!.id);
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

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.minutes,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final int? minutes;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: minutes == null
              ? const Icon(Icons.schedule, size: 18)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: Text(Fmt.timeOfDayMinutes(minutes)),
      ),
    );
  }
}
