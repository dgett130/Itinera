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
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../explore/explore_providers.dart';
import 'activity_sheet.dart';
import 'itinerary_domain.dart';
import 'itinerary_providers.dart';

/// Modulo Itinerario: i giorni del viaggio in un'unica lista. La striscia in
/// testata porta al giorno scelto e segue lo scorrimento.
class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  final _strip = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};
  String? _selectedDayId;

  /// Vero mentre la lista scorre da sola verso il giorno toccato.
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    // Genera i giorni per l'intervallo del viaggio (idempotente).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itineraryRepositoryProvider).ensureDays(widget.tripId);
    });
  }

  @override
  void dispose() {
    _strip.dispose();
    super.dispose();
  }

  Future<void> _onDayTap(ItineraryDay day, int index) async {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _selectedDayId = day.id);
    _revealInStrip(index);
    final target = _sectionKeys[day.id]?.currentContext;
    if (target == null) return;
    _jumping = true;
    await Scrollable.ensureVisible(
      target,
      duration: Motion.of(context, Motion.standard),
      curve: Curves.easeOutCubic,
    );
    _jumping = false;
  }

  /// La selezione segue lo scorrimento: il giorno attivo e' il primo che
  /// occupa ancora la cima della lista.
  bool _onListScroll(ScrollUpdateNotification n, List<ItineraryDay> days) {
    if (_jumping || n.depth != 0) return false;
    final list = n.context?.findRenderObject();
    if (list is! RenderBox) return false;
    var index = days.length - 1;
    if (n.metrics.extentAfter > 1) {
      for (var i = 0; i < days.length; i++) {
        final box = _sectionKeys[days[i].id]?.currentContext
            ?.findRenderObject();
        if (box is! RenderBox) continue;
        final bottom = box
            .localToGlobal(Offset(0, box.size.height), ancestor: list)
            .dy;
        if (bottom > 40) {
          index = i;
          break;
        }
      }
    }
    if (days[index].id != _selectedDayId) {
      setState(() => _selectedDayId = days[index].id);
      _revealInStrip(index);
    }
    return false;
  }

  /// Tiene la tessera del giorno dentro la striscia.
  void _revealInStrip(int index) {
    if (!_strip.hasClients) return;
    final position = _strip.position;
    final target =
        (index * _DayStrip.step -
                (position.viewportDimension - _DayStrip.tileWidth) / 2)
            .clamp(0.0, position.maxScrollExtent);
    final duration = Motion.of(context, Motion.standard);
    if (duration == Duration.zero) {
      _strip.jumpTo(target);
    } else {
      _strip.animateTo(target, duration: duration, curve: Curves.easeOutCubic);
    }
  }

  Future<void> _setDates() async {
    await context.push('/trip/${widget.tripId}/edit');
    if (!mounted) return;
    await ref.read(itineraryRepositoryProvider).ensureDays(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(itineraryDaysProvider(widget.tripId)).value;
    final activities = ref.watch(activitiesProvider(widget.tripId)).value;
    final categories = ref.watch(activityCategoriesProvider).value;
    final locations = ref.watch(locationsProvider(widget.tripId)).value;

    if (days == null ||
        activities == null ||
        categories == null ||
        locations == null) {
      return const Scaffold(
        body: Column(
          children: [
            ModuleHeader(style: ModuleStyle.marcia, title: 'Tabella di marcia'),
            Expanded(child: _ItinerarySkeleton()),
          ],
        ),
      );
    }

    final actsByDay = <String, List<Activity>>{};
    for (final a in activities) {
      actsByDay.putIfAbsent(a.dayId, () => []).add(a);
    }
    final locById = {for (final l in locations) l.id: l};

    final visibleDays = days
        .where((d) => d.date != null || (actsByDay[d.id]?.isNotEmpty ?? false))
        .toList();

    final selected = visibleDays.indexWhere((d) => d.id == _selectedDayId);
    final selectedIndex = selected < 0 ? 0 : selected;
    if (selected < 0 && visibleDays.isNotEmpty) {
      _selectedDayId = visibleDays.first.id;
    }

    void addActivity({bool fromFab = false}) => showActivitySheet(
      context,
      tripId: widget.tripId,
      dayId: days.first.id,
      days: days,
      categories: categories,
      fromFab: fromFab,
    );

    // Righe numerate di seguito: solo le prime entrano in cascata.
    var stagger = 0;
    final sections = <Widget>[];
    for (final day in visibleDays) {
      final dayActivities = actsByDay[day.id] ?? const <Activity>[];
      sections.add(
        KeyedSubtree(
          key: _sectionKeys.putIfAbsent(day.id, GlobalKey.new),
          child: _DaySection(
            tripId: widget.tripId,
            day: day,
            activities: dayActivities,
            allDays: days,
            categories: categories,
            locById: locById,
            staggerStart: stagger,
          ),
        ),
      );
      stagger += 1 + (dayActivities.isEmpty ? 1 : dayActivities.length);
    }

    return Scaffold(
      floatingActionButton: visibleDays.isEmpty
          ? null
          : CartolinaFab(
              label: 'Attività',
              onPressed: () => addActivity(fromFab: true),
            ),
      body: Column(
        children: [
          ModuleHeader(
            style: ModuleStyle.marcia,
            title: 'Tabella di marcia',
            child: visibleDays.isEmpty
                ? null
                : _DayStrip(
                    days: visibleDays,
                    selectedIndex: selectedIndex,
                    controller: _strip,
                    onTap: _onDayTap,
                  ),
          ),
          Expanded(
            child: visibleDays.isEmpty
                ? _EmptyItinerary(
                    onAdd: days.isEmpty ? null : addActivity,
                    onSetDates: _setDates,
                  )
                : NotificationListener<ScrollUpdateNotification>(
                    onNotification: (n) => _onListScroll(n, visibleDays),
                    // Non pigra: il tocco su un giorno deve trovare la sezione
                    // anche se e' fuori schermo.
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sections,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Striscia dei giorni: la selezione gialla scorre da una tessera all'altra.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.days,
    required this.selectedIndex,
    required this.controller,
    required this.onTap,
  });

  static const tileWidth = 46.0;
  static const tileHeight = 52.0;
  static const step = tileWidth + 6;

  final List<ItineraryDay> days;
  final int selectedIndex;
  final ScrollController controller;
  final void Function(ItineraryDay day, int index) onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return SizedBox(
      height: tileHeight,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: SizedBox(
          width: days.length * step - (step - tileWidth),
          height: tileHeight,
          child: Stack(
            children: [
              for (var i = 0; i < days.length; i++)
                Positioned(
                  left: i * step,
                  top: 0,
                  bottom: 0,
                  width: tileWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Cartolina.cobaltoScuro,
                      borderRadius: radius,
                    ),
                  ),
                ),
              AnimatedPositioned(
                duration: Motion.of(context, Motion.standard),
                curve: Curves.easeOutCubic,
                left: selectedIndex * step,
                top: 0,
                bottom: 0,
                width: tileWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Cartolina.sole,
                    borderRadius: radius,
                  ),
                ),
              ),
              for (var i = 0; i < days.length; i++)
                Positioned(
                  left: i * step,
                  top: 0,
                  bottom: 0,
                  width: tileWidth,
                  child: _DayTile(
                    day: days[i],
                    selected: i == selectedIndex,
                    onTap: () => onTap(days[i], i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final ItineraryDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final date = day.date;
    final color = selected ? Cartolina.inchiostro : Colors.white;
    final duration = Motion.of(context, Motion.fast);
    return Semantics(
      button: true,
      selected: selected,
      label: dayLabel(day),
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    style: TextStyle(
                      fontFamily: tokens.labelFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    // Il bucket senza data non ha giorno della settimana.
                    child: Text(
                      date != null
                          ? DateFormat('EEE', Fmt.locale).format(date)
                          : 'senza',
                    ),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    style: TextStyle(
                      fontFamily: tokens.displayFont,
                      fontSize: date != null ? 18 : 11,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    child: Text(date != null ? '${date.day}' : 'data'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DaySection extends ConsumerWidget {
  const _DaySection({
    required this.tripId,
    required this.day,
    required this.activities,
    required this.allDays,
    required this.categories,
    required this.locById,
    required this.staggerStart,
  });

  final String tripId;
  final ItineraryDay day;
  final List<Activity> activities;
  final List<ItineraryDay> allDays;
  final List<ActivityCategory> categories;
  final Map<String, Location> locById;
  final int staggerStart;

  void _add(BuildContext context) => showActivitySheet(
    context,
    tripId: tripId,
    dayId: day.id,
    days: allDays,
    categories: categories,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(itineraryRepositoryProvider);
    final tokens = context.tokens;
    final scheme = context.scheme;
    final ordered = [...activities]
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final conflicts = ItineraryDomain.conflictingIds(activities);
    final minutes = ItineraryDomain.plannedMinutes(activities);
    final cost = ItineraryDomain.dayCostCents(activities);
    final catById = {for (final c in categories) c.id: c};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggerIn(
          index: staggerStart,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel(day),
                        style: context.texts.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (activities.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _summary(minutes, cost, conflicts.length),
                          style: context.texts.bodySmall?.copyWith(
                            fontWeight: conflicts.isNotEmpty
                                ? FontWeight.w500
                                : null,
                            color: conflicts.isNotEmpty
                                ? tokens.warning
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (activities.length > 1)
                  IconButton(
                    tooltip: 'Ordina per orario',
                    icon: const Icon(Icons.sort),
                    onPressed: () => repo.reorderDay(
                      ItineraryDomain.sortForDisplay(
                        activities,
                      ).map((a) => a.id).toList(),
                    ),
                  ),
                if (activities.isNotEmpty)
                  IconButton.outlined(
                    tooltip: 'Aggiungi attività',
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      foregroundColor: scheme.onSurface,
                      side: BorderSide(color: scheme.onSurface, width: 1.5),
                    ),
                    onPressed: () => _add(context),
                  ),
              ],
            ),
          ),
        ),
        if (ordered.isEmpty)
          StaggerIn(
            index: staggerStart + 1,
            // Il giorno libero si riempie toccandolo.
            child: PosterTile(
              color: Cartolina.sole,
              title: 'Giornata libera',
              onTap: () => _add(context),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            // La copia trascinata non deve rifare l'ingresso in cascata.
            proxyDecorator: (child, index, animation) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Material(type: MaterialType.transparency, child: child),
            ),
            onReorder: (oldIndex, newIndex) {
              final ids = ordered.map((a) => a.id).toList();
              if (newIndex > oldIndex) newIndex -= 1;
              final id = ids.removeAt(oldIndex);
              ids.insert(newIndex, id);
              repo.reorderDay(ids);
            },
            children: [
              for (var i = 0; i < ordered.length; i++)
                _ActivityTile(
                  key: ValueKey(ordered[i].id),
                  index: i,
                  staggerIndex: staggerStart + 1 + i,
                  tripId: tripId,
                  activity: ordered[i],
                  category: catById[ordered[i].categoryId],
                  location: ordered[i].locationId == null
                      ? null
                      : locById[ordered[i].locationId],
                  isConflict: conflicts.contains(ordered[i].id),
                  allDays: allDays,
                  categories: categories,
                ),
            ],
          ),
      ],
    );
  }

  String _summary(int minutes, int cost, int conflicts) {
    final parts = <String>['${activities.length} attività'];
    if (minutes > 0) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      parts.add(h > 0 ? '${h}h ${m}m' : '${m}m');
    }
    if (cost > 0) parts.add(Fmt.currencyCents(cost));
    if (conflicts > 0) {
      parts.add(conflicts == 1 ? '1 conflitto' : '$conflicts conflitti');
    }
    return parts.join(' · ');
  }
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({
    required super.key,
    required this.index,
    required this.staggerIndex,
    required this.tripId,
    required this.activity,
    required this.category,
    required this.location,
    required this.isConflict,
    required this.allDays,
    required this.categories,
  });

  final int index;
  final int staggerIndex;
  final String tripId;
  final Activity activity;
  final ActivityCategory? category;
  final Location? location;
  final bool isConflict;
  final List<ItineraryDay> allDays;
  final List<ActivityCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final scheme = context.scheme;
    final done = activity.status == ActivityStatus.done;
    final skipped =
        activity.status == ActivityStatus.skipped ||
        activity.status == ActivityStatus.cancelled;
    final isRoute = activity.routeId != null;
    // Sul corallo tutti i testi sono inchiostro.
    final Color titleColor = isRoute
        ? Cartolina.inchiostro
        : skipped
        ? scheme.onSurfaceVariant
        : scheme.onSurface;
    final Color subtleColor = isRoute
        ? Cartolina.inchiostro
        : scheme.onSurfaceVariant;
    final Color warnColor = isRoute ? Cartolina.inchiostro : tokens.warning;
    final details = [?category?.name, ?location?.label].join(' · ');
    final borderColor = isConflict
        ? tokens.warning
        : isRoute
        ? Colors.transparent
        : null;

    return StaggerIn(
      index: staggerIndex,
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ItineraCard(
            color: isRoute ? Cartolina.corallo : null,
            borderColor: borderColor,
            // Un'attività-percorso apre il riepilogo del percorso (mappa e
            // scaletta); le altre il foglio di modifica dell'attività.
            onTap: isRoute
                ? () => context.push(
                    '/trip/$tripId/route/${activity.routeId}/summary',
                  )
                : () => showActivitySheet(
                    context,
                    tripId: tripId,
                    dayId: activity.dayId,
                    days: allDays,
                    categories: categories,
                    existing: activity,
                    existingLocation: location,
                  ),
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimeColumn(
                  activity: activity,
                  subtle: subtleColor,
                  ink: titleColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: context.texts.titleMedium?.copyWith(
                          color: titleColor,
                          decoration: (done || skipped)
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: titleColor,
                        ),
                      ),
                      if (isRoute) ...[
                        const SizedBox(height: 3),
                        Text(
                          [
                            l10n.routeStopsCount(
                              ref
                                      .watch(
                                        routeStopsProvider(activity.routeId!),
                                      )
                                      .value
                                      ?.length ??
                                  0,
                            ),
                            l10n.itineraryRouteOpen,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: subtleColor,
                          ),
                        ),
                      ],
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            color: subtleColor,
                          ),
                        ),
                      ],
                      if (isConflict) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Sovrapposta',
                          style: context.texts.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: warnColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (activity.costCents != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 1),
                    child: Text(
                      Fmt.currencyCents(activity.costCents!),
                      style: context.texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                if (done)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check,
                      size: 20,
                      color: isRoute ? Cartolina.inchiostro : tokens.positive,
                    ),
                  ),
                _ActivityMenu(
                  tripId: tripId,
                  activity: activity,
                  hasLocation: location != null,
                  color: subtleColor,
                  onOpenMap: location != null
                      ? () => _openInMaps(location!)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openInMaps(Location location) async {
    final Uri uri;
    if (location.latitude != null && location.longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query='
        '${location.latitude},${location.longitude}',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query='
        '${Uri.encodeComponent(location.label)}',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Colonna oraria a sinistra dell'attività.
class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.activity,
    required this.subtle,
    required this.ink,
  });
  final Activity activity;
  final Color subtle;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final hasTime = activity.startMinutes != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasTime ? Fmt.timeOfDayMinutes(activity.startMinutes) : '·',
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: hasTime ? ink : subtle,
            ),
          ),
          if (activity.endMinutes != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                Fmt.timeOfDayMinutes(activity.endMinutes),
                style: context.texts.bodySmall?.copyWith(color: subtle),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityMenu extends ConsumerWidget {
  const _ActivityMenu({
    required this.tripId,
    required this.activity,
    required this.hasLocation,
    required this.color,
    required this.onOpenMap,
  });

  final String tripId;
  final Activity activity;
  final bool hasLocation;
  final Color color;
  final VoidCallback? onOpenMap;

  PopupMenuItem<String> _item(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(itineraryRepositoryProvider);
    return SizedBox(
      width: 36,
      height: 36,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 20,
        iconColor: color,
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          switch (value) {
            case 'done':
              repo.setStatus(activity.id, ActivityStatus.done);
            case 'planned':
              repo.setStatus(activity.id, ActivityStatus.planned);
            case 'skipped':
              repo.setStatus(activity.id, ActivityStatus.skipped);
            case 'map':
              onOpenMap?.call();
          }
        },
        itemBuilder: (context) => [
          _item('done', Icons.check, 'Segna come fatta'),
          _item('planned', Icons.calendar_today_outlined, 'Pianificata'),
          _item('skipped', Icons.skip_next, 'Saltata'),
          if (hasLocation) _item('map', Icons.place, 'Apri in mappa'),
        ],
      ),
    );
  }
}

class _EmptyItinerary extends StatelessWidget {
  const _EmptyItinerary({this.onAdd, required this.onSetDates});
  final VoidCallback? onAdd;
  final VoidCallback onSetDates;

  @override
  Widget build(BuildContext context) {
    // Centrato, ma scorre se i testi non ci stanno.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: EmptyState(
            icon: Icons.calendar_today,
            color: Cartolina.cobalto,
            iconColor: Colors.white,
            title: 'Costruisci la tua tabella di marcia',
            message:
                'Imposta le date del viaggio per avere un giorno per ogni data, '
                'oppure aggiungi subito un\'attività.',
            action: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (onAdd != null) ...[
                  FilledButton(
                    onPressed: onAdd,
                    child: const Text('Aggiungi attività'),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  onPressed: onSetDates,
                  child: const Text('Imposta le date'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Segnaposto mentre arrivano i dati.
class _ItinerarySkeleton extends StatelessWidget {
  const _ItinerarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 120, height: 22),
          SizedBox(height: 8),
          Skeleton(width: 190, height: 12),
          SizedBox(height: 14),
          Skeleton(height: 66, radius: 20),
          SizedBox(height: 10),
          Skeleton(height: 66, radius: 20),
          SizedBox(height: 10),
          Skeleton(height: 66, radius: 20),
        ],
      ),
    );
  }
}
