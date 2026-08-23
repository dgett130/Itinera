import 'package:flutter/material.dart';

import '../core/enums.dart';
import '../data/database.dart';

/// Sistema di temi di Itinera.
///
/// Ogni viaggio puo' indossare uno di tre **stili** ([TripStyle]) con una
/// propria identita' di colore, tipografia e "firma" grafica. Fuori dai
/// viaggi (home, impostazioni, onboarding) si usa il tema di marca neutro
/// [ItineraTheme.brand], cosi' la home fa da cornice sobria e ogni viaggio
/// rivela il suo carattere.
///
/// I token specifici (gradiente, accento firma, font) viaggiano in un
/// [ThemeExtension] cosi' i widget possono leggerli con `context.tokens`
/// senza conoscere lo stile attivo.

/// Quale trattamento decorativo "firma" lo stile.
enum StyleSignature {
  /// Curve di livello + coordinate (Atlante).
  contour,

  /// Perforazione e tratteggio da biglietto (Boarding Pass).
  ticket,

  /// Grande gradiente tramonto (Sunset).
  gradient,
}

/// Token di design che cambiano con lo stile del viaggio.
@immutable
class ItineraTokens extends ThemeExtension<ItineraTokens> {
  const ItineraTokens({
    required this.style,
    required this.signature,
    required this.displayFont,
    required this.monoFont,
    required this.heroGradient,
    required this.heroForeground,
    required this.heroForegroundMuted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.hairline,
    required this.positive,
    required this.warning,
  });

  /// Stile a cui appartengono questi token.
  final TripStyle style;

  /// Trattamento decorativo caratteristico.
  final StyleSignature signature;

  /// Famiglia del font display (titoli grandi ed eroi).
  final String displayFont;

  /// Famiglia monospace per dati e micro-etichette.
  final String monoFont;

  /// Gradiente dell'intestazione/eroe del viaggio (2-3 fermate).
  final List<Color> heroGradient;

  /// Colore del testo/icone sopra l'eroe.
  final Color heroForeground;

  /// Variante attenuata del foreground dell'eroe.
  final Color heroForegroundMuted;

  /// Accento "firma" (corallo/rosso timbro/viola).
  final Color accent;

  /// Testo leggibile sopra [accent].
  final Color onAccent;

  /// Tinta tenue dell'accento, per contenitori e badge.
  final Color accentSoft;

  /// Linea sottile per bordi e divisori.
  final Color hairline;

  /// Colore "positivo" (spuntato, pagato, entro i limiti).
  final Color positive;

  /// Colore "attenzione" (oltre il limite, conflitto orario).
  final Color warning;

  LinearGradient get heroLinearGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: heroGradient,
      );

  @override
  ItineraTokens copyWith({
    TripStyle? style,
    StyleSignature? signature,
    String? displayFont,
    String? monoFont,
    List<Color>? heroGradient,
    Color? heroForeground,
    Color? heroForegroundMuted,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? hairline,
    Color? positive,
    Color? warning,
  }) {
    return ItineraTokens(
      style: style ?? this.style,
      signature: signature ?? this.signature,
      displayFont: displayFont ?? this.displayFont,
      monoFont: monoFont ?? this.monoFont,
      heroGradient: heroGradient ?? this.heroGradient,
      heroForeground: heroForeground ?? this.heroForeground,
      heroForegroundMuted: heroForegroundMuted ?? this.heroForegroundMuted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      hairline: hairline ?? this.hairline,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
    );
  }

  @override
  ItineraTokens lerp(ThemeExtension<ItineraTokens>? other, double t) {
    if (other is! ItineraTokens) return this;
    return ItineraTokens(
      style: t < 0.5 ? style : other.style,
      signature: t < 0.5 ? signature : other.signature,
      displayFont: t < 0.5 ? displayFont : other.displayFont,
      monoFont: t < 0.5 ? monoFont : other.monoFont,
      heroGradient: _lerpColors(heroGradient, other.heroGradient, t),
      heroForeground:
          Color.lerp(heroForeground, other.heroForeground, t) ?? heroForeground,
      heroForegroundMuted:
          Color.lerp(heroForegroundMuted, other.heroForegroundMuted, t) ??
              heroForegroundMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      onAccent: Color.lerp(onAccent, other.onAccent, t) ?? onAccent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      hairline: Color.lerp(hairline, other.hairline, t) ?? hairline,
      positive: Color.lerp(positive, other.positive, t) ?? positive,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
    );
  }

  static List<Color> _lerpColors(List<Color> a, List<Color> b, double t) {
    final n = a.length < b.length ? a.length : b.length;
    return [
      for (var i = 0; i < n; i++) Color.lerp(a[i], b[i], t) ?? a[i],
    ];
  }
}

