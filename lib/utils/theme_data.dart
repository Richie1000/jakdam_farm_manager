import 'package:flutter/material.dart';

ThemeData buildThemeData() {
  final baseTheme = ThemeData.light();

  return baseTheme.copyWith(
    primaryColor: Colors.blueAccent,
    hintColor: Colors.cyan,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueAccent,
      elevation: 4.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    textTheme: _buildTextTheme(baseTheme.textTheme),
    cardTheme: CardTheme(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.blueAccent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 16.0,
      color: Colors.black,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 14.0,
      color: Colors.black,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12.0,
      color: Colors.grey[600],
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
}
