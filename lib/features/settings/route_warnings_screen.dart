import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../explore/explore_ui.dart';
import '../explore/warning_settings_provider.dart';

/// Impostazioni → "Percorsi e avvisi": quali avvisi mostrare mentre si
/// pianifica un percorso e con quali soglie (solo su questo dispositivo).
class RouteWarningsScreen extends ConsumerWidget {
  const RouteWarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(warningSettingsProvider);
    final ctrl = ref.read(warningSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rwTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          _WarningCard(
            icon: Icons.door_front_door_outlined,
            title: l10n.rwHours,
            subtitle: l10n.rwHoursSub,
            enabled: s.hours,
            onEnabled: (v) => ctrl.save(s.copyWith(hours: v)),
          ),
          _WarningCard(
            icon: Icons.nights_stay_outlined,
            title: l10n.rwLateEnd,
            subtitle: l10n.rwLateEndSub(Fmt.timeOfDayMinutes(s.lateEndMinutes)),
            enabled: s.lateEnd,
            onEnabled: (v) => ctrl.save(s.copyWith(lateEnd: v)),
            onLess: s.lateEndMinutes > 17 * 60
                ? () => ctrl.save(
                    s.copyWith(lateEndMinutes: s.lateEndMinutes - 30),
                  )
                : null,
            onMore: s.lateEndMinutes < 23 * 60 + 30
                ? () => ctrl.save(
                    s.copyWith(lateEndMinutes: s.lateEndMinutes + 30),
                  )
                : null,
          ),
          _WarningCard(
            icon: Icons.hourglass_bottom,
            title: l10n.rwLongDay,
            subtitle: l10n.rwLongDaySub(
              formatDuration(l10n, s.longDayMinutes * 60),
            ),
            enabled: s.longDay,
            onEnabled: (v) => ctrl.save(s.copyWith(longDay: v)),
            onLess: s.longDayMinutes > 5 * 60
                ? () => ctrl.save(
                    s.copyWith(longDayMinutes: s.longDayMinutes - 30),
                  )
                : null,
            onMore: s.longDayMinutes < 14 * 60
                ? () => ctrl.save(
                    s.copyWith(longDayMinutes: s.longDayMinutes + 30),
                  )
                : null,
          ),
          _WarningCard(
            icon: Icons.directions_walk,
            title: l10n.rwWalk,
            subtitle: l10n.rwKmSub('${s.walkKm}'),
            enabled: s.walk,
            onEnabled: (v) => ctrl.save(s.copyWith(walk: v)),
            onLess: s.walkKm > 5
                ? () => ctrl.save(s.copyWith(walkKm: s.walkKm - 1))
                : null,
            onMore: s.walkKm < 40
                ? () => ctrl.save(s.copyWith(walkKm: s.walkKm + 1))
                : null,
          ),
          _WarningCard(
            icon: Icons.directions_bike,
            title: l10n.rwBike,
            subtitle: l10n.rwKmSub('${s.bikeKm}'),
            enabled: s.bike,
            onEnabled: (v) => ctrl.save(s.copyWith(bike: v)),
            onLess: s.bikeKm > 10
                ? () => ctrl.save(s.copyWith(bikeKm: s.bikeKm - 5))
                : null,
            onMore: s.bikeKm < 150
                ? () => ctrl.save(s.copyWith(bikeKm: s.bikeKm + 5))
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.rwInfo,
            style: context.texts.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Un avviso: interruttore e, se ha una soglia, "Meno"/"Di più".
class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onEnabled,
    this.onLess,
    this.onMore,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<bool> onEnabled;
  final VoidCallback? onLess;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasThreshold = onLess != null || onMore != null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ItineraCard(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Column(
          children: [
            SwitchListTile(
              secondary: Icon(icon, color: context.tokens.accent),
              title: Text(title),
              subtitle: Text(subtitle),
              value: enabled,
              onChanged: onEnabled,
            ),
            if (enabled && hasThreshold)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onLess,
                        icon: const Icon(Icons.remove),
                        label: Text(l10n.rwLess),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onMore,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.rwMore),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
