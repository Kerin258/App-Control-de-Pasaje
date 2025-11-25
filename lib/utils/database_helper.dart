import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static SharedPreferences? _preferences;

  DatabaseHelper._init();

  Future<void> _initPrefs() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<Expense> create(Expense expense) async {
    await _initPrefs();
    final expenses = await readAllExpenses();

    // Generate a simple ID if not present (using timestamp)
    final newExpense = expense.copy(id: DateTime.now().millisecondsSinceEpoch);

    expenses.insert(0, newExpense); // Add to top

    await _saveExpenses(expenses);
    return newExpense;
  }

  Future<Expense> readExpense(int id) async {
    final expenses = await readAllExpenses();
    return expenses.firstWhere((e) => e.id == id);
  }

  Future<List<Expense>> readAllExpenses() async {
    await _initPrefs();
    final String? expensesString = _preferences?.getString('expenses_list');
    if (expensesString == null) return [];

    final List<dynamic> jsonList = jsonDecode(expensesString);
    return jsonList.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> update(Expense expense) async {
    await _initPrefs();
    final expenses = await readAllExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);

    if (index != -1) {
      expenses[index] = expense;
      await _saveExpenses(expenses);
      return 1;
    }
    return 0;
  }

  Future<int> delete(int id) async {
    await _initPrefs();
    final expenses = await readAllExpenses();
    final initialLength = expenses.length;

    expenses.removeWhere((e) => e.id == id);

    if (expenses.length != initialLength) {
      await _saveExpenses(expenses);
      return 1;
    }
    return 0;
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final String encoded = jsonEncode(expenses.map((e) => e.toMap()).toList());
    await _preferences?.setString('expenses_list', encoded);
  }

  Future<void> close() async {
    // No explicit close needed for SharedPreferences
  }
}