/// Comodita' per leggere i token di stile dal contesto.
extension ItineraThemeContext on BuildContext {
  ItineraTokens get tokens =>
      Theme.of(this).extension<ItineraTokens>() ?? ItineraTheme.fallbackTokens;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;
}

/// Descrittore leggibile di uno stile, per il selettore nel form.
class StyleMeta {
  const StyleMeta({
    required this.style,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.swatch,
  });

  final TripStyle style;
  final String name;
  final String tagline;
  final IconData icon;

  /// Colori rappresentativi per l'anteprima nel selettore.
  final List<Color> swatch;
}

/// Fabbrica dei temi e dei metadati di stile.
class ItineraTheme {
  ItineraTheme._();

  static const String _display = 'Inter';

  /// Token di riserva, usati fuori da un viaggio (tema di marca).
  static const ItineraTokens fallbackTokens = ItineraTokens(
    style: TripStyle.atlante,
    signature: StyleSignature.contour,
    displayFont: 'Fraunces',
    monoFont: 'Space Mono',
    heroGradient: [Color(0xFF0E2A47), Color(0xFF0EA5A4)],
    heroForeground: Colors.white,
    heroForegroundMuted: Color(0xCCFFFFFF),
    accent: Color(0xFFFF6B5C),
    onAccent: Colors.white,
    accentSoft: Color(0x1AFF6B5C),
    hairline: Color(0xFFE4DCCB),
    positive: Color(0xFF0EA5A4),
    warning: Color(0xFFE1483B),
  );

  /// Stile suggerito in base al tipo di viaggio (solo preselezione: l'utente
  /// puo' sempre cambiarlo).
  static TripStyle suggestStyle(TripType type) {
    return switch (type) {
      TripType.mountain => TripStyle.atlante,
      TripType.roadTrip => TripStyle.atlante,
      TripType.backpacking => TripStyle.atlante,
      TripType.sea => TripStyle.boardingPass,
      TripType.business => TripStyle.boardingPass,
      TripType.city => TripStyle.sunset,
      TripType.generic => TripStyle.atlante,
    };
  }

  /// Stile effettivo di un viaggio (esplicito o dedotto dal tipo).
  static TripStyle effectiveStyle(Trip trip) =>
      trip.themeStyle ?? suggestStyle(trip.tripType);

  static StyleMeta meta(TripStyle style) {
    return switch (style) {
      TripStyle.atlante => const StyleMeta(
          style: TripStyle.atlante,
          name: 'Atlante',
          tagline: 'Cartografico, da esploratore',
          icon: Icons.explore_outlined,
          swatch: [Color(0xFF0E2A47), Color(0xFF0EA5A4), Color(0xFFFF6B5C)],
        ),
      TripStyle.boardingPass => const StyleMeta(
          style: TripStyle.boardingPass,
          name: 'Boarding Pass',
          tagline: 'Da carta d\'imbarco',
          icon: Icons.airplane_ticket_outlined,
          swatch: [Color(0xFF1B4DFF), Color(0xFF14181F), Color(0xFFE1483B)],
        ),
      TripStyle.sunset => const StyleMeta(
          style: TripStyle.sunset,
          name: 'Sunset',
          tagline: 'Vibrante, al tramonto',
          icon: Icons.wb_twilight_outlined,
          swatch: [Color(0xFFFF7A59), Color(0xFF7C5CFF), Color(0xFFFFC15E)],
        ),
    };
  }

  /// Tema di marca neutro per le schermate fuori dai viaggi.
  static ThemeData brand(Brightness brightness) =>
      forStyle(TripStyle.atlante, brightness, brand: true);

  /// Tema completo per uno stile e una luminosita'.
  static ThemeData forStyle(
    TripStyle style,
    Brightness brightness, {
    bool brand = false,
  }) {
    final p = _paletteFor(style, brightness);
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.accent,
      onSecondary: p.onAccent,
      tertiary: p.heroGradient.last,
      surface: p.surface,
      onSurface: p.onSurface,
      surfaceContainerLowest: isDark ? p.surface : Colors.white,
      surfaceContainerLow: p.card,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.cardHigh,
      surfaceContainerHighest: p.cardHigh,
      onSurfaceVariant: p.onSurfaceMuted,
      outline: p.hairline,
      outlineVariant: p.hairline,
      error: p.warning,
    );

