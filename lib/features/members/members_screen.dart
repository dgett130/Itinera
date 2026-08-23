import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import '../auth/auth_providers.dart';
import '../friends/friends_providers.dart';
import '../friends/user_search_sheet.dart';
import 'members_providers.dart';
import 'members_service.dart';

/// Persone di un viaggio: membri attivi, inviti in sospeso, e (per l'owner)
/// aggiunta di nuove persone via email o dalla rubrica amici.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final uid = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Persone')),
      body: membersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => const EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Elenco non disponibile',
          message: 'Serve la connessione per gestire le persone del viaggio.',
        ),
        data: (members) {
          final isOwner =
              members.any((m) => m.userId == uid && m.isOwner);
          final memberIds = {
            for (final m in members)
              if (m.userId != null) m.userId!
          };
          return Scaffold(
            floatingActionButton: isOwner
                ? FloatingActionButton.extended(
                    onPressed: () => _invite(context, ref, memberIds),
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Aggiungi'),
                  )
                : null,
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                for (final m in members) ...[
                  _MemberTile(
                    member: m,
                    canRemove: isOwner && !m.isOwner,
                    onRemove: () async {
                      await ref
                          .read(membersServiceProvider)
                          .remove(m.id);
                      ref.invalidate(tripMembersProvider(tripId));
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                if (!isOwner)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Solo il proprietario del viaggio puo\' invitare persone.',
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _invite(
      BuildContext context, WidgetRef ref, Set<String> memberIds) async {
    final members = ref.read(membersServiceProvider);
    final friends = ref.read(friendsServiceProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: UserSearchSheet(
          title: 'Aggiungi al viaggio',
          actionLabel: 'Aggiungi',
          excludedUserIds: memberIds,
          onSelect: (u) async {
            await members.addUser(tripId, u.userId);
            // Se non e' gia' un amico, mando anche la richiesta di amicizia.
            if (u.relation != 'friend') {
              try {
                await friends.sendRequest(u.userId);
              } catch (_) {}
            }
            return '${u.display} aggiunto al viaggio.';
          },
        ),
      ),
    );
    ref.invalidate(tripMembersProvider(tripId));
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.canRemove,
    required this.onRemove,
  });
  final TripMember member;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = member.email ?? 'Utente';
    final initial = label.characters.first.toUpperCase();
    return ItineraCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tokens.accentSoft,
            foregroundColor: tokens.accent,
            child: Text(initial,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    MonoTag(member.isOwner ? 'PROPRIETARIO' : 'EDITOR'),
                    if (member.isPending) ...[
                      const SizedBox(width: 6),
                      MonoTag('IN ATTESA',
                          color: tokens.warning,
                          background: tokens.warning.withValues(alpha: 0.12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Rimuovi',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
