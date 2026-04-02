import 'package:flutter/material.dart';

/// Layered color system for FileSnap.
/// Each theme defines: background, surface, card, elevatedCard, accent,
/// highlight, divider, textPrimary, textSecondary.
class LayeredColors {
  final Color background;
  final Color surface;
  final Color card;
  final Color elevatedCard;
  final Color accent;
  final Color highlight;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Brightness brightness;

  const LayeredColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.elevatedCard,
    required this.accent,
    required this.highlight,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.brightness,
  });
}

class AppColors {
  static const slateSand = LayeredColors(
    background: Color(0xFF1A1A1A),
    surface: Color(0xFF1E1E1E),
    card: Color(0xFF272727),
    elevatedCard: Color(0xFF303030),
    accent: Color(0xFFD4AA7D),
    highlight: Color(0x22D4AA7D),
    divider: Color(0xFF3A3A3A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF9E9E9E),
    brightness: Brightness.dark,
  );

  static const forestCocoa = LayeredColors(
    background: Color(0xFF1A211A),
    surface: Color(0xFF212920),
    card: Color(0xFF2C362B),
    elevatedCard: Color(0xFF354434),
    accent: Color(0xFFD2A581),
    highlight: Color(0x22D2A581),
    divider: Color(0xFF3D4A3C),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF9CAF96),
    brightness: Brightness.dark,
  );

  static const midnightBlue = LayeredColors(
    background: Color(0xFF070F17),
    surface: Color(0xFF0B1D2A),
    card: Color(0xFF0F2638),
    elevatedCard: Color(0xFF153048),
    accent: Color(0xFF3A86FF),
    highlight: Color(0x223A86FF),
    divider: Color(0xFF1A3550),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF7EB0E0),
    brightness: Brightness.dark,
  );

  static const royalIndigo = LayeredColors(
    background: Color(0xFF12121F),
    surface: Color(0xFF1A1A2E),
    card: Color(0xFF22223A),
    elevatedCard: Color(0xFF2C2C4A),
    accent: Color(0xFF6C5CE7),
    highlight: Color(0x226C5CE7),
    divider: Color(0xFF363650),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFA09CC0),
    brightness: Brightness.dark,
  );

  static const sunsetEmber = LayeredColors(
    background: Color(0xFF1E1210),
    surface: Color(0xFF2B1B17),
    card: Color(0xFF362420),
    elevatedCard: Color(0xFF422E28),
    accent: Color(0xFFFF6B35),
    highlight: Color(0x22FF6B35),
    divider: Color(0xFF4A3530),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFC09080),
    brightness: Brightness.dark,
  );

  static const oceanTeal = LayeredColors(
    background: Color(0xFF0A2020),
    surface: Color(0xFF0F2F2F),
    card: Color(0xFF153A3A),
    elevatedCard: Color(0xFF1C4848),
    accent: Color(0xFF2EC4B6),
    highlight: Color(0x222EC4B6),
    divider: Color(0xFF205050),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF80C0B8),
    brightness: Brightness.dark,
  );

  static const graphiteGold = LayeredColors(
    background: Color(0xFF141414),
    surface: Color(0xFF1C1C1C),
    card: Color(0xFF252525),
    elevatedCard: Color(0xFF303030),
    accent: Color(0xFFFFD166),
    highlight: Color(0x22FFD166),
    divider: Color(0xFF3A3A3A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB0B0B0),
    brightness: Brightness.dark,
  );

  static const lavenderMist = LayeredColors(
    background: Color(0xFF221F2D),
    surface: Color(0xFF2E2A3B),
    card: Color(0xFF38334A),
    elevatedCard: Color(0xFF443E58),
    accent: Color(0xFFC77DFF),
    highlight: Color(0x22C77DFF),
    divider: Color(0xFF504A66),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB0A0C8),
    brightness: Brightness.dark,
  );

  static const emeraldDepth = LayeredColors(
    background: Color(0xFF0A2A1E),
    surface: Color(0xFF0F3D2E),
    card: Color(0xFF154D3A),
    elevatedCard: Color(0xFF1C5E48),
    accent: Color(0xFF2ECC71),
    highlight: Color(0x222ECC71),
    divider: Color(0xFF206848),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF80C0A0),
    brightness: Brightness.dark,
  );

  static const crimsonNight = LayeredColors(
    background: Color(0xFF1A0A0A),
    surface: Color(0xFF2A0F0F),
    card: Color(0xFF361818),
    elevatedCard: Color(0xFF442222),
    accent: Color(0xFFFF4D4D),
    highlight: Color(0x22FF4D4D),
    divider: Color(0xFF4A2828),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFC08080),
    brightness: Brightness.dark,
  );

  static const pureOled = LayeredColors(
    background: Color(0xFF000000),
    surface: Color(0xFF050505),
    card: Color(0xFF0E0E0E),
    elevatedCard: Color(0xFF181818),
    accent: Color(0xFF00E5FF),
    highlight: Color(0x2200E5FF),
    divider: Color(0xFF222222),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF808080),
    brightness: Brightness.dark,
  );

  static const lightTheme = LayeredColors(
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFEFEFF2),
    card: Colors.white,
    elevatedCard: Color(0xFFF8F8FA),
    accent: Color(0xFF007AFF),
    highlight: Color(0x22007AFF),
    divider: Color(0xFFD8D8DC),
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF8E8E93),
    brightness: Brightness.light,
  );

  static const darkTheme = LayeredColors(
    background: Color(0xFF000000),
    surface: Color(0xFF0A0A0A),
    card: Color(0xFF1C1C1E),
    elevatedCard: Color(0xFF2C2C2E),
    accent: Color(0xFF0A84FF),
    highlight: Color(0x220A84FF),
    divider: Color(0xFF38383A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF8E8E93),
    brightness: Brightness.dark,
  );
}
