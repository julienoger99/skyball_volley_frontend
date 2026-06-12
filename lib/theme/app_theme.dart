import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background    = Color(0xFF1E003D);  // violet principal (allégé)
  static const backgroundDeep = Color(0xFF100020); // ancre sombre pour gradients
  static const surface       = Color(0xFF360068);  // surfaces / cards
  static const surfaceHigh   = Color(0xFF440085);  // cards élevées / gradients
  static const primary       = Color(0xFFFFD100);
  static const primarySoft   = Color(0x1AFFD100);
  static const primaryDim    = Color(0x33FFD100);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA08CC0);
  static const inputFill     = Color(0xFF330070);
  static const uiBorder      = Color(0xFF4A0090);
  static const teamHighlight = Color(0xFFF472B6);  // rose — équipe du joueur
  static const error         = Color(0xFFFF5C5C);
  static const win           = Color(0xFF4ADE80);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDeep, background],
    stops: [0.0, 0.6],
  );
}

TextTheme _textTheme() => GoogleFonts.exo2TextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: _textTheme(),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    surface: AppColors.surface,
    error: AppColors.error,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.uiBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: const TextStyle(color: AppColors.textSecondary),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.backgroundDeep,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.exo2(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primaryDim,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.exo2(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        );
      }
      return GoogleFonts.exo2(color: AppColors.textSecondary, fontSize: 11);
    }),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
  ),
);
