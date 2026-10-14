import 'package:flutter/material.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../transport/routing_service.dart';
import 'explore_ui.dart';
import 'geo_codec.dart';
import 'route_schedule.dart';
import 'route_warnings.dart';

/// Pezzi di interfaccia della scaletta, condivisi tra il passo "Pianifica"
/// (modificabile) e il riepilogo in sola lettura aperto dall'itinerario.

/// Scaletta delle tappe [refs] (nell'ordine del percorso) dai tratti salvati.
RouteSchedule? scheduleForRefs(
  SightseeingRoute route,
  List<(SightseeingRouteStop, Location)> refs,
) => buildSchedule(
  stops: [
    for (final (s, l) in refs)
      ScheduleStop(
        hasCoords: l.latitude != null && l.longitude != null,
        visitMinutes: effectiveVisitMinutes(s.visitMinutes, l.poiCategory),
      ),
  ],
  legs: decodeLegs(route.legs),
  returnToStart: route.returnToStart,
);

/// Avvisi per le tappe [refs] con la scaletta [schedule]; [weekday] è il
/// giorno della settimana del giorno scelto (null se senza data).
List<RouteWarning> warningsForRefs(
  SightseeingRoute route,
  List<(SightseeingRouteStop, Location)> refs,
  RouteSchedule schedule,
  WarningSettings settings,
  int? weekday,
) => routeWarnings(
  schedule: schedule,
  openingHours: [for (final r in refs) r.$2.openingHours],
  visitMinutes: [
    for (final (s, l) in refs)
      effectiveVisitMinutes(s.visitMinutes, l.poiCategory),
  ],
  mode: route.travelMode,
  settings: settings,
  startMinutes: route.startMinutes,
  weekday: weekday,
);

/// Testo dell'avviso, senza il nome della tappa (sta sotto la tappa).
String warningText(AppLocalizations l10n, RouteWarning w) {
  String t(int? m) => Fmt.timeOfDayMinutes((m ?? 0) % (24 * 60));
  return switch (w.kind) {
    WarningKind.closedDay => l10n.warnClosedDay,
    WarningKind.opensLater => l10n.warnOpensLater(t(w.a), t(w.b)),
    WarningKind.closedEarlier =>
      w.a == null
          ? l10n.warnClosedAtArrival(t(w.b))
          : l10n.warnClosedEarlier(t(w.a), t(w.b)),
    WarningKind.closesDuringVisit => l10n.warnClosesDuringVisit(t(w.a)),
    WarningKind.lateEnd => l10n.warnLateEnd(t(w.a)),
    WarningKind.longDay => l10n.warnLongDay(
      formatDuration(l10n, (w.a ?? 0) * 60),
    ),
    WarningKind.farWalk => l10n.warnFarWalk(formatDistance(l10n, w.a ?? 0)),
    WarningKind.farBike => l10n.warnFarBike(formatDistance(l10n, w.a ?? 0)),
  };
}

/// Una riga di avviso (icona e testo nel colore "attenzione").
class RouteWarningRow extends StatelessWidget {
  const RouteWarningRow({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.warning;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: context.texts.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avvisi sulla giornata (non legati a una tappa).
class RouteWarningsCard extends StatelessWidget {
  const RouteWarningsCard({super.key, required this.warnings, this.onSplit});
  final List<RouteWarning> warnings;

  /// Se valorizzato e la giornata è lunga, propone "Dividi in 2 giorni".
  final VoidCallback? onSplit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ItineraCard(
      accentEdge: context.tokens.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.warnTitle, style: context.texts.titleSmall),
          const SizedBox(height: 6),
          for (final w in warnings) RouteWarningRow(text: warningText(l10n, w)),
          if (onSplit != null &&
              warnings.any((w) => w.kind == WarningKind.longDay)) ...[
            const SizedBox(height: 6),
            FilledButton.tonalIcon(
              onPressed: onSplit,
              icon: const Icon(Icons.call_split),
              label: Text(l10n.splitInTwo),
            ),
          ],
        ],
      ),
    );
  }
}

/// Durata di visita leggibile; 0 = "Solo partenza" (prima tappa) o "Solo
/// passaggio".
String visitLabel(AppLocalizations l10n, int minutes, {required bool first}) {
  if (minutes == 0) return first ? l10n.flowStartOnly : l10n.planPassOnly;
  return formatDuration(l10n, minutes * 60);
}

/// Tempo e distanza di un tratto, tra una tappa e la successiva.
class RouteLegRow extends StatelessWidget {
  const RouteLegRow({
    super.key,
    required this.leg,
    required this.mode,
    required this.estimate,
    this.label,
  });

  final RouteLeg leg;
  final RouteTravelMode mode;

