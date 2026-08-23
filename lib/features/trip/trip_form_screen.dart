import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/signatures.dart';
import '../../ui/widgets.dart';
import '../places/country_autocomplete_field.dart';
import '../places/place_autocomplete_field.dart';
import 'trip_providers.dart';

/// Form di creazione o modifica di un viaggio.
class TripFormScreen extends ConsumerStatefulWidget {
  const TripFormScreen({super.key, this.tripId});

  final String? tripId;
  bool get isEditing => tripId != null;

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  TripType _tripType = TripType.generic;
  Climate _climate = Climate.temperate;
  int _travelerCount = 1;

  /// null = automatico (dedotto dal tipo di viaggio).
  TripStyle? _style;

  bool _loading = false;

  TripStyle get _effectiveStyle => _style ?? ItineraTheme.suggestStyle(_tripType);

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadTrip();
  }

  Future<void> _loadTrip() async {
    setState(() => _loading = true);
    final trip = await ref.read(tripRepositoryProvider).getTrip(widget.tripId!);
    if (trip != null && mounted) {
      _nameCtrl.text = trip.name;
      _destCtrl.text = trip.destination ?? '';
      _countryCtrl.text = trip.country ?? '';
      _notesCtrl.text = trip.notes ?? '';
      setState(() {
        _startDate = trip.startDate;
        _endDate = trip.endDate;
        _tripType = trip.tripType;
        _climate = trip.climate;
        _travelerCount = trip.travelerCount;
        _style = trip.themeStyle;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destCtrl.dispose();
    _countryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('it'),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
        if (_startDate != null && picked.isBefore(_startDate!)) {
          _startDate = picked;
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(tripRepositoryProvider);
    final name = _nameCtrl.text.trim();
    final dest = _destCtrl.text.trim().isEmpty ? null : _destCtrl.text.trim();
    final country =
        _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    if (widget.isEditing) {
      await repo.updateTrip(
        widget.tripId!,
        name: name,
        destination: dest,
        country: country,
        startDate: _startDate,
        endDate: _endDate,
        tripType: _tripType,
        climate: _climate,
        travelerCount: _travelerCount,
        themeStyle: _style,
        notes: notes,
      );
      if (mounted) context.pop();
    } else {
      final id = await repo.createTrip(
        name: name,
        destination: dest,
        country: country,
        startDate: _startDate,
        endDate: _endDate,
        tripType: _tripType,
        climate: _climate,
        travelerCount: _travelerCount,
        themeStyle: _style,
        notes: notes,
      );
      if (mounted) context.pushReplacement('/trip/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;

    // Il form stesso anticipa l'identita' scelta: si ri-tematizza in tempo reale.
    return Theme(
      data: ItineraTheme.forStyle(_effectiveStyle, brightness),
      child: Builder(
        builder: (context) {
          if (_loading) {
            return const Scaffold(body: LoadingView());
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.isEditing ? l10n.tripEdit : l10n.tripNew),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  SectionHeader('Il viaggio'),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.tripName,
                      prefixIcon: const Icon(Icons.title),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.commonRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  PlaceAutocompleteField(
                    controller: _destCtrl,
                    label: l10n.tripDestination,
                    onSelected: (place) {
                      if (place.country != null && place.country!.isNotEmpty) {
                        _countryCtrl.text = place.country!;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  CountryAutocompleteField(
                    controller: _countryCtrl,
                    label: l10n.tripCountry,
                  ),
                  SectionHeader('Quando'),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: l10n.tripStartDate,
                          value: _startDate,
                          onTap: () => _pickDate(isStart: true),
                          onClear: () => setState(() => _startDate = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: l10n.tripEndDate,
                          value: _endDate,
                          onTap: () => _pickDate(isStart: false),
                          onClear: () => setState(() => _endDate = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TravelerStepper(
                    label: l10n.tripTravelers,
                    value: _travelerCount,
                    onChanged: (v) => setState(() => _travelerCount = v),
                  ),
                  SectionHeader(l10n.tripType),
                  _TypeSelector(
                    value: _tripType,
                    onChanged: (t) => setState(() => _tripType = t),
                  ),
                  SectionHeader(l10n.tripClimate),
                  _ClimateSelector(
                    value: _climate,
                    onChanged: (c) => setState(() => _climate = c),
                  ),
                  SectionHeader('Stile visivo'),
                  _StylePicker(
                    value: _style,
                    suggested: ItineraTheme.suggestStyle(_tripType),
                    onChanged: (s) => setState(() => _style = s),
                  ),
                  SectionHeader(l10n.commonNotes),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Promemoria, link, idee…',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event),
          suffixIcon: value == null
              ? const Icon(Icons.chevron_right, size: 20)
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: Text(value == null ? '—' : Fmt.date(value!)),
      ),
    );
  }
}

class _TravelerStepper extends StatelessWidget {
  const _TravelerStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.group_outlined),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$value', style: context.texts.titleMedium),
          Row(
            children: [
              IconButton.outlined(
                icon: const Icon(Icons.remove),
                visualDensity: VisualDensity.compact,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                icon: const Icon(Icons.add),
                visualDensity: VisualDensity.compact,
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.value, required this.onChanged});
  final TripType value;
  final ValueChanged<TripType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in TripType.values)
          _PickChip(
            icon: t.icon,
            label: t.label,
            selected: t == value,
            onTap: () => onChanged(t),
          ),
      ],
    );
  }
}

class _ClimateSelector extends StatelessWidget {
  const _ClimateSelector({required this.value, required this.onChanged});
  final Climate value;
  final ValueChanged<Climate> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in Climate.values)
          _PickChip(
            label: c.label,
            selected: c == value,
            onTap: () => onChanged(c),
          ),
      ],
    );
  }
}

/// Chip selezionabile con icona opzionale.
class _PickChip extends StatelessWidget {
  const _PickChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tokens.accentSoft : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? tokens.accent : tokens.hairline,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 17,
                color: selected ? tokens.accent : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? tokens.accent : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selettore dello stile visivo: Automatico + i tre stili con anteprima.
class _StylePicker extends StatelessWidget {
  const _StylePicker({
    required this.value,
    required this.suggested,
    required this.onChanged,
  });

  final TripStyle? value;
  final TripStyle suggested;
  final ValueChanged<TripStyle?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AutoStyleTile(
          selected: value == null,
          suggested: suggested,
          onTap: () => onChanged(null),
        ),
        const SizedBox(height: 10),
        for (final s in TripStyle.values) ...[
          _StyleOptionTile(
            style: s,
            selected: value == s,
            onTap: () => onChanged(s),
          ),
          if (s != TripStyle.values.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AutoStyleTile extends StatelessWidget {
  const _AutoStyleTile({
    required this.selected,
    required this.suggested,
    required this.onTap,
  });
  final bool selected;
  final TripStyle suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final meta = ItineraTheme.meta(suggested);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? tokens.accentSoft : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? tokens.accent : tokens.hairline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: tokens.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Automatico', style: context.texts.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Segue il tipo di viaggio → ${meta.name}',
                    style: context.texts.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: tokens.accent),
          ],
        ),
      ),
    );
  }
}

class _StyleOptionTile extends StatelessWidget {
  const _StyleOptionTile({
    required this.style,
    required this.selected,
    required this.onTap,
  });
  final TripStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final meta = ItineraTheme.meta(style);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected ? tokens.accentSoft : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? tokens.accent : tokens.hairline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Anteprima gradiente con le tacche/firma dello stile.
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [meta.swatch.first, meta.swatch[1]],
                ),
              ),
              child: CustomPaint(
                painter: _miniPainter(style, Colors.white),
                child: Center(child: Icon(meta.icon, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.name, style: context.texts.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    meta.tagline,
                    style: context.texts.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: selected
                  ? Icon(Icons.check_circle, color: tokens.accent)
                  : Icon(Icons.circle_outlined, color: tokens.hairline),
            ),
          ],
        ),
      ),
    );
  }

  CustomPainter _miniPainter(TripStyle style, Color c) => switch (style) {
        TripStyle.atlante => ContourPainter(c),
        TripStyle.boardingPass => TicketPainter(c),
        TripStyle.sunset => SunsetPreviewPainter(c),
      };
}
