import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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

String _capitalized(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Sabato 24 ottobre".
String routeDayLong(DateTime d) =>
    _capitalized(DateFormat('EEEE d MMMM', Fmt.locale).format(d));

/// "Sab 24 ott".
String routeDayShort(DateTime d) => _capitalized(Fmt.dateShort(d));

/// Come si dice il mezzo dopo una durata: "8 min a piedi".
String routeModePhrase(RouteTravelMode m) => switch (m) {
  RouteTravelMode.walk => 'a piedi',
  RouteTravelMode.bike => 'in bici',
  RouteTravelMode.car => 'in auto',
};

/// Tessera tonda del mezzo di un percorso.
class RouteModeTile extends StatelessWidget {
  const RouteModeTile(this.mode, {super.key, this.size = 44});

  final RouteTravelMode mode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconTile(
      routeModeIcon(mode),
      round: true,
      size: size,
      color: switch (mode) {
        RouteTravelMode.walk => Cartolina.corallo,
        RouteTravelMode.bike => Cartolina.sole,
        RouteTravelMode.car => Cartolina.laguna,
      },
    );
  }
}

/// Tessera tonda della categoria di un luogo.
class PoiTile extends StatelessWidget {
  const PoiTile(this.category, {super.key, this.size = 44});

  final PoiCategory? category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color, onColor) = switch (category) {
      PoiCategory.monument => (
        Icons.castle,
        Cartolina.sole,
        Cartolina.inchiostro,
      ),
      PoiCategory.museum => (
        Icons.account_balance,
        Cartolina.laguna,
        Cartolina.inchiostro,
      ),
      PoiCategory.nature => (
        Icons.park,
        Cartolina.laguna,
        Cartolina.inchiostro,
      ),
      PoiCategory.viewpoint => (
        Icons.landscape,
        Cartolina.corallo,
        Cartolina.inchiostro,
      ),
      PoiCategory.religious => (
        Icons.church,
        Cartolina.sole,
        Cartolina.inchiostro,
      ),
      PoiCategory.attraction => (
        Icons.attractions,
        Cartolina.corallo,
        Cartolina.inchiostro,
      ),
      _ => (Icons.place, Cartolina.cobalto, Colors.white),
    };
    return IconTile(
      icon,
      round: true,
      size: size,
      color: color,
      iconColor: onColor,
    );
  }
}

/// Numero della tappa nelle righe degli elenchi: cobalto in chiaro e in scuro,
/// come gli spilli sulla mappa.
class StopNumber extends StatelessWidget {
  const StopNumber(this.number, {super.key, this.size = 28});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Cartolina.cobalto,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontFamily: context.tokens.displayFont,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.46,
        ),
      ),
    );
  }
}

/// Attesa del percorso: niente rotelline a tutta pagina.
class RouteLoadingView extends StatelessWidget {
  const RouteLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModuleHeader(
            style: ModuleStyle.luoghi,
            title: AppLocalizations.of(context).exploreTitle,
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.route,
              color: Cartolina.corallo,
              iconColor: Cartolina.inchiostro,
              title: 'Calcolo le strade…',
              action: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: Motion.off(context) ? 0.5 : null,
                  minHeight: 8,
                  color: Cartolina.corallo,
                  backgroundColor: context.tokens.hairline,
                ),
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
      color: Cartolina.sole.withValues(alpha: 0.2),
      borderColor: Cartolina.sole,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 22,
                color: context.tokens.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.warnTitle, style: context.texts.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final w in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                warningText(l10n, w),
                style: context.texts.bodyMedium,
              ),
            ),
          if (onSplit != null &&
              warnings.any((w) => w.kind == WarningKind.longDay)) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onSplit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                minimumSize: const Size(0, 40),
              ),
              child: Text(l10n.splitInTwo),
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
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: Row(
        children: [
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

/// Spillo numerato di una tappa sulla mappa. Il cerchio è più piccolo
/// dell'area che riceve il tocco.
class RouteStopMarker extends StatelessWidget {
  const RouteStopMarker({super.key, required this.number, this.onTap});
  final int number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Cartolina.cobalto,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 4),
            ],
          ),
          child: Text(
            '$number',
            style: TextStyle(
              fontFamily: context.tokens.displayFont,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Spillo che cade dall'alto la prima volta che compare. [seen] ricorda quelli
/// già visti: la mappa toglie gli spilli fuori schermo e li ricrea, e quando
/// rientrano non devono ricadere. La chiave del widget va legata a [id].
class PinDrop extends StatefulWidget {
  const PinDrop({
    super.key,
    required this.id,
    required this.seen,
    required this.child,
    this.index = 0,
  });

  final String id;
  final Set<String> seen;
  final Widget child;

  /// Posizione nella cascata, se ne cadono più insieme.
  final int index;

  @override
  State<PinDrop> createState() => _PinDropState();
}

class _PinDropState extends State<PinDrop> with SingleTickerProviderStateMixin {
  static const _height = 44.0;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.standard,
  );
  Timer? _delay;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.seen.add(widget.id) || Motion.off(context)) {
      _c.value = 1;
      return;
    }
    final steps = math.min(widget.index, Motion.staggerMax);
    _delay = Timer(Motion.stagger * steps, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value;
        if (v >= 1) return child!;
        return Opacity(
          opacity: math.min(v * 3, 1),
          child: Transform.translate(
            offset: Offset(0, -_height * (1 - Motion.pop.transform(v))),
            child: child,
          ),
        );
      },
    );
  }
}

/// Tracciato del percorso: si disegna per lunghezza quando entra o cambia.
/// Ridisegna solo questo strato (mai le tile) e non rifà il calcolo delle
/// strade. Se la nuova linea inizia come la vecchia, si traccia solo il pezzo
/// nuovo. Un tocco sulla mappa lo completa subito ([RouteLineState.finish]).
class RouteLine extends StatefulWidget {
  const RouteLine({super.key, required this.points, required this.color});

