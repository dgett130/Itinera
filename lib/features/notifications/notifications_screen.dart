import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'notifications_providers.dart';
import 'notifications_repository.dart';

/// Centro notifiche: elenco in tempo reale delle notifiche dell'utente.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsRepositoryProvider).markAllRead(),
              child: Text(l10n.notificationsMarkAllRead),
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.notificationsPrefsTitle,
            onPressed: () => context.push('/settings/notifications'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(e),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_outlined,
              title: l10n.notificationsEmptyTitle,
              message: l10n.notificationsEmptyMessage,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _NotificationTile(notification: items[i]),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    final repo = ref.read(notificationsRepositoryProvider);
    final unread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => repo.delete(notification.id),
      child: ItineraCard(
        onTap: () {
          if (unread) repo.markRead(notification.id);
          final route = notification.route;
          if (route != null && route.isNotEmpty) context.push(route);
        },
        color: unread ? tokens.accentSoft : null,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(notification.type), color: tokens.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: context.texts.titleSmall?.copyWith(
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body!,
                      style: context.texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(context, notification.createdAt),
                    style: context.texts.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 6, left: 6),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: tokens.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
    'friend_request' => Icons.person_add_alt_1_outlined,
    'friend_accepted' => Icons.people_alt_outlined,
    'shared_trip' => Icons.card_travel_outlined,
    'new_document' => Icons.folder_shared_outlined,
    _ => Icons.campaign_outlined,
  };

  String _relativeTime(BuildContext context, DateTime t) {
    final l10n = AppLocalizations.of(context);
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.timeJustNow;
    if (d.inMinutes < 60) return l10n.timeMinutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.timeHoursAgo(d.inHours);
    if (d.inDays < 7) return l10n.timeDaysAgo(d.inDays);
    return '${t.day}/${t.month}/${t.year}';
  }
}
