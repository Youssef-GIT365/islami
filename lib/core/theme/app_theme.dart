import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';

abstract class AppTheme {
  static ThemeData getThemeData() => ThemeData(
    primaryColor: AppColors.Gold,
    scaffoldBackgroundColor: AppColors.Black,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.Gold,
      selectedIconTheme: IconThemeData(color: AppColors.white),

      unselectedItemColor: AppColors.Black,
      selectedItemColor: AppColors.white,
      showUnselectedLabels: false,

      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontFamily: 'jana',
        fontWeight: FontWeight.w700,
      ),
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: "jana",
        color: AppColors.Black,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: "jana",
        fontSize: 20,
        color: AppColors.Black,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: "jana",
        color: AppColors.Black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: "jana",
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      displayLarge: TextStyle(
        fontFamily: "kamali",
        color: AppColors.Gold,
        fontSize: 80,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}
