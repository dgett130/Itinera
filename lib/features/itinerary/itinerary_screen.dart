import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';
import '../../core/enums.dart';
import '../../core/format.dart';
import '../../core/icon_keys.dart';
import '../../data/database.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../trip/trip_providers.dart';
import 'activity_sheet.dart';
import 'itinerary_domain.dart';
import 'itinerary_providers.dart';

/// Modulo Itinerario: timeline giorno per giorno con attivita'.
class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  void initState() {
    super.initState();
    // Genera i giorni per l'intervallo del viaggio (idempotente).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itineraryRepositoryProvider).ensureDays(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.tripId)).value;
    final style =
        trip == null ? TripStyle.atlante : ItineraTheme.effectiveStyle(trip);
    return TripThemeScope(style: style, child: _buildBody());
  }

  Widget _buildBody() {
    final days = ref.watch(itineraryDaysProvider(widget.tripId)).value;
    final activities = ref.watch(activitiesProvider(widget.tripId)).value;
    final categories = ref.watch(activityCategoriesProvider).value;
    final locations = ref.watch(locationsProvider(widget.tripId)).value;

    if (days == null ||
        activities == null ||
        categories == null ||
        locations == null) {
      return const Scaffold(body: LoadingView());
    }

    final actsByDay = <String, List<Activity>>{};
    for (final a in activities) {
      actsByDay.putIfAbsent(a.dayId, () => []).add(a);
    }
    final locById = {for (final l in locations) l.id: l};

    final visibleDays = days
        .where((d) => d.date != null || (actsByDay[d.id]?.isNotEmpty ?? false))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tabella di marcia')),
      floatingActionButton: days.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showActivitySheet(
                context,
                tripId: widget.tripId,
                dayId: days.first.id,
                days: days,
                categories: categories,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Attività'),
            ),
      body: visibleDays.isEmpty
          ? const _EmptyItinerary()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                for (final day in visibleDays)
                  _DaySection(
                    tripId: widget.tripId,
                    day: day,
                    activities: actsByDay[day.id] ?? const [],
                    allDays: days,
                    categories: categories,
                    locById: locById,
                  ),
              ],
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
  });

  final String tripId;
  final ItineraryDay day;
  final List<Activity> activities;
  final List<ItineraryDay> allDays;
  final List<ActivityCategory> categories;
  final Map<String, Location> locById;

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

    final dayNumber = day.date != null ? '${day.date!.day}' : '∙';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNumber,
                  style: TextStyle(
                    fontFamily: tokens.displayFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: tokens.accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.date != null
                          ? Fmt.dateShort(day.date!)
                          : 'Non programmato',
                      style: context.texts.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _summary(minutes, cost, conflicts.length),
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontSize: 11.5,
                        color: conflicts.isNotEmpty
                            ? tokens.warning
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (activities.length > 1)
                IconButton(
                  tooltip: 'Ordina per orario',
                  icon: const Icon(Icons.sort),
                  onPressed: () => repo.reorderDay(
                    ItineraryDomain.sortForDisplay(activities)
                        .map((a) => a.id)
                        .toList(),
                  ),
                ),
              IconButton.filledTonal(
                tooltip: 'Aggiungi attività',
                icon: const Icon(Icons.add),
                onPressed: () => showActivitySheet(
                  context,
                  tripId: tripId,
                  dayId: day.id,
                  days: allDays,
                  categories: categories,
                ),
              ),
            ],
          ),
        ),
        if (ordered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 56, bottom: 4),
            child: Text(
              'Giornata libera',
              style: context.texts.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
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
    return parts.join('  ·  ');
  }
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({
    required super.key,
    required this.index,
    required this.tripId,
    required this.activity,
    required this.category,
    required this.location,
    required this.isConflict,
    required this.allDays,
    required this.categories,
  });

  final int index;
  final String tripId;
  final Activity activity;
  final ActivityCategory? category;
  final Location? location;
  final bool isConflict;
  final List<ItineraryDay> allDays;
  final List<ActivityCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final done = activity.status == ActivityStatus.done;
    final skipped = activity.status == ActivityStatus.skipped ||
        activity.status == ActivityStatus.cancelled;
    Color? catColor;
    if (category?.colorHex != null) {
      catColor =
          Color(int.parse('FF${category!.colorHex!.substring(1)}', radix: 16));
    }
    final edge = isConflict ? tokens.warning : (catColor ?? tokens.accent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ItineraCard(
        accentEdge: edge,
        onTap: () => showActivitySheet(
          context,
          tripId: tripId,
          dayId: activity.dayId,
          days: allDays,
          categories: categories,
          existing: activity,
          existingLocation: location,
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimeColumn(activity: activity),
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 12, top: 1),
              decoration: BoxDecoration(
                color: (catColor ?? tokens.accent).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconForKey(category?.iconKey ?? 'place'),
                size: 18,
                color: catColor ?? tokens.accent,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: context.texts.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          (done || skipped) ? TextDecoration.lineThrough : null,
                      color: skipped ? scheme.onSurfaceVariant : null,
                    ),
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 13, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            location!.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isConflict) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.warning_amber,
                            size: 13, color: tokens.warning),
                        const SizedBox(width: 3),
                        Text(
                          'Sovrapposta',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.warning,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (done)
                      Icon(Icons.check_circle,
                          size: 18, color: tokens.positive),
                    _ActivityMenu(
                      tripId: tripId,
                      activity: activity,
                      hasLocation: location != null,
                      onOpenMap:
                          location != null ? () => _openInMaps(location!) : null,
                    ),
                  ],
                ),
                if (activity.costCents != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      Fmt.currencyCents(activity.costCents!),
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 2),
                    child: Icon(Icons.drag_indicator,
                        size: 18, color: tokens.hairline),
                  ),
                ),
              ],
            ),
          ],
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

/// Colonna oraria a sinistra dell'attività (monospace).
class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final hasTime = activity.startMinutes != null;
    return SizedBox(
      width: 42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasTime ? Fmt.timeOfDayMinutes(activity.startMinutes) : '·',
            style: TextStyle(
              fontFamily: tokens.monoFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: hasTime ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
          if (activity.endMinutes != null)
            Text(
              Fmt.timeOfDayMinutes(activity.endMinutes),
              style: TextStyle(
                fontFamily: tokens.monoFont,
                fontSize: 11,
                color: scheme.onSurfaceVariant,
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
    required this.onOpenMap,
  });

  final String tripId;
  final Activity activity;
  final bool hasLocation;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(itineraryRepositoryProvider);
    return PopupMenuButton<String>(
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
        const PopupMenuItem(value: 'done', child: Text('Segna come fatta')),
        const PopupMenuItem(value: 'planned', child: Text('Pianificata')),
        const PopupMenuItem(value: 'skipped', child: Text('Saltata')),
        if (hasLocation)
          const PopupMenuItem(value: 'map', child: Text('Apri in mappa')),
      ],
    );
  }
}

class _EmptyItinerary extends StatelessWidget {
  const _EmptyItinerary();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.map_outlined,
      title: 'Nessun giorno da mostrare',
      message: 'Imposta le date del viaggio per generare i giorni, '
          'oppure aggiungi un\'attività non programmata.',
    );
  }
}
