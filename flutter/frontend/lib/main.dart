import 'package:flutter/material.dart';
import 'shell/home_shell.dart';

void main() {
  runApp(const TravelPlannerApp());
}

/// Seoul-inspired palette used across the app.
class SeoulPalette {
  // Warm persimmon / hibiscus — borrowed from hanbok dyes and Seoul sunsets.
  static const Color persimmon = Color(0xFFE63946);
  static const Color persimmonSoft = Color(0xFFFFB4B4);

  // Han River at dusk.
  static const Color hanNavy = Color(0xFF1D3557);
  static const Color skyBlue = Color(0xFF457B9D);

  // Mustard gold — temple roofs, gat hats, autumn ginkgo leaves.
  static const Color gold = Color(0xFFF4A261);

  // Jade — palace tilework.
  static const Color jade = Color(0xFF2A9D8F);

  // Warm cream paper — like a hanji notebook.
  static const Color cream = Color(0xFFFFFBF5);
  static const Color creamDeep = Color(0xFFFFF1E0);
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: SeoulPalette.persimmon,
      brightness: Brightness.light,
      primary: SeoulPalette.persimmon,
      secondary: SeoulPalette.hanNavy,
      tertiary: SeoulPalette.gold,
      surface: SeoulPalette.cream,
    );

    return MaterialApp(
      title: 'Seoul Travel Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: SeoulPalette.cream,
        fontFamily: 'Helvetica Neue',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: SeoulPalette.hanNavy,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: lightScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: SeoulPalette.creamDeep,
          selectedColor: SeoulPalette.persimmon,
          side: BorderSide(color: SeoulPalette.persimmon.withValues(alpha: 0.25)),
          labelStyle: const TextStyle(
            color: SeoulPalette.hanNavy,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          hintStyle: TextStyle(
            color: SeoulPalette.hanNavy.withValues(alpha: 0.4),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: SeoulPalette.persimmon.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: SeoulPalette.persimmon,
              width: 1.5,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: SeoulPalette.hanNavy,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: SeoulPalette.hanNavy,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(color: SeoulPalette.hanNavy),
        ),
      ),
      home: const HomeShell(),
    );
  }
}
