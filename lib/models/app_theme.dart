import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ARCHITECTURE FIX: Prevent accidental instantiation of this utility class.
  AppTheme._();

  static const Color bg = Color(0xFF0A0A0A);
  static const Color bgCard = Color(0xFF111111);
  static const Color bgCardAlt = Color(0xFF0C2018);
  static const Color accent = Color(0xFF1D9E75);
  static const Color accentLight = Color(0xFF5DCAA5);
  static const Color accentBorder = Color(0xFF1D4A30);
  static const Color border = Color(0xFF1E1E1E);
  static const Color borderLight = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);

  // ACCESSIBILITY FIX: 0xFF444444 fails WCAG contrast standards on a dark bg.
  // Bumped to 0xFF666666 so text is actually legible on real devices.
  static const Color textMuted = Color(0xFF666666);

  static const Color warn = Color(0xFFFF9800);
  static const Color danger = Color(0xFFFF4444);

  // PERFORMANCE FIX: Changed from a getter to `static final`.
  // ThemeData and GoogleFonts are now only evaluated once, rather than
  // recalculating the entire theme engine every time it is accessed.
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentLight,
      surface: bgCard,
    ),
    // ThemeData.dark().textTheme is heavy to build; doing it once is optimal.
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
    useMaterial3: true,
  );
}
