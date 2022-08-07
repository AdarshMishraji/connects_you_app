import 'package:flutter/material.dart';

class CustomTheme {
  static const gradientColors = [
    Color.fromRGBO(0, 100, 255, 2),
    Color.fromRGBO(0, 125, 255, 1),
    Color.fromRGBO(0, 150, 255, 1),
    Color.fromRGBO(0, 100, 255, 1)
  ];
  static const typography = TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
    displayLarge: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.blue,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.blue,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.blue,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Colors.blue,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.blue,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.blue,
    ),
  );
  static const pageTransitionTheme = PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  });
  static final cardTheme = CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );
  static final lightTheme = ThemeData(
      fontFamily: 'Quicksand',
      primarySwatch: Colors.blue,
      textTheme: typography,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        titleTextStyle: typography.titleLarge!.copyWith(color: Colors.blue),
        iconTheme: const IconThemeData(color: Colors.blue),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      cardTheme: cardTheme,
      pageTransitionsTheme: pageTransitionTheme);
  static final darkTheme = ThemeData(
    fontFamily: 'Quicksand',
    primarySwatch: Colors.blue,
    textTheme: typography,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: typography.titleLarge!.copyWith(color: Colors.blue),
      iconTheme: const IconThemeData(color: Colors.blue),
      elevation: 0,
    ),
    backgroundColor: Colors.black,
    cardTheme: cardTheme,
    pageTransitionsTheme: pageTransitionTheme,
  );
}
