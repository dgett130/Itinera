import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import '../auth/auth_providers.dart';
import '../friends/friends_providers.dart';
import '../friends/friends_service.dart';
import 'notifications_providers.dart';

/// Pannello admin per inviare un messaggio di sistema a tutti o a un utente.
/// Visibile solo agli account con `is_admin` (vedi router/impostazioni).
class AdminMessageScreen extends ConsumerStatefulWidget {
  const AdminMessageScreen({super.key});

  @override
  ConsumerState<AdminMessageScreen> createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends ConsumerState<AdminMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _toAll = true;
  String? _targetUserId;
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_toAll && _targetUserId == null) {
      _snack(l10n.adminMsgPickUser);
      return;
    }
    setState(() => _sending = true);
    try {
      final n = await ref
          .read(notificationsRepositoryProvider)
          .sendSystemMessage(
            _titleCtrl.text.trim(),
            _bodyCtrl.text.trim(),
            targetUserId: _toAll ? null : _targetUserId,
          );
      if (!mounted) return;
      _snack(l10n.adminMsgSent(n));
      context.pop();
    } catch (e) {
      if (mounted) _snack(l10n.adminMsgError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final friends = ref.watch(friendsProvider).value ?? const <UserRef>[];
    final selfId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminMsgTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.adminMsgFieldTitle,
                prefixIcon: const Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.commonRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyCtrl,
              decoration: InputDecoration(labelText: l10n.adminMsgFieldBody),
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.commonRequired : null,
            ),
            const SizedBox(height: 16),
            SectionHeader(l10n.adminMsgRecipients),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.adminMsgAll)),
                ButtonSegment(value: false, label: Text(l10n.adminMsgOneUser)),
              ],
              selected: {_toAll},
              onSelectionChanged: (s) => setState(() => _toAll = s.first),
            ),
            if (!_toAll) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _targetUserId,
                decoration: InputDecoration(
                  labelText: l10n.adminMsgUser,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                items: [
                  if (selfId != null)
                    DropdownMenuItem(
                      value: selfId,
                      child: Text(l10n.adminMsgMyself),
                    ),
                  for (final f in friends)
                    DropdownMenuItem(value: f.userId, child: Text(f.display)),
                ],
                onChanged: (v) => setState(() => _targetUserId = v),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(l10n.adminMsgSend),
            ),
          ],
        ),
      ),
    );
  }
}
