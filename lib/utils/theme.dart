import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

ButtonStyle elevatedStyle(BuildContext context) => ElevatedButton.styleFrom();

ButtonStyle actionStyle(BuildContext context) => TextButton.styleFrom(
      primary: Colors.white,
      onSurface: Colors.white,
      disabledMouseCursor: MouseCursor.defer,
      enabledMouseCursor: SystemMouseCursors.click,
      padding: const EdgeInsets.symmetric(horizontal: 17),
    );

ButtonStyle menuStyle(BuildContext context, {EdgeInsetsGeometry? padding}) =>
    TextButton.styleFrom(
      padding: padding,
    );

ThemeData lightTheme() {
  final _baseTheme = ThemeData.light();
  return ThemeData(
    primarySwatch: Colors.teal,
    brightness: Brightness.light,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xfff5f8fa),
    textTheme: GoogleFonts.nunitoSansTextTheme(_baseTheme.textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: Colors.black,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
    ),
  );
}

ThemeData darkTheme() {
  final _baseTheme = ThemeData.dark();
  final accentColor = Colors.teal[600];
  return _baseTheme.copyWith(
    // primaryColor: Colors.black,
    toggleableActiveColor: accentColor,
    accentColor: accentColor,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.white,
    ),
    brightness: Brightness.dark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // scaffoldBackgroundColor: const Color(0xfff5f8fa),
    textTheme: GoogleFonts.nunitoSansTextTheme(_baseTheme.textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.black26,
        onPrimary: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          // primary: Colors.black,
          ),
    ),
  );
}
