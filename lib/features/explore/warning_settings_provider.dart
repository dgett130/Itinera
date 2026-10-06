import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import 'route_warnings.dart';

const String _kWarningsPref = 'route_warnings';

/// Soglie degli avvisi sui percorsi, persistite in `_app_prefs` (locali al
/// dispositivo, non sincronizzate).
class WarningSettingsController extends Notifier<WarningSettings> {
  @override
  WarningSettings build() {
    _load();
    return const WarningSettings();
  }

  Future<void> _load() async {
    final v = await ref.read(databaseProvider).getPref(_kWarningsPref);
    state = WarningSettings.decode(v);
  }

  Future<void> save(WarningSettings next) async {
    state = next;
    await ref.read(databaseProvider).setPref(_kWarningsPref, next.encode());
  }
}

final warningSettingsProvider =
    NotifierProvider<WarningSettingsController, WarningSettings>(
      WarningSettingsController.new,
    );
