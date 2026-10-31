import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../core/visit_duration.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'explore_providers.dart';
import 'explore_repository.dart';
import 'explore_ui.dart';
import 'opening_hours.dart';
import 'poi_parser.dart';
import 'route_schedule_view.dart';

/// Dati mostrati dalla scheda luogo, indipendenti dalla provenienza
/// (suggerimento OSM non ancora scelto oppure luogo già nel viaggio).
class PlaceInfo {
  const PlaceInfo({
    required this.name,
    this.category,
    this.lat,
    this.lng,
    this.address,
    this.description,
    this.website,
    this.openingHours,
    this.locationId,
    this.notes,
    this.fromOsm = false,
    this.visitMinutes,
    this.fee,
    this.wikidata,
  });

  factory PlaceInfo.fromSuggestion(PoiSuggestion p) => PlaceInfo(
    name: p.name,
    category: p.category,
    lat: p.lat,
    lng: p.lng,
    address: p.address,
    description: p.description,
    website: p.website,
    openingHours: p.openingHours,
    fromOsm: true,
    fee: p.fee,
    wikidata: p.wikidata,
  );

  factory PlaceInfo.fromLocation(Location l, {int? visitMinutes}) => PlaceInfo(
    name: l.label,
    category: l.poiCategory,
    lat: l.latitude,
    lng: l.longitude,
    address: l.address,
    description: l.description,
    website: l.website,
    openingHours: l.openingHours,
    locationId: l.id,
    notes: l.notes,
    fromOsm: l.source == LocationSource.osm,
    visitMinutes: visitMinutes,
    fee: l.fee,
    wikidata: l.wikidata,
  );

  final String name;
  final PoiCategory? category;
  final double? lat;
  final double? lng;
  final String? address;
  final String? description;
  final String? website;
  final String? openingHours;

  /// Valorizzato se il luogo è già nel viaggio: abilita le note personali.
  final String? locationId;
  final String? notes;
  final bool fromOsm;

  /// Durata di visita scelta nel percorso (null = predefinita per categoria;
  /// 0 = solo partenza/passaggio, senza riga "visita").
  final int? visitMinutes;

  /// Tag OSM `fee` (ingresso), se noto.
  final String? fee;

  /// Codice Wikidata (tag OSM): da qui arriva la foto, se c'è.
  final String? wikidata;

  bool get hasCoords => lat != null && lng != null;
}

/// Azione principale della scheda (es. "Salva luogo", "Togli dal percorso").
/// Dopo l'azione la scheda si chiude.
class PlaceSheetAction {
  const PlaceSheetAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final bool destructive;
}

/// Apre la scheda luogo: pannello trascinabile a tre altezze. Un luogo da
/// aggiungere parte basso (nome e azione); una tappa parte più alta, con foto,
/// stato e azioni. La mappa resta visibile dietro.
Future<void> showPlaceSheet(
  BuildContext context, {
  required PlaceInfo place,
  String? distanceLabel,
  PlaceSheetAction? action,
  PlaceSheetAction? secondaryAction,
  PlaceSheetAction? extraAction,
}) {
  // Il pannello vive in una route separata: riporto il tema dello schermo
  // chiamante.
  final theme = Theme.of(context);
  final adding = action != null && secondaryAction == null;
  final initial = adding ? 0.38 : 0.52;
  return showCartolinaSheet<void>(
    context: context,
    builder: (_) => Theme(
      data: theme,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: initial,
        minChildSize: 0.25,
        maxChildSize: 0.92,
        snap: true,
        snapSizes: [initial, 0.83],
        builder: (context, scroll) => PlaceSheet(
          place: place,
          distanceLabel: distanceLabel,
          action: action,
          secondaryAction: secondaryAction,
          extraAction: extraAction,
          scrollController: scroll,
        ),
      ),
    ),
  );
}

/// Contenuto della scheda luogo (usabile anche fuori da un bottom sheet).
class PlaceSheet extends StatelessWidget {
  const PlaceSheet({
    super.key,
    required this.place,
    this.distanceLabel,
    this.action,
    this.secondaryAction,
    this.extraAction,
    this.scrollController,
  });

  final PlaceInfo place;
  final String? distanceLabel;
  final PlaceSheetAction? action;

  /// Seconda azione, affiancata alla principale (es. "Sposta" accanto a
  /// "Togli").
  final PlaceSheetAction? secondaryAction;

  /// Terza azione, in fila con le altre (es. "Dividi da qui").
  final PlaceSheetAction? extraAction;
  final ScrollController? scrollController;

