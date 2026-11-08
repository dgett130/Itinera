import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/enums.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../itinerary/activity_sheet.dart';
import '../itinerary/itinerary_providers.dart';
import '../itinerary/today_plan.dart';
import '../weather/weather_providers.dart';

/// Tempi della scheda (FigCraft, pagina K, fila 10).
const _tick = Duration(milliseconds: 240);
const _check = Duration(milliseconds: 280);
const _swap = Duration(milliseconds: 360);
const _side = Duration(milliseconds: 300);
const _digits = Duration(milliseconds: 200);

final _day = DateFormat('EEE d MMMM', Fmt.locale);

/// La scheda "Oggi" sotto il poster del viaggio in corso (FigCraft, pagina P):
/// la giornata dell'itinerario con "adesso" all'ora della destinazione, la
/// prossima attivita' e quanto manca, Spesa e Tabella di marcia. Fuori dalle
/// date del viaggio non c'e'.
class TodayCard extends ConsumerStatefulWidget {
  const TodayCard({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends ConsumerState<TodayCard> {
  // Riaprendo la Home la scheda torna sempre su Oggi.
  var _tomorrow = false;
  var _showDay = false;

  Trip get trip => widget.trip;

  @override
  Widget build(BuildContext context) {
    final start = trip.startDate;
    final local = ref.watch(tripLocalNowProvider(trip.id));
    if (start == null || !TodayPlan.within(start, trip.endDate, local)) {
      return const SizedBox.shrink();
    }
    final end = trip.endDate ?? start;
    final days = ref.watch(itineraryDaysProvider(trip.id)).value ?? const [];
    final acts = ref.watch(activitiesProvider(trip.id)).value ?? const [];
    final locs = ref.watch(locationsProvider(trip.id)).value ?? const [];
    // Tenuto vivo per il foglio "+ Attività".
    ref.watch(activityCategoriesProvider);
    final date = DateTime(local.year, local.month, local.day);
    TodayPlan planOn(DateTime d, {int? now}) => TodayPlan.of(
      tripStart: start,
      tripEnd: end,
      date: d,
      days: days,
      activities: acts,
      locations: locs,
      nowMinutes: now,
    );
    final today = planOn(date, now: local.hour * 60 + local.minute);
    final next = today.isLast
        ? null
        : planOn(DateTime(date.year, date.month, date.day + 1));
    final tomorrow = _tomorrow && next != null;
    final plan = tomorrow ? next : today;
    final t = context.tokens;
    final scheme = context.scheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.hairline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              plan: plan,
              tomorrow: tomorrow,
              onTab: next == null
                  ? null
                  : (v) {
                      if (v == _tomorrow) return;
                      unawaited(HapticFeedback.selectionClick());
                      setState(() => _tomorrow = v);
                    },
            ),
            const SizedBox(height: 14),
            ClipRect(
              child: AnimatedSize(
                duration: Motion.of(context, _swap),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: Motion.of(context, _side),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: _topStack,
                  transitionBuilder: (child, anim) {
                    // Domani entra da destra, Oggi da sinistra.
                    final incoming = child.key == ValueKey(tomorrow);
                    final dir = tomorrow ? 1.0 : -1.0;
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: Offset((incoming ? dir : -dir) * 0.3, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(tomorrow),
                    child: _body(
                      context,
                      plan,
                      today: !tomorrow,
                      next: next,
                      local: local,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    TodayPlan plan, {
    required bool today,
    required DateTime local,
    TodayPlan? next,
  }) {
    final muted = context.scheme.onSurfaceVariant;
    final over = today && plan.focus == FocusKind.over;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FocusSwitcher(
          child: _focus(context, plan, today: today, next: next),
        ),
        if (over) ...[
          const SizedBox(height: 14),
          _DoneRow(
            plan: plan,
            open: _showDay,
            onTap: () => setState(() => _showDay = !_showDay),
          ),
        ],
        if (plan.steps.isNotEmpty && (!over || _showDay)) ...[
          const SizedBox(height: 14),
          _DayList(
            plan: plan,
            now: today && !over ? local : null,
            onToggle: _toggle,
          ),
        ],
        if (plan.freeCount > 0) ...[
          const SizedBox(height: 10),
          Text(
            "Tocca il cerchio per segnare fatta un'attività.",
            style: context.texts.bodySmall?.copyWith(
              fontSize: 13,
              color: muted,
            ),
          ),
        ],
        if (plan.isEmpty && today && next != null) ...[
          const SizedBox(height: 14),
          _TomorrowRow(next: next),
        ],
        const SizedBox(height: 14),
        _Actions(
          trip: trip,
          onAdd: plan.isEmpty ? () => _add(plan.date) : null,
        ),
      ],
    );
  }

  Widget _focus(
    BuildContext context,
    TodayPlan plan, {
    required bool today,
    TodayPlan? next,
  }) {
    final s = plan.focusStep;
    final key = ValueKey('${plan.focus.name}/${s?.activity.id}');
    switch (plan.focus) {
      case FocusKind.free:
        return _Block(
          key: key,
          color: Cartolina.sole,
          title: 'Giornata libera',
          sub: 'Nessuna attività in programma.',
        );
      case FocusKind.next:
        return _Block(
          key: key,
          color: Cartolina.sole,
          kicker: 'PROSSIMA · ${inMinutes(plan.minutes!).toUpperCase()}',
          title: s!.activity.title,
          sub: [Fmt.timeOfDayMinutes(s.start), ?_place(s)].join(' · '),
          location: s.location,
        );
      case FocusKind.running:
        final after = plan.after;
        return _Block(
          key: key,
          color: Cartolina.sole,
          kicker:
              'IN CORSO · FINISCE ${inMinutes(plan.minutes!).toUpperCase()}',
          title: s!.activity.title,
          sub: [
            'fino alle ${Fmt.timeOfDayMinutes(s.end)}',
            if (after != null)
              'poi ${after.activity.title} alle '
                  '${Fmt.timeOfDayMinutes(after.start)}',
          ].join(' · '),
          progress: plan.progress,
        );
      case FocusKind.todo:
        final n = plan.freeCount;
        return _Block(
          key: key,
          color: Cartolina.sole,
          kicker: 'DA FARE',
          title: s!.activity.title,
          sub: [
            ?_place(s),
            n == 1 ? "l'ultima da fare" : '$n attività ancora',
          ].join(' · '),
          location: s.location,
        );
      case FocusKind.first:
        final n = plan.steps.length;
        return _Block(
          key: key,
          color: Cartolina.laguna,
          kicker: s!.timed
              ? 'LA PRIMA · ALLE ${Fmt.timeOfDayMinutes(s.start)}'
              : 'LA PRIMA',
          title: s.activity.title,
          sub: [
            ?_place(s),
            n == 1 ? "l'unica" : '$n attività in tutto',
          ].join(' · '),
          location: s.location,
        );
      case FocusKind.over:
        if (next == null) {
          return _Block(
            key: key,
            color: Cartolina.laguna,
            kicker: 'FINE DEL VIAGGIO',
            title: 'Giornata finita',
            sub: "Era l'ultimo giorno. Buon rientro.",
          );
        }
        final f = next.focusStep;
        final last = next.isLast ? ' · ultimo giorno' : '';
        return _Block(
          key: key,
          color: Cartolina.laguna,
          kicker: 'DOMANI · ${_day.format(next.date).toUpperCase()}',
          title: f == null
              ? 'Giornata libera'
              : f.timed
              ? '${f.activity.title} alle ${Fmt.timeOfDayMinutes(f.start)}'
              : f.activity.title,
          sub: f == null
              ? 'Nessuna attività in programma$last'
              : '${_count(next.steps.length)}$last',
        );
    }
  }

  Future<void> _toggle(Activity a) async {
    unawaited(HapticFeedback.lightImpact());
    await ref
        .read(itineraryRepositoryProvider)
        .setStatus(
          a.id,
          a.status == ActivityStatus.done
              ? ActivityStatus.planned
              : ActivityStatus.done,
        );
  }

  Future<void> _add(DateTime date) async {
    final repo = ref.read(itineraryRepositoryProvider);
    await repo.ensureDays(trip.id);
    final days = await repo.getDays(trip.id);
    ItineraryDay? day;
    for (final d in days) {
      final x = d.date;
      if (x != null &&
          x.year == date.year &&
          x.month == date.month &&
          x.day == date.day) {
        day = d;
      }
    }
    if (day == null || !mounted) return;
    await showActivitySheet(
      context,
      tripId: trip.id,
      dayId: day.id,
      days: days,
      categories: ref.read(activityCategoriesProvider).value ?? const [],
    );
  }
}

String? _place(TodayStep s) {
  final l = s.location?.label.trim();
  return l == null || l.isEmpty ? null : l;
}

String _count(int n) => n == 1 ? '1 attività' : '$n attività';

Widget _topStack(Widget? current, List<Widget> previous) =>
    Stack(alignment: Alignment.topCenter, children: [...previous, ?current]);

/// Titolo, data e il selettore Oggi | Domani.
class _Header extends StatelessWidget {
  const _Header({
    required this.plan,
    required this.tomorrow,
    required this.onTab,
  });

  final TodayPlan plan;
  final bool tomorrow;

  /// Null l'ultimo giorno: domani il viaggio e' finito.
  final ValueChanged<bool>? onTab;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = context.scheme;
    final which = plan.totalDays == 1
        ? null
        : plan.isLast
        ? 'ultimo giorno'
        : 'giorno ${plan.dayNumber} di ${plan.totalDays}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tomorrow ? 'Domani' : 'Oggi',
                style: TextStyle(
                  fontFamily: t.displayFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  height: 1.15,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                [_day.format(plan.date), ?which].join(' · '),
                style: context.texts.bodySmall?.copyWith(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (onTab != null) _Segmented(tomorrow: tomorrow, onTab: onTab!),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.tomorrow, required this.onTab});

  final bool tomorrow;
  final ValueChanged<bool> onTab;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cta = dark ? Cartolina.sole : Cartolina.inchiostro;
    final onCta = dark ? Cartolina.inchiostro : Colors.white;
    Widget cell(String label, bool value) {
      final on = tomorrow == value;
      return Semantics(
        selected: on,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTab(value),
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.fast),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: on ? cta : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: t.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: on ? onCta : context.scheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [cell('Oggi', false), cell('Domani', true)],
      ),
    );
  }
}

/// Il riquadro che cambia: il vecchio esce in alto, il nuovo entra dal basso;
/// giallo e laguna si passano il posto in dissolvenza.
class _FocusSwitcher extends StatelessWidget {
  const _FocusSwitcher({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.of(context, _swap),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: _topStack,
      transitionBuilder: (c, anim) {
        final incoming = c.key == child.key;
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: Offset(0, incoming ? 0.35 : -0.35),
              end: Offset.zero,
            ).animate(anim),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

/// Il riquadro colorato: la prossima, quella in corso o domani.
class _Block extends StatelessWidget {
  const _Block({
    super.key,
    required this.color,
    required this.title,
    required this.sub,
    this.kicker,
    this.progress,
    this.location,
  });

  final Color color;
  final String? kicker;
  final String title;
  final String sub;
  final double? progress;

  /// Con un luogo compare "Vai" (indicazioni in Google Maps).
  final Location? location;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final body = context.texts.bodyMedium!;
    const ink = Cartolina.inchiostro;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kicker != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: _Rolling(
                      kicker!,
                      style: body.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: t.displayFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    height: 24 / 21,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: ink,
                  ),
                ),
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: Motion.of(context, _tick),
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 6,
                          color: ink,
                          backgroundColor: ink.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (location != null) ...[
            const SizedBox(width: 12),
            _Go(location: location!, color: color),
          ],
        ],
      ),
    );
  }
}

/// La riga che cambia ogni minuto: il nuovo testo sale da sotto.
class _Rolling extends StatelessWidget {
  const _Rolling(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: Motion.of(context, _digits),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, anim) {
          final incoming = child.key == ValueKey(text);
          return SlideTransition(
            position: Tween(
              begin: Offset(0, incoming ? 1 : -1),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          );
        },
        child: Text(
          text,
          key: ValueKey(text),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }
}

/// "Vai": le indicazioni verso il luogo in Google Maps.
class _Go extends StatelessWidget {
  const _Go({required this.location, required this.color});

