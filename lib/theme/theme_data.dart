import 'package:flutter/material.dart';

ThemeData getAppThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    fontFamily: 'OpenSans Regular',
    useMaterial3: true,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'OpenSans Regular',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),

    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: Color(0xFFF5F5F5),
      hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 17),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      labelStyle: TextStyle(color: Color(0xFF999999)),
      floatingLabelStyle: TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: BorderSide.none,
      ),
      // enabledBorder: OutlineInputBorder(
      // borderRadius: BorderRadius.circular(12),
      // // borderSide: BorderSide.none,
      // ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      // Optional error style
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    ),
  );
}