  /// Luogo non ancora nel percorso: una sola azione, per aggiungerlo.
  bool get _adding => action != null && secondaryAction == null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final scheme = context.scheme;
    final category = place.category;
    final hours = place.openingHours != null
        ? humanizeOpeningHours(place.openingHours!)
        : const <String>[];
    final subtitle = [
      if (category != null) poiCategoryLabel(l10n, category),
      ?distanceLabel,
    ].join(' · ');
    final status = _openStatus(l10n, tokens, scheme);
    final canOpenMaps = place.hasCoords || place.address != null;
    final mapsButton = SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _openInMaps(place),
        icon: const Icon(Icons.open_in_new),
        label: Text(l10n.placeOpenInMaps),
      ),
    );

    // Tessera, categoria e stato; col luogo da aggiungere anche il nome.
    Widget identity({String? name}) => Row(
      children: [
        PoiTile(category, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name != null) Text(name, style: context.texts.titleMedium),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: context.texts.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              if (status case (final text, final color))
                Text(
                  text,
                  style: context.texts.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (_adding) ...[
            // --- Luogo da aggiungere: prima l'azione, poi i dettagli ----------
            Text(
              'Luogo non ancora nel percorso',
              style: context.texts.titleLarge,
            ),
            const SizedBox(height: 12),
            identity(name: place.name),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: () => _run(context, action!),
                icon: Icon(action!.icon),
                label: Text(
                  action!.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (canOpenMaps) ...[const SizedBox(height: 10), mapsButton],
            const SizedBox(height: 16),
            if (place.wikidata != null) _PlaceHead(wikidata: place.wikidata),
          ] else ...[
            // --- Tappa: foto, nome, stato e azioni in fila --------------------
            _PlaceHead(wikidata: place.wikidata, name: place.name),
            const SizedBox(height: 12),
            if (category != null || subtitle.isNotEmpty || status != null)
              identity(),
            if (action != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final (i, a) in [
                    ?secondaryAction,
                    action!,
                    ?extraAction,
                  ].indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: _button(context, a)),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 14),
          ],
          // --- Orari, visita, ingresso, indirizzo e sito ----------------------
          ItineraCard(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow(
                  icon: Icons.schedule,
                  title: l10n.placeOpeningHours,
                  lines: hours.isNotEmpty ? hours : [l10n.placeHoursUnknown],
                ),
                if (place.visitMinutes != 0)
                  _InfoRow(
                    icon: Icons.landscape,
                    title: l10n.placeVisitAbout(
                      formatDuration(
                        l10n,
                        (place.visitMinutes ?? defaultVisitMinutes(category)) *
                            60,
                      ),
                    ),
                  ),
                if (_feeLabel(l10n, place.fee) case final fee?)
                  _InfoRow(
                    icon: Icons.euro,
                    title: l10n.placeFee,
                    lines: [fee],
                  ),
                if (place.address != null && place.address!.trim().isNotEmpty)
                  _InfoRow(icon: Icons.place, title: place.address!),
                if (place.website != null && place.website!.trim().isNotEmpty)
                  InkWell(
                    onTap: () => _openWebsite(place.website!),
                    child: _InfoRow(
                      icon: Icons.language,
                      title: l10n.placeWebsite,
                      lines: [place.website!],
                      singleLine: true,
                      trailing: Icons.open_in_new,
                    ),
                  ),
              ],
            ),
          ),
          if (!_adding && canOpenMaps) ...[
            const SizedBox(height: 12),
            mapsButton,
          ],
          // --- Approfondimento ------------------------------------------------
          if (place.description != null &&
              place.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(place.description!, style: context.texts.bodyMedium),
          ],
          const SizedBox(height: 14),
          if (place.locationId != null)
            _NotesField(locationId: place.locationId!, initial: place.notes)
          else ...[
            Text(l10n.placeNotes, style: context.texts.titleSmall),
            const SizedBox(height: 4),
            Text(
              l10n.placeNotesNeedSave,
              style: context.texts.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (place.fromOsm) ...[
            const SizedBox(height: 16),
            Text(
              l10n.exploreAttribution,
              style: context.texts.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// "Aperto ora · chiude alle …" / "Chiuso ora · apre alle …" adesso;
  /// "Orari da verificare" se gli orari ci sono ma non sono interpretabili.
  (String, Color)? _openStatus(
    AppLocalizations l10n,
    ItineraTokens tokens,
    ColorScheme scheme,
  ) {
    final raw = place.openingHours;
    if (raw == null || raw.trim().isEmpty) return null;
    final oh = OpeningHours.parse(raw);
    if (oh == null) return (l10n.placeHoursCheck, scheme.onSurfaceVariant);
    final now = DateTime.now();
    final minute = now.hour * 60 + now.minute;
    String t(int m) => Fmt.timeOfDayMinutes(m % (24 * 60));
    if (oh.isOpen(now.weekday, minute)) {
      final closes = oh.closesAt(now.weekday, minute);
      return (
        closes == null ? l10n.placeOpenNow : l10n.placeOpenUntil(t(closes)),
        tokens.positive,
      );
    }
    final next = oh.nextOpening(now.weekday, minute);
    final text = switch (next) {
      null => l10n.placeClosedNow,
      (0, final m) => l10n.placeClosedUntil(t(m)),
      (1, final m) => l10n.placeClosedUntilTomorrow(t(m)),
      (final d, final m) => l10n.placeClosedUntilDay(
        DateFormat.EEEE('it_IT').format(now.add(Duration(days: d))),
        t(m),
      ),
    };
    return (text, tokens.warning);
  }

  /// Tag OSM `fee`: `no` gratuito, `yes` a pagamento, `donation` offerta
  /// libera; altri valori (orari, importi…) non li interpretiamo.
  static String? _feeLabel(AppLocalizations l10n, String? fee) =>
      switch (fee?.trim().toLowerCase()) {
        'no' => l10n.placeFeeFree,
        'yes' => l10n.placeFeePaid,
        'donation' => l10n.placeFeeDonation,
        _ => null,
      };

  /// Bottone della fila di azioni: tre stanno in una riga, il testo si
  /// rimpicciolisce invece di tagliarsi.
  Widget _button(BuildContext context, PlaceSheetAction a) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () => _run(context, a),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(a.label, maxLines: 1),
        ),
      ),
    );
  }

  /// La scheda si chiude PRIMA dell'azione: così l'azione può aprire un
  /// altro pannello (es. la scelta del percorso) senza sovrapporsi.
  Future<void> _run(BuildContext context, PlaceSheetAction a) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
    await a.onPressed();
  }

  static Future<void> _openInMaps(PlaceInfo p) async {
    final query = p.hasCoords
        ? '${p.lat},${p.lng}'
        : Uri.encodeComponent(p.address ?? p.name);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> _openWebsite(String raw) async {
    final url = raw.trim();
    final uri = Uri.tryParse(url.contains('://') ? url : 'https://$url');
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    this.lines = const [],
    this.singleLine = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final bool singleLine;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final muted = context.scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.texts.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                for (final line in lines)
                  Text(
                    line,
                    maxLines: singleLine ? 1 : null,
                    overflow: singleLine ? TextOverflow.ellipsis : null,
                    style: context.texts.bodyMedium?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, size: 18, color: muted),
          ],
        ],
      ),
    );
  }
}

