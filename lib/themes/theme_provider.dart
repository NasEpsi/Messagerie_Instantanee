import 'package:flutter/material.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider with ChangeNotifier {
  // LightMode Par defaut

  ThemeData _themeData = lightMode;

  // On recupere le theme actif

  ThemeData get themeData => _themeData;

// is it Dark Mode ???

  bool get isDarkMode => _themeData == darkMode;

// on actualise le theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    // ON MET A JOUR LAFFICHAGE DE L'UI
    notifyListeners();
  }

// methode changes the theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}