  /// Tempi stimati senza rete: il valore diventa "circa …".
  final bool estimate;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = context.scheme.onSurfaceVariant;
    final seconds = leg.durationSeconds < 60 ? 60 : leg.durationSeconds;
    final value =
        '${formatDuration(l10n, seconds)} · '
        '${formatDistance(l10n, leg.distanceMeters)}';
    final text = [?label, estimate ? l10n.flowAbout(value) : value].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 8),
      child: Row(
        children: [
          Icon(Icons.south, size: 16, color: color),
          const SizedBox(width: 6),
          Icon(routeModeIcon(mode), size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: context.texts.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pin numerato di una tappa sulla mappa.
class RouteStopMarker extends StatelessWidget {
  const RouteStopMarker({super.key, required this.number, this.onTap});
  final int number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 4)],
        ),
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: TextStyle(
            color: tokens.onAccent,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Scaletta: orari di arrivo (con l'ora di partenza), tratti tra le tappe e
/// durata di visita. Con [onEditVisit] la durata è modificabile; senza
/// [schedule] (tempi da calcolare) mostra solo tappe e durate.
class RouteScheduleList extends StatelessWidget {
  const RouteScheduleList({
    super.key,
    required this.route,
    required this.refs,
    required this.schedule,
    required this.onTapStop,
    this.onEditVisit,
    this.warnings = const [],
  });

  final SightseeingRoute route;
  final List<(SightseeingRouteStop, Location)> refs;
  final RouteSchedule? schedule;

  /// Avvisi: quelli di una tappa compaiono sotto la tappa.
  final List<RouteWarning> warnings;
  final void Function(SightseeingRouteStop stop, Location loc) onTapStop;
  final void Function(SightseeingRouteStop stop, Location loc, bool first)?
  onEditVisit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    final start = route.startMinutes;
    final estimate = route.calcSource != DistanceSource.onlineRouting;
    final timings = schedule?.stops;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (stop, loc)) in refs.indexed) ...[
          if (timings?[i].legBefore case final leg?)
            RouteLegRow(leg: leg, mode: route.travelMode, estimate: estimate),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ItineraCard(
              onTap: () => onTapStop(stop, loc),
              padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
              child: Row(
                children: [
                  if (start != null && timings != null)
                    SizedBox(
                      width: 50,
                      child: Text(
                        Fmt.timeOfDayMinutes(
                          RouteSchedule.clock(start, timings[i].arriveSeconds) %
                              (24 * 60),
                        ),
                        style: TextStyle(
                          fontFamily: tokens.monoFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: tokens.accentSoft,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: tokens.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.titleSmall,
                        ),
                        if (loc.latitude == null || loc.longitude == null)
                          Text(
                            l10n.placeNoCoords,
                            style: context.texts.bodySmall?.copyWith(
                              color: context.scheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _visit(context, l10n, stop, loc, i == 0, muted),
                ],
              ),
            ),
          ),
          for (final w in warnings.where((w) => w.stopIndex == i))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 4),
              child: RouteWarningRow(text: warningText(l10n, w)),
            ),
        ],
        if (schedule?.returnLeg case final back? when refs.isNotEmpty)
          RouteLegRow(
            leg: back,
            mode: route.travelMode,
            estimate: estimate,
            label: l10n.flowLegBack(refs.first.$2.label),
          ),
      ],
    );
  }

  Widget _visit(
    BuildContext context,
    AppLocalizations l10n,
    SightseeingRouteStop stop,
    Location loc,
    bool first,
    TextStyle? muted,
  ) {
    final label = visitLabel(
      l10n,
      effectiveVisitMinutes(stop.visitMinutes, loc.poiCategory),
      first: first,
    );
    final edit = onEditVisit;
    if (edit == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label, style: muted),
      );
    }
    return TextButton(
      onPressed: () => edit(stop, loc, first),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const Icon(Icons.expand_more, size: 18)],
      ),
    );
  }
}

/// Riga finale: fine prevista (o durata totale senza orario) e ripartizione
/// tra spostamenti e visite.
class RouteScheduleFooter extends StatelessWidget {
  const RouteScheduleFooter({
    super.key,
    required this.route,
    required this.schedule,
  });

  final SightseeingRoute route;
  final RouteSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = route.startMinutes;
    final title = start == null
        ? l10n.planTotal(formatDuration(l10n, schedule.endSeconds))
        : l10n.planEndAt(
            Fmt.timeOfDayMinutes(
              RouteSchedule.clock(start, schedule.endSeconds) % (24 * 60),
            ),
          );
    final source = route.calcSource == DistanceSource.onlineRouting
        ? l10n.routeSourceOnline
        : l10n.routeSourceEstimate;
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    return ItineraCard(
      child: Row(
        children: [
          Icon(Icons.sports_score, color: context.tokens.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.titleMedium),
                Text(
                  l10n.planBreakdown(
                    formatDistance(l10n, schedule.distanceMeters),
                    formatDuration(l10n, schedule.travelSeconds),
                    formatDuration(l10n, schedule.visitSeconds),
                  ),
                  style: context.texts.bodySmall,
                ),
                Text(source, style: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
