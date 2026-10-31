import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlainHeader(title: l10n.rwTitle, size: 32),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StaggerIn(
                    child: _WarningCard(
                      title: l10n.rwHours,
                      subtitle: l10n.rwHoursSub,
                      enabled: s.hours,
                      onEnabled: (v) => ctrl.save(s.copyWith(hours: v)),
                    ),
                  ),
                  StaggerIn(
                    index: 1,
                    child: _WarningCard(
                      title: l10n.rwLateEnd,
                      subtitle: l10n.rwLateEndSub(
                        Fmt.timeOfDayMinutes(s.lateEndMinutes),
                      ),
                      value: Fmt.timeOfDayMinutes(s.lateEndMinutes),
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
                  ),
                  StaggerIn(
                    index: 2,
                    child: _WarningCard(
                      title: l10n.rwLongDay,
                      subtitle: l10n.rwLongDaySub(
                        formatDuration(l10n, s.longDayMinutes * 60),
                      ),
                      value: formatDuration(l10n, s.longDayMinutes * 60),
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
                  ),
                  StaggerIn(
                    index: 3,
                    child: _WarningCard(
                      title: l10n.rwWalk,
                      subtitle: l10n.rwKmSub('${s.walkKm}'),
                      value: '${s.walkKm} km',
                      enabled: s.walk,
                      onEnabled: (v) => ctrl.save(s.copyWith(walk: v)),
                      onLess: s.walkKm > 5
                          ? () => ctrl.save(s.copyWith(walkKm: s.walkKm - 1))
                          : null,
                      onMore: s.walkKm < 40
                          ? () => ctrl.save(s.copyWith(walkKm: s.walkKm + 1))
                          : null,
                    ),
                  ),
                  StaggerIn(
                    index: 4,
                    child: _WarningCard(
                      title: l10n.rwBike,
                      subtitle: l10n.rwKmSub('${s.bikeKm}'),
                      value: '${s.bikeKm} km',
                      enabled: s.bike,
                      onEnabled: (v) => ctrl.save(s.copyWith(bike: v)),
                      onLess: s.bikeKm > 10
                          ? () => ctrl.save(s.copyWith(bikeKm: s.bikeKm - 5))
                          : null,
                      onMore: s.bikeKm < 150
                          ? () => ctrl.save(s.copyWith(bikeKm: s.bikeKm + 5))
                          : null,
                    ),
                  ),
                  Text(
                    l10n.rwInfo,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un avviso: interruttore e, se ha una soglia, "Meno", il valore e "Di più".
class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onEnabled,
    this.value,
    this.onLess,
    this.onMore,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<bool> onEnabled;

  /// Soglia attuale, già scritta per esteso (es. "20:00", "12 km").
  final String? value;
  final VoidCallback? onLess;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasThreshold = onLess != null || onMore != null;
    // AnimatedSize non regge la durata zero: con le animazioni ridotte, 1 ms.
    final resize = Motion.off(context)
        ? const Duration(milliseconds: 1)
        : Motion.standard;
    final step = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 42),
      padding: const EdgeInsets.symmetric(horizontal: 20),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ItineraCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              title: Text(title, style: context.texts.titleMedium),
              subtitle: Text(
                subtitle,
                style: context.texts.bodySmall?.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
              value: enabled,
              onChanged: onEnabled,
            ),
            AnimatedSize(
              duration: resize,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: enabled && hasThreshold
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: Row(
                        children: [
                          OutlinedButton(
                            style: step,
                            onPressed: onLess,
                            child: Text(l10n.rwLess),
                          ),
                          Expanded(
                            child: Text(
                              value ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.titleMedium?.copyWith(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            style: step,
                            onPressed: onMore,
                            child: Text(l10n.rwMore),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
