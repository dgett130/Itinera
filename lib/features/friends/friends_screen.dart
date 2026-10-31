import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
    final count = friendsAsync.value?.length ?? 0;
    final noOne = friendsAsync.value?.isEmpty == true && requests.isEmpty;

    return Scaffold(
      // Da vuoto l'azione è già al centro della pagina.
      floatingActionButton: noOne
          ? null
          : CartolinaFab(
              label: 'Aggiungi',
              tint: Cartolina.corallo,
              onPressed: () => _openSearch(context, ref),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModuleHeader(
            style: ModuleStyle.luoghi,
            title: 'Amici',
            note: count == 0
                ? null
                : count == 1
                ? '1 compagno di viaggio'
                : '$count compagni di viaggio',
          ),
          Expanded(
            child: friendsAsync.when(
              loading: () => const _FriendsSkeleton(),
              error: (e, _) => EmptyState(
                icon: Icons.warning_rounded,
                color: Cartolina.sole.withValues(alpha: 0.2),
                iconColor: context.tokens.warning,
                title: 'Elenco non disponibile',
                message: 'Serve la connessione per gestire gli amici.',
                action: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref.invalidate(friendsProvider);
                      ref.invalidate(friendRequestsProvider);
                    },
                    child: const Text('Riprova'),
                  ),
                ),
              ),
              data: (friends) {
                if (friends.isEmpty && requests.isEmpty) {
                  return EmptyState(
                    icon: Icons.group,
                    color: Cartolina.corallo,
                    iconColor: Cartolina.inchiostro,
                    title: 'Nessun amico, per ora',
                    message:
                        'Cerca i tuoi compagni di viaggio e mandagli una '
                        'richiesta.',
                    action: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _openSearch(context, ref),
                        child: const Text('Trova amici'),
                      ),
                    ),
                  );
                }
                // Cascata solo sulle prime righe: le altre arrivano scorrendo.
                var row = 0;
                Widget enter(Widget child) {
                  final i = row++;
                  return i < Motion.staggerMax
                      ? StaggerIn(index: i, child: child)
                      : child;
                }

                const sectionPadding = EdgeInsets.fromLTRB(0, 14, 0, 10);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (requests.isNotEmpty) ...[
                        const SectionHeader(
                          'Richieste ricevute',
                          padding: sectionPadding,
                        ),
                        for (final r in requests) ...[
                          enter(_RequestTile(user: r)),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SectionHeader(
                        'I tuoi amici',
                        padding: sectionPadding,
                      ),
                      if (friends.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Ancora nessun amico. Usa "Aggiungi" per cercarli.',
                            style: context.texts.bodyMedium?.copyWith(
                              color: context.scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        for (final f in friends) ...[
                          enter(_FriendTile(friend: f)),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSearch(BuildContext context, WidgetRef ref) async {
    final service = ref.read(friendsServiceProvider);
    await showCartolinaSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: UserSearchSheet(
          title: 'Trova amici',
          actionLabel: 'Richiedi',
          showFriends: false,
          onSelect: (u) async {
            switch (u.relation) {
              case 'friend':
                return 'Siete già amici.';
              case 'pending_out':
                return 'Richiesta già inviata.';
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

/// Segnaposto dell'elenco mentre arriva dalla rete.
class _FriendsSkeleton extends StatelessWidget {
  const _FriendsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 3; i++) ...[
            const Skeleton(height: 78, radius: 20),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Iniziale, nome e riga sotto: la testa comune delle righe di questa pagina.
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.name, this.note, this.trailing});

  final String name;
  final String? note;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InitialAvatar(name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.titleMedium,
              ),
              if (note != null)
                Text(
                  note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.user});
  final UserRef user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> respond(bool accept) async {
      await ref
          .read(friendsServiceProvider)
          .respond(user.friendshipId!, accept: accept);
      ref.invalidate(friendsProvider);
      ref.invalidate(friendRequestsProvider);
    }

    const compact = Size(0, 44);
    final label = TextStyle(
      fontFamily: context.tokens.displayFont,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    );
    return ItineraCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersonRow(name: user.display, note: 'Vuole aggiungerti agli amici'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: compact,
                    textStyle: label,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => respond(false),
                  child: const Text('Rifiuta'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: compact,
                    textStyle: label,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => respond(true),
                  child: const Text('Accetta'),
                ),
              ),
            ],
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
    return ItineraCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
      child: _PersonRow(
        name: friend.display,
        note: friend.email,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Rimuovi',
          onPressed: () async {
            await ref.read(friendsServiceProvider).remove(friend.friendshipId!);
            ref.invalidate(friendsProvider);
          },
        ),
      ),
    );
  }
}
