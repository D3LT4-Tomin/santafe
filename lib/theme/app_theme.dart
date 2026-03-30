import 'package:flutter/material.dart';

// ─── HIG Color System ────────────────────────────────────────────────────────
class AppColors {
  static const systemBackground = Color(0xFF000000);
  static const secondaryBackground = Color(0xFF1C1C1E);
  static const tertiaryBackground = Color(0xFF2C2C2E);
  static const label = Color(0xFFFFFFFF);
  static const secondaryLabel = Color(0xFF8E8E93);
  static const tertiaryLabel = Color(0xFF48484A);
  static const systemBlue = Color(0xFF0A84FF);
  static const systemGreen = Color(0xFF30D158);
  static const systemRed = Color(0xFFFF453A);
  static const systemOrange = Color(0xFFFF9F0A);
  static const systemTeal = Color(0xFF64D2FF);
  static const systemIndigo = Color(0xFF5E5CE6);
  static const systemPurple = Color(0xFFBF5AF2);
  static const systemYellow = Color(0xFFFFD60A);
  static const separator = Color(0xFF38383A);
  static const tertiaryFill = Color(0x1F767680);
  static const frostedBlue = Color(0xFF070D1A);

  static const white05 = Color(0x0DFFFFFF);
  static const white07 = Color(0x12FFFFFF);
  static const white08 = Color(0x14FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const frostedBlue85 = Color(0xD9070D1A);
  static const blueTipBg = Color(0x1F0A84FF);
  static const blueTipBorder = Color(0x330A84FF);
}

// ─── HIG Typography Scale ────────────────────────────────────────────────────
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
}
