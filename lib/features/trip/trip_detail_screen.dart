import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/services.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/posters.dart';
import '../../ui/widgets.dart';
import '../bacheca/bacheca_providers.dart';
import '../explore/explore_providers.dart';
import '../itinerary/itinerary_providers.dart';
import '../packing/packing_providers.dart';
import '../../ui/poster_sky.dart';
import '../transport/transport_providers.dart';
import '../weather/weather_providers.dart';
import 'trip_providers.dart';
import 'trip_status.dart';

/// Dettaglio di un viaggio: poster + dati principali + tessere dei moduli.
class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider(tripId));

    return tripAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(body: ErrorView(e)),
      data: (trip) {
        if (trip == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Viaggio non trovato',
            ),
          );
        }
        return _TripDetailBody(trip: trip);
      },
    );
  }
}

class _TripDetailBody extends ConsumerStatefulWidget {
  const _TripDetailBody({required this.trip});
  final Trip trip;

  @override
  ConsumerState<_TripDetailBody> createState() => _TripDetailBodyState();
}

class _TripDetailBodyState extends ConsumerState<_TripDetailBody> {
  static const _posterHeight = 420.0;
  final _scroll = ScrollController();

  /// Quanto il sole e' tramontato: segue lo scorrimento senza ricostruire.
  final _sink = ValueNotifier<double>(0);

