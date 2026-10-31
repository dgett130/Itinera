import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enum_labels.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/posters.dart';
import '../../ui/widgets.dart';
import '../auth/auth_providers.dart';
import '../places/country_autocomplete_field.dart';
import '../places/place_autocomplete_field.dart';
import 'google_drive_service.dart';
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
  final _driveCtrl = TextEditingController();

  /// Creazione cartella Drive in corso.
  bool _creatingDrive = false;

  DateTime? _startDate;
  DateTime? _endDate;
  TripType _tripType = TripType.generic;
  Climate _climate = Climate.temperate;
  int _travelerCount = 1;

  /// Coordinate della destinazione (dall'autocomplete). Invalidate se l'utente
  /// modifica il testo a mano.
  double? _destLat;
  double? _destLng;

  /// Dato dei vecchi stili: non piu' usato, si conserva cosi' com'e'.
  TripStyle? _style;

  bool _loading = false;

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
      _driveCtrl.text = trip.driveUrl ?? '';
      _destLat = trip.destinationLat;
      _destLng = trip.destinationLng;
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
    _driveCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    // Chiude la tastiera, che altrimenti si riapre al ritorno dal selettore.
    FocusManager.instance.primaryFocus?.unfocus();
    // Il ritorno parte dal mese della partenza, se c'e' gia'.
    final initial =
        (isStart ? _startDate : _endDate ?? _startDate) ?? DateTime.now();
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
    final country = _countryCtrl.text.trim().isEmpty
        ? null
        : _countryCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty
        ? null
        : _notesCtrl.text.trim();
    final drive = _driveCtrl.text.trim().isEmpty
        ? null
        : _driveCtrl.text.trim();

    if (widget.isEditing) {
      await repo.updateTrip(
        widget.tripId!,
        name: name,
        destination: dest,
        country: country,
        destinationLat: dest == null ? null : _destLat,
        destinationLng: dest == null ? null : _destLng,
        startDate: _startDate,
        endDate: _endDate,
        tripType: _tripType,
        climate: _climate,
        travelerCount: _travelerCount,
        themeStyle: _style,
        notes: notes,
        driveUrl: drive,
      );
      if (mounted) context.pop();
    } else {
      final id = await repo.createTrip(
        name: name,
        destination: dest,
        country: country,
        destinationLat: dest == null ? null : _destLat,
        destinationLng: dest == null ? null : _destLng,
        startDate: _startDate,
        endDate: _endDate,
        tripType: _tripType,
        climate: _climate,
        travelerCount: _travelerCount,
        themeStyle: _style,
        notes: notes,
        driveUrl: drive,
      );
      if (mounted) context.pushReplacement('/trip/$id');
    }
  }

  /// Crea una cartella Drive condivisa (nome = nome del viaggio) e ne inserisce
  /// il link nel campo. Richiede l'account Google collegato.
  Future<void> _createDriveFolder() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack(l10n.tripDriveNeedName);
      return;
    }
    setState(() => _creatingDrive = true);
    try {
      final folder = await ref
          .read(googleDriveServiceProvider)
          .createSharedFolder('Itinera – $name');
      if (!mounted) return;
      setState(() => _driveCtrl.text = folder.webViewLink);
      _snack(l10n.tripDriveCreated);
    } on DriveException catch (e) {
      if (mounted) _snack(e.message);
    } catch (e) {
      if (mounted) _snack(l10n.tripDriveError);
    } finally {
      if (mounted) setState(() => _creatingDrive = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final googleLinked = ref.watch(googleLinkedProvider);

    return Builder(
      builder: (context) {
        if (_loading) {
          return const Scaffold(body: LoadingView());
        }
        // Ricostruisce il poster quando si apre o chiude la tastiera.
        MediaQuery.viewInsetsOf(context);
        return Scaffold(
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                // Il poster resta in vista: si vede cambiare col tipo di viaggio.
                _FormPoster(
                  type: _tripType,
                  name: _nameCtrl,
                  note: widget.isEditing ? l10n.tripEdit : l10n.tripNew,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      SectionHeader('Il viaggio'),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(labelText: l10n.tripName),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.commonRequired
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: PlaceAutocompleteField(
                              controller: _destCtrl,
                              label: l10n.tripDestination,
                              onSelected: (place) {
                                _destLat = place.latitude;
                                _destLng = place.longitude;
                                if (place.country != null &&
                                    place.country!.isNotEmpty) {
                                  _countryCtrl.text = place.country!;
                                }
                              },
                              onManualEdit: (_) {
                                // Modifica manuale del testo: invalida le coordinate.
                                _destLat = null;
                                _destLng = null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: CountryAutocompleteField(
                              controller: _countryCtrl,
                              label: l10n.tripCountry,
                            ),
                          ),
                        ],
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
                          const SizedBox(width: 10),
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
                      const SizedBox(height: 10),
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
                      SectionHeader(l10n.tripDriveSection),
                      TextFormField(
                        controller: _driveCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.tripDriveLink,
                          hintText: 'https://drive.google.com/…',
                        ),
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.tripDriveHint,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ),
                      if (googleLinked) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _creatingDrive
                                ? null
                                : _createDriveFolder,
                            icon: _creatingDrive
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_to_drive_outlined),
                            label: Text(l10n.tripDriveCreate),
                          ),
                        ),
                      ],
                      SectionHeader(l10n.commonNotes),
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Promemoria, link, idee…',
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _save,
                          child: Text(l10n.commonSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: value == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Togli la data',
                  onPressed: onClear,
                ),
        ),
        child: Text(
          value == null ? '—' : Fmt.date(value!),
          style: context.texts.bodyLarge,
        ),
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
    final tokens = context.tokens;
    final scheme = context.scheme;
    final button = Theme.of(context).filledButtonTheme.style;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.texts.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton.outlined(
            icon: const Icon(Icons.remove, size: 20),
            tooltip: 'Meno',
            style: IconButton.styleFrom(
              side: BorderSide(
                color: value > 1 ? scheme.onSurface : tokens.hairline,
                width: 1.5,
              ),
            ),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: context.texts.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton.filled(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Più',
            style: IconButton.styleFrom(
              backgroundColor: button?.backgroundColor?.resolve(const {}),
              foregroundColor: button?.foregroundColor?.resolve(const {}),
            ),
            onPressed: () => onChanged(value + 1),
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

/// Pillola selezionabile: gialla quando e' scelta.
class _PickChip extends StatelessWidget {
  const _PickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () {
          if (!selected) HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: radius,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.fast),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Cartolina.sole : scheme.surfaceContainerLow,
            borderRadius: radius,
            border: Border.all(
              color: selected ? Cartolina.sole : tokens.hairline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Cartolina.inchiostro : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Poster del viaggio in cima al form: cambia con il tipo e il nome. Si
/// riduce quando c'e' la tastiera, per lasciare spazio ai campi.
class _FormPoster extends StatelessWidget {
  const _FormPoster({
    required this.type,
    required this.name,
    required this.note,
  });

  final TripType type;
  final TextEditingController name;
  final String note;

  @override
  Widget build(BuildContext context) {
    final c = type.posterColors;
    final media = MediaQuery.of(context);
    final top = media.padding.top;
    final typing = View.of(context).viewInsets.bottom > 0;
    final width = media.size.width;
    // La scena parte sotto la riga del titolo e la sua fascia bassa si taglia.
    final sceneHeight = width * 240 / 372;
    final height = top + (typing ? 56.0 : sceneHeight - 26);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleOn(c.background),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.emphasis),
          curve: Curves.easeOutCubic,
          height: height,
          // Il cielo sfuma; il paesaggio nuovo sale e quello vecchio svanisce.
          color: c.background,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: top + 44,
                height: sceneHeight,
                child: AnimatedSwitcher(
                  duration: Motion.of(context, Motion.emphasis),
                  switchInCurve: Motion.spring,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation.drive(
                      CurveTween(curve: const Interval(0, 0.4)),
                    ),
                    child: SlideTransition(
                      position: animation.drive(
                        Tween(begin: const Offset(0, 0.6), end: Offset.zero),
                      ),
                      child: child,
                    ),
                  ),
                  child: PosterArt(
                    key: ValueKey(type),
                    type: type,
                    paintBackground: false,
                  ),
                ),
              ),
              Positioned(
                left: 4,
                right: 20,
                top: top + 4,
                height: 48,
                child: Row(
                  children: [
                    BackButton(color: c.foreground),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: name,
                        builder: (context, value, _) =>
                            AnimatedDefaultTextStyle(
                              duration: Motion.of(context, Motion.standard),
                              style: context.texts.titleLarge!.copyWith(
                                fontSize: 26,
                                color: c.foreground,
                              ),
                              child: Text(
                                value.text.trim().isEmpty
                                    ? type.label
                                    : value.text.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!typing)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 12,
                  child: AnimatedDefaultTextStyle(
                    duration: Motion.of(context, Motion.standard),
                    style: context.texts.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.lowerForeground,
                    ),
                    child: Text(note, maxLines: 1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
