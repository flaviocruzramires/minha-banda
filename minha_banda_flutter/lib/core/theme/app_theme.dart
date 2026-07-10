import 'package:flutter/material.dart';

abstract final class AppColors {
  static const stageBlack = Color(0xFF151317);
  static const stageBlack2 = Color(0xFF1D1A20);
  static const spotlight = Color(0xFFF2A93B);
  static const spotlightDim = Color(0xFFB87F27);
  static const curtainWine = Color(0xFF7A1F3D);
  static const warmWhite = Color(0xFFF7F3EC);
  static const confirmed = Color(0xFF4C7A5E);
  static const danger = Color(0xFFC0503C);
  static const line = Color(0x1AF7F3EC);
  static const lineSoft = Color(0x0FF7F3EC);
  static const inputBg = Color(0x0FF7F3EC);
  static const inputBorder = Color(0x1AF7F3EC);
  static const inputActiveBorder = Color(0xFFF2A93B);
  static const inputActiveBg = Color(0x0FF2A93B);
  static const hintText = Color(0x59F7F3EC);
  static const bodyText = Color(0xB8F7F3EC);
  static const dangerBorder = Color(0x80C0503C);
  static const dangerBg = Color(0x0FC0503C);
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.stageBlack,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.spotlight,
      surface: AppColors.stageBlack2,
      error: AppColors.danger,
    ),
    fontFamily: 'Inter',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputActiveBorder),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.spotlight,
        foregroundColor: AppColors.stageBlack,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.warmWhite,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      bodyMedium: TextStyle(
        color: AppColors.bodyText,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: AppColors.hintText,
        fontSize: 12,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        color: AppColors.spotlight,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.12,
      ),
    ),
  );
}
