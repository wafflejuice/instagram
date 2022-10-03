import 'package:flutter/material.dart';

var theme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 1,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
      actionsIconTheme: IconThemeData(color: Colors.black, size: 30),
    ),
    textTheme: TextTheme(bodyText2: TextStyle(color: Colors.red)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: IconThemeData(
          color: Colors.black,
        )));
