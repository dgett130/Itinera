import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'auth_providers.dart';

/// Profilo dell'utente loggato: nome visualizzato + email + logout.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider).updateDisplayName(_nameCtrl.text);
      ref.invalidate(profileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profilo aggiornato')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);

    if (user == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'Non hai eseguito l\'accesso',
        ),
      );
    }

    final profile = profileAsync.value;
    if (!_prefilled && profile?.displayName != null) {
      _nameCtrl.text = profile!.displayName!;
      _prefilled = true;
    }
    final initial = (profile?.displayName?.isNotEmpty == true
            ? profile!.displayName!
            : (user.email ?? '?'))
        .characters
        .first
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [tokens.accent, tokens.heroGradient.last],
                    ),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: tokens.displayFont,
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.email ?? '',
                    style: context.texts.bodyMedium
                        ?.copyWith(color: context.scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader('Dati profilo'),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome visualizzato',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('Salva'),
          ),
          SectionHeader('Sessione'),
          ItineraCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.logout, color: tokens.warning),
              title: const Text('Esci'),
              subtitle: const Text('Termina la sessione su questo dispositivo'),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
