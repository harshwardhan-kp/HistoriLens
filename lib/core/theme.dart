import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF10A37F);
  static const Color primaryLight = Color(0xFFE8F7F3);
  static const Color primaryDark = Color(0xFF0D8A6A);

  // ─── Light palette ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F8);
  static const Color surfaceVariant = Color(0xFFEFEFF0);
  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF6E6E80);
  static const Color textTertiary = Color(0xFF9A9AAF);
  static const Color border = Color(0xFFE5E5E5);
  static const Color error = Color(0xFFD93025);
  static const Color cardShadow = Color(0x14000000);

  // ─── Dark palette ─────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F10);
  static const Color darkSurface = Color(0xFF1A1A1B);
  static const Color darkSurfaceVariant = Color(0xFF242425);
  static const Color darkTextPrimary = Color(0xFFF2F2F3);
  static const Color darkTextSecondary = Color(0xFF9A9AAF);
  static const Color darkTextTertiary = Color(0xFF6E6E80);
  static const Color darkBorder = Color(0xFF2E2E30);
  static const Color darkCardShadow = Color(0x40000000);

  static const List<Color> perspectiveGradients = [
    Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB),
    Color(0xFFF5576C), Color(0xFF4FACFE), Color(0xFF00F2FE),
    Color(0xFF43E97B), Color(0xFF38F9D7), Color(0xFFFFA17F),
    Color(0xFF00223E), Color(0xFFFFE259), Color(0xFFFFA751),
  ];

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? darkBackground : background;
    final surf = isDark ? darkSurface : surface;
    final txt = isDark ? darkTextPrimary : textPrimary;
    final txtSec = isDark ? darkTextSecondary : textSecondary;
    final txtTer = isDark ? darkTextTertiary : textTertiary;
    final brd = isDark ? darkBorder : border;
    final shadow = isDark ? darkCardShadow : cardShadow;
    final primLight = isDark ? const Color(0xFF1A3330) : primaryLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              onPrimary: Colors.white,
              secondary: primary,
              surface: surf,
              onSurface: txt,
              outline: brd,
              error: error,
            )
          : ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              secondary: primary,
              surface: surf,
              onSurface: txt,
              outline: brd,
              error: error,
            ),
      scaffoldBackgroundColor: bg,
      extensions: [
        AppColors(
          background: bg,
          surface: surf,
          surfaceVariant: isDark ? darkSurfaceVariant : surfaceVariant,
          textPrimary: txt,
          textSecondary: txtSec,
          textTertiary: txtTer,
          border: brd,
          cardShadow: shadow,
          primaryLight: primLight,
        ),
      ],
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: txt, letterSpacing: -0.5),
        displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w600, color: txt, letterSpacing: -0.3),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: txt, letterSpacing: -0.2),
        titleLarge: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: txt),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: txt),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: txt, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: txtSec, height: 1.5),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: txt),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: txtSec, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: txt,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: brd,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: txt),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txt,
          side: BorderSide(color: brd, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: txtTer),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: txtSec),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brd)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brd)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: error, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surf,
        selectedColor: primLight,
        checkmarkColor: primary,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: brd),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: brd, thickness: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: surf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: brd)),
      ),
    );
  }
}

// ─── ThemeExtension for adaptive colors in widgets ────────────────────────────
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color cardShadow;
  final Color primaryLight;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.cardShadow,
    required this.primaryLight,
  });

  @override
  AppColors copyWith({
    Color? background, Color? surface, Color? surfaceVariant,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? border, Color? cardShadow, Color? primaryLight,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      cardShadow: cardShadow ?? this.cardShadow,
      primaryLight: primaryLight ?? this.primaryLight,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
    );
  }
}

// Helper extension for easy access in widgets
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
