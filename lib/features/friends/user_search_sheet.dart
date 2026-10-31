import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/itinera_theme.dart';
import '../../ui/motion.dart';
import '../../ui/widgets.dart';
import 'friends_providers.dart';
import 'friends_service.dart';

/// Foglio riutilizzabile per trovare utenti (per email o nome) e agire su di
/// loro: mandare una richiesta di amicizia oppure aggiungerli a un viaggio.
/// Mostra anche gli amici già presenti per una selezione rapida.
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

  /// Utenti già presenti (es. già membri del viaggio): mostrati come tali.
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final friendsAsync = ref.watch(friendsProvider);
    OutlineInputBorder pill(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: color, width: width),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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
              border: pill(tokens.hairline, 1),
              enabledBorder: pill(tokens.hairline, 1),
              focusedBorder: pill(tokens.accent, 2),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: 'Cerca',
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
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      for (final (i, u) in _results!.indexed)
                        i < Motion.staggerMax
                            ? StaggerIn(
                                key: ValueKey(u.userId),
                                index: i,
                                child: _tile(u),
                              )
                            : _tile(u),
                  ],
                  if (widget.showFriends)
                    friendsAsync.maybeWhen(
                      data: (friends) {
                        final list = friends
                            .where(
                              (f) => !widget.excludedUserIds.contains(f.userId),
                            )
                            .toList();
                        if (list.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SectionHeader(
                              'Dai tuoi amici',
                              padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                            ),
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
    final hasEmail = u.email != null && u.name != null && u.name!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ItineraCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            InitialAvatar(u.display),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.titleMedium,
                  ),
                  if (hasEmail)
                    Text(
                      u.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (already)
              MonoTag('Già presente', background: tokens.hairline)
            else if (done)
              Icon(Icons.check_circle, color: tokens.positive)
            else
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: TextStyle(
                    fontFamily: tokens.displayFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                onPressed: () => _pick(u),
                child: Text(widget.actionLabel),
              ),
          ],
        ),
      ),
    );
  }
}
