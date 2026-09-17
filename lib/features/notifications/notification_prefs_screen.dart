import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../trip/trip_providers.dart';
import 'notifications_providers.dart';
import 'notifications_repository.dart';

/// Preferenze notifiche: master + toggle per categoria. L'utente decide se e
/// quali notifiche ricevere; le preferenze sono su Supabase, cosi' il server
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsPrefsTitle)),
      body: !_loaded || p == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _SwitchCard(
                  title: l10n.notificationsPushMaster,
                  subtitle: l10n.notificationsPushMasterHint,
                  value: p.pushEnabled,
                  onChanged: (v) => _update(p.copyWith(pushEnabled: v)),
                ),
                const SizedBox(height: 8),
                SectionHeader(l10n.notificationsCategories),
                _SwitchCard(
                  title: l10n.notificationsFriendRequests,
                  icon: Icons.person_add_alt_1_outlined,
                  value: p.friendRequests,
                  enabled: p.pushEnabled,
                  onChanged: (v) => _update(p.copyWith(friendRequests: v)),
                ),
                const SizedBox(height: 8),
                _SwitchCard(
                  title: l10n.notificationsSharedTrips,
                  icon: Icons.card_travel_outlined,
                  value: p.sharedTrips,
                  enabled: p.pushEnabled,
                  onChanged: (v) => _update(p.copyWith(sharedTrips: v)),
                ),
                const SizedBox(height: 8),
                _SwitchCard(
                  title: l10n.notificationsNewDocuments,
                  icon: Icons.folder_shared_outlined,
                  value: p.newDocuments,
                  enabled: p.pushEnabled,
                  onChanged: (v) => _update(p.copyWith(newDocuments: v)),
                ),
                const SizedBox(height: 8),
                _SwitchCard(
                  title: l10n.notificationsSystemMessages,
                  icon: Icons.campaign_outlined,
                  value: p.systemMessages,
                  enabled: p.pushEnabled,
                  onChanged: (v) => _update(p.copyWith(systemMessages: v)),
                ),
                SectionHeader(l10n.notificationsLocalSection),
                _SwitchCard(
                  title: l10n.notificationsDeadlines,
                  subtitle: l10n.notificationsDeadlinesHint,
                  icon: Icons.event_outlined,
                  value: _deadlines,
                  onChanged: _setDeadlines,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.notificationsPrefsFooter,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: tokens.accent),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: context.texts.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: context.texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
