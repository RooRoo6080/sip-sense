import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme;

  ThemeNotifier(this._isDarkTheme);

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }

  ThemeData getThemeData() {
    return Styles.themeData(_isDarkTheme, Colors.blue);
  }
}

class Styles {
  static ThemeData themeData(bool isDarkTheme, Color color) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: GoogleFonts.montserrat(),
        displaySmall: GoogleFonts.montserrat(),
      ),
    );
  }
}
