import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import '../trip/trip_providers.dart';
import 'notifications_providers.dart';
import 'notifications_repository.dart';

/// Preferenze notifiche: master + toggle per categoria. L'utente decide se e
/// quali notifiche ricevere; le preferenze sono su Supabase, così il server
/// (Edge Function) le rispetta prima di inviare il push.
class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState
    extends ConsumerState<NotificationPrefsScreen> {
  NotificationPrefs? _prefs;
  bool _deadlines = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(notificationsRepositoryProvider).prefs();
    final d = await ref.read(deadlineRemindersProvider).isEnabled();
    if (mounted) {
      setState(() {
        _prefs = p;
        _deadlines = d;
        _loaded = true;
      });
    }
  }

  Future<void> _setDeadlines(bool v) async {
    setState(() => _deadlines = v);
    final trips = ref.read(tripsProvider).value ?? const [];
    await ref.read(deadlineRemindersProvider).setEnabled(v, trips);
  }

  Future<void> _update(NotificationPrefs next) async {
    setState(() => _prefs = next);
    await ref.read(notificationsRepositoryProvider).savePrefs(next);
    ref.invalidate(notificationPrefsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = _prefs;
    const sectionPadding = EdgeInsets.fromLTRB(0, 16, 0, 10);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlainHeader(title: l10n.notificationsPrefsTitle, size: 30),
          Expanded(
            child: !_loaded || p == null
                ? const _PrefsSkeleton()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StaggerIn(
                          child: ItineraCard(
                            padding: _cardPadding,
                            child: _SwitchRow(
                              title: l10n.notificationsPushMaster,
                              subtitle: l10n.notificationsPushMasterHint,
                              value: p.pushEnabled,
                              onChanged: (v) =>
                                  _update(p.copyWith(pushEnabled: v)),
                            ),
                          ),
                        ),
                        StaggerIn(
                          index: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SectionHeader(
                                l10n.notificationsCategories,
                                padding: sectionPadding,
                              ),
                              ItineraCard(
                                padding: _cardPadding,
                                child: Column(
                                  children: [
                                    _SwitchRow(
                                      title: l10n.notificationsFriendRequests,
                                      light: true,
                                      value: p.friendRequests,
                                      enabled: p.pushEnabled,
                                      onChanged: (v) => _update(
                                        p.copyWith(friendRequests: v),
                                      ),
                                    ),
                                    _SwitchRow(
                                      title: l10n.notificationsSharedTrips,
                                      light: true,
                                      value: p.sharedTrips,
                                      enabled: p.pushEnabled,
                                      onChanged: (v) =>
                                          _update(p.copyWith(sharedTrips: v)),
                                    ),
                                    _SwitchRow(
                                      title: l10n.notificationsNewDocuments,
                                      light: true,
                                      value: p.newDocuments,
                                      enabled: p.pushEnabled,
                                      onChanged: (v) =>
                                          _update(p.copyWith(newDocuments: v)),
                                    ),
                                    _SwitchRow(
                                      title: l10n.notificationsSystemMessages,
                                      light: true,
                                      value: p.systemMessages,
                                      enabled: p.pushEnabled,
                                      onChanged: (v) => _update(
                                        p.copyWith(systemMessages: v),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        StaggerIn(
                          index: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SectionHeader(
                                l10n.notificationsLocalSection,
                                padding: sectionPadding,
                              ),
                              ItineraCard(
                                padding: _cardPadding,
                                child: _SwitchRow(
                                  title: l10n.notificationsDeadlines,
                                  subtitle: l10n.notificationsDeadlinesHint,
                                  value: _deadlines,
                                  onChanged: _setDeadlines,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.notificationsPrefsFooter,
                                style: context.texts.bodySmall?.copyWith(
                                  color: context.scheme.onSurfaceVariant,
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
    );
  }
}

const _cardPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 6);

/// Segnaposto mentre le preferenze arrivano dal server.
class _PrefsSkeleton extends StatelessWidget {
  const _PrefsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Skeleton(height: 68, radius: 20),
          SizedBox(height: 48),
          Skeleton(height: 184, radius: 20),
        ],
      ),
    );
  }
}

/// Riga con interruttore: titolo in evidenza o, con [light], semplice voce di un
/// elenco. Si attenua quando il push generale è spento.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.light = false,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool light;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.5,
      duration: Motion.of(context, Motion.standard),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: light
                      ? context.texts.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        )
                      : context.texts.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}
