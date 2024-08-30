import 'package:flutter/material.dart';

const seedColor = Color.fromARGB(219, 3, 120, 216);
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Nunito',
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Nunito',
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ),
);
