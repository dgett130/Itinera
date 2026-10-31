import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers.dart';
import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
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
  bool _uploadingAvatar = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 82,
    );
    if (img == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await img.readAsBytes();
      final ext = img.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      await ref.read(authServiceProvider).uploadAvatar(bytes, ext: ext);
      ref.invalidate(profileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore caricamento: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider).updateDisplayName(_nameCtrl.text);
      ref.invalidate(profileProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profilo aggiornato')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go('/');
  }

  Future<void> _deleteAccount() async {
    final warning = context.tokens.warning;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina account'),
        content: Text(
          'Questa azione è irreversibile: tutti i tuoi viaggi, i dati e la '
          'condivisione verranno cancellati definitivamente. Continuare?',
          style: ctx.texts.bodyMedium?.copyWith(
            color: ctx.scheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: ctx.scheme.onSurface),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(authServiceProvider).deleteAccount();
      await ref.read(databaseProvider).clearSyncedData();
      messenger.showSnackBar(
        const SnackBar(content: Text('Account eliminato')),
      );
      router.go('/');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileProvider);

    if (user == null) {
      return const Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlainHeader(title: 'Profilo'),
            Expanded(
              child: EmptyState(
                icon: Icons.lock_outline,
                title: 'Non hai eseguito l\'accesso',
              ),
            ),
          ],
        ),
      );
    }

    final profile = profileAsync.value;
    if (!_prefilled && profile?.displayName != null) {
      _nameCtrl.text = profile!.displayName!;
      _prefilled = true;
    }
    final email = user.email ?? '';
    final name = profile?.displayName?.isNotEmpty == true
        ? profile!.displayName!
        : email;
    const tall = Size.fromHeight(56);
    const sectionPadding = EdgeInsets.fromLTRB(0, 18, 0, 10);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(
            name: name,
            email: email == name ? null : email,
            avatarUrl: profile?.avatarUrl,
            uploading: _uploadingAvatar,
            onPick: _uploadingAvatar ? null : _pickAvatar,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StaggerIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(
                          'Dati profilo',
                          padding: sectionPadding,
                        ),
                        TextField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome visualizzato',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(minimumSize: tall),
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Salva'),
                        ),
                      ],
                    ),
                  ),
                  StaggerIn(
                    index: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionHeader(
                          'Sessione',
                          padding: sectionPadding,
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: tall,
                            textStyle: TextStyle(
                              fontFamily: tokens.displayFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Esci'),
                        ),
                      ],
                    ),
                  ),
                  StaggerIn(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: sectionPadding,
                          child: Text(
                            'Zona pericolosa',
                            style: context.texts.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: tokens.warning,
                            ),
                          ),
                        ),
                        ItineraCard(
                          borderColor: tokens.warning,
                          padding: const EdgeInsets.all(14),
                          onTap: _deleteAccount,
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: tokens.warning),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Elimina account',
                                      style: context.texts.titleMedium
                                          ?.copyWith(color: tokens.warning),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Cancella definitivamente account e dati',
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

/// Testata sole del profilo: avatar con il badge per cambiare foto, nome, email.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.uploading,
    required this.onPick,
  });

  final String name;
  final String? email;
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback? onPick;

  static const double _avatar = 96;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final initialAvatar = InitialAvatar(
      name,
      size: _avatar,
      color: Cartolina.inchiostro,
      foreground: Colors.white,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyleOn(Cartolina.sole),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Cartolina.sole,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, top + 32, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Semantics(
                      button: true,
                      label: 'Cambia foto',
                      child: GestureDetector(
                        onTap: onPick,
                        child: SizedBox.square(
                          dimension: _avatar,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (avatarUrl != null)
                                ClipOval(
                                  child: Image.network(
                                    avatarUrl!,
                                    width: _avatar,
                                    height: _avatar,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => initialAvatar,
                                  ),
                                )
                              else
                                initialAvatar,
                              if (uploading)
                                Container(
                                  width: _avatar,
                                  height: _avatar,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera,
                                    size: 17,
                                    color: Cartolina.inchiostro,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.displaySmall?.copyWith(
                      fontSize: 28,
                      height: 1.1,
                      color: Cartolina.inchiostro,
                    ),
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      email!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Cartolina.inchiostro,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: top + 4,
              left: 8,
              child: const BackButton(color: Cartolina.inchiostro),
            ),
          ],
        ),
      ),
    );
  }
}
