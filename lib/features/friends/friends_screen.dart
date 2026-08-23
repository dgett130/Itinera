import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'friends_providers.dart';
import 'friends_service.dart';

/// Rubrica dei compagni di viaggio. Da qui, in futuro, si invitano ai viaggi.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Amici')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFriend(context, ref),
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
          if (friends.isEmpty) {
            return EmptyState(
              icon: Icons.group_outlined,
              title: 'Nessun amico, per ora',
              message:
                  'Aggiungi i tuoi compagni di viaggio per invitarli ai viaggi.',
              action: FilledButton.icon(
                onPressed: () => _addFriend(context, ref),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Aggiungi amico'),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
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

  Future<void> _addFriend(BuildContext context, WidgetRef ref) async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi amico'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome (opzionale)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserisci un\'email valida')),
        );
      }
      return;
    }
    try {
      await ref
          .read(friendsServiceProvider)
          .add(email: email, name: nameCtrl.text);
      ref.invalidate(friendsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _FriendTile extends ConsumerWidget {
  const _FriendTile({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final initial = friend.display.characters.first.toUpperCase();
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
                if (friend.name != null && friend.name!.isNotEmpty)
                  Text(friend.name!, style: context.texts.titleSmall),
                Text(
                  friend.email,
                  style: context.texts.bodySmall
                      ?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Rimuovi',
            onPressed: () async {
              await ref.read(friendsServiceProvider).remove(friend.id);
              ref.invalidate(friendsProvider);
            },
          ),
        ],
      ),
    );
  }
}
