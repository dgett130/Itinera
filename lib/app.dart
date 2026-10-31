import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase_config.dart';
import 'features/homewidget/home_widget_sync.dart';
import 'features/settings/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'ui/itinera_theme.dart';
import 'ui/sunrise_splash.dart';

/// Widget radice dell'app.
class ItineraApp extends ConsumerWidget {
  const ItineraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // Il widget sulla Home segue l'account e i tocchi aprono il viaggio. Sta
    // sopra il navigatore: con altre schermate aperte non deve andare in pausa.
    if (SupabaseConfig.hasCredentials && supabaseReady) {
      ref.watch(homeWidgetSyncProvider);
      ref.watch(homeWidgetLinksProvider);
    }
    return MaterialApp.router(
      title: 'Itinera',
      debugShowCheckedModeBanner: false,
      theme: ItineraTheme.brand(Brightness.light),
      darkTheme: ItineraTheme.brand(Brightness.dark),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) =>
          SunriseSplash(child: child ?? const SizedBox.shrink()),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
    );
  }
}
