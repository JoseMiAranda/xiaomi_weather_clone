import 'dart:ui';

class AppColors {
  final Color whiteColor;
  final Color blackColor;
  final Color backgroundColor;
  final Color textColor;
  final Color primaryColor;

  AppColors({
    required this.whiteColor,
    required this.blackColor,
    required this.backgroundColor,
    required this.textColor,
    required this.primaryColor,
  });

  // ========================================================
  // Main color theme
  static final mainColors = AppColors(
    whiteColor: const Color(0xffFFFFFF),
    blackColor: const Color(0xff000000),
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    textColor: const Color.fromARGB(255, 55, 56, 56),
    primaryColor: const Color.fromARGB(255, 90, 154, 192),
  );

  // ========================================================
  // Dark color theme
  static final darkColors = AppColors(
    whiteColor: const Color(0xff000000),
    blackColor: const Color(0xffFFFFFF),
    backgroundColor: const Color.fromARGB(255, 55, 56, 56),
    textColor: const Color.fromARGB(255, 255, 255, 255),
    primaryColor: const Color.fromARGB(255, 154, 169, 178),
  );
}