  final List<LatLng> points;
  final Color color;

  @override
  State<RouteLine> createState() => RouteLineState();
}

class RouteLineState extends State<RouteLine> {
  static const _draw = Duration(milliseconds: 700);

  /// Lunghezza percorsa fino a ogni punto, in gradi (basta il rapporto).
  late List<double> _lengths = _measure(widget.points);
  double _from = 0;
  var _run = 0;
  var _done = false;

  /// Porta subito il tracciato alla fine.
  void finish() {
    if (!_done && mounted) setState(() => _done = true);
  }

  @override
  void didUpdateWidget(RouteLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.points;
    if (listEquals(before, widget.points)) return;
    final n = math.min(before.length, widget.points.length);
    var same = 0;
    while (same < n && before[same] == widget.points[same]) {
      same++;
    }
    _lengths = _measure(widget.points);
    final total = _lengths.last;
    _from = same == 0 || total <= 0 ? 0 : _lengths[same - 1] / total;
    _run++;
    _done = false;
  }

  static List<double> _measure(List<LatLng> points) {
    final out = List<double>.filled(points.length, 0);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final cos = math.cos(a.latitude * math.pi / 180);
      final dx = (b.longitude - a.longitude) * cos;
      final dy = b.latitude - a.latitude;
      out[i] = out[i - 1] + math.sqrt(dx * dx + dy * dy);
    }
    return out;
  }

  /// I punti fino alla frazione [t] della lunghezza, con l'ultimo interpolato.
  List<LatLng> _cut(double t) {
    final points = widget.points;
    if (t >= 1 || _lengths.last <= 0) return points;
    final target = _lengths.last * t;
    var lo = 1;
    var hi = points.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_lengths[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final a = points[lo - 1];
    final b = points[lo];
    final span = _lengths[lo] - _lengths[lo - 1];
    final f = span <= 0 ? 0.0 : (target - _lengths[lo - 1]) / span;
    return [
      ...points.sublist(0, lo),
      LatLng(
        a.latitude + (b.latitude - a.latitude) * f,
        a.longitude + (b.longitude - a.longitude) * f,
      ),
    ];
  }

  Widget _layer(List<LatLng> points) => PolylineLayer(
    polylines: [Polyline(points: points, strokeWidth: 5, color: widget.color)],
  );

  @override
  Widget build(BuildContext context) {
    if (_done || Motion.off(context) || _from >= 1) {
      return _layer(widget.points);
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey(_run),
      tween: Tween(begin: _from, end: 1),
      duration: _draw,
      curve: Curves.easeInOut,
      onEnd: () => _done = true,
      builder: (context, t, _) => _layer(_cut(t)),
    );
  }
}

/// Scaletta: orari di arrivo (con l'ora di partenza) e durata di visita, con
/// gli avvisi della tappa dentro la sua riga. Con [onEditVisit] la durata è
/// modificabile; senza [schedule] (tempi da calcolare) mostra solo tappe e
/// durate; senza ora di partenza mostra i tratti tra le tappe, che altrimenti
/// si leggono dagli orari.
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

  /// Avvisi: quelli di una tappa compaiono dentro la riga della tappa.
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
        for (final (i, (stop, loc)) in refs.indexed)
          StaggerIn(
            key: ValueKey(stop.id),
            index: i,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (timings?[i].legBefore case final leg? when start == null)
                  RouteLegRow(
                    leg: leg,
                    mode: route.travelMode,
                    estimate: estimate,
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ItineraCard(
                    onTap: () => onTapStop(stop, loc),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Row(
                      children: [
                        if (start != null && timings != null)
                          SizedBox(
                            width: 54,
                            child: Text(
                              Fmt.timeOfDayMinutes(
                                RouteSchedule.clock(
                                      start,
                                      timings[i].arriveSeconds,
                                    ) %
                                    (24 * 60),
                              ),
                              style: TextStyle(
                                fontFamily: tokens.labelFont,
                                color: tokens.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        StopNumber(i + 1),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.texts.titleMedium,
                              ),
                              if (loc.latitude == null || loc.longitude == null)
                                Text(
                                  l10n.placeNoCoords,
                                  style: context.texts.bodySmall?.copyWith(
                                    color: context.scheme.error,
                                  ),
                                ),
                              _visit(context, l10n, stop, loc, i == 0, muted),
                              for (final w in warnings.where(
                                (w) => w.stopIndex == i,
                              ))
                                Text(
                                  warningText(l10n, w),
                                  style: context.texts.bodySmall?.copyWith(
                                    color: tokens.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    if (edit == null) return Text(label, style: muted);
    return TextButton(
      onPressed: () => edit(stop, loc, first),
      style: TextButton.styleFrom(
        foregroundColor: context.scheme.onSurfaceVariant,
        padding: const EdgeInsets.only(right: 8),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: muted,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const Icon(Icons.expand_more, size: 16)],
      ),
    );
  }
}

/// Riga finale: fine prevista (o durata totale senza orario) e ripartizione
/// tra spostamenti e visite. La fonte dei tempi si dice solo se sono stimati.
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
    final muted = context.texts.bodySmall?.copyWith(
      color: context.scheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.texts.titleMedium),
        const SizedBox(height: 2),
        Text(
          l10n.planBreakdown(
            formatDistance(l10n, schedule.distanceMeters),
            formatDuration(l10n, schedule.travelSeconds),
            formatDuration(l10n, schedule.visitSeconds),
          ),
          style: muted,
        ),
        if (route.calcSource != DistanceSource.onlineRouting)
          Text(l10n.routeSourceEstimate, style: muted),
      ],
    );
  }
}