    final tokens = ItineraTokens(
      style: style,
      signature: _signatureFor(style),
      displayFont: brand ? _display : _displayFontFor(style),
      monoFont: 'Space Mono',
      heroGradient: p.heroGradient,
      heroForeground: p.heroForeground,
      heroForegroundMuted: p.heroForegroundMuted,
      accent: p.accent,
      onAccent: p.onAccent,
      accentSoft: p.accentSoft,
      hairline: p.hairline,
      positive: p.positive,
      warning: p.warning,
    );

    final displayFont = tokens.displayFont;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: _display,
      extensions: [tokens],
    );

    TextTheme t = base.textTheme.apply(
      bodyColor: p.onSurface,
      displayColor: p.onSurface,
      fontFamily: _display,
    );

    // Titoli grandi ed eroi con il font display dello stile; corpo con Inter.
    t = t.copyWith(
      displayLarge: t.displayLarge?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600, height: 1.0),
      displayMedium: t.displayMedium?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600, height: 1.02),
      displaySmall: t.displaySmall?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600),
      headlineLarge: t.headlineLarge?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600),
      headlineMedium: t.headlineMedium?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600),
      headlineSmall: t.headlineSmall?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600),
      titleLarge: t.titleLarge?.copyWith(
          fontFamily: displayFont, fontWeight: FontWeight.w600),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: t,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: t.titleLarge?.copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusFor(style)),
          side: BorderSide(color: p.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: p.hairline, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: p.card,
        side: BorderSide(color: p.hairline),
        labelStyle: t.labelLarge?.copyWith(color: p.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusFor(style) * 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.card : Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
        labelStyle: TextStyle(color: p.onSurfaceMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        // Le CTA piene usano il colore PRIMARIO (teal/brand), non l'accento
        // corallo: un grande pulsante rosso sembrava un'azione negativa.
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          textStyle: t.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          side: BorderSide(color: p.hairline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.onSurface,
        contentTextStyle: TextStyle(color: p.background),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.hairline,
      ),
    );
  }

  static String _displayFontFor(TripStyle style) => switch (style) {
        TripStyle.atlante => 'Fraunces',
        TripStyle.boardingPass => 'Space Grotesk',
        TripStyle.sunset => 'Unbounded',
      };

  static StyleSignature _signatureFor(TripStyle style) => switch (style) {
        TripStyle.atlante => StyleSignature.contour,
        TripStyle.boardingPass => StyleSignature.ticket,
        TripStyle.sunset => StyleSignature.gradient,
      };

  static double _radiusFor(TripStyle style) => switch (style) {
        TripStyle.atlante => 16,
        TripStyle.boardingPass => 10,
        TripStyle.sunset => 22,
      };

  static _Palette _paletteFor(TripStyle style, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (style) {
      TripStyle.atlante => dark
          ? const _Palette(
              primary: Color(0xFF3FBFBE),
              onPrimary: Color(0xFF02201F),
              accent: Color(0xFFFF7A6B),
              onAccent: Color(0xFF2A0A05),
              accentSoft: Color(0x33FF7A6B),
              background: Color(0xFF0A1A28),
              surface: Color(0xFF0A1A28),
              card: Color(0xFF102636),
              cardHigh: Color(0xFF163247),
              onSurface: Color(0xFFE7EEF4),
              onSurfaceMuted: Color(0xFF9DB2C4),
              hairline: Color(0xFF21384B),
              heroGradient: [Color(0xFF0C2137), Color(0xFF0E7C7B)],
              heroForeground: Colors.white,
              heroForegroundMuted: Color(0xCCFFFFFF),
              positive: Color(0xFF3FBFBE),
              warning: Color(0xFFFF8A7A),
            )
          : const _Palette(
              primary: Color(0xFF0E7C7B),
              onPrimary: Colors.white,
              accent: Color(0xFFF2583F),
              onAccent: Colors.white,
              accentSoft: Color(0x1AF2583F),
              background: Color(0xFFF4EEE3),
              surface: Color(0xFFF4EEE3),
              card: Color(0xFFFCFAF4),
              cardHigh: Colors.white,
              onSurface: Color(0xFF102A3E),
              onSurfaceMuted: Color(0xFF5E7385),
              hairline: Color(0xFFE0D6C4),
              heroGradient: [Color(0xFF0E2A47), Color(0xFF0EA5A4)],
              heroForeground: Colors.white,
              heroForegroundMuted: Color(0xCCFFFFFF),
              positive: Color(0xFF0E7C7B),
              warning: Color(0xFFC23A26),
            ),
      TripStyle.boardingPass => dark
          ? const _Palette(
              primary: Color(0xFF6C8BFF),
              onPrimary: Color(0xFF04103F),
              accent: Color(0xFFFF6A5C),
              onAccent: Color(0xFF2A0A05),
              accentSoft: Color(0x33FF6A5C),
              background: Color(0xFF0D1016),
              surface: Color(0xFF0D1016),
              card: Color(0xFF171C25),
              cardHigh: Color(0xFF1E2532),
              onSurface: Color(0xFFECEFF4),
              onSurfaceMuted: Color(0xFF97A0B0),
              hairline: Color(0xFF283040),
              heroGradient: [Color(0xFF1B3AA8), Color(0xFF3D6BFF)],
              heroForeground: Colors.white,
              heroForegroundMuted: Color(0xCCFFFFFF),
              positive: Color(0xFF4EC0A0),
              warning: Color(0xFFFF7A6B),
            )
          : const _Palette(
              primary: Color(0xFF1B4DFF),
              onPrimary: Colors.white,
              accent: Color(0xFFE1483B),
              onAccent: Colors.white,
              accentSoft: Color(0x1AE1483B),
              background: Color(0xFFF7F3EA),
              surface: Color(0xFFF7F3EA),
              card: Color(0xFFFFFDF8),
              cardHigh: Colors.white,
              onSurface: Color(0xFF14181F),
              onSurfaceMuted: Color(0xFF66707E),
              hairline: Color(0xFFE3DCCC),
              heroGradient: [Color(0xFF1B4DFF), Color(0xFF0B216E)],
              heroForeground: Colors.white,
              heroForegroundMuted: Color(0xCCFFFFFF),
              positive: Color(0xFF1C8C6A),
              warning: Color(0xFFC23A26),
            ),
      TripStyle.sunset => dark
          ? const _Palette(
              primary: Color(0xFFFF8C6B),
              onPrimary: Color(0xFF2A0A05),
              accent: Color(0xFF9B84FF),
              onAccent: Color(0xFF17082E),
              accentSoft: Color(0x339B84FF),
              background: Color(0xFF17111F),
              surface: Color(0xFF17111F),
              card: Color(0xFF221830),
              cardHigh: Color(0xFF2C2140),
              onSurface: Color(0xFFF4ECFB),
              onSurfaceMuted: Color(0xFFB2A3C4),
              hairline: Color(0xFF35283F),
              heroGradient: [Color(0xFFFF7A59), Color(0xFF7C5CFF)],
              heroForeground: Colors.white,
              heroForegroundMuted: Color(0xE6FFFFFF),
              positive: Color(0xFF57C79A),
              warning: Color(0xFFFFB25C),
            )
          : const _Palette(
              primary: Color(0xFFF2643C),
              onPrimary: Colors.white,
              accent: Color(0xFF7C5CFF),
              onAccent: Colors.white,
              accentSoft: Color(0x1A7C5CFF),
              background: Color(0xFFFFF6F0),
              surface: Color(0xFFFFF6F0),
              card: Colors.white,
              cardHigh: Colors.white,
              onSurface: Color(0xFF2A1A3A),
              onSurfaceMuted: Color(0xFF7C6A86),
              hairline: Color(0xFFF1E1D8),
              heroGradient: [Color(0xFFFF7A59), Color(0xFF7C5CFF)],
              heroForeground: Colors.white,
              heroForegroundMuted: Color(0xE6FFFFFF),
              positive: Color(0xFF1FA97C),
              warning: Color(0xFFE07A2B),
            ),
    };
  }
}

/// Insieme completo di colori risolti per uno stile+luminosita'.
class _Palette {
  const _Palette({
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.card,
    required this.cardHigh,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.hairline,
    required this.heroGradient,
    required this.heroForeground,
    required this.heroForegroundMuted,
    required this.positive,
    required this.warning,
  });

  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color background;
  final Color surface;
  final Color card;
  final Color cardHigh;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color hairline;
  final List<Color> heroGradient;
  final Color heroForeground;
  final Color heroForegroundMuted;
  final Color positive;
  final Color warning;
}
