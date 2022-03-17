import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTheme {
  static var darkTheme = ThemeData(
    primaryColor: Colors.grey,
    textTheme: const TextTheme(
        headline6: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        headline5: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
    primarySwatch: Colors.deepOrange,
//because body color is originally offwhite so there is slight difference  between  appbar and body
    scaffoldBackgroundColor: const Color(0xff0D1E37),
    appBarTheme: const AppBarTheme(
//change  color of any icon in appbar
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xff0D1E37),
      ),
      backgroundColor: Color(0xff0D1E37),
//text style in appbar
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrange,
      backgroundColor: Color(0xff0D1E37),
      unselectedItemColor: Colors.white,
    ),
  );

  static var lighTheme = ThemeData(
    primaryColor: Colors.white,
    primarySwatch: Colors.deepOrange,
    textTheme: const TextTheme(
        headline6: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24),
        headline5: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
//because body color is originally offwhite so there is slight difference  between  appbar and body
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
//change  color of any icon in appbar
      iconTheme: IconThemeData(color: Colors.black),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      ),
      backgroundColor: Colors.white,
//text style in appbar
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrange,
    ),
  );

  static const smallPadding = 8.00;
  static const mediumPadding = 16.00;
  static const largePadding = 32.00;
}
