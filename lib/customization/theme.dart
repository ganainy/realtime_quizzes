import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const smallPadding = 8.00;
const mediumPadding = 16.00;
const largePadding = 32.00;

var darkBg = Color(0xFF68869A);
var lightBg = Color(0xFFC1E2FF);

var darkText = Color(0xFF2C353E);
var lightText = Color(0xFF455361);
var whiteText = Colors.white;

Color bgColor = Colors.white;

const cardWidth = 160.00;
var bgMaterialColor = MyTheme.generateMaterialColorFromColor(bgColor);

class MyTheme {
  static var darkTheme = ThemeData();

  static var lighTheme = ThemeData(
    scaffoldBackgroundColor: bgColor,
    primarySwatch: generateMaterialColorFromColor(darkText),
    appBarTheme: AppBarTheme(
//change  color of any icon in appbar
      iconTheme: IconThemeData(color: darkText),
      backgroundColor: bgColor,
      elevation: 0,
      titleTextStyle:
          TextStyle(color: darkText, fontSize: 40, fontFamily: 'Plex'),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: bgColor,
      ),
    ),
    fontFamily: 'IBM',
    textTheme: TextTheme(
      headline1: TextStyle(color: darkText, fontSize: 32),
      subtitle1: TextStyle(color: darkText, fontSize: 18),
    ),
  );

  static MaterialColor generateMaterialColorFromColor(Color color) {
    return MaterialColor(color.value, {
      50: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
      100: Color.fromRGBO(color.red, color.green, color.blue, 0.2),
      200: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
      300: Color.fromRGBO(color.red, color.green, color.blue, 0.4),
      400: Color.fromRGBO(color.red, color.green, color.blue, 0.5),
      500: Color.fromRGBO(color.red, color.green, color.blue, 0.6),
      600: Color.fromRGBO(color.red, color.green, color.blue, 0.7),
      700: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
      800: Color.fromRGBO(color.red, color.green, color.blue, 0.9),
      900: Color.fromRGBO(color.red, color.green, color.blue, 1.0),
    });
  }
}

/*
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
*/
