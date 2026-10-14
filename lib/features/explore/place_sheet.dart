import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../core/visit_duration.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import 'explore_providers.dart';
import 'explore_repository.dart';
import 'explore_ui.dart';
import 'opening_hours.dart';
import 'poi_parser.dart';

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

/// Apre la scheda luogo: pannello trascinabile a tre altezze (essenziale →
/// orari e visita → descrizione, sito e note). La mappa resta visibile dietro.
Future<void> showPlaceSheet(
  BuildContext context, {
  required PlaceInfo place,
  String? distanceLabel,
  PlaceSheetAction? action,
  PlaceSheetAction? secondaryAction,
  PlaceSheetAction? extraAction,
}) {
  // Il pannello vive in una route separata: riporto il tema dello schermo
  // chiamante, così resta nello stile del viaggio.
  final theme = Theme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Theme(
      data: theme,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.42,
        minChildSize: 0.25,
        maxChildSize: 0.92,
        snap: true,
        snapSizes: const [0.42, 0.7],
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

  /// Azione meno frequente, come bottone di testo sotto le altre (es.
  /// "Dividi da qui").
  final PlaceSheetAction? extraAction;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final scheme = context.scheme;
    final category = place.category;
    final catColor = category != null
        ? poiCategoryColor(category)
        : tokens.accent;
    final hours = place.openingHours != null
        ? humanizeOpeningHours(place.openingHours!)
        : const <String>[];
    final subtitle = [
      if (category != null) poiCategoryLabel(l10n, category),
      ?distanceLabel,
    ].join(' · ');

    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          if (place.wikidata != null) _PlacePhotoHeader(place.wikidata!),
          // --- Essenziale (sempre visibile) ---------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: catColor.withValues(alpha: 0.15),
                child: Icon(
                  category != null ? poiCategoryIcon(category) : Icons.place,
                  color: catColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: context.texts.titleLarge),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.texts.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_openStatus(l10n, tokens, scheme) case (
                      final text,
                      final color,
                    )) ...[
                      const SizedBox(height: 2),
                      Text(
                        text,
                        style: context.texts.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (secondaryAction != null) ...[
                  Expanded(child: _button(context, secondaryAction!)),
                  const SizedBox(width: 10),
                ],
                Expanded(child: _button(context, action!)),
              ],
            ),
            if (extraAction != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _run(context, extraAction!),
                  icon: Icon(extraAction!.icon),
                  label: Text(extraAction!.label),
                ),
              ),
          ],
          const SizedBox(height: 12),
          // --- Orari e visita -------------------------------------------------
          _InfoRow(
            icon: Icons.schedule,
            title: l10n.placeOpeningHours,
            lines: hours.isNotEmpty ? hours : [l10n.placeHoursUnknown],
            muted: hours.isEmpty,
          ),
          if (place.visitMinutes != 0)
            _InfoRow(
              icon: Icons.hourglass_bottom,
              title: l10n.placeVisitAbout(
                formatDuration(
                  l10n,
                  (place.visitMinutes ?? defaultVisitMinutes(category)) * 60,
                ),
              ),
              lines: [
                place.visitMinutes == null
                    ? l10n.placeVisitHint
                    : l10n.placeVisitChosen,
              ],
              muted: true,
            ),
          if (_feeLabel(l10n, place.fee) case final fee?)
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              title: l10n.placeFee,
              lines: [fee],
            ),
          if (place.address != null && place.address!.trim().isNotEmpty)
            _InfoRow(icon: Icons.place_outlined, title: place.address!),
          if (place.hasCoords || place.address != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openInMaps(place),
                icon: const Icon(Icons.map_outlined),
                label: Text(l10n.placeOpenInMaps),
              ),
            ),
          // --- Approfondimento ------------------------------------------------
          if (place.description != null &&
              place.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.placeAbout, style: context.texts.titleSmall),
            const SizedBox(height: 4),
            Text(place.description!, style: context.texts.bodyMedium),
          ],
          if (place.website != null && place.website!.trim().isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(l10n.placeWebsite),
              subtitle: Text(
                place.website!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openWebsite(place.website!),
            ),
          const SizedBox(height: 12),
          Text(l10n.placeNotes, style: context.texts.titleSmall),
          const SizedBox(height: 6),
          if (place.locationId != null)
            _NotesField(locationId: place.locationId!, initial: place.notes)
          else
            Text(
              l10n.placeNotesNeedSave,
              style: context.texts.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
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
    final opens = oh.opensAfter(now.weekday, minute);
    return (
      opens == null ? l10n.placeClosedNow : l10n.placeClosedUntil(t(opens)),
      tokens.warning,
    );
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

  Widget _button(BuildContext context, PlaceSheetAction a) {
    final icon = Icon(a.icon);
    final label = Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis);
    return SizedBox(
      height: 48,
      child: a.destructive
          ? OutlinedButton.icon(
              onPressed: () => _run(context, a),
              icon: icon,
              label: label,
            )
          : FilledButton.icon(
              onPressed: () => _run(context, a),
              icon: icon,
              label: label,
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
    this.muted = false,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: context.tokens.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.bodyLarge),
                for (final line in lines)
                  Text(
                    line,
                    style: context.texts.bodyMedium?.copyWith(
                      color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
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
      minLines: 2,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: l10n.placeNotesHint),
    );
  }
}

/// Foto del luogo da Wikimedia Commons con autore e licenza. Compare solo
/// quando c'è (con la rete); altrimenti non occupa spazio.
class _PlacePhotoHeader extends ConsumerStatefulWidget {
  const _PlacePhotoHeader(this.wikidata);
  final String wikidata;

  @override
  ConsumerState<_PlacePhotoHeader> createState() => _PlacePhotoHeaderState();
}

class _PlacePhotoHeaderState extends ConsumerState<_PlacePhotoHeader> {
  /// L'immagine non si è caricata (es. rete persa): niente foto né crediti.
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final photo = ref.watch(placePhotoProvider(widget.wikidata)).value;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final show = photo != null && !_failed;
    return AnimatedSize(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // Fascia bassa: all'apertura nome e azioni restano
                    // visibili sotto la foto.
                    child: AspectRatio(
                      aspectRatio: 2.4,
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
                  InkWell(
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
                ],
              ),
            ),
    );
  }
}
