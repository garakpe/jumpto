import 'package:flutter/material.dart';

/// 앱 전체에서 사용될 테마를 정의합니다.
class AppTheme {
  // 앱의 주요 색상
  static const Color primaryColor = Color(0xFF2196F3); // 메인 파란색
  static const Color secondaryColor = Color(0xFF03A9F4); // 보조 파란색
  static const Color accentColor = Color(0xFFFFC107); // 강조 노란색
  static const Color backgroundColor = Color(0xFFF5F5F5); // 배경 색상
  static const Color errorColor = Color(0xFFE53935); // 오류 색상
  
  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );
  
  // 다크 모드 지원 여부
  static const bool supportDarkMode = true;
  
  // 라이트 테마
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    ),
  );
  
  // 다크 테마 (나중에 필요하면 구현)
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    // 다크 테마 설정
  );
  
  // 현재 시스템 설정에 따라 테마 반환
  static ThemeData getTheme(Brightness brightness) {
    if (supportDarkMode && brightness == Brightness.dark) {
      return darkTheme;
    }
    return lightTheme;
  }
}
