import "package:flutter/material.dart";
import "package:flutter/services.dart";

class MaterialTheme {
  final TextTheme textTheme;

  static const Color greenCardSurface = Color.fromARGB(255, 42, 66, 50);

  static const Color primaryColor = Color(0xff11d452);

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      surfaceTint: Color.fromARGB(255, 4, 51, 20),
      onPrimary: Color.fromARGB(255, 0, 0, 0),
      primaryContainer: Color(0xffcdeda4),
      onPrimaryContainer: Color(0xff354e16),
      secondary: Color(0xff586249),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdbe7c8),
      onSecondaryContainer: Color(0xff404a33),
      tertiary: Color(0xff386663),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbcece7),
      onTertiaryContainer: Color(0xff1f4e4b),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff1a1c16),
      onSurfaceVariant: Color(0xff44483d),
      outline: Color(0xff75796c),
      outlineVariant: Color(0xffc5c8ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffb1d18a),
      primaryFixed: Color(0xffcdeda4),
      onPrimaryFixed: Color(0xff102000),
      primaryFixedDim: Color(0xffb1d18a),
      onPrimaryFixedVariant: Color(0xff354e16),
      secondaryFixed: Color(0xffdbe7c8),
      onSecondaryFixed: Color(0xff151e0b),
      secondaryFixedDim: Color(0xffbfcbad),
      onSecondaryFixedVariant: Color(0xff404a33),
      tertiaryFixed: Color(0xffbcece7),
      onTertiaryFixed: Color(0xff00201e),
      tertiaryFixedDim: Color(0xffa0d0cb),
      onTertiaryFixedVariant: Color(0xff1f4e4b),
      surfaceDim: Color(0xffdadbd0),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4e9),
      surfaceContainer: Color(0xffeeefe3),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    const surfaceBase = Color(0xFF0F1A14);
    const surfaceLow = Color(0xFF14221A);
    const surfaceMid = Color(0xFF182820);
    const surfaceHigh = Color(0xFF1E3127);
    const surfaceHighest = Color(0xFF243A2F);

    const tableGreen = Color(0xFF3FA34D);
    const tableGreenContainer = Color(0xFF1B5E20);

    const goldAccent = Color(0xFFD4AF37);

    return const ColorScheme(
      brightness: Brightness.dark,

      // Primary (Table Green)
      primary: primaryColor,
      onPrimary: Color(0xFF000000),
      primaryContainer: tableGreenContainer,
      onPrimaryContainer: Color(0xFFC8E6C9),

      // Secondary (Gold Accent)
      secondary: goldAccent,
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFF3A2F0B),
      onSecondaryContainer: Color(0xFFFFE082),

      // Tertiary (Cool subtle contrast - keep restrained)
      tertiary: Color(0xFF4DB6AC),
      onTertiary: Color(0xFF00201E),
      tertiaryContainer: Color(0xFF003735),
      onTertiaryContainer: Color(0xFFB2DFDB),

      // Error (leave Material defaults styled for dark)
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // Surfaces (Tonal Baize Ladder)
      surface: surfaceBase,
      onSurface: Color(0xFFE2E8E3),

      surfaceDim: Color(0xFF0C1510),
      surfaceBright: Color(0xFF2A4034),

      surfaceContainerLowest: surfaceBase,
      surfaceContainerLow: surfaceLow,
      surfaceContainer: surfaceMid,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHighest,

      // Outlines
      outline: Color(0xFF6B7D73),
      outlineVariant: Color(0xFF3A4A42),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),

      // Inverse (rarely used but keep consistent)
      inverseSurface: Color(0xFFE2E8E3),
      onInverseSurface: Color(0xFF0F1A14),
      inversePrimary: Color(0xFF81C784),

      surfaceTint: tableGreen,
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    const double radius = 16;
    final bool isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: colorScheme.surface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 8 : 4,
        shadowColor: colorScheme.shadow.withValues(alpha: isDark ? 0.4 : 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: isDark ? 4 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: isDark ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(),
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
