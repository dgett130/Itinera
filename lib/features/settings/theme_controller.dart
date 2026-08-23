import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

const String _kThemePref = 'theme_mode';

/// Gestisce la scelta del tema (sistema / chiaro / scuro), persistita in
/// `_app_prefs` (locale al dispositivo, non sincronizzata, non azzerata al
/// cambio account).
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final v = await ref.read(databaseProvider).getPref(_kThemePref);
    state = _parse(v);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(databaseProvider).setPref(_kThemePref, mode.name);
  }

  static ThemeMode _parse(String? v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