  final Location location;
  final Color color;

  Future<void> _open() async {
    final l = location;
    final to = l.latitude != null && l.longitude != null
        ? '${l.latitude},${l.longitude}'
        : Uri.encodeComponent(
            (l.address?.trim().isNotEmpty ?? false) ? l.address! : l.label,
          );
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$to',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Cartolina.inchiostro,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _open,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                Icons.navigation,
                size: 22,
                color: color,
                semanticLabel: 'Indicazioni',
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Vai',
          style: context.texts.bodySmall?.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Cartolina.inchiostro,
          ),
        ),
      ],
    );
  }
}

/// Le righe della giornata sul binario, con "adesso" in mezzo.
class _DayList extends StatelessWidget {
  const _DayList({
    required this.plan,
    required this.now,
    required this.onToggle,
  });

  final TodayPlan plan;

  /// L'ora della destinazione; null per domani (niente "adesso").
  final DateTime? now;
  final ValueChanged<Activity> onToggle;

  @override
  Widget build(BuildContext context) {
    final steps = plan.steps;
    final at = now == null ? null : plan.nowAfter;
    final timeCol = plan.anyTimed;
    final line = at == null
        ? null
        : _NowLine(
            time: Fmt.timeOfDayMinutes(now!.hour * 60 + now!.minute),
            fraction: plan.nowFraction,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (at == -1) ?line,
        for (final (k, s) in steps.indexed) ...[
          _StepRow(
            step: s,
            last: k == steps.length - 1,
            timeCol: timeCol,
            onToggle: s.timed ? null : () => onToggle(s.activity),
          ),
          if (at == k) ?line,
        ],
      ],
    );
  }
}

