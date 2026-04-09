import 'package:flutter/material.dart';

// ─── Banco Azteca Color System ───────────────────────────────────────────────
// Adapted from HIG structure to Banco Azteca brand identity.
// Light-mode first. Primary brand: Dark Green #006341, Accent: Dark Red #af272f
class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────────────────────
  // White canvas as primary surface
  static const systemBackground = Color(0xFFFFFFFF);
  // Lighter warm-gray for card/sheet surfaces
  static const secondaryBackground = Color(0xFFFAFAFA);
  // Very light cool-gray for nested surfaces
  static const tertiaryBackground = Color(0xFFF5F5F5);

  // ── Labels / Text ───────────────────────────────────────────────────────────
  // Near-black for primary text (replaces HIG white)
  static const label = Color(0xFF1A1A1A);
  // Logo Gray light — secondary text (replaces HIG #8E8E93)
  static const secondaryLabel = Color(0xFF75787B);
  // Logo Gray dark — disabled/hint text (replaces HIG #48484A)
  static const tertiaryLabel = Color(0xFF53565A);

  // ── Brand Primary ───────────────────────────────────────────────────────────
  // Dark Green — primary action, CTAs, active states (replaces systemBlue)
  static const systemGreen = Color(0xFF006341);
  // Light Green — success states, badges, confirmations (replaces systemGreen)
  static const systemLightGreen = Color(0xFF43B02A);

  // ── Brand Accent ────────────────────────────────────────────────────────────
  // Dark Red — secondary actions, highlights (replaces systemRed)
  static const systemRed = Color(0xFFAF272F);
  // Bright Red — errors, urgent alerts (replaces systemOrange)
  static const systemOrange = Color(0xFFE63422);

  // ── Extended Brand Colors ────────────────────────────────────────────────────
  // Teal — positive balance, fintech accent (replaces systemTeal)
  static const systemTeal = Color(0xFF009D7E);
  // Deep Forest Green — dark variant for pressed/hover states
  static const systemIndigo = Color(0xFF144733);
  // Warm Orange — highlights, promo tags (replaces systemPurple)
  static const systemPurple = Color(0xFFF99D25);
  // Warm Orange-Red — warnings (replaces systemYellow)
  static const systemYellow = Color(0xFFF05327);

  // ── Chrome & Dividers ────────────────────────────────────────────────────────
  // Light cool-gray separator (replaces dark HIG separator)
  static const separator = Color(0xFFD0D2D3);
  // Very light tint for subtle fills (replaces HIG tertiaryFill)
  static const tertiaryFill = Color(0x1F53565A);

  // ── Frosted / Overlay Surfaces ───────────────────────────────────────────────
  // Solid white for header and footer (100% opacity)
  static const frostedGreen = Color(0xFFFFFFFF);
  static const frostedGreen85 = Color(0xFFFFFFFF);
  // Semi-transparent overlays on white surfaces
  static const black05 = Color(0x0D000000);
  static const black07 = Color(0x12000000);
  static const black08 = Color(0x14000000);
  static const black10 = Color(0x1A000000);

  // ── Tip / Info Banners ───────────────────────────────────────────────────────
  // Green-tinted info banner bg (replaces blueTipBg)
  static const greenTipBg = Color(0x1F006341);
  // Green-tinted info banner border (replaces blueTipBorder)
  static const greenTipBorder = Color(0x33006341);

  // ── Tint Ramp (for cards, chips, backgrounds) ────────────────────────────────
  // Warm reds
  static const warmRed100 = Color(0xFF80251580); // #80251580 approx
  static const warmRed75 = Color(0xBF802515);
  static const warmRed50 = Color(0x80802515);
  static const warmRed25 = Color(0x40802515);

  // Cool greens
  static const coolGreen100 = Color(0xFF006241);
  static const coolGreen75 = Color(0xBF006241);
  static const coolGreen50 = Color(0x80006241);
  static const coolGreen25 = Color(0x40006241);

  // Neutrals
  static const neutral100 = Color(0xFF55565A);
  static const neutral75 = Color(0xBF55565A);
  static const neutral50 = Color(0x8055565A);
  static const neutral25 = Color(0x4055565A);

  // ── White Variants (for dark content / contrast) ───────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const white95 = Color(0xF2FFFFFF);
  static const white90 = Color(0xE6FFFFFF);
  static const white80 = Color(0xCCFFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white25 = Color(0x40FFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white15 = Color(0x26FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white08 = Color(0x14FFFFFF);
  static const white05 = Color(0x0DFFFFFF);

  // ── Card Surfaces (white theme) ──────────────────────────────────────────────────
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardBorder = Color(0x1A000000); // subtle gray border
  static const cardShadow = Color(0x0D000000);

  // ── Special Use Cases ───────────────────────────────────────────────────────────
  // For gradients and dark surfaces
  static const gradientStart = Color(0xFF0F2748);
  static const gradientEnd = Color(0xFF0A1A35);
  // Lesson screen backgrounds (light gray like rest of app)
  static const lessonBackground = secondaryBackground;
  // Achievement/score highlight
  static const goldAccent = Color(0xFFFFCC00);
  // Legacy brand blue (for gradients)
  static const legacyBlue = Color(0xFF0A84FF);
  static const legacyBlueLight = Color(0xFF409CFF);
  // Legacy greens
  static const legacyGreen = Color(0xFF34C759);

  // ── Additional ─────────────────────────────────────────────────────────────────
  static const divider = Color(0xFF38383A);
  static const disabledGray = Color(0xFF636366);

  // ── Shadows & Effects ────────────────────────────────────────────────────────────
  static const primaryButtonGradientStart = Color(0xFF006341);
  static const primaryButtonGradientEnd = Color(0xFF008751);
  static const primaryButtonShadow = Color(0x4D006341);
  static const primaryButtonShadowLight = Color(0x33006341);

  // ── Chat Border Animation ───────────────────────────────────────────────────────
  static const chatBorderColor = Color(0xFF006341);
  static const chatBorderGlow = Color(0x33006341);

  // ── Blob Colors (for animated backgrounds) ───────────────────────────────────────
  static const blobPurple = Color(0xFF2563EB);
  static const blobGreen = Color(0xFF581C87);
}

// ─── Typography Scale ────────────────────────────────────────────────────────
// Same HIG scale; colors updated to Banco Azteca tokens.
// Font: system default. Swap fontFamily to 'YourBrandFont' if licensed.
class AppTextStyles {
  static const title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
    color: AppColors.label,
    height: 1.27,
  );
  static const title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    color: AppColors.label,
    height: 1.30,
  );
  static const headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: AppColors.label,
    height: 1.29,
  );
  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: AppColors.label,
    height: 1.29,
  );
  static const subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: AppColors.secondaryLabel,
    height: 1.33,
  );
  static const caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: AppColors.secondaryLabel,
    height: 1.33,
  );

  // ── Brand-specific variants ──────────────────────────────────────────────────
  // Use for primary CTA labels on green backgrounds
  static const ctaLabel = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: Color(0xFFFFFFFF),
    height: 1.29,
  );
  // Use for amount/balance displays
  static const balanceLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    color: AppColors.label,
    height: 1.21,
  );
  // Use for currency labels or unit suffixes next to amounts
  static const balanceUnit = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: AppColors.secondaryLabel,
    height: 1.29,
  );
  // Use for status chips: success
  static const statusSuccess = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    color: AppColors.systemLightGreen,
    height: 1.33,
  );
  // Use for status chips: error/alert
  static const statusError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    color: AppColors.systemRed,
    height: 1.33,
  );
}
