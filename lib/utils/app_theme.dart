import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    cardColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xffFDFCFA),
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff841e73),
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: const Color(0xff841e73)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: const Color(0xff841e73),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    cardTheme: CardThemeData(
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade300,
        ), // Using a light grey similar to divider
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[CustomColors.light],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    cardColor: const Color(0xff1A1A1A),
    scaffoldBackgroundColor: const Color(0xff121212),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff841e73),
      brightness: Brightness.dark,
      surface: const Color(0xff1A1A1A),
      onSurface: Colors.white,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: const Color(0xffAC2180),
        ), // Light purple for dark theme
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: const Color(0xffAC2180),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      surfaceTintColor: Colors.transparent,
      color: const Color(0xff1A1A1A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade700,
        ), // Using a dark grey similar to divider
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[CustomColors.dark],
  );
}

// Custom theme extension for additional colors
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.highlightedText,
    required this.success,
    required this.warning,
    required this.error,
    required this.borderColor,
    required this.categoryBG,
    required this.categoryText,
  });

  final Color highlightedText;
  final Color success;
  final Color warning;
  final Color error;
  final Color borderColor;
  final Color categoryBG;
  final Color categoryText;

  @override
  CustomColors copyWith({
    Color? highlightedText,
    Color? success,
    Color? warning,
    Color? error,
    Color? borderColor,
    Color? categoryBG,
    Color? categoryText,
  }) {
    return CustomColors(
      highlightedText: highlightedText ?? this.highlightedText,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      borderColor: borderColor ?? this.borderColor,
      categoryBG: categoryBG ?? this.categoryBG,
      categoryText: categoryText ?? this.categoryText,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      highlightedText: Color.lerp(highlightedText, other.highlightedText, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      categoryBG: Color.lerp(categoryBG, other.categoryBG, t)!,
      categoryText: Color.lerp(categoryText, other.categoryText, t)!,
    );
  }

  // Light theme colors
  static const light = CustomColors(
    highlightedText: Color(0xff918F8F), // Purple highlight
    success: Color(0xff4CAF50), // Green
    warning: Color(0xffFF9800), // Orange
    error: Color(0xffAC213B), // Red
    borderColor: Color(0xffC4C4C4), // Light grey border
    categoryBG: Color(0xfff9daec), // Material 3 primary container
    categoryText: Color(0xff35002e), // Material 3 on primary container
  );

  // Dark theme colors
  static const dark = CustomColors(
    highlightedText: Color(0xff918F8F), // Light purple for dark theme
    success: Color(0xff66BB6A), // Lighter green
    warning: Color(0xffFFB74D), // Lighter orange
    error: Color(0xffEF5350), // Lighter red
    borderColor: Color(0xff404040), // Dark grey border
    categoryBG: Color(0xff67355a), // Material 3 primary container dark
    categoryText: Color(0xffffd7ef), // Material 3 on primary container dark
  );
}

// Helper extension to easily access theme information
extension ThemeHelper on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Get theme-aware colors
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get backgroundColor => Theme.of(this).colorScheme.background;
  Color get onBackgroundColor => Theme.of(this).colorScheme.onBackground;

  // Custom colors that adapt to theme
  Color get customPurple =>
      isDarkMode ? const Color(0xffE5DFF2) : const Color(0xff841e73);
  Color get customPurpleDark =>
      isDarkMode ? const Color(0xffE5DFF2) : const Color(0xff841e73);
  Color get customPurpleLight =>
      isDarkMode ? const Color(0xff2D1B69) : const Color(0xffE5DFF2);
  Color get customRed =>
      isDarkMode ? const Color(0xffFF6B6B) : const Color(0xffAC213B);
  Color get customBlue =>
      isDarkMode ? const Color(0xff64B5F6) : const Color(0xff274560);
  Color get customLightBlue =>
      isDarkMode ? const Color(0xff42A5F5) : const Color(0xff007AFF);
  Color get customGrey =>
      isDarkMode ? const Color(0xffB0B0B0) : const Color(0xff918F8F);
  Color get customBorder =>
      isDarkMode ? const Color(0xff404040) : const Color(0xffC4C4C4);
  Color get customTextFieldBackground =>
      isDarkMode ? const Color(0xff2C2C2C) : const Color(0xffE5E5E5);
  Color get customCategoryBG =>
      isDarkMode ? const Color(0xfff9daec) : const Color(0xff67355a);
  Color get customCategoryText =>
      isDarkMode ? const Color(0xff35002e) : const Color(0xffffd7ef);

  // Access custom theme colors
  CustomColors get appColors => Theme.of(this).extension<CustomColors>()!;

  // Material 3 color scheme helpers for category cards
  Color get primaryContainer => Theme.of(this).colorScheme.primaryContainer;
  Color get onPrimaryContainer => Theme.of(this).colorScheme.onPrimaryContainer;
  Color get secondaryContainer => Theme.of(this).colorScheme.secondaryContainer;
  Color get onSecondaryContainer =>
      Theme.of(this).colorScheme.onSecondaryContainer;
  Color get tertiaryContainer => Theme.of(this).colorScheme.tertiaryContainer;
  Color get onTertiaryContainer =>
      Theme.of(this).colorScheme.onTertiaryContainer;
}