/// "Adesso": la pillola con l'ora e la riga corallo. Scende piano tra la fine
/// di un'attivita' e l'inizio della successiva.
class _NowLine extends StatelessWidget {
  const _NowLine({required this.time, required this.fraction});

  final String time;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    const room = 12.0;
    return AnimatedPadding(
      duration: Motion.of(context, _tick),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        top: 2 + room * fraction,
        bottom: 8 + room * (1 - fraction),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            decoration: BoxDecoration(
              color: Cartolina.corallo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontFamily: context.tokens.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: Cartolina.inchiostro,
              ),
            ),
          ),
          Expanded(child: Container(height: 2, color: Cartolina.corallo)),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.last,
    required this.timeCol,
    this.onToggle,
  });

  final TodayStep step;
  final bool last;
  final bool timeCol;

  /// Solo le attivita' senza orario si spuntano a mano.
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = context.scheme;
    final body = context.texts.bodyMedium!;
    final done = step.state == StepMark.done;
    final a = step.activity;
    final place = _place(step);
    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (timeCol) ...[
            SizedBox(
              width: 46,
              child: step.timed
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Fmt.timeOfDayMinutes(step.start),
                          style: TextStyle(
                            fontFamily: t.displayFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: done
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface,
                          ),
                        ),
                        if (a.endMinutes != null)
                          Text(
                            Fmt.timeOfDayMinutes(a.endMinutes),
                            style: body.copyWith(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 22,
            child: Column(
              children: [
                _Dot(state: step.state),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 2),
                      color: t.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: Motion.of(context, _tick),
                    style: body.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: done ? scheme.onSurfaceVariant : scheme.onSurface,
                    ),
                    child: Text(
                      a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (place != null)
                    Text(
                      place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: body.copyWith(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (onToggle == null) return row;
    // Si tocca il cerchio, ma basta toccare la riga.
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Fatta' : 'Segna fatta',
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: row,
      ),
    );
  }
}

/// Il pallino sul binario: spunta, in corso, da fare. Diventa la spunta con
/// uno scatto.
class _Dot extends StatelessWidget {
  const _Dot({required this.state});

  final StepMark state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scheme = context.scheme;
    final Widget dot = switch (state) {
      StepMark.done => Container(
        decoration: BoxDecoration(color: t.positive, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 15, color: Colors.white),
      ),
      StepMark.now => Container(
        decoration: const BoxDecoration(
          color: Cartolina.corallo,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
      StepMark.todo || StepMark.free => Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: state == StepMark.free
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    };
    final shown = SizedBox(
      width: 22,
      height: 22,
      child: AnimatedSwitcher(
        duration: Motion.of(context, _check),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Motion.pop),
          child: child,
        ),
        child: KeyedSubtree(key: ValueKey(state), child: dot),
      ),
    );
    return shown;
  }
}

/// Fine giornata: le attivita' di oggi in una riga.
class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.plan, required this.open, required this.onTap});

  final TodayPlan plan;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final n = plan.steps.length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          const _Dot(state: StepMark.done),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              n == 1
                  ? 'Oggi 1 attività su 1'
                  : 'Oggi ${plan.doneCount} attività su $n',
              style: context.texts.bodyMedium?.copyWith(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              open ? 'nascondi' : 'mostra',
              style: TextStyle(
                fontFamily: t.displayFont,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: t.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Giornata libera: uno sguardo a domani.
class _TomorrowRow extends StatelessWidget {
  const _TomorrowRow({required this.next});

  final TodayPlan next;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final body = context.texts.bodyMedium!;
    final f = next.focusStep;
    final what = f == null
        ? 'giornata libera'
        : [
            if (f.timed)
              '${Fmt.timeOfDayMinutes(f.start)} ${f.activity.title}'
            else
              f.activity.title,
            _count(next.steps.length),
          ].join(' · ');
    return Row(
      children: [
        Text(
          'Domani',
          style: body.copyWith(fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            what,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: body.copyWith(fontSize: 14, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// Spesa e Tabella di marcia; nella giornata libera "+ Attività" e Spesa.
class _Actions extends StatelessWidget {
  const _Actions({required this.trip, this.onAdd});

  final Trip trip;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final on = context.scheme.onSurface;
    final spesa = _Pill(
      icon: Icons.add,
      label: 'Spesa',
      color: Cartolina.sole,
      ink: Cartolina.inchiostro,
      onTap: () => context.push('/trip/${trip.id}/expense'),
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: onAdd != null
          ? [
              _Pill(
                icon: Icons.add,
                label: 'Attività',
                color: dark ? Cartolina.sole : Cartolina.inchiostro,
                ink: dark ? Cartolina.inchiostro : Colors.white,
                iconColor: dark ? Cartolina.inchiostro : Cartolina.sole,
                onTap: onAdd!,
              ),
              spesa,
            ]
          : [
              spesa,
              _Pill(
                icon: Icons.calendar_month_outlined,
                label: 'Tabella di marcia',
                color: Colors.transparent,
                ink: on,
                border: on,
                onTap: () => context.push('/trip/${trip.id}/itinerary'),
              ),
            ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.ink,
    required this.onTap,
    this.iconColor,
    this.border,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color ink;
  final Color? iconColor;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: StadiumBorder(
        side: border == null
            ? BorderSide.none
            : BorderSide(color: border!, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor ?? ink),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: context.tokens.displayFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
