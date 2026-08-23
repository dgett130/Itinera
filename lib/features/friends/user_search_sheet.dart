import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/widgets.dart';
import 'friends_providers.dart';
import 'friends_service.dart';

/// Foglio riutilizzabile per trovare utenti (per email o nome) e agire su di
/// loro: mandare una richiesta di amicizia oppure aggiungerli a un viaggio.
/// Mostra anche gli amici gia' presenti per una selezione rapida.
class UserSearchSheet extends ConsumerStatefulWidget {
  const UserSearchSheet({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onSelect,
    this.excludedUserIds = const <String>{},
    this.showFriends = true,
  });

  final String title;
  final String actionLabel;

  /// Esegue l'azione sull'utente scelto e restituisce il messaggio da mostrare.
  final Future<String> Function(UserRef user) onSelect;

  /// Utenti gia' presenti (es. gia' membri del viaggio): mostrati come tali.
  final Set<String> excludedUserIds;
  final bool showFriends;

  @override
  ConsumerState<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<UserSearchSheet> {
  final _ctrl = TextEditingController();
  List<UserRef>? _results; // null = nessuna ricerca ancora
  bool _searching = false;
  String _lastQuery = '';
  final _done = <String>{};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    FocusScope.of(context).unfocus();
    if (q.length < 3) {
      setState(() {
        _results = const <UserRef>[];
        _lastQuery = q;
      });
      return;
    }
    setState(() {
      _searching = true;
      _lastQuery = q;
    });
    try {
      final r = await ref.read(friendsServiceProvider).search(q);
      if (mounted) {
        setState(() {
          _results = r;
          _searching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = const <UserRef>[];
          _searching = false;
        });
      }
    }
  }

  Future<void> _pick(UserRef u) async {
    try {
      final msg = await widget.onSelect(u);
      if (!mounted) return;
      setState(() => _done.add(u.userId));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(widget.title),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cerca per email o nome',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _search,
                    ),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_results != null) ...[
                    if (_results!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _lastQuery.length < 3
                              ? 'Scrivi almeno 3 caratteri per cercare.'
                              : 'Nessun utente trovato con «$_lastQuery».',
                          textAlign: TextAlign.center,
                          style: context.texts.bodyMedium?.copyWith(
                              color: context.scheme.onSurfaceVariant),
                        ),
                      )
                    else
                      for (final u in _results!) _tile(u),
                    const SizedBox(height: 8),
                  ],
                  if (widget.showFriends)
                    friendsAsync.maybeWhen(
                      data: (friends) {
                        final list = friends
                            .where((f) =>
                                !widget.excludedUserIds.contains(f.userId))
                            .toList();
                        if (list.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SectionHeader('Dai tuoi amici'),
                            for (final f in list) _tile(f),
                          ],
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(UserRef u) {
    final tokens = context.tokens;
    final already = widget.excludedUserIds.contains(u.userId);
    final done = _done.contains(u.userId);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: tokens.accentSoft,
        foregroundColor: tokens.accent,
        child: Text(u.initial,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      title: Text(u.display),
      subtitle: (u.email != null && u.name != null && u.name!.isNotEmpty)
          ? Text(u.email!,
              maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: already
          ? const MonoTag('GIA\' PRESENTE')
          : done
              ? Icon(Icons.check_circle, color: tokens.positive)
              : FilledButton(
                  onPressed: () => _pick(u),
                  child: Text(widget.actionLabel),
                ),
    );
  }
}
