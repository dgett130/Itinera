import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'friends_providers.dart';
import 'friends_service.dart';
import 'user_search_sheet.dart';

/// Amici: richieste ricevute + elenco amici. Da qui si cercano nuovi utenti e
/// si mandano richieste; gli amici poi si aggiungono ai viaggi.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final requests = ref.watch(friendRequestsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Amici')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSearch(context, ref),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Aggiungi'),
      ),
      body: friendsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => const EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Elenco non disponibile',
          message: 'Serve la connessione per gestire gli amici.',
        ),
        data: (friends) {
          if (friends.isEmpty && requests.isEmpty) {
            return EmptyState(
              icon: Icons.group_outlined,
              title: 'Nessun amico, per ora',
              message:
                  'Cerca i tuoi compagni di viaggio e mandagli una richiesta.',
              action: FilledButton.icon(
                onPressed: () => _openSearch(context, ref),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Trova amici'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              if (requests.isNotEmpty) ...[
                SectionHeader('Richieste ricevute'),
                for (final r in requests) ...[
                  _RequestTile(user: r),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
              SectionHeader('I tuoi amici'),
              if (friends.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Ancora nessun amico. Usa "Aggiungi" per cercarli.',
                    style: context.texts.bodyMedium
                        ?.copyWith(color: context.scheme.onSurfaceVariant),
                  ),
                )
              else
                for (final f in friends) ...[
                  _FriendTile(friend: f),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSearch(BuildContext context, WidgetRef ref) async {
    final service = ref.read(friendsServiceProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: UserSearchSheet(
          title: 'Trova amici',
          actionLabel: 'Richiedi',
          showFriends: false,
          onSelect: (u) async {
            switch (u.relation) {
              case 'friend':
                return 'Siete gia\' amici.';
              case 'pending_out':
                return 'Richiesta gia\' inviata.';
              case 'pending_in':
                await service.sendRequest(u.userId); // accetta la reciproca
                return 'Ora siete amici!';
              default:
                await service.sendRequest(u.userId);
                return 'Richiesta inviata a ${u.display}.';
            }
          },
        ),
      ),
    );
    ref.invalidate(friendsProvider);
    ref.invalidate(friendRequestsProvider);
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.user});
  final UserRef user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    Future<void> respond(bool accept) async {
      await ref
          .read(friendsServiceProvider)
          .respond(user.friendshipId!, accept: accept);
      ref.invalidate(friendsProvider);
      ref.invalidate(friendRequestsProvider);
    }

    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tokens.accentSoft,
            foregroundColor: tokens.accent,
            child: Text(user.initial,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.display, style: context.texts.titleSmall),
                Text('Vuole aggiungerti agli amici',
                    style: context.texts.bodySmall
                        ?.copyWith(color: context.scheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_circle, color: tokens.positive),
            tooltip: 'Accetta',
            onPressed: () => respond(true),
          ),
          IconButton(
            icon: Icon(Icons.cancel_outlined,
                color: context.scheme.onSurfaceVariant),
            tooltip: 'Rifiuta',
            onPressed: () => respond(false),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends ConsumerWidget {
  const _FriendTile({required this.friend});
  final UserRef friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tokens.accentSoft,
            foregroundColor: tokens.accent,
            child: Text(friend.initial,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.display, style: context.texts.titleSmall),
                if (friend.email != null)
                  Text(friend.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.scheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_remove_outlined),
            tooltip: 'Rimuovi',
            onPressed: () async {
              await ref
                  .read(friendsServiceProvider)
                  .remove(friend.friendshipId!);
              ref.invalidate(friendsProvider);
            },
          ),
        ],
      ),
    );
  }
}
