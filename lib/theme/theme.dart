import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paper_league/theme/tokens.dart';

ThemeData buildPaperLeagueTheme() {
  final space = GoogleFonts.spaceGroteskTextTheme();
  final plex = GoogleFonts.ibmPlexSansTextTheme();
  final mono = GoogleFonts.jetBrainsMonoTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PlColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: PlColors.surface,
      primary: PlColors.accent,
      onPrimary: PlColors.onAccent,
      secondary: PlColors.bull,
      error: PlColors.bear,
      onSurface: PlColors.text,
    ),
  );

  final textTheme = plex
      .copyWith(
        displayLarge: space.displayLarge?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        displayMedium: space.displayMedium?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
        ),
        headlineMedium: space.headlineMedium?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          fontSize: 24,
        ),
        headlineSmall: space.headlineSmall?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleLarge: space.titleLarge?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: plex.titleMedium?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        bodyLarge: plex.bodyLarge?.copyWith(
          color: PlColors.text,
          fontSize: 16,
          height: 1.35,
        ),
        bodyMedium: plex.bodyMedium?.copyWith(
          color: PlColors.muted,
          fontSize: 14,
          height: 1.4,
        ),
        bodySmall: plex.bodySmall?.copyWith(
          color: PlColors.faint,
          fontSize: 12,
          height: 1.35,
        ),
        labelLarge: plex.labelLarge?.copyWith(
          color: PlColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
        labelMedium: mono.labelMedium?.copyWith(
          color: PlColors.muted,
          fontSize: 12,
          letterSpacing: 0.2,
        ),
        labelSmall: mono.labelSmall?.copyWith(
          color: PlColors.faint,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      )
      .apply(bodyColor: PlColors.text, displayColor: PlColors.text);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: PlColors.bg,
      foregroundColor: PlColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: PlColors.lineSoft,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: PlColors.surface,
      modalBackgroundColor: PlColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PlRadius.sheet)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PlColors.surface2,
      contentTextStyle: plex.bodyMedium?.copyWith(color: PlColors.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlRadius.md),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PlColors.text,
        side: const BorderSide(color: PlColors.line),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlRadius.md)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: PlColors.accent),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: PlColors.surface2,
      selectedColor: PlColors.accentSoft,
      disabledColor: PlColors.surface,
      labelStyle: textTheme.labelMedium,
      side: const BorderSide(color: PlColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PlRadius.sm)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 3,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      isDense: true,
      hintStyle: TextStyle(color: PlColors.faint),
    ),
  );
}
