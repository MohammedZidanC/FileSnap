import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

enum AppThemeMode {
  slateSand,
  forestCocoa,
  midnightBlue,
  royalIndigo,
  sunsetEmber,
  oceanTeal,
  graphiteGold,
  lavenderMist,
  emeraldDepth,
  crimsonNight,
  pureOled,
  light,
  dark,
}

class AppTheme {
  static LayeredColors getColors(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.slateSand:      return AppColors.slateSand;
      case AppThemeMode.forestCocoa:    return AppColors.forestCocoa;
      case AppThemeMode.midnightBlue:   return AppColors.midnightBlue;
      case AppThemeMode.royalIndigo:    return AppColors.royalIndigo;
      case AppThemeMode.sunsetEmber:    return AppColors.sunsetEmber;
      case AppThemeMode.oceanTeal:      return AppColors.oceanTeal;
      case AppThemeMode.graphiteGold:   return AppColors.graphiteGold;
      case AppThemeMode.lavenderMist:   return AppColors.lavenderMist;
      case AppThemeMode.emeraldDepth:   return AppColors.emeraldDepth;
      case AppThemeMode.crimsonNight:   return AppColors.crimsonNight;
      case AppThemeMode.pureOled:       return AppColors.pureOled;
      case AppThemeMode.light:          return AppColors.lightTheme;
      case AppThemeMode.dark:           return AppColors.darkTheme;
    }
  }

  static TextTheme _buildTextTheme(String fontFamily, LayeredColors colors, bool isBold) {
    TextTheme base;
    switch (fontFamily) {
      case 'inter':
        base = GoogleFonts.interTextTheme();
        break;
      case 'oswald':
        base = GoogleFonts.oswaldTextTheme();
        break;
      case 'poppins':
        base = GoogleFonts.poppinsTextTheme();
        break;
      case 'roboto':
        base = GoogleFonts.robotoTextTheme();
        break;
      case 'lato':
        base = GoogleFonts.latoTextTheme();
        break;
      case 'montserrat':
        base = GoogleFonts.montserratTextTheme();
        break;
      case 'nunito':
        base = GoogleFonts.nunitoTextTheme();
        break;
      case 'raleway':
        base = GoogleFonts.ralewayTextTheme();
        break;
      case 'openSans':
        base = GoogleFonts.openSansTextTheme();
        break;
      case 'sourceSansPro':
        base = GoogleFonts.sourceCodeProTextTheme();
        break;
      case 'quicksand':
        base = GoogleFonts.quicksandTextTheme();
        break;
      case 'comfortaa':
        base = GoogleFonts.comfortaaTextTheme();
        break;
      case 'rubik':
        base = GoogleFonts.rubikTextTheme();
        break;
      case 'karla':
        base = GoogleFonts.karlaTextTheme();
        break;
      case 'cabin':
        base = GoogleFonts.cabinTextTheme();
        break;
      case 'outfit':
        base = GoogleFonts.outfitTextTheme();
        break;
      case 'dmSans':
        base = GoogleFonts.dmSansTextTheme();
        break;
      case 'system':
      default:
        base = ThemeData(brightness: colors.brightness).textTheme;
        break;
    }

    base = base.apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    if (isBold) {
      base = base.copyWith(
        bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      );
    }

    return base;
  }

  static ThemeData getTheme(
    AppThemeMode mode, {
    String fontFamily = 'inter',
    bool isBold = false,
    bool useInter = true,
  }) {
    final colors = getColors(mode);
    
    final effectiveFont = fontFamily;

    final textTheme = _buildTextTheme(effectiveFont, colors, isBold);

    return ThemeData(
      brightness: colors.brightness,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.accent,
      cardColor: colors.card,
      dividerColor: colors.divider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: colors.brightness,
        primary: colors.accent,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      textTheme: textTheme,
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.card,
        selectedItemColor: colors.accent,
        unselectedItemColor: colors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.brightness == Brightness.light ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.accent.withValues(alpha: 0.2),
        thumbColor: colors.accent,
        overlayColor: colors.accent.withValues(alpha: 0.1),
        valueIndicatorColor: colors.accent,
        valueIndicatorTextStyle: TextStyle(color: colors.textPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accent;
          return colors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accent.withValues(alpha: 0.5);
          return colors.divider;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.elevatedCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.card,
        selectedColor: colors.accent.withValues(alpha: 0.3),
        labelStyle: TextStyle(color: colors.textPrimary),
      ),
    );
  }

  static String themeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.slateSand:      return 'Slate Sand';
      case AppThemeMode.forestCocoa:    return 'Forest Cocoa';
      case AppThemeMode.midnightBlue:   return 'Midnight Blue';
      case AppThemeMode.royalIndigo:    return 'Royal Indigo';
      case AppThemeMode.sunsetEmber:    return 'Sunset Ember';
      case AppThemeMode.oceanTeal:      return 'Ocean Teal';
      case AppThemeMode.graphiteGold:   return 'Graphite Gold';
      case AppThemeMode.lavenderMist:   return 'Lavender Mist';
      case AppThemeMode.emeraldDepth:   return 'Emerald Depth';
      case AppThemeMode.crimsonNight:   return 'Crimson Night';
      case AppThemeMode.pureOled:       return 'Pure OLED';
      case AppThemeMode.light:          return 'Light';
      case AppThemeMode.dark:           return 'Dark';
    }
  }

  static const List<Map<String, String>> availableFonts = [
    {'id': 'inter', 'name': 'Inter'},
    {'id': 'system', 'name': 'System Default'},
    {'id': 'oswald', 'name': 'Oswald Bold'},
    {'id': 'poppins', 'name': 'Poppins'},
    {'id': 'roboto', 'name': 'Roboto'},
    {'id': 'lato', 'name': 'Lato'},
    {'id': 'montserrat', 'name': 'Montserrat'},
    {'id': 'nunito', 'name': 'Nunito'},
    {'id': 'raleway', 'name': 'Raleway'},
    {'id': 'openSans', 'name': 'Open Sans'},
    {'id': 'quicksand', 'name': 'Quicksand'},
    {'id': 'comfortaa', 'name': 'Comfortaa'},
    {'id': 'rubik', 'name': 'Rubik'},
    {'id': 'karla', 'name': 'Karla'},
    {'id': 'cabin', 'name': 'Cabin'},
    {'id': 'outfit', 'name': 'Outfit'},
    {'id': 'dmSans', 'name': 'DM Sans'},
  ];
}