  /// Il poster e' arrotolato: il nome passa nella barra in alto.
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      _sink.value = (_scroll.offset / (_posterHeight - 150)).clamp(0.0, 1.0);
      final collapsed = _scroll.offset > _posterHeight - 150;
      if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _sink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = widget.trip;
    final tripId = trip.id;
    final sky = ref.watch(posterSkyProvider(tripId));
    final c = sky?.colorsFor(trip.tripType) ?? trip.tripType.posterColors;
    final overlay = c.overlayBrightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _posterHeight,
            backgroundColor: c.background,
            foregroundColor: c.foreground,
            systemOverlayStyle: overlay,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            clipBehavior: Clip.antiAlias,
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: Text(
                trip.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.foreground),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _DetailPoster(trip: trip, sink: _sink, sky: sky),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.people_outline),
                tooltip: 'Persone',
                onPressed: () => context.push('/trip/$tripId/members'),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.commonEdit,
                onPressed: () => context.push('/trip/$tripId/edit'),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: c.foreground),
                onSelected: (v) async {
                  final repo = ref.read(tripRepositoryProvider);
                  switch (v) {
                    case 'duplicate':
                      final id = await repo.duplicateTrip(tripId);
                      if (context.mounted) context.pushReplacement('/trip/$id');
                    case 'delete':
                      final ok = await _confirmDelete(context, l10n);
                      if (ok && context.mounted) {
                        await repo.deleteTrip(tripId);
                        if (context.mounted) context.pop();
                      }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Text(l10n.commonDuplicate),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.commonDelete),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList.list(
              children: [
                StaggerIn(
                  index: 1,
                  child: _FactsRow(trip: trip, sky: sky),
                ),
                const SizedBox(height: 16),
                StaggerIn(
                  index: 2,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _PackingTile(tripId: tripId)),
                        const SizedBox(width: 12),
                        Expanded(child: _TransportTile(tripId: tripId)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                StaggerIn(index: 3, child: _ItineraryTile(tripId: tripId)),
                const SizedBox(height: 12),
                StaggerIn(
                  index: 4,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _PlacesTile(tripId: tripId)),
                        const SizedBox(width: 12),
                        Expanded(child: _BachecaTile(tripId: tripId)),
                      ],
                    ),
                  ),
                ),
                if (trip.driveUrl != null &&
                    trip.driveUrl!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ItineraCard(
                    onTap: () => _openDrive(context, trip.driveUrl!.trim()),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: context.tokens.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.tripDrivePhotos,
                                style: context.texts.titleMedium,
                              ),
                              Text(
                                l10n.tripDriveOpen,
                                style: context.texts.bodySmall?.copyWith(
                                  color: context.scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new, size: 18),
                      ],
                    ),
                  ),
                ],
                if (trip.notes != null && trip.notes!.trim().isNotEmpty) ...[
                  SectionHeader(l10n.commonNotes),
                  ItineraCard(
                    child: Text(trip.notes!, style: context.texts.bodyMedium),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDrive(BuildContext context, String url) async {
    var uri = Uri.tryParse(url);
    if (uri != null && !uri.hasScheme) uri = Uri.tryParse('https://$url');
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.tripDriveOpenError)));
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.commonDelete),
        content: Text(l10n.tripDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Il poster del viaggio, a tutta larghezza.
class _DetailPoster extends StatelessWidget {
  const _DetailPoster({
    required this.trip,
    required this.sink,
    required this.sky,
  });
  final Trip trip;
  final ValueListenable<double> sink;
  final PosterSky? sky;

  @override
  Widget build(BuildContext context) {
    final c = sky?.colorsFor(trip.tripType) ?? trip.tripType.posterColors;
    final place = tripPlaceLine(trip);
    return LayoutBuilder(
      builder: (context, box) => Stack(
        fit: StackFit.expand,
        children: [
          PosterHero(
            tripId: trip.id,
            child: PosterArt(
              type: trip.tripType,
              alive: true,
              sink: sink,
              sky: sky,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: MediaQuery.paddingOf(context).top + kToolbarHeight + 4,
            // Svanisce scorrendo, prima di arrivare sotto le icone in alto.
            child: ValueListenableBuilder<double>(
              valueListenable: sink,
              builder: (context, v, child) =>
                  Opacity(opacity: (1 - v * 5).clamp(0.0, 1.0), child: child),
              child: Text(
                trip.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.texts.displaySmall?.copyWith(
                  fontSize: box.maxWidth * 0.105,
                  height: 1.02,
                  color: c.foreground,
                ),
              ),
            ),
          ),
          if (place.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Text(
                place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.lowerForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Stato, durata e persone del viaggio.
class _FactsRow extends StatelessWidget {
  const _FactsRow({required this.trip, required this.sky});
  final Trip trip;

  /// Il cielo vivo: pillola del meteo e riga con ora e tramonto.
  final PosterSky? sky;

  @override
  Widget build(BuildContext context) {
    final s = trip.startDate;
    final e = trip.endDate;
    final days = s != null && e != null ? e.difference(s).inDays + 1 : null;
    final people = trip.travelerCount;
    final sky = this.sky;
    final weather = sky?.weather;
    final temp = sky?.temperature;
    final row = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          PosterPill(tripStatusLabel(trip)),
          const SizedBox(width: 8),
          if (sky != null && weather != null && temp != null) ...[
            _OutlinePill('$temp° · ${weather.label}', icon: sky.icon),
            const SizedBox(width: 8),
          ],
          if (days != null) ...[
            _OutlinePill(days == 1 ? '1 giorno' : '$days giorni'),
            const SizedBox(width: 8),
          ],
          _OutlinePill(people == 1 ? '1 persona' : '$people persone'),
        ],
      ),
    );
    final note = sky?.note;
    if (note == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row,
        const SizedBox(height: 10),
        Text(
          note,
          style: context.texts.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _OutlinePill extends StatelessWidget {
  const _OutlinePill(this.text, {this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(color: context.scheme.onSurface, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: context.scheme.onSurface),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: context.tokens.displayFont,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.2,
              color: context.scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackingTile extends ConsumerWidget {
  const _PackingTile({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(packingItemsProvider(tripId)).value ?? const [];
    final total = items.length;
    final packed = items
        .where((i) => i.packedCount >= i.quantity && i.quantity > 0)
        .length;
    return PosterTile(
      color: Cartolina.sole,
      value: total == 0 ? null : '$packed/$total',
      title: l10n.sectionPacking,
      note: total == 0 ? 'Prepara e spunta il bagaglio' : null,
      onTap: () => context.push('/trip/$tripId/packing'),
      child: total == 0
          ? null
          : MeterBar(
              value: packed / total,
              color: Cartolina.inchiostro,
              track: const Color(0x3011153A),
            ),
    );
  }
}

class _TransportTile extends ConsumerWidget {
  const _TransportTile({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final segments = ref.watch(segmentsProvider(tripId)).value ?? const [];
    final expenses = ref.watch(expensesProvider(tripId)).value ?? const [];
    final spent = expenses
        .where((e) => e.status == CostStatus.actual)
        .fold<int>(0, (a, e) => a + e.amountCents);
    final note = segments.isEmpty
        ? (spent > 0 ? null : 'Tratte, carburante e spese')
        : (segments.length == 1 ? '1 tratta' : '${segments.length} tratte');
    return PosterTile(
      color: Cartolina.laguna,
      value: spent > 0 ? Fmt.currencyCents(spent) : null,
      title: l10n.sectionTransport,
      note: note,
      onTap: () => context.push('/trip/$tripId/transport'),
    );
  }
}

class _ItineraryTile extends ConsumerWidget {
  const _ItineraryTile({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activities = ref.watch(activitiesProvider(tripId)).value ?? const [];
    final days = <DateTime>[
      for (final d
          in ref.watch(itineraryDaysProvider(tripId)).value ??
              const <ItineraryDay>[])
        if (d.date != null) d.date!,
    ];
    final now = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    final highlight = days.any(isToday) ? null : days.firstOrNull;
    return PosterTile(
      color: Cartolina.cobalto,
      foreground: Colors.white,
      title: l10n.sectionItinerary,
      note: activities.isEmpty
          ? 'Programma giorno per giorno'
          : (activities.length == 1
                ? '1 attività'
                : '${activities.length} attività'),
      onTap: () => context.push('/trip/$tripId/itinerary'),
      child: days.isEmpty
          ? null
          : SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final d = days[i];
                  final on = isToday(d) || d == highlight;
                  return Container(
                    width: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? Cartolina.sole : Cartolina.cobaltoScuro,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${d.day}',
                      style: TextStyle(
                        fontFamily: context.tokens.displayFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        color: on ? Cartolina.inchiostro : Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _PlacesTile extends ConsumerWidget {
  const _PlacesTile({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final routes = ref.watch(routesProvider(tripId)).value ?? const [];
    return PosterTile(
      color: Cartolina.corallo,
      value: routes.isEmpty ? null : '${routes.length}',
      title: l10n.sectionExplore,
      note: routes.isEmpty ? l10n.exploreModuleSubtitle : null,
      onTap: () => context.push('/trip/$tripId/explore'),
    );
  }
}

class _BachecaTile extends ConsumerWidget {
  const _BachecaTile({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final files = ref.watch(tripFilesProvider(tripId)).value ?? const [];
    final scheme = context.scheme;
    return PosterTile(
      color: scheme.surfaceContainerLow,
      foreground: scheme.onSurface,
      borderColor: scheme.onSurface,
      valueColor: context.tokens.accent,
      value: files.isEmpty ? null : '${files.length}',
      title: l10n.bachecaTitle,
      note: files.isEmpty ? l10n.bachecaModuleSubtitle : 'file condivisi',
      onTap: () => context.push('/trip/$tripId/files'),
    );
  }
}
