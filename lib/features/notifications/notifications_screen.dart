import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlainHeader(
            title: l10n.notificationsTitle,
            actions: [
              if (unread > 0)
                TextButton(
                  onPressed: () =>
                      ref.read(notificationsRepositoryProvider).markAllRead(),
                  child: Text(l10n.notificationsMarkAllRead),
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                color: context.scheme.onSurface,
                tooltip: l10n.notificationsPrefsTitle,
                onPressed: () => context.push('/settings/notifications'),
              ),
            ],
          ),
          Expanded(
            child: async.when(
              loading: () => const _NotificationsSkeleton(),
              error: (e, _) => ErrorView(e),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications,
                    color: Cartolina.cobalto,
                    iconColor: Colors.white,
                    title: l10n.notificationsEmptyTitle,
                    message: l10n.notificationsEmptyMessage,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final tile = _NotificationTile(notification: items[i]);
                    return i < Motion.staggerMax
                        ? _EnterOnce(index: i, child: tile)
                        : tile;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Ingresso in cascata che non si ripete tornando in cima all'elenco: la riga
/// resta viva anche fuori schermo.
class _EnterOnce extends StatefulWidget {
  const _EnterOnce({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_EnterOnce> createState() => _EnterOnceState();
}

class _EnterOnceState extends State<_EnterOnce>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StaggerIn(index: widget.index, child: widget.child);
  }
}

/// Segnaposto dell'elenco mentre arriva dalla rete.
class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 4; i++) ...[
            const Skeleton(height: 84, radius: 20),
            const SizedBox(height: 12),
          ],
        ],
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
    final (tile, icon, iconColor) = _styleFor(notification.type);
    final fade = Motion.of(context, Motion.standard);
    // AnimatedSize non regge la durata zero: con le animazioni ridotte, 1 ms.
    final resize = Motion.off(context)
        ? const Duration(milliseconds: 1)
        : Motion.standard;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => repo.delete(notification.id),
      // Da letta il fondo si attenua: la tessera sopra resta trasparente.
      child: AnimatedContainer(
        duration: fade,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: unread ? tokens.accentSoft : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ItineraCard(
          onTap: () {
            if (unread) repo.markRead(notification.id);
            final route = notification.route;
            if (route != null && route.isNotEmpty) context.push(route);
          },
          color: Colors.transparent,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconTile(icon, color: tile, iconColor: iconColor, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: context.texts.titleMedium),
                    if (notification.body != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        notification.body!,
                        style: context.texts.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      _relativeTime(context, notification.createdAt),
                      style: context.texts.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: resize,
                curve: Curves.easeOut,
                child: unread
                    ? Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: tokens.accent,
                          shape: BoxShape.circle,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Colore della tessera, icona e colore dell'icona per tipo di notifica.
  (Color, IconData, Color) _styleFor(String type) => switch (type) {
    'friend_request' => (Cartolina.corallo, Icons.group, Cartolina.inchiostro),
    'friend_accepted' => (Cartolina.corallo, Icons.group, Cartolina.inchiostro),
    'shared_trip' => (Cartolina.sole, Icons.luggage, Cartolina.inchiostro),
    'new_document' => (
      Cartolina.laguna,
      Icons.description,
      Cartolina.inchiostro,
    ),
    _ => (Cartolina.cobalto, Icons.notifications, Colors.white),
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
