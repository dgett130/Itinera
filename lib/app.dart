import 'package:flutter/material.dart';

import 'core/enums.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'ui/itinera_theme.dart';

/// Widget radice dell'app.
class ItineraApp extends StatelessWidget {
  const ItineraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Itinera',
      debugShowCheckedModeBanner: false,
      theme: ItineraTheme.brand(Brightness.light),
      darkTheme: ItineraTheme.brand(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('it'),
    );
  }
}

/// Applica alla sottostruttura il tema dello stile [style], rispettando la
/// luminosita' attiva. Usato dagli schermi interni a un viaggio per far
/// "indossare" al viaggio la sua identita' visiva.
class TripThemeScope extends StatelessWidget {
  const TripThemeScope({super.key, required this.style, required this.child});

  final TripStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // AnimatedTheme fa una transizione morbida di colori/gradiente quando si
    // cambia stile del viaggio (i token interpolano via ItineraTokens.lerp).
    return AnimatedTheme(
      data: ItineraTheme.forStyle(style, brightness),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}
