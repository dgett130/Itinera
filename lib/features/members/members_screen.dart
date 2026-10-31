import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
    final members = membersAsync.value;
    final isOwner =
        !membersAsync.hasError &&
        (members?.any((m) => m.userId == uid && m.isOwner) ?? false);

    return Scaffold(
      floatingActionButton: isOwner
          ? CartolinaFab(
              label: 'Aggiungi',
              tint: Cartolina.corallo,
              onPressed: () => _invite(context, ref, {
                for (final m in members!)
                  if (m.userId != null) m.userId!,
              }),
            )
          : null,
      body: Column(
        children: [
          const PlainHeader(title: 'Persone'),
          Expanded(
            child: membersAsync.when(
              loading: () => const _MembersSkeleton(),
              error: (e, _) => EmptyState(
                icon: Icons.warning_rounded,
                color: Cartolina.sole.withValues(alpha: 0.22),
                iconColor: context.tokens.warning,
                title: 'Elenco non disponibile',
                message:
                    'Serve la connessione per gestire le persone del viaggio.',
                action: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        ref.invalidate(tripMembersProvider(tripId)),
                    child: const Text('Riprova'),
                  ),
                ),
              ),
              data: (members) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < members.length; i++) ...[
                      StaggerIn(
                        key: ValueKey(members[i].id),
                        index: i,
                        child: _MemberTile(
                          member: members[i],
                          canRemove: isOwner && !members[i].isOwner,
                          onRemove: () async {
                            await ref
                                .read(membersServiceProvider)
                                .remove(members[i].id);
                            ref.invalidate(tripMembersProvider(tripId));
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!isOwner) const _OwnerOnlyNote(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _invite(
    BuildContext context,
    WidgetRef ref,
    Set<String> memberIds,
  ) async {
    final members = ref.read(membersServiceProvider);
    final friends = ref.read(friendsServiceProvider);
    await showCartolinaSheet<void>(
      context: context,
      fromFab: true,
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
    final scheme = context.scheme;
    final texts = context.texts;
    final (role, roleColor, roleWeight) = member.isPending
        ? ('In attesa', tokens.warning, FontWeight.w600)
        : member.isOwner
        ? ('Proprietario', tokens.accent, FontWeight.w500)
        : ('Può modificare', scheme.onSurfaceVariant, FontWeight.w400);
    return ItineraCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      child: Row(
        children: [
          // Il proprietario è sempre cobalto.
          member.isOwner
              ? InitialAvatar(
                  member.label,
                  color: Cartolina.cobalto,
                  foreground: Colors.white,
                )
              : InitialAvatar(member.label),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: texts.bodySmall?.copyWith(
                    fontWeight: roleWeight,
                    color: roleColor,
                  ),
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.close),
              color: scheme.onSurfaceVariant,
              tooltip: 'Rimuovi',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

/// Avviso per chi non e' proprietario del viaggio.
class _OwnerOnlyNote extends StatelessWidget {
  const _OwnerOnlyNote();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = context.scheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.accentSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: tokens.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Solo il proprietario del viaggio può invitare persone.',
              style: context.texts.bodySmall?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segnaposto mentre arriva l'elenco.
class _MembersSkeleton extends StatelessWidget {
  const _MembersSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: [
          Skeleton(height: 78, radius: 20),
          SizedBox(height: 12),
          Skeleton(height: 78, radius: 20),
          SizedBox(height: 12),
          Skeleton(height: 78, radius: 20),
        ],
      ),
    );
  }
}
