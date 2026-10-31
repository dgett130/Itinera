import 'package:flutter/material.dart';

/// Identita' "Cartolina" di Itinera: i manifesti turistici italiani degli anni
/// '50. Colori pieni e forme piatte; ogni viaggio ha il suo poster (vedi
/// `posters.dart`), scelto in base al tipo di viaggio.
///
/// I token che cambiano tra chiaro e scuro viaggiano in un [ThemeExtension],
/// cosi' i widget li leggono con `context.tokens`.

/// Colori fissi dell'identita', uguali in chiaro e in scuro.
class Cartolina {
  Cartolina._();

  static const cobalto = Color(0xFF1B3FD8);
  static const cobaltoScuro = Color(0xFF0E2AA8);
  static const sole = Color(0xFFFFC21A);
  static const corallo = Color(0xFFFF7A59);
  static const laguna = Color(0xFF12B6BE);
  static const inchiostro = Color(0xFF11153A);
  static const carta = Color(0xFFF5F6FB);
}

/// Token di design che cambiano tra tema chiaro e scuro.
@immutable
class ItineraTokens extends ThemeExtension<ItineraTokens> {
  const ItineraTokens({
    required this.displayFont,
    required this.labelFont,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.hairline,
    required this.positive,
    required this.warning,
  });

  /// Famiglia dei titoli e dei numeri grandi.
  final String displayFont;

  /// Famiglia di dati e micro-etichette.
  final String labelFont;

  /// Colore d'accento per icone, link e dati in evidenza.
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

  @override
  ItineraTokens copyWith({
    String? displayFont,
    String? labelFont,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? hairline,
    Color? positive,
    Color? warning,
  }) {
    return ItineraTokens(
      displayFont: displayFont ?? this.displayFont,
      labelFont: labelFont ?? this.labelFont,
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
      displayFont: t < 0.5 ? displayFont : other.displayFont,
      labelFont: t < 0.5 ? labelFont : other.labelFont,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      onAccent: Color.lerp(onAccent, other.onAccent, t) ?? onAccent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      hairline: Color.lerp(hairline, other.hairline, t) ?? hairline,
      positive: Color.lerp(positive, other.positive, t) ?? positive,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
    );
  }
}

/// Comodita' per leggere i token dal contesto.
extension ItineraThemeContext on BuildContext {
  ItineraTokens get tokens =>
      Theme.of(this).extension<ItineraTokens>() ?? ItineraTheme.fallbackTokens;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get texts => Theme.of(this).textTheme;
}

/// Fabbrica del tema dell'app.
class ItineraTheme {
  ItineraTheme._();

  static const String _display = 'Bricolage Grotesque';
  static const String _body = 'Figtree';

  /// Token di riserva, se il tema non li porta (es. test senza tema).
  static const ItineraTokens fallbackTokens = ItineraTokens(
    displayFont: _display,
    labelFont: _body,
    accent: Cartolina.cobalto,
    onAccent: Colors.white,
    accentSoft: Color(0x1A1B3FD8),
    hairline: Color(0xFFDFE2F0),
    positive: Color(0xFF0A7F86),
    warning: Color(0xFFC2410C),
  );

  /// Tema completo per una luminosita'.
  static ThemeData brand(Brightness brightness) {
    final p = brightness == Brightness.dark ? _Palette.dark : _Palette.light;
    final isDark = brightness == Brightness.dark;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: Cartolina.cobalto,
          brightness: brightness,
        ).copyWith(
          primary: p.primary,
          onPrimary: p.onPrimary,
          secondary: p.accent,
          onSecondary: p.onAccent,
          tertiary: Cartolina.corallo,
          onTertiary: Cartolina.inchiostro,
          surface: p.background,
          onSurface: p.onSurface,
          surfaceContainerLowest: p.card,
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
      displayFont: _display,
      labelFont: _body,
      accent: p.accent,
      onAccent: p.onAccent,
      accentSoft: p.accentSoft,
      hairline: p.hairline,
      positive: p.positive,
      warning: p.warning,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: _body,
      extensions: [tokens],
    );

    TextTheme t = base.textTheme.apply(
      bodyColor: p.onSurface,
      displayColor: p.onSurface,
      fontFamily: _body,
    );

    TextStyle? display(TextStyle? s, FontWeight w) =>
        s?.copyWith(fontFamily: _display, fontWeight: w);

