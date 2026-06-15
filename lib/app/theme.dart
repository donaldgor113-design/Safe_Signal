import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class SafeSignalColors extends ThemeExtension<SafeSignalColors> {
  final Color sosRed;
  final Color sosRedPressed;
  final Color sosGlow;
  final Color statusActive;
  final Color statusWarning;
  final Color statusInactive;
  final Color deliverySuccess;
  final Color deliveryFailed;

  const SafeSignalColors({
    required this.sosRed,
    required this.sosRedPressed,
    required this.sosGlow,
    required this.statusActive,
    required this.statusWarning,
    required this.statusInactive,
    required this.deliverySuccess,
    required this.deliveryFailed,
  });

  @override
  SafeSignalColors copyWith({
    Color? sosRed,
    Color? sosRedPressed,
    Color? sosGlow,
    Color? statusActive,
    Color? statusWarning,
    Color? statusInactive,
    Color? deliverySuccess,
    Color? deliveryFailed,
  }) {
    return SafeSignalColors(
      sosRed: sosRed ?? this.sosRed,
      sosRedPressed: sosRedPressed ?? this.sosRedPressed,
      sosGlow: sosGlow ?? this.sosGlow,
      statusActive: statusActive ?? this.statusActive,
      statusWarning: statusWarning ?? this.statusWarning,
      statusInactive: statusInactive ?? this.statusInactive,
      deliverySuccess: deliverySuccess ?? this.deliverySuccess,
      deliveryFailed: deliveryFailed ?? this.deliveryFailed,
    );
  }

  @override
  SafeSignalColors lerp(SafeSignalColors? other, double t) {
    if (other is! SafeSignalColors) return this;
    return SafeSignalColors(
      sosRed: Color.lerp(sosRed, other.sosRed, t)!,
      sosRedPressed: Color.lerp(sosRedPressed, other.sosRedPressed, t)!,
      sosGlow: Color.lerp(sosGlow, other.sosGlow, t)!,
      statusActive: Color.lerp(statusActive, other.statusActive, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusInactive: Color.lerp(statusInactive, other.statusInactive, t)!,
      deliverySuccess:
          Color.lerp(deliverySuccess, other.deliverySuccess, t)!,
      deliveryFailed: Color.lerp(deliveryFailed, other.deliveryFailed, t)!,
    );
  }

  static const light = SafeSignalColors(
    sosRed: Color(0xFFD50000),
    sosRedPressed: Color(0xFFB71C1C),
    sosGlow: Color(0x4DD50000),
    statusActive: Color(0xFF2E7D32),
    statusWarning: Color(0xFFF57F17),
    statusInactive: Color(0xFF9E9E9E),
    deliverySuccess: Color(0xFF2E7D32),
    deliveryFailed: Color(0xFFC62828),
  );

  static const dark = SafeSignalColors(
    sosRed: Color(0xFFFF1744),
    sosRedPressed: Color(0xFFD50000),
    sosGlow: Color(0x4DFF1744),
    statusActive: Color(0xFF69F0AE),
    statusWarning: Color(0xFFFFD54F),
    statusInactive: Color(0xFF9E9E9E),
    deliverySuccess: Color(0xFF69F0AE),
    deliveryFailed: Color(0xFFFF5252),
  );
}

abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;
}

abstract class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      primary: const Color(0xFF1565C0),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFD1E4FF),
      secondary: const Color(0xFF455A64),
      onSecondary: const Color(0xFFFFFFFF),
      error: const Color(0xFFC62828),
      tertiary: const Color(0xFFF57F17),
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1C1B1F),
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      primary: const Color(0xFF90CAF9),
      onPrimary: const Color(0xFF003258),
      primaryContainer: const Color(0xFF004881),
      secondary: const Color(0xFF90A4AE),
      error: const Color(0xFFFF5252),
      tertiary: const Color(0xFFFFD54F),
      surface: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFE6E1E5),
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final textTheme = GoogleFonts.interTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF5F5F5)
          : const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      extensions: [
        brightness == Brightness.light
            ? SafeSignalColors.light
            : SafeSignalColors.dark,
      ],
    );
  }
}