/// Note personali: salvate in automatico mentre scrivi (e alla chiusura).
class _NotesField extends ConsumerStatefulWidget {
  const _NotesField({required this.locationId, this.initial});
  final String locationId;
  final String? initial;

  @override
  ConsumerState<_NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends ConsumerState<_NotesField> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.initial ?? '',
  );
  late final ExploreRepository _repo = ref.read(exploreRepositoryProvider);
  Timer? _debounce;
  bool _dirty = false;

  void _onChanged(String _) {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _flush);
  }

  void _flush() {
    if (!_dirty) return;
    _dirty = false;
    unawaited(_repo.updateLocationNotes(widget.locationId, _ctrl.text));
  }

  @override
  void initState() {
    super.initState();
    // Forza la lettura del repository finché il widget è montato.
    _repo;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _flush();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _ctrl,
      onChanged: _onChanged,
      minLines: 1,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: l10n.placeNotes,
        hintText: l10n.placeNotesHint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

/// Testa della scheda: foto da Wikimedia Commons (compare solo quando c'è, con
/// la rete; altrimenti non occupa spazio), [name] se c'è, poi autore e licenza.
class _PlaceHead extends ConsumerStatefulWidget {
  const _PlaceHead({this.wikidata, this.name});
  final String? wikidata;
  final String? name;

  @override
  ConsumerState<_PlaceHead> createState() => _PlaceHeadState();
}

class _PlaceHeadState extends ConsumerState<_PlaceHead> {
  /// L'immagine non si è caricata (es. rete persa): niente foto né crediti.
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wikidata = widget.wikidata;
    final photo = wikidata == null
        ? null
        : ref.watch(placePhotoProvider(wikidata)).value;
    final show = photo != null && !_failed;
    final duration = Motion.of(context, Motion.standard);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: !show
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    // Fascia bassa: all'apertura nome e azioni restano
                    // visibili sotto la foto.
                    child: AspectRatio(
                      aspectRatio: 2.2,
                      child: ColoredBox(
                        color: context.tokens.accentSoft,
                        child: Image(
                          image: ref.watch(placePhotoImageProvider)(
                            photo.imageUrl,
                          ),
                          fit: BoxFit.cover,
                          semanticLabel: photo.author,
                          errorBuilder: (_, _, _) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !_failed) {
                                setState(() => _failed = true);
                              }
                            });
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (widget.name != null)
          Text(
            widget.name!,
            style: context.texts.titleLarge?.copyWith(fontSize: 26),
          ),
        AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: !show
              ? const SizedBox(width: double.infinity)
              : InkWell(
                  onTap: () => launchUrl(
                    Uri.parse(photo.pageUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      l10n.placePhotoCredit(
                        [
                          ?photo.author,
                          ?photo.license,
                          'Wikimedia Commons',
                        ].join(' · '),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
