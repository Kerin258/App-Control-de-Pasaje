import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/expense_model.dart';
import '../models/shortcut_model.dart';
import '../utils/database_helper.dart';
import '../utils/preferences_service.dart';

/// Provider principal que gestiona toda la lógica de negocio de la aplicación.
///
/// Este provider maneja:
/// - Lista de gastos y operaciones CRUD
/// - Presupuesto del usuario
/// - Atajos rápidos personalizados
/// - Información del perfil del usuario
/// - Cálculos de gastos totales y presupuesto restante
///
/// Utiliza SQLite para persistir gastos y SharedPreferences para configuración.
///
/// Desarrollado por: Kevin y kerin
/// Fecha: Noviembre 2025
class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Shortcut> _shortcuts = [];
  double _budget = 0.0;
  bool _isStudent = false;
  String _userName = '';
  String _userSurname = '';
  String _userAge = '';
  String? _profileImagePath;
  bool _isLoading = false;

  // Getters para acceder a los datos desde la UI
  List<Expense> get expenses => _expenses;
  List<Shortcut> get shortcuts => _shortcuts;
  double get budget => _budget;
  bool get isStudent => _isStudent;
  String get userName => _userName;
  String get userSurname => _userSurname;
  String get userAge => _userAge;
  String? get profileImagePath => _profileImagePath;
  bool get isLoading => _isLoading;

  /// Calcula el total gastado sumando todos los gastos registrados
  double get totalSpent {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Calcula cuánto presupuesto queda disponible
  double get remainingBudget => _budget - totalSpent;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PreferencesService _prefsService = PreferencesService();

  /// Carga todos los datos de la aplicación al iniciar
  ///
  /// Lee los gastos desde SQLite y la configuración del usuario
  /// desde SharedPreferences. Se ejecuta al iniciar la app.
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await _dbHelper.readAllExpenses();
    _budget = await _prefsService.getBudget();
    _isStudent = await _prefsService.getIsStudent();
    _userName = await _prefsService.getUserName();
    _userSurname = await _prefsService.getSurname();
    _userAge = await _prefsService.getAge();
    _profileImagePath = await _prefsService.getProfileImagePath();
    await _loadShortcuts();

    _isLoading = false;
    notifyListeners();
  }

  /// Agrega un nuevo gasto a la base de datos y actualiza la UI
  Future<void> addExpense(Expense expense) async {
    final newExpense = await _dbHelper.create(expense);
    _expenses.insert(0, newExpense); // Add to top
    notifyListeners();
  }

  /// Actualiza un gasto existente en la base de datos
  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.update(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  /// Elimina un gasto de la base de datos
  Future<void> deleteExpense(int id) async {
    await _dbHelper.delete(id);
    _expenses.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> updateBudget(double newBudget) async {
    await _prefsService.saveBudget(newBudget);
    _budget = newBudget;
    notifyListeners();
  }

  Future<void> updateIsStudent(bool isStudent) async {
    await _prefsService.saveIsStudent(isStudent);
    _isStudent = isStudent;
    // If shortcuts are empty (first run), reload defaults based on new student status
    if (_shortcuts.isEmpty) {
      await _loadShortcuts();
    }
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    await _prefsService.saveUserName(name);
    _userName = name;
    notifyListeners();
  }

  Future<void> updateUserSurname(String surname) async {
    await _prefsService.saveSurname(surname);
    _userSurname = surname;
    notifyListeners();
  }

  Future<void> updateUserAge(String age) async {
    await _prefsService.saveAge(age);
    _userAge = age;
    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    await _prefsService.saveProfileImagePath(path);
    _profileImagePath = path;
    notifyListeners();
  }

  Future<void> _loadShortcuts() async {
    final shortcutsJson = await _prefsService.getShortcuts();
    if (shortcutsJson != null) {
      final List<dynamic> decoded = jsonDecode(shortcutsJson);
      _shortcuts = decoded.map((item) => Shortcut.fromJson(item)).toList();
    } else {
      _initializeDefaultShortcuts();
    }
  }

  void _initializeDefaultShortcuts() {
    // User requested to start with NO shortcuts.
    _shortcuts = [];
    _saveShortcuts();
  }

  Future<void> addShortcut(Shortcut shortcut) async {
    _shortcuts.add(shortcut);
    await _saveShortcuts();
    notifyListeners();
  }

  Future<void> editShortcut(Shortcut shortcut) async {
    final index = _shortcuts.indexWhere((s) => s.id == shortcut.id);
    if (index != -1) {
      _shortcuts[index] = shortcut;
      await _saveShortcuts();
      notifyListeners();
    }
  }

  Future<void> deleteShortcut(String id) async {
    _shortcuts.removeWhere((s) => s.id == id);
    await _saveShortcuts();
    notifyListeners();
  }

  Future<void> _saveShortcuts() async {
    final shortcutsJson = jsonEncode(
      _shortcuts.map((s) => s.toJson()).toList(),
    );
    await _prefsService.saveShortcuts(shortcutsJson);
  }

  /// Obtiene el precio predeterminado según la categoría y tipo de usuario
  ///
  /// Retorna precios diferenciados para estudiantes y no estudiantes.
  /// Para categorías variables como Taxi/Uber, retorna 0.0
  ///
  /// [category] - Categoría del transporte (Autobús, Metro, etc.)
  double getDefaultPrice(String category) {
    if (_isStudent) {
      switch (category) {
        case 'Autobús':
          return 4.0;
        case 'Metro':
          return 5.0;
        case 'Colectivo':
          return 4.0;
        case 'Taxi/Uber':
          return 0.0; // Varies too much
        default:
          return 0.0;
      }
    } else {
      switch (category) {
        case 'Autobús':
          return 8.0;
        case 'Metro':
          return 5.0;
        case 'Colectivo':
          return 8.0;
        case 'Taxi/Uber':
          return 0.0; // Varies too much
        default:
          return 0.0;
      }
    }
  }
}
