import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sync/sync_engine.dart';
import '../../data/sync/sync_providers.dart';
import '../../ui/itinera_theme.dart';

/// Piccolo indicatore di stato della sincronizzazione. Tocco = sincronizza ora.
class SyncStatusButton extends ConsumerWidget {
  const SyncStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(syncEngineProvider);
    if (engine == null) return const SizedBox.shrink();
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: engine.status,
      builder: (context, s, _) {
        final tokens = context.tokens;
        final scheme = context.scheme;
        final (IconData icon, Color color, String tip) = switch (s.phase) {
          SyncPhase.syncing => (
              Icons.cloud_sync_outlined,
              scheme.onSurfaceVariant,
              'Sincronizzazione…'
            ),
          SyncPhase.offline => (
              Icons.cloud_off_outlined,
              scheme.onSurfaceVariant,
              'Offline — sincronizzo al ritorno della rete'
            ),
          SyncPhase.error => (
              Icons.error_outline,
              tokens.warning,
              'Errore di sincronizzazione — tocca per riprovare'
            ),
          SyncPhase.idle => (
              Icons.cloud_done_outlined,
              tokens.positive,
              'Tutto sincronizzato'
            ),
        };
        return IconButton(
          icon: Icon(icon, color: color),
          tooltip: tip,
          onPressed: () => engine.syncNow(),
        );
      },
    );
  }
}