    // Titoli e numeri da manifesto; testi e note con Figtree.
    t = t.copyWith(
      displayLarge: display(t.displayLarge, FontWeight.w800),
      displayMedium: display(t.displayMedium, FontWeight.w800),
      displaySmall: display(t.displaySmall, FontWeight.w800),
      headlineLarge: display(t.headlineLarge, FontWeight.w800),
      headlineMedium: display(t.headlineMedium, FontWeight.w800),
      headlineSmall: display(t.headlineSmall, FontWeight.w800),
      titleLarge: display(t.titleLarge, FontWeight.w800),
      titleMedium: display(t.titleMedium, FontWeight.w700),
      titleSmall: display(t.titleSmall, FontWeight.w700),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    const pill = StadiumBorder();

    return base.copyWith(
      textTheme: t,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: t.titleLarge?.copyWith(fontSize: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: p.hairline, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: p.card,
        selectedColor: p.chipSelected,
        secondarySelectedColor: p.chipSelected,
        checkmarkColor: Cartolina.inchiostro,
        side: BorderSide(color: p.hairline),
        labelStyle: t.labelLarge?.copyWith(color: p.onSurface),
        secondaryLabelStyle: t.labelLarge?.copyWith(
          color: Cartolina.inchiostro,
        ),
        shape: pill,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        // Etichetta dentro il campo, non sul bordo.
        border: _FieldBorder(BorderSide(color: p.hairline)),
        enabledBorder: _FieldBorder(BorderSide(color: p.hairline)),
        disabledBorder: _FieldBorder(BorderSide(color: p.hairline)),
        focusedBorder: _FieldBorder(BorderSide(color: p.accent, width: 2)),
        errorBorder: _FieldBorder(BorderSide(color: p.warning)),
        focusedErrorBorder: _FieldBorder(
          BorderSide(color: p.warning, width: 2),
        ),
        labelStyle: TextStyle(color: p.onSurfaceMuted),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (s) => TextStyle(
            color: s.contains(WidgetState.focused)
                ? p.accent
                : p.onSurfaceMuted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.cta,
          foregroundColor: p.onCta,
          textStyle: t.labelLarge?.copyWith(
            fontFamily: _display,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: pill,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          side: BorderSide(color: p.onSurface, width: 1.5),
          textStyle: t.labelLarge?.copyWith(
            fontFamily: _display,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: t.labelLarge,
          shape: pill,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: p.hairline)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.chipSelected : p.card,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? Cartolina.inchiostro
                : p.onSurface,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.cta,
        foregroundColor: p.onCta,
        elevation: 2,
        extendedTextStyle: t.labelLarge?.copyWith(
          fontFamily: _display,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        shape: pill,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? (isDark ? Cartolina.inchiostro : Colors.white)
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.switchOn : null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.switchOn : null,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Cartolina.carta : Cartolina.inchiostro,
        contentTextStyle: TextStyle(
          fontFamily: _body,
          color: isDark ? Cartolina.inchiostro : Colors.white,
        ),
        actionTextColor: isDark ? Cartolina.cobalto : Cartolina.sole,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.cardHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.hairline,
      ),
    );
  }
}

/// Bordo arrotondato dei campi: a differenza di quello "outline" tiene
/// l'etichetta dentro il campo, come nelle maschere.
class _FieldBorder extends InputBorder {
  const _FieldBorder(BorderSide side) : super(borderSide: side);

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  bool get isOutline => false;

  @override
  InputBorder copyWith({BorderSide? borderSide}) =>
      _FieldBorder(borderSide ?? this.borderSide);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  ShapeBorder scale(double t) => _FieldBorder(borderSide.scale(t));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_radius.toRRect(rect).deflate(borderSide.width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_radius.toRRect(rect));

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    canvas.drawRRect(
      _radius.toRRect(rect).deflate(borderSide.width / 2),
      borderSide.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _FieldBorder && other.borderSide == borderSide;

  @override
  int get hashCode => borderSide.hashCode;
}

/// Colori risolti per una luminosita'.
class _Palette {
  const _Palette({
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.background,
    required this.card,
    required this.cardHigh,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.hairline,
    required this.positive,
    required this.warning,
    required this.cta,
    required this.onCta,
    required this.chipSelected,
    required this.switchOn,
  });

  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color background;
  final Color card;
  final Color cardHigh;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color hairline;
  final Color positive;
  final Color warning;

  /// Bottone principale.
  final Color cta;
  final Color onCta;
  final Color chipSelected;
  final Color switchOn;

  static const light = _Palette(
    primary: Cartolina.cobalto,
    onPrimary: Colors.white,
    accent: Cartolina.cobalto,
    onAccent: Colors.white,
    accentSoft: Color(0x1A1B3FD8),
    background: Cartolina.carta,
    card: Colors.white,
    cardHigh: Colors.white,
    onSurface: Cartolina.inchiostro,
    onSurfaceMuted: Color(0xFF565C85),
    hairline: Color(0xFFDFE2F0),
    positive: Color(0xFF0A7F86),
    warning: Color(0xFFC2410C),
    cta: Cartolina.inchiostro,
    onCta: Colors.white,
    chipSelected: Cartolina.sole,
    switchOn: Cartolina.cobalto,
  );

  static const dark = _Palette(
    primary: Cartolina.sole,
    onPrimary: Cartolina.inchiostro,
    accent: Color(0xFF9DAEFF),
    onAccent: Cartolina.inchiostro,
    accentSoft: Color(0x339DAEFF),
    background: Color(0xFF0C0F2B),
    card: Color(0xFF171B45),
    cardHigh: Color(0xFF20255A),
    onSurface: Cartolina.carta,
    onSurfaceMuted: Color(0xFFA9B0DA),
    hairline: Color(0xFF2B3066),
    positive: Cartolina.laguna,
    warning: Color(0xFFFFB14A),
    cta: Cartolina.sole,
    onCta: Cartolina.inchiostro,
    chipSelected: Cartolina.sole,
    switchOn: Cartolina.sole,
  );
}
