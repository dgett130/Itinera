import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import 'whats_new_data.dart';
import 'whats_new_sheet.dart';

/// Preferenza locale (per-dispositivo, non sincronizzata): ultima versione di
/// cui l'utente ha visto le novità.
const String _kSeenKey = 'whatsnew_seen_version';

/// Mostra il pannello "Novità" UNA sola volta dopo ogni aggiornamento, poi
/// memorizza la versione vista. Avvolge la home.
class WhatsNewGate extends ConsumerStatefulWidget {
  const WhatsNewGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<WhatsNewGate> createState() => _WhatsNewGateState();
}

class _WhatsNewGateState extends ConsumerState<WhatsNewGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    if (_checked || !mounted) return;
    _checked = true;
    final db = ref.read(databaseProvider);
    final seen = await db.getPref(_kSeenKey);
    if (seen == kWhatsNewVersion || !mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const WhatsNewSheet(),
    );
    await db.setPref(_kSeenKey, kWhatsNewVersion);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
