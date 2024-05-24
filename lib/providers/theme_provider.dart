import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Google fonts provider.
final FutureProvider<List<void>> googleFontsProvider =
    FutureProvider<List<void>>(
  (FutureProviderRef<List<void>> ref) =>
      GoogleFonts.pendingFonts(<void>[GoogleFonts.interTextTheme()]),
);

/// Provider for the app's theme data.
final Provider<ThemeData> themeProvider = Provider<ThemeData>(
  (ProviderRef<ThemeData> ref) {
    const Color primaryColor = Color(0xFF15202E);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.interTextTheme(),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0084E6),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
    );
  },
);
