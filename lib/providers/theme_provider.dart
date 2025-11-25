import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que gestiona el tema de la aplicación (modo claro/oscuro).
///
/// Permite al usuario cambiar entre tema claro y oscuro, guardando
/// su preferencia en SharedPreferences para mantenerla entre sesiones.
///
/// Desarrollado por: Kevin y [Nombre del compañero/a]
/// Fecha: Noviembre 2025
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// Obtiene el modo de tema actual
  ThemeMode get themeMode => _themeMode;

  /// Indica si el tema oscuro está activo
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Constructor que carga el tema guardado al iniciar la app
  ThemeProvider() {
    _loadTheme();
  }

  /// Cambia el tema entre claro y oscuro
  ///
  /// Actualiza el tema y guarda la preferencia del usuario.
  /// [isDark] - true para tema oscuro, false para tema claro
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  /// Carga el tema guardado desde SharedPreferences
  ///
  /// Se ejecuta al iniciar la aplicación para restaurar
  /// la preferencia del usuario. Por defecto usa tema claro.
